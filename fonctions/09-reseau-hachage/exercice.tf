# Remplacez chaque null par une expression. Les données sont dans donnees.tf.
locals {
  # Q01. Le sous-réseau /24 numéro 1 de l'espace d'adresses du dev.
  #      Attendu : "10.10.1.0/24"
  q01 = null

  # Q02. Trois sous-réseaux pour la prod, sans chevauchement : gateway et bastion en /24, aks en /20.
  #      Résultat sous forme de map nom => plage.
  #      Attendu : { aks = "10.30.16.0/20", bastion = "10.30.1.0/24", gateway = "10.30.0.0/24" }
  q02 = null

  # Q03. La première adresse utilisable par une VM dans 10.10.1.0/24 (Azure réserve les 4 premières).
  #      Attendu : "10.10.1.4"
  q03 = null

  # Q04. Le masque de l'espace d'adresses du dev.
  #      Attendu : "255.255.0.0"
  q04 = null

  # Q05. Le sous-réseau /24 numéro 1 de chaque environnement.
  #      Attendu : { dev = "10.10.1.0/24", prod = "10.30.1.0/24", recette = "10.20.1.0/24" }
  q05 = null

  # Q06. Le nombre d'adresses utilisables par des VM dans un /24 Azure.
  #      Attendu : 251
  q06 = null

  # Q07. Un nom de storage account unique et stable pour le dev :
  #      "st" + nom sans tiret + les 6 premiers caractères du sha256 de nom.
  #      Attendu : "stnebuleusedeve94c92"
  nom = "nebuleuse-dev"
  q07 = null

  # Q08. Un identifiant stable pour le frontend, dérivé de son nom DNS.
  #      Attendu : "10919eba-c9b2-5ad6-91b2-a2fb82c33f7a"
  q08 = null
}
