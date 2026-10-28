# Les sorties de l'exercice final. Ne modifiez pas ce fichier.

output "utilisateurs" {
  value = local.utilisateurs
}

output "reseaux" {
  value = local.reseaux
}

output "deploiements" {
  value = local.deploiements
}

output "storage_accounts" {
  value = local.storage_accounts

  precondition {
    condition     = try(alltrue([for n in values(local.storage_accounts) : can(regex("^[a-z0-9]{3,24}$", n))]), true)
    error_message = "Un nom de storage account ne respecte pas la règle : 3 à 24 minuscules ou chiffres."
  }
}

output "tfvars" {
  value = local.tfvars
}

output "rapport" {
  value = local.rapport
}

output "script" {
  value = local.script
}

check "haute_disponibilite" {
  assert {
    condition     = try(alltrue([for d in values(local.deploiements) : d.replicas >= 2 if d.env == "prod"]), true)
    error_message = "En prod, chaque service doit avoir au moins 2 réplicas."
  }
}
