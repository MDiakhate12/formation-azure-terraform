# Les données du fil rouge, identiques dans chaque thème.
# Lancez « terraform console » dans ce dossier : local.equipe, local.services
# et local.environnements y sont disponibles.
locals {
  dossier_donnees = "${path.module}/../donnees"

  equipe         = csvdecode(file("${local.dossier_donnees}/equipe.csv"))
  services       = yamldecode(file("${local.dossier_donnees}/services.yaml")).services
  environnements = jsondecode(file("${local.dossier_donnees}/environnements.json"))
}
