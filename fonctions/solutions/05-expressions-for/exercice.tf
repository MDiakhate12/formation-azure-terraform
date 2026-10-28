# Solution du thème 05.
locals {
  q01 = [for p in local.equipe : title(lower(p.prenom))]
  q02 = [for p in local.equipe : title(lower(p.prenom)) if p.actif == "true"]
  q03 = { for p in local.equipe : title(lower(p.prenom)) => p.ville }
  q04 = { for p in local.equipe : p.role => title(lower(p.prenom))... }
  q05 = [for nom, s in local.services : nom if s.exposition == "publique"]
  q06 = { for nom, s in local.services : nom => s.replicas * local.environnements.prod.facteur_replicas }

  q07 = {
    for d in flatten([
      for env, e in local.environnements : [
        for svc, s in local.services : {
          env      = env
          service  = svc
          replicas = s.replicas * e.facteur_replicas
        }
      ]
    ]) : "${d.env}-${d.service}" => d
  }

  q08 = length(local.q07)
}
