resource "random_string" "resource_naming" {
  count   = var.cluster_name == "" ? 1 : 0
  length  = 14
  special = false
  upper   = false
}