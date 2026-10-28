# Remplacez chaque null par une expression. Les données sont dans donnees.tf.
locals {
  # Q01. Le fichier equipe.csv existe-t-il dans local.dossier_donnees ?
  #      Attendu : true
  q01 = null

  # Q02. Les fichiers JSON et YAML du dossier de données.
  #      Attendu : ["environnements.json", "services.yaml"]
  q02 = null

  # Q03. Les noms des fichiers du dossier de données (pas des sous-dossiers), sans leur extension.
  #      Attendu : ["environnements", "equipe", "services"]
  q03 = null

  # Q04. Le message de bienvenue de Chloé, avec modeles/bienvenue.txt.tftpl.
  #      Attendu : "Bienvenue Chloé chez Nébuleuse !\n"
  q04 = null

  # Q05. Le tableau des services, avec modeles/services.md.tftpl (complétez d'abord sa ligne).
  #      Attendu :
  #      | Service | Port | Réplicas |
  #      |---|---|---|
  #      | commandes | 8080 | 3 |
  #      | factures | 9090 | 1 |
  #      | frontend | 80 | 2 |
  #      | stock | 8081 | 1 |
  q05 = null

  # Q06. Le nom du resource group, à partir du modèle ci-dessous.
  #      Attendu : "rg-nebuleuse-dev"
  modele_nom = "rg-$${societe}-$${env}"
  q06        = null

  # Q07. Le nombre de personnes, en comptant les lignes de equipe.csv sans csvdecode.
  #      Attendu : 5
  q07 = null
}
