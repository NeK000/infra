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
proxmox_api_url      = "https://10.50.10.10:8006"
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
  rootfs_storage     = "local-lvm"
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
    target_node    = "pve2"
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
    target_node    = "pve2"
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
    target_node    = "pve2"
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
    target_node    = "pve2"
    hostname       = "monitoring"
    description    = "Fresh LXC managed by Terraform"
    ip_address     = "10.50.10.213"
    rootfs_size_gb = 16
    cores          = 2
    memory_mb      = 2048
    swap_mb        = 512
    ansible_groups = ["monitoring"]
  }
}
