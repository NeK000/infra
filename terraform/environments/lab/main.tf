locals {
  proxmox_endpoint = trimsuffix(var.proxmox_api_url, "/api2/json")
  inventory_groups = distinct(flatten([
    for lxc in values(var.lxcs) : lxc.ansible_groups
  ]))

  ansible_inventory = {
    all = {
      children = {
        for group in local.inventory_groups :
        group => {
          hosts = {
            for lxc in values(var.lxcs) :
            lxc.name => {
              ansible_host = lxc.ip_address
              ansible_user = var.default_user
            }
            if contains(lxc.ansible_groups, group)
          }
        }
      }
    }
  }
}

provider "proxmox" {
  endpoint = local.proxmox_endpoint
  insecure = var.proxmox_insecure_tls
}

module "lxc" {
  for_each = var.lxcs

  source = "../../modules/proxmox_lxc"

  name               = each.value.name
  vm_id              = each.value.vm_id
  target_node        = each.value.target_node
  hostname           = coalesce(each.value.hostname, each.value.name)
  description        = coalesce(each.value.description, "Managed by Terraform (${var.environment})")
  ip_address         = each.value.ip_address
  gateway            = each.value.gateway != null ? each.value.gateway : var.proxmox_node_defaults.gateway
  cidr_prefix        = coalesce(each.value.cidr_prefix, var.proxmox_node_defaults.cidr_prefix, 24)
  bridge             = coalesce(each.value.bridge, var.proxmox_node_defaults.bridge, "vmbr0")
  vlan_tag           = each.value.vlan_tag != null ? each.value.vlan_tag : var.proxmox_node_defaults.vlan_tag
  nameserver         = each.value.nameserver != null ? each.value.nameserver : var.proxmox_node_defaults.nameserver
  search_domain      = each.value.search_domain != null ? each.value.search_domain : var.proxmox_node_defaults.search_domain
  ostemplate         = each.value.ostemplate != null ? each.value.ostemplate : var.proxmox_node_defaults.ostemplate
  ostemplate_storage = coalesce(each.value.ostemplate_storage, var.proxmox_node_defaults.ostemplate_storage)
  rootfs_storage     = coalesce(each.value.rootfs_storage, var.proxmox_node_defaults.rootfs_storage)
  rootfs_size_gb     = coalesce(each.value.rootfs_size_gb, var.proxmox_node_defaults.rootfs_size_gb, 8)
  mount_points       = each.value.mount_points
  cores              = each.value.cores
  memory_mb          = each.value.memory_mb
  swap_mb            = each.value.swap_mb
  start_on_boot      = coalesce(each.value.start_on_boot, var.proxmox_node_defaults.start_on_boot, true)
  protection         = coalesce(each.value.protection, var.proxmox_node_defaults.protection, false)
  unprivileged       = coalesce(each.value.unprivileged, var.proxmox_node_defaults.unprivileged, true)
  nesting            = coalesce(each.value.nesting, var.proxmox_node_defaults.nesting, false)
  keyctl             = coalesce(each.value.keyctl, var.proxmox_node_defaults.keyctl, false)
  fuse               = coalesce(each.value.fuse, var.proxmox_node_defaults.fuse, false)
  ssh_public_keys    = each.value.ssh_public_keys != null ? each.value.ssh_public_keys : coalesce(var.proxmox_node_defaults.ssh_public_keys, [])
  tags               = each.value.tags != null ? each.value.tags : coalesce(var.proxmox_node_defaults.tags, [])
}
