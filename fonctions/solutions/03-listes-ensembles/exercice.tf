# Solution du thème 03.
locals {
  prenoms = local.equipe[*].prenom

  q01 = length(local.equipe)
  q02 = sort(distinct(local.equipe[*].ville))
  q03 = contains(local.equipe[*].ville, "Lyon")
  q04 = sort(distinct(flatten(values(local.services)[*].tags)))
  q05 = element(local.prenoms, 7)
  q06 = formatlist("snet-%02d", range(1, 4))
  q07 = setsubtract(local.services.stock.tags, local.services.commandes.tags)
  q08 = length(setproduct(keys(local.environnements), keys(local.services)))

  region_saisie = ""
  q09           = coalesce(local.region_saisie, local.environnements.dev.region)

  q10 = chunklist(local.prenoms, 2)
}
