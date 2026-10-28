# Ne modifiez pas ce fichier : il compare vos réponses aux résultats attendus.
locals {
  attendu = {
    q01 = 5
    q02 = ["Lille", "Lyon", "Nantes", "Paris"]
    q03 = true
    q04 = ["api", "base-de-donnees", "batch", "nginx", "python", "web"]
    q05 = "chloé"
    q06 = ["snet-01", "snet-02", "snet-03"]
    q07 = ["base-de-donnees"]
    q08 = 12
    q09 = "swedencentral"
    q10 = [["alain", "Bérénice"], ["chloé", "David"], ["Émile"]]
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
    q09 = local.q09
    q10 = local.q10
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
