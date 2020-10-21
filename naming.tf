resource "random_string" "resource_naming" {
  count   = var.resource_naming == "" ? 1 : 0
  length  = 14
  special = false
  upper   = false
}
