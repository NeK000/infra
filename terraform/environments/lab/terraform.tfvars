# Copy this file to terraform.tfvars and fill in the non-secret values.
# Secrets should come from Doppler-injected environment variables, not this file.
#
# Expected env vars for Proxmox provider authentication:
# - PROXMOX_VE_API_TOKEN
# or:
# - PROXMOX_VE_USERNAME
# - PROXMOX_VE_PASSWORD
# Optional if your Proxmox endpoint uses self-signed TLS:
# - PROXMOX_VE_INSECURE=true

environment  = "lab"
default_user = "root"

# Non-secret provider settings.
# The provider endpoint must not include /api2/json.
proxmox_api_url      = "https://10.50.10.50:8006"
proxmox_insecure_tls = true

# Shared defaults for LXC provisioning.
proxmox_node_defaults = {
  start_on_boot      = true
  protection         = false
  unprivileged       = true
  nesting            = true
  keyctl             = true
  fuse               = true
  ostemplate_storage = "local"
  rootfs_storage     = "local-zfs"
  ostemplate         = "ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
  rootfs_size_gb     = 8
  bridge             = "vmbr0"
  gateway            = "10.50.10.1"
  cidr_prefix        = 24
  nameserver         = "10.50.10.212"
  search_domain      = "ninik.lab"
  ssh_public_keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGG3p4BAp4knnHin4c5jBekR9D9XhRqfFLjlYd1Jxeeg ninik@kontor"
  ]
  tags = ["lab", "lxc", "terraform"]
}

lxcs = {
  edge = {
    name           = "edge"
    vm_id          = 210
    target_node    = "pve-intel"
    hostname       = "edge"
    description    = "Fresh LXC managed by Terraform"
    ip_address     = "10.50.10.210"
    rootfs_size_gb = 8
    cores          = 2
    memory_mb      = 2048
    swap_mb        = 512
    ansible_groups = ["edge"]
  }
  teslamate = {
    name           = "teslamate"
    vm_id          = 211
    target_node    = "pve-intel"
    hostname       = "teslamate"
    description    = "Fresh LXC managed by Terraform"
    ip_address     = "10.50.10.211"
    rootfs_size_gb = 16
    cores          = 2
    memory_mb      = 2048
    swap_mb        = 512
    ansible_groups = ["teslamate"]
  }
  dns = {
    name           = "dns"
    vm_id          = 212
    target_node    = "pve-intel"
    hostname       = "dns"
    description    = "Fresh LXC managed by Terraform"
    ip_address     = "10.50.10.212"
    nameserver     = "10.50.10.1"
    rootfs_size_gb = 16
    cores          = 2
    memory_mb      = 2048
    swap_mb        = 512
    ansible_groups = ["dns"]
  }
  monitoring = {
    name           = "monitoring"
    vm_id          = 213
    target_node    = "pve-intel"
    hostname       = "monitoring"
    description    = "Fresh LXC managed by Terraform"
    ip_address     = "10.50.10.213"
    rootfs_size_gb = 16
    cores          = 2
    memory_mb      = 2048
    swap_mb        = 512
    ansible_groups = ["monitoring"]
  }
  aiml = {
    name           = "aiml"
    vm_id          = 214
    target_node    = "pve-intel"
    hostname       = "aiml"
    description    = "Fresh LXC managed by Terraform"
    ip_address     = "10.50.10.214"
    rootfs_size_gb = 25
    cores          = 4
    memory_mb      = 8192
    swap_mb        = 1024
    ansible_groups = ["aiml"]
    mount_points = [
      {
        path   = "/data/photos"
        volume = "/rpool/data/aiml-photos"
      }
    ]
    raw_lxc_config_ssh_host = "10.50.10.50"
    raw_lxc_config = [
      "lxc.idmap: u 0 100000 65536",
      "lxc.idmap: g 0 100000 65536",
      "lxc.cgroup2.devices.allow: c 195:* rwm",
      "lxc.cgroup2.devices.allow: c 510:* rwm",
      "lxc.cgroup2.devices.allow: c 235:* rwm",
      "lxc.mount.entry: /dev/nvidia0 dev/nvidia0 none bind,optional,create=file",
      "lxc.mount.entry: /dev/nvidiactl dev/nvidiactl none bind,optional,create=file",
      "lxc.mount.entry: /dev/nvidia-modeset dev/nvidia-modeset none bind,optional,create=file",
      "lxc.mount.entry: /dev/nvidia-uvm dev/nvidia-uvm none bind,optional,create=file",
      "lxc.mount.entry: /dev/nvidia-uvm-tools dev/nvidia-uvm-tools none bind,optional,create=file",
      "lxc.mount.entry: /dev/nvidia-caps dev/nvidia-caps none bind,optional,create=dir",
      "lxc.mount.entry: /usr/bin/nvidia-smi usr/bin/nvidia-smi none bind,ro,optional,create=file",
      "lxc.mount.entry: /usr/lib/x86_64-linux-gnu/nvidia/current/libnvidia-ml.so.550.163.01 usr/lib/x86_64-linux-gnu/libnvidia-ml.so.550.163.01 none bind,ro,optional,create=file",
      "lxc.mount.entry: /usr/lib/x86_64-linux-gnu/nvidia/current/libcuda.so.550.163.01 usr/lib/x86_64-linux-gnu/libcuda.so.550.163.01 none bind,ro,optional,create=file",
    ]
  }
}
