# Ne modifiez pas ce fichier : il compare vos réponses aux résultats attendus.
locals {
  attendu = {
    q01 = "15/03/2023"
    q02 = "Wednesday 15 March 2023"
    q03 = "2026-08-30T00:00:00Z"
    q04 = ["Alain", "Bérénice", "David"]
    q05 = "2022-11-07"
    q06 = "2027-10-28T09:00:00Z"
    q07 = "20261028-0900"
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
