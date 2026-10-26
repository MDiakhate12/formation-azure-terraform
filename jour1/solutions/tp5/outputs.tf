output "dev_vnet" {
  value = module.network_dev.vnet_id
}

output "prod_vnet" {
  value = module.network_prod.vnet_id
}

output "subnet_ids" {
  value = {
    dev  = module.network_dev.subnet_ids
    prod = module.network_prod.subnet_ids
  }
}
