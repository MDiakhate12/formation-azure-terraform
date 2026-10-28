# Exercice final : préparez les données de la plateforme Nébuleuse.
# Remplacez chaque null en suivant le README. Les données sont dans donnees.tf.
locals {
  societe      = "nebuleuse"
  date_rapport = "2026-10-28T09:00:00Z"
  tags_communs = { societe = local.societe, gere_par = "terraform" }

  # 1. Les utilisateurs : une map identifiant => { nom_complet, role, ville, arrivee, actif }.
  utilisateurs = null

  # 2. Les réseaux : une map environnement => { vnet, aks, app }.
  reseaux = null

  # 3. Les déploiements : une map "<env>-<service>" => { env, service, nom, port, replicas, sous_reseau, url, tags }.
  deploiements = null

  # 4. Les storage accounts : une map environnement => nom.
  storage_accounts = null

  # 5. Les fichiers tfvars : une map environnement => contenu.
  tfvars = null

  # 6. Le rapport, avec modeles/rapport.md.tftpl.
  rapport = null

  # 7. Le script qui écrit les fichiers, avec modeles/exporter.sh.tftpl.
  script = null
}
