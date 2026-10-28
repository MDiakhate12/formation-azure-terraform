# Remplacez chaque null par une expression. Les données sont dans donnees.tf.
locals {
  # Q01. Le nombre de personnes actives, en convertissant le champ actif en booléen.
  #      Attendu : 4
  q01 = null

  # Q02. Le port du frontend, en texte (pour une variable d'environnement).
  #      Attendu : "80"
  q02 = null

  # Q03. La configuration du frontend en JSON compact : port et replicas seulement.
  #      Attendu : "{\"port\":80,\"replicas\":2}"
  q03 = null

  # Q04. Le nom de la ville de la première personne, lu dans ce JSON.
  #      Attendu : "Paris"
  json_recu = "{\"personne\": {\"prenom\": \"alain\", \"ville\": \"Paris\"}}"
  q04       = null

  # Q05. Les mêmes données en YAML : { nom = "frontend", replicas = 2 }.
  #      Attendu : "\"nom\": \"frontend\"\n\"replicas\": 2\n"
  q05 = null

  # Q06. Un en-tête d'authentification basique : "Basic " suivi de "utilisateur:motdepasse" en base64.
  #      Attendu : "Basic bmVidWxldXNlOmRlbW8="
  utilisateur = "nebuleuse"
  motdepasse  = "demo"
  q06         = null

  # Q07. Un paramètre d'URL sûr.
  #      Attendu : "%C3%A9quipe+plateforme+%26+ops"
  recherche = "équipe plateforme & ops"
  q07       = null

  # Q08. Le contenu d'un fichier dev.tfvars : region et noeuds du dev.
  #      Indice : provider::terraform::encode_tfvars
  #      Attendu : "noeuds = 1\nregion = \"swedencentral\"\n"
  q08 = null
}
