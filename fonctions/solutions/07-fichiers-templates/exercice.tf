# Solution du thème 07.
locals {
  q01 = fileexists("${local.dossier_donnees}/equipe.csv")
  q02 = fileset(local.dossier_donnees, "*.{json,yaml}")
  q03 = [for f in fileset(local.dossier_donnees, "*") : replace(f, "/\\.[a-z]+$/", "")]

  q04 = templatefile("${path.module}/modeles/bienvenue.txt.tftpl", {
    prenom  = "Chloé"
    societe = "Nébuleuse"
  })

  q05 = templatefile("${path.module}/modeles/services.md.tftpl", {
    services = local.services
  })

  modele_nom = "rg-$${societe}-$${env}"
  q06        = templatestring(local.modele_nom, { societe = "nebuleuse", env = "dev" })

  q07 = length(split("\n", chomp(file("${local.dossier_donnees}/equipe.csv")))) - 1
}
