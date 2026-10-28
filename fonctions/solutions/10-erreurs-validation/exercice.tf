# Solution du thème 10.
locals {
  en_tete_auth = sensitive("Basic bmVidWxldXNlOmRlbW8=")

  candidats = ["stnebuleusedev", "st-nebuleuse", "st", "stnebuleuseproductioneurope01"]

  q01 = try(local.services.frontend.planification, "aucune")
  q02 = try(local.environnements["preprod"].noeuds, 0)
  q03 = can(regex("^[a-z0-9]{3,24}$", "St-Nebuleuse"))
  q04 = alltrue([for p in local.equipe : can(formatdate("YYYY", "${p.arrivee}T00:00:00Z"))])
  q05 = [for n in local.candidats : n if !can(regex("^[a-z0-9]{3,24}$", n))]
  q06 = var.nouveau_service
  q07 = local.environnements[var.environnement].noeuds
  q08 = issensitive(local.en_tete_auth)
}

# Partie 2

output "url_frontend" {
  value = "http://frontend.nebuleuse.fr"

  precondition {
    condition     = local.services.frontend.exposition == "publique"
    error_message = "Le frontend n'est pas exposé publiquement."
  }
}

check "replicas" {
  assert {
    condition     = alltrue([for s in values(local.services) : s.replicas >= 2])
    error_message = "Services avec moins de 2 réplicas : ${join(", ", [for n, s in local.services : n if s.replicas < 2])}."
  }
}

output "en_tete" {
  value     = local.en_tete_auth
  sensitive = true
}
