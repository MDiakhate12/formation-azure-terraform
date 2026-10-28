# Remplacez chaque null par une expression. Les données sont dans donnees.tf.
locals {
  prenoms = local.equipe[*].prenom

  # Q01. Le nombre de personnes dans l'équipe.
  #      Attendu : 5
  q01 = null

  # Q02. Les villes de l'équipe, sans doublon, triées.
  #      Attendu : ["Lille", "Lyon", "Nantes", "Paris"]
  q02 = null

  # Q03. Lyon fait-elle partie des villes de l'équipe ?
  #      Attendu : true
  q03 = null

  # Q04. Tous les tags de tous les services, dans une seule liste, sans doublon, triés.
  #      Indice : values(local.services)[*].tags donne une liste de listes.
  #      Attendu : ["api", "base-de-donnees", "batch", "nginx", "python", "web"]
  q04 = null

  # Q05. L'astreinte tourne chaque semaine dans l'ordre de local.prenoms.
  #      Qui est d'astreinte la semaine 7 (la première semaine est la semaine 0) ?
  #      Attendu : "chloé"
  q05 = null

  # Q06. Les noms de trois sous-réseaux numérotés.
  #      Attendu : ["snet-01", "snet-02", "snet-03"]
  q06 = null

  # Q07. Les tags du service stock qu'on ne trouve pas sur le service commandes.
  #      Attendu : ["base-de-donnees"]
  q07 = null

  # Q08. Combien de couples (environnement, service) faut-il déployer ?
  #      Indice : keys() donne les noms des environnements et des services.
  #      Attendu : 12
  q08 = null

  # Q09. La région à utiliser : la première qui n'est pas vide.
  #      Attendu : "swedencentral"
  region_saisie = ""
  q09           = null

  # Q10. L'équipe répartie en binômes, dans l'ordre de local.prenoms.
  #      Attendu : [["alain", "Bérénice"], ["chloé", "David"], ["Émile"]]
  q10 = null
}
