# Remplacez chaque null par une expression. Les données sont dans donnees.tf.
locals {
  societe = "nébuleuse"

  # Q01. Le nom de la société en majuscules.
  #      Attendu : "NÉBULEUSE"
  q01 = null

  # Q02. La première personne de l'équipe (local.equipe[0]) au format « Prénom NOM ».
  #      Attendu : "Alain MARTIN"
  q02 = null

  # Q03. Les villes de l'équipe, séparées par une virgule et une espace.
  #      Indice : local.equipe[*].ville donne la liste des villes.
  #      Attendu : "Paris, Lyon, Nantes, Paris, Lille"
  q03 = null

  # Q04. La liste des étiquettes contenues dans cette chaîne.
  #      Attendu : ["web", "nginx", "https"]
  etiquettes = "web,nginx,https"
  q04        = null

  # Q05. Un nom de ressource Azure avec des tirets au lieu des soulignés.
  #      Attendu : "rg-nebuleuse-dev"
  nom_brut = "rg_nebuleuse_dev"
  q05      = null

  # Q06. L'année d'arrivée de la première personne (champ arrivee).
  #      Attendu : "2023"
  q06 = null

  # Q07. La taille de VM du dev commence-t-elle par "Standard_D" ?
  #      Indice : local.environnements.dev.taille_vm
  #      Attendu : true
  q07 = null

  # Q08. Un nom DNS par service : "<service>.nebuleuse.fr".
  #      Indice : keys(local.services) donne les noms des services, triés.
  #      Attendu : ["commandes.nebuleuse.fr", "factures.nebuleuse.fr", "frontend.nebuleuse.fr", "stock.nebuleuse.fr"]
  q08 = null

  # Q09. Une saisie à nettoyer.
  #      Attendu : "frontend"
  saisie = "   frontend  \n"
  q09    = null

  # Q10. L'identifiant de Bérénice (local.equipe[1].prenom) : en minuscules et sans accent,
  #      comme le préfixe de vos ressources pendant la formation.
  #      Attendu : "berenice"
  q10 = null
}
