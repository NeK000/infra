output "ansible_inventory" {
  value = local.ansible_inventory
}

output "lxc_summary" {
  value = {
    for key, lxc in module.lxc :
    key => {
      name        = lxc.name
      vm_id       = lxc.vm_id
      target_node = lxc.target_node
    }
  }
}
