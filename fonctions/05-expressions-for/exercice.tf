# Remplacez chaque null par une expression. Les données sont dans donnees.tf.
locals {
  # Q01. Les prénoms bien écrits : une majuscule, le reste en minuscules.
  #      Attendu : ["Alain", "Bérénice", "Chloé", "David", "Émile"]
  q01 = null

  # Q02. Les prénoms bien écrits des personnes actives (attention : actif est un texte).
  #      Attendu : ["Alain", "Bérénice", "Chloé", "Émile"]
  q02 = null

  # Q03. Une map prénom bien écrit => ville.
  #      Attendu : { Alain = "Paris", Bérénice = "Lyon", Chloé = "Nantes", David = "Paris", Émile = "Lille" }
  q03 = null

  # Q04. Les prénoms bien écrits, regroupés par rôle.
  #      Attendu : { admin = ["Alain"], dev = ["Bérénice", "Chloé"], ops = ["David", "Émile"] }
  q04 = null

  # Q05. Les services exposés publiquement (champ exposition).
  #      Attendu : ["frontend"]
  q05 = null

  # Q06. Le nombre de réplicas de chaque service en prod (replicas x facteur_replicas de la prod).
  #      Attendu : { commandes = 6, factures = 2, frontend = 4, stock = 2 }
  q06 = null

  # Q07. Une map prête pour un for_each : une entrée par couple (environnement, service),
  #      de clé "<env>-<service>" et de valeur { env, service, replicas }.
  #      Les réplicas suivent le facteur_replicas de l'environnement.
  #      Attendu (extrait) : "prod-commandes" = { env = "prod", service = "commandes", replicas = 6 }
  q07 = null

  # Q08. Le nombre d'entrées de q07.
  #      Attendu : 12
  q08 = null
}
