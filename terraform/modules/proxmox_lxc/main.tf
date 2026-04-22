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

locals {
  container_hostname = coalesce(var.hostname, var.name)
  template_file_id   = "${var.ostemplate_storage}:vztmpl/${var.ostemplate}"
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
