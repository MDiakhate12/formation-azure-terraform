# Solution du thème 06.
locals {
  q01 = length([for p in local.equipe : p if tobool(p.actif)])
  q02 = tostring(local.services.frontend.port)
  q03 = jsonencode({ port = local.services.frontend.port, replicas = local.services.frontend.replicas })

  json_recu = "{\"personne\": {\"prenom\": \"alain\", \"ville\": \"Paris\"}}"
  q04       = jsondecode(local.json_recu).personne.ville

  q05 = yamlencode({ nom = "frontend", replicas = local.services.frontend.replicas })

  utilisateur = "nebuleuse"
  motdepasse  = "demo"
  q06         = "Basic ${base64encode("${local.utilisateur}:${local.motdepasse}")}"

  recherche = "équipe plateforme & ops"
  q07       = urlencode(local.recherche)

  q08 = provider::terraform::encode_tfvars({
    region = local.environnements.dev.region
    noeuds = local.environnements.dev.noeuds
  })
}
