# Solution du thème 04.
locals {
  tags_communs = { societe = "nebuleuse", gere_par = "terraform", env = "inconnu" }
  tags_prod    = { env = "prod", centre_de_cout = "cc-42" }

  tags_par_service = {
    frontend  = ["web", "nginx"]
    commandes = ["api", "python"]
    stock     = ["api", "python", "base-de-donnees"]
    factures  = ["batch"]
  }

  q01 = keys(local.environnements)
  q02 = merge(local.tags_communs, local.tags_prod)
  q03 = lookup(local.services.factures, "planification", "aucune")
  q04 = lookup(local.services.frontend, "planification", "aucune")
  q05 = zipmap(keys(local.services), values(local.services)[*].port)
  q06 = transpose(local.tags_par_service)

  env_demande = "preprod"
  q07         = lookup(local.environnements, local.env_demande, local.environnements.dev).taille_vm

  q08 = contains(keys(local.services), "stock")
}
