# Solution du thème 01.
locals {
  societe = "nébuleuse"

  q01 = upper(local.societe)
  q02 = format("%s %s", title(lower(local.equipe[0].prenom)), upper(local.equipe[0].nom))
  q03 = join(", ", local.equipe[*].ville)

  etiquettes = "web,nginx,https"
  q04        = split(",", local.etiquettes)

  nom_brut = "rg_nebuleuse_dev"
  q05      = replace(local.nom_brut, "_", "-")

  q06 = substr(local.equipe[0].arrivee, 0, 4)
  q07 = startswith(local.environnements.dev.taille_vm, "Standard_D")
  q08 = formatlist("%s.nebuleuse.fr", keys(local.services))

  saisie = "   frontend  \n"
  q09    = trimspace(local.saisie)

  q10 = replace(lower(local.equipe[1].prenom), "/[éèêë]/", "e")
}
