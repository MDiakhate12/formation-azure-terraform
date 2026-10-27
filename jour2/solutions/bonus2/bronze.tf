resource "azurerm_mssql_database" "bronze" {
  name        = "db-bronze"
  server_id   = azurerm_mssql_server.equipe.id
  sku_name    = "Basic"
  max_size_gb = 2

  tags = {
    owner = "titouan"
  }
}

output "bronze_id" {
  value = azurerm_mssql_database.bronze.id
}
