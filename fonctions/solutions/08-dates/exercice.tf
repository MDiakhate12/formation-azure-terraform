# Solution du thème 08.
locals {
  q01 = formatdate("DD/MM/YYYY", "${local.equipe[0].arrivee}T00:00:00Z")
  q02 = formatdate("EEEE DD MMMM YYYY", "${local.equipe[0].arrivee}T00:00:00Z")
  q03 = timeadd("${local.equipe[4].arrivee}T00:00:00Z", "${90 * 24}h")
  q04 = [
    for p in local.equipe : title(lower(p.prenom))
    if timecmp("${p.arrivee}T00:00:00Z", "2025-01-01T00:00:00Z") < 0
  ]
  q05 = sort(local.equipe[*].arrivee)[0]

  emission = "2026-10-28T09:00:00Z"
  q06      = timeadd(local.emission, "${365 * 24}h")
  q07      = formatdate("YYYYMMDD-hhmm", local.emission)
}

output "maintenant" {
  value = formatdate("DD/MM/YYYY hh:mm:ss", timestamp())
}
