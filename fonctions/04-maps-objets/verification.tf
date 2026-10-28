# Ne modifiez pas ce fichier : il compare vos réponses aux résultats attendus.
locals {
  attendu = {
    q01 = ["dev", "prod", "recette"]
    q02 = { centre_de_cout = "cc-42", env = "prod", gere_par = "terraform", societe = "nebuleuse" }
    q03 = "0 2 * * *"
    q04 = "aucune"
    q05 = { commandes = 8080, factures = 9090, frontend = 80, stock = 8081 }
    q06 = {
      api               = ["commandes", "stock"]
      "base-de-donnees" = ["stock"]
      batch             = ["factures"]
      nginx             = ["frontend"]
      python            = ["commandes", "stock"]
      web               = ["frontend"]
    }
    q07 = "Standard_D2as_v6"
    q08 = true
  }
  reponses = {
    q01 = local.q01
    q02 = local.q02
    q03 = local.q03
    q04 = local.q04
    q05 = local.q05
    q06 = local.q06
    q07 = local.q07
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
