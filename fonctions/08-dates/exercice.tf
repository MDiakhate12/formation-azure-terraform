# Remplacez chaque null par une expression. Les données sont dans donnees.tf.
locals {
  # Q01. La date d'arrivée de la première personne, au format français.
  #      Attendu : "15/03/2023"
  q01 = null

  # Q02. La même date en toutes lettres.
  #      Attendu : "Wednesday 15 March 2023"
  q02 = null

  # Q03. La fin de la période d'essai d'Émile (local.equipe[4]) : 90 jours après son arrivée.
  #      Attendu : "2026-08-30T00:00:00Z"
  q03 = null

  # Q04. Les prénoms bien écrits des personnes arrivées avant le 1er janvier 2025.
  #      Attendu : ["Alain", "Bérénice", "David"]
  q04 = null

  # Q05. La date de la première arrivée dans l'équipe.
  #      Attendu : "2022-11-07"
  q05 = null

  # Q06. Un certificat émis à cette date expire un an plus tard (365 jours).
  #      Attendu : "2027-10-28T09:00:00Z"
  emission = "2026-10-28T09:00:00Z"
  q06      = null

  # Q07. Un suffixe de sauvegarde au format AAAAMMJJ-hhmm, pour la date d'émission.
  #      Attendu : "20261028-0900"
  q07 = null
}

output "maintenant" {
  value = formatdate("DD/MM/YYYY hh:mm:ss", timestamp())
}
