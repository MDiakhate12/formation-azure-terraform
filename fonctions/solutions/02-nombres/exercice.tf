# Solution du thème 02.
locals {
  q01 = sum(values(local.services)[*].replicas)
  q02 = max(values(local.services)[*].port...)
  q03 = sum(values(local.environnements)[*].noeuds)

  prix_horaire_noeud = 0.096
  q04                = ceil(local.prix_horaire_noeud * 730 * local.environnements.prod.noeuds)

  rouge_hexa = "ff"
  q05        = parseint(local.rouge_hexa, 16)

  pods_par_noeud = 4
  q06            = ceil(local.q01 * local.environnements.prod.facteur_replicas / local.pods_par_noeud)

  q07 = format("%.1f", local.services.frontend.replicas / local.q01 * 100)

  port_texte = "8080"
  q08        = tonumber(local.port_texte) + 1000
}
