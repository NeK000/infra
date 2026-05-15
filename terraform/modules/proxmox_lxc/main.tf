terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
  }
}

variable "name" {
  type = string
}

variable "vm_id" {
  type = number
}

variable "target_node" {
  type = string
}

variable "hostname" {
  type    = string
  default = null
}

variable "description" {
  type    = string
  default = null
}

variable "ip_address" {
  type = string
}

variable "gateway" {
  type    = string
  default = null
}

variable "cidr_prefix" {
  type    = number
  default = 24
}

variable "bridge" {
  type    = string
  default = "vmbr0"
}

variable "vlan_tag" {
  type    = number
  default = null
}

variable "nameserver" {
  type    = string
  default = null
}

variable "search_domain" {
  type    = string
  default = null
}

variable "ostemplate" {
  type = string
}

variable "ostemplate_storage" {
  type = string
}

variable "rootfs_storage" {
  type = string
}

variable "rootfs_size_gb" {
  type    = number
  default = 8
}

variable "cores" {
  type    = number
  default = 2
}

variable "memory_mb" {
  type    = number
  default = 2048
}

variable "swap_mb" {
  type    = number
  default = 512
}

variable "start_on_boot" {
  type    = bool
  default = true
}

variable "protection" {
  type    = bool
  default = false
}

variable "unprivileged" {
  type    = bool
  default = true
}

variable "nesting" {
  type    = bool
  default = false
}

variable "keyctl" {
  type    = bool
  default = false
}

variable "fuse" {
  type    = bool
  default = false
}

variable "ssh_public_keys" {
  type    = list(string)
  default = []
}

variable "tags" {
  type    = list(string)
  default = []
}

variable "mount_points" {
  type = list(object({
    path   = string
    volume = string
  }))
  default = []
}

variable "raw_lxc_config" {
  type        = list(string)
  description = "Raw LXC config lines to manage in /etc/pve/lxc/<vm_id>.conf over SSH for options unsupported by the Proxmox API."
  default     = []
}

variable "raw_lxc_config_ssh_host" {
  type        = string
  description = "SSH host used when applying raw_lxc_config. Defaults to target_node."
  default     = null
}

variable "post_create_reboot_delay_seconds" {
  type        = number
  description = "When greater than zero, wait this many seconds after provisioning and then reboot the LXC over SSH from the Proxmox host."
  default     = 0
}

locals {
  container_hostname      = coalesce(var.hostname, var.name)
  template_file_id        = "${var.ostemplate_storage}:vztmpl/${var.ostemplate}"
  raw_lxc_config          = trimspace(join("\n", var.raw_lxc_config))
  raw_lxc_config_ssh_host = coalesce(var.raw_lxc_config_ssh_host, var.target_node)
}

resource "proxmox_virtual_environment_container" "this" {
  node_name     = var.target_node
  vm_id         = var.vm_id
  description   = var.description
  tags          = var.tags
  start_on_boot = var.start_on_boot
  protection    = var.protection
  unprivileged  = var.unprivileged

  features {
    nesting = var.nesting
    keyctl  = var.keyctl
    fuse    = var.fuse
  }

  cpu {
    cores = var.cores
  }

  memory {
    dedicated = var.memory_mb
    swap      = var.swap_mb
  }

  disk {
    datastore_id = var.rootfs_storage
    size         = var.rootfs_size_gb
  }

  dynamic "mount_point" {
    for_each = var.mount_points

    content {
      path   = mount_point.value.path
      volume = mount_point.value.volume
    }
  }

  initialization {
    hostname = local.container_hostname

    ip_config {
      ipv4 {
        address = "${var.ip_address}/${var.cidr_prefix}"
        gateway = var.gateway
      }
    }

    dns {
      domain  = var.search_domain
      servers = var.nameserver == null ? null : [var.nameserver]
    }

    user_account {
      keys = var.ssh_public_keys
    }
  }

  network_interface {
    name    = "eth0"
    bridge  = var.bridge
    vlan_id = var.vlan_tag
  }

  operating_system {
    template_file_id = local.template_file_id
    type             = "ubuntu"
  }
}

resource "terraform_data" "raw_lxc_config" {
  count = local.raw_lxc_config == "" ? 0 : 1

  triggers_replace = {
    config_hash      = sha256(local.raw_lxc_config)
    restart_strategy = "stop-start-after-raw-lxc-config"
    ssh_host         = local.raw_lxc_config_ssh_host
    target_node      = var.target_node
    vm_id            = var.vm_id
    container_id     = proxmox_virtual_environment_container.this.id
  }

  provisioner "local-exec" {
    command = <<-EOT
set -eu
ssh root@${local.raw_lxc_config_ssh_host} 'CONFIG_PATH="/etc/pve/lxc/${var.vm_id}.conf" python3 - <<'"'"'PY'"'"'
import os
from pathlib import Path

config_path = Path(os.environ["CONFIG_PATH"])
managed = """${local.raw_lxc_config}""".strip()
start = "# BEGIN terraform raw_lxc_config"
end = "# END terraform raw_lxc_config"
block = f"{start}\n{managed}\n{end}\n"

text = config_path.read_text()
obsolete_prefixes = (
    "dev",
)
obsolete_contains = (
    "/dev/dri",
    "c 226:0 rwm",
    "c 226:128 rwm",
)
kept_lines = []
for line in text.splitlines():
    stripped = line.strip()
    if stripped.startswith("lxc.idmap: "):
        continue
    if any(stripped.startswith(prefix) for prefix in obsolete_prefixes):
        continue
    if any(value in stripped for value in obsolete_contains):
        continue
    kept_lines.append(line)
text = "\n".join(kept_lines)

if start in text and end in text:
    before = text.split(start, 1)[0].rstrip()
    after = text.split(end, 1)[1].lstrip()
    text = f"{before}\n{block}{after}"
else:
    text = text.rstrip() + "\n" + block

config_path.write_text(text)
PY'

ssh root@${local.raw_lxc_config_ssh_host} 'set -eu
if pct status ${var.vm_id} | grep -q "status: running"; then
  pct stop ${var.vm_id}
fi
pct start ${var.vm_id}
'
EOT
  }
}

resource "terraform_data" "post_create_reboot" {
  count = var.post_create_reboot_delay_seconds > 0 ? 1 : 0

  depends_on = [
    proxmox_virtual_environment_container.this,
    terraform_data.raw_lxc_config,
  ]

  triggers_replace = {
    delay_seconds = var.post_create_reboot_delay_seconds
    ssh_host      = local.raw_lxc_config_ssh_host
    target_node   = var.target_node
    vm_id         = var.vm_id
    container_id  = proxmox_virtual_environment_container.this.id
  }

  provisioner "local-exec" {
    command = <<-EOT
set -eu
ssh root@${local.raw_lxc_config_ssh_host} 'set -eu
sleep ${var.post_create_reboot_delay_seconds}
pct stop ${var.vm_id}
sleep ${var.post_create_reboot_delay_seconds}
pct start ${var.vm_id}
'
EOT
  }
}

output "name" {
  value = var.name
}

output "vm_id" {
  value = proxmox_virtual_environment_container.this.vm_id
}

output "target_node" {
  value = proxmox_virtual_environment_container.this.node_name
}

output "description" {
  value = proxmox_virtual_environment_container.this.description
}

output "tags" {
  value = proxmox_virtual_environment_container.this.tags
}
