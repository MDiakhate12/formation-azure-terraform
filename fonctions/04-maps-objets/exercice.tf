# Remplacez chaque null par une expression. Les données sont dans donnees.tf.
locals {
  tags_communs = { societe = "nebuleuse", gere_par = "terraform", env = "inconnu" }
  tags_prod    = { env = "prod", centre_de_cout = "cc-42" }

  tags_par_service = {
    frontend  = ["web", "nginx"]
    commandes = ["api", "python"]
    stock     = ["api", "python", "base-de-donnees"]
    factures  = ["batch"]
  }

  # Q01. Les noms des environnements.
  #      Attendu : ["dev", "prod", "recette"]
  q01 = null

  # Q02. Les tags de la prod : les tags communs, complétés et corrigés par tags_prod.
  #      Attendu : { centre_de_cout = "cc-42", env = "prod", gere_par = "terraform", societe = "nebuleuse" }
  q02 = null

  # Q03. La planification du service factures, ou "aucune" s'il n'en a pas.
  #      Attendu : "0 2 * * *"
  q03 = null

  # Q04. La même chose pour le frontend.
  #      Attendu : "aucune"
  q04 = null

  # Q05. Une map service => port.
  #      Attendu : { commandes = 8080, factures = 9090, frontend = 80, stock = 8081 }
  q05 = null

  # Q06. À partir de tags_par_service, une map tag => services qui le portent.
  #      Attendu : { api = ["commandes", "stock"], base-de-donnees = ["stock"], batch = ["factures"],
  #                  nginx = ["frontend"], python = ["commandes", "stock"], web = ["frontend"] }
  q06 = null

  # Q07. La taille de VM de l'environnement demandé, ou celle du dev s'il n'existe pas.
  #      Attendu : "Standard_D2as_v6"
  env_demande = "preprod"
  q07         = null

  # Q08. Le service stock existe-t-il ?
  #      Attendu : true
  q08 = null
}
