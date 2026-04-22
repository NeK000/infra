variable "name" {
  type = string
}

variable "vm_id" {
  type = number
}

variable "target_node" {
  type = string
}

variable "description" {
  type    = string
  default = null
}

variable "tags" {
  type    = list(string)
  default = []
}

output "name" {
  value = var.name
}

output "vm_id" {
  value = var.vm_id
}

output "target_node" {
  value = var.target_node
}

output "description" {
  value = var.description
}

output "tags" {
  value = var.tags
}
