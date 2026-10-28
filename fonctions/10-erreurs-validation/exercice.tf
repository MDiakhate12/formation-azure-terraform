# Remplacez chaque null par une expression. Les données sont dans donnees.tf.
locals {
  en_tete_auth = sensitive("Basic bmVidWxldXNlOmRlbW8=")

  candidats = ["stnebuleusedev", "st-nebuleuse", "st", "stnebuleuseproductioneurope01"]

  # Q01. La planification du frontend, ou "aucune" s'il n'en a pas, avec try.
  #      Attendu : "aucune"
  q01 = null

  # Q02. Le nombre de nœuds de l'environnement preprod, ou 0 s'il n'existe pas.
  #      Attendu : 0
  q02 = null

  # Q03. "St-Nebuleuse" est-il un nom de storage account valide (3 à 24 minuscules ou chiffres) ?
  #      Attendu : false
  q03 = null

  # Q04. Toutes les dates d'arrivée de l'équipe sont-elles des dates valides ?
  #      Indice : formatdate échoue sur une date invalide.
  #      Attendu : true
  q04 = null

  # Q05. Les noms de candidats qui ne sont pas des noms de storage account valides.
  #      Attendu : ["st-nebuleuse", "st", "stnebuleuseproductioneurope01"]
  q05 = null

  # Q06. Le nouveau service, une fois le type de la variable écrit dans variables.tf.
  #      Attendu : { nom = "paiement", port = 80, replicas = 1 }
  q06 = var.nouveau_service

  # Q07. Le nombre de nœuds de l'environnement choisi par var.environnement.
  #      Attendu : 1
  q07 = null

  # Q08. La valeur de en_tete_auth est-elle marquée sensible ?
  #      Attendu : true
  q08 = null
}
