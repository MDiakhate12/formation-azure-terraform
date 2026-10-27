resource "azurerm_mssql_database" "gold" {
  name        = "db-gold"
  server_id   = azurerm_mssql_server.equipe.id
  sku_name    = "Basic"
  max_size_gb = 2

  tags = {
    owner = "jean-erwan"
  }
}

output "gold_id" {
  value = azurerm_mssql_database.gold.id
}
