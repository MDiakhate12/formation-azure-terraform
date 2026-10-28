# Remplacez chaque null par une expression. Les données sont dans donnees.tf.
locals {
  # Q01. Le nombre total de réplicas des services (champ replicas).
  #      Indice : values(local.services)[*].replicas donne la liste des réplicas.
  #      Attendu : 7
  q01 = null

  # Q02. Le plus grand port utilisé par les services.
  #      Attendu : 9090
  q02 = null

  # Q03. Le nombre total de nœuds, tous environnements confondus.
  #      Attendu : 5
  q03 = null

  # Q04. Le coût mensuel des nœuds de prod, arrondi à l'euro supérieur.
  #      Un mois compte 730 heures. Le prix est fictif.
  #      Attendu : 211
  prix_horaire_noeud = 0.096
  q04                = null

  # Q05. Une couleur en hexadécimal convertie en nombre.
  #      Attendu : 255
  rouge_hexa = "ff"
  q05        = null

  # Q06. En prod, chaque service a facteur_replicas fois plus de réplicas.
  #      Un nœud accueille 4 pods. Combien de nœuds faut-il au minimum ?
  #      Attendu : 4   (7 réplicas x 2 = 14 pods, 14 / 4 = 3,5)
  pods_par_noeud = 4
  q06            = null

  # Q07. La part des réplicas du frontend sur le total, en pourcentage, à une décimale.
  #      Attendu : "28.6"
  q07 = null

  # Q08. Le port d'administration : le port du service commandes plus 1000.
  #      Le port est lu depuis un texte.
  #      Attendu : 9080
  port_texte = "8080"
  q08        = null
}
