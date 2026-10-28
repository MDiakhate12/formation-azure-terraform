# Ne modifiez pas ce fichier : il compare vos réponses aux résultats attendus.
locals {
  attendu = {
    q01 = 4
    q02 = "80"
    q03 = "{\"port\":80,\"replicas\":2}"
    q04 = "Paris"
    q05 = "\"nom\": \"frontend\"\n\"replicas\": 2\n"
    q06 = "Basic bmVidWxldXNlOmRlbW8="
    q07 = "%C3%A9quipe+plateforme+%26+ops"
    q08 = "noeuds = 1\nregion = \"swedencentral\"\n"
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
