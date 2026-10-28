# Ne modifiez pas ce fichier : il compare vos réponses aux résultats attendus.
locals {
  attendu = {
    q01 = "10.10.1.0/24"
    q02 = { aks = "10.30.16.0/20", bastion = "10.30.1.0/24", gateway = "10.30.0.0/24" }
    q03 = "10.10.1.4"
    q04 = "255.255.0.0"
    q05 = { dev = "10.10.1.0/24", prod = "10.30.1.0/24", recette = "10.20.1.0/24" }
    q06 = 251
    q07 = "stnebuleusedeve94c92"
    q08 = "10919eba-c9b2-5ad6-91b2-a2fb82c33f7a"
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
