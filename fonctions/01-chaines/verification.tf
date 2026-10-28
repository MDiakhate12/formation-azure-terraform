# Ne modifiez pas ce fichier : il compare vos réponses aux résultats attendus.
locals {
  attendu = {
    q01 = "NÉBULEUSE"
    q02 = "Alain MARTIN"
    q03 = "Paris, Lyon, Nantes, Paris, Lille"
    q04 = ["web", "nginx", "https"]
    q05 = "rg-nebuleuse-dev"
    q06 = "2023"
    q07 = true
    q08 = ["commandes.nebuleuse.fr", "factures.nebuleuse.fr", "frontend.nebuleuse.fr", "stock.nebuleuse.fr"]
    q09 = "frontend"
    q10 = "berenice"
  }
  reponses = {
    q01 = local.q01, q02 = local.q02, q03 = local.q03, q04 = local.q04, q05 = local.q05
    q06 = local.q06, q07 = local.q07, q08 = local.q08, q09 = local.q09, q10 = local.q10
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
