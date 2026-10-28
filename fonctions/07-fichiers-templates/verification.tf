# Ne modifiez pas ce fichier : il compare vos réponses aux résultats attendus.
locals {
  attendu = {
    q01 = true
    q02 = ["environnements.json", "services.yaml"]
    q03 = ["environnements", "equipe", "services"]
    q04 = "Bienvenue Chloé chez Nébuleuse !\n"
    q05 = <<-EOT
      | Service | Port | Réplicas |
      |---|---|---|
      | commandes | 8080 | 3 |
      | factures | 9090 | 1 |
      | frontend | 80 | 2 |
      | stock | 8081 | 1 |
    EOT
    q06 = "rg-nebuleuse-dev"
    q07 = 5
  }
  reponses = {
    q01 = local.q01
    q02 = local.q02
    q03 = local.q03
    q04 = local.q04
    q05 = local.q05
    q06 = local.q06
    q07 = local.q07
  }
}

# jsonencode compare les valeurs sans tenir compte du type (liste, tuple, ensemble).
locals {
  resultats = { for q, v in local.attendu : q => jsonencode(local.reponses[q]) == jsonencode(v) }
}

output "reponses" {
  value = local.reponses
}

output "verification" {
  value = { for q, ok in local.resultats : q => ok ? "OK" : "à revoir" }
}

output "score" {
  value = "${length([for ok in values(local.resultats) : ok if ok])}/${length(local.resultats)}"
}
