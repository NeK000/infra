variable "environment" {
  type    = string
  default = "lab"
}

variable "proxmox_api_url" {
  type    = string
  default = null
}

variable "proxmox_insecure_tls" {
  type    = bool
  default = false
}

variable "proxmox_node_defaults" {
  type = object({
    start_on_boot      = optional(bool, true)
    protection         = optional(bool, false)
    unprivileged       = optional(bool, true)
    nesting            = optional(bool, false)
    keyctl             = optional(bool, false)
    fuse               = optional(bool, false)
    ostemplate         = optional(string)
    ostemplate_storage = optional(string)
    rootfs_storage     = optional(string)
    rootfs_size_gb     = optional(number, 8)
    bridge             = optional(string, "vmbr0")
    vlan_tag           = optional(number)
    gateway            = optional(string)
    cidr_prefix        = optional(number, 24)
    nameserver         = optional(string)
    search_domain      = optional(string)
    ssh_public_keys    = optional(list(string))
    tags               = optional(list(string))
  })
  default = {}
}

variable "default_user" {
  type    = string
  default = "root"
}

variable "lxcs" {
  type = map(object({
    name                    = string
    vm_id                   = number
    target_node             = string
    raw_lxc_config_ssh_host = optional(string)
    hostname                = optional(string)
    description             = optional(string)
    ip_address              = string
    gateway                 = optional(string)
    cidr_prefix             = optional(number)
    bridge                  = optional(string)
    vlan_tag                = optional(number)
    nameserver              = optional(string)
    search_domain           = optional(string)
    ostemplate              = optional(string)
    ostemplate_storage      = optional(string)
    rootfs_storage          = optional(string)
    rootfs_size_gb          = optional(number)
    mount_points = optional(list(object({
      path   = string
      volume = string
    })), [])
    raw_lxc_config  = optional(list(string), [])
    cores           = optional(number, 2)
    memory_mb       = optional(number, 2048)
    swap_mb         = optional(number, 512)
    start_on_boot   = optional(bool)
    protection      = optional(bool)
    unprivileged    = optional(bool)
    nesting         = optional(bool)
    keyctl          = optional(bool)
    fuse            = optional(bool)
    ssh_public_keys = optional(list(string))
    ansible_groups  = optional(list(string), [])
    tags            = optional(list(string))
  }))
}
