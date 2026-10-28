# Ne modifiez pas ce fichier : il compare vos réponses aux résultats attendus.
locals {
  attendu = {
    q01 = ["Alain", "Bérénice", "Chloé", "David", "Émile"]
    q02 = ["Alain", "Bérénice", "Chloé", "Émile"]
    q03 = { Alain = "Paris", "Bérénice" = "Lyon", "Chloé" = "Nantes", David = "Paris", "Émile" = "Lille" }
    q04 = { admin = ["Alain"], dev = ["Bérénice", "Chloé"], ops = ["David", "Émile"] }
    q05 = ["frontend"]
    q06 = { commandes = 6, factures = 2, frontend = 4, stock = 2 }
    q07 = { env = "prod", service = "commandes", replicas = 6 }
    q08 = 12
  }
  reponses = {
    q01 = local.q01
    q02 = local.q02
    q03 = local.q03
    q04 = local.q04
    q05 = local.q05
    q06 = local.q06
    q07 = try(local.q07["prod-commandes"], null)
    q08 = local.q08
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
