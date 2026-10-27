resource "azurerm_mssql_database" "silver" {
  name        = "db-silver"
  server_id   = azurerm_mssql_server.equipe.id
  sku_name    = "Basic"
  max_size_gb = 2

  tags = {
    owner = "alain"
  }
}

output "silver_id" {
  value = azurerm_mssql_database.silver.id
}
