# Solution de l'exercice final.
locals {
  societe      = "nebuleuse"
  date_rapport = "2026-10-28T09:00:00Z"
  tags_communs = { societe = local.societe, gere_par = "terraform" }

  # 1. Chaînes, dates, conversions et expressions for.
  utilisateurs = {
    for p in local.equipe : replace(lower(p.prenom), "/[éèêë]/", "e") => {
      nom_complet = "${title(lower(p.prenom))} ${upper(p.nom)}"
      role        = p.role
      ville       = p.ville
      arrivee     = formatdate("DD/MM/YYYY", "${p.arrivee}T00:00:00Z")
      actif       = tobool(p.actif)
    }
  }

  # 2. Réseau.
  reseaux = {
    for env, e in local.environnements : env => {
      vnet = e.espace_adresses
      aks  = cidrsubnet(e.espace_adresses, 8, 1)
      app  = cidrsubnet(e.espace_adresses, 8, 2)
    }
  }

  # 3. Boucles imbriquées, merge, condition.
  deploiements = {
    for d in flatten([
      for env, e in local.environnements : [
        for svc, s in local.services : {
          env         = env
          service     = svc
          nom         = "${local.societe}-${env}-${svc}"
          port        = s.port
          replicas    = s.replicas * e.facteur_replicas
          sous_reseau = local.reseaux[env].app
          url = s.exposition != "publique" ? null : (
            env == "prod" ? "https://${svc}.nebuleuse.fr" : "https://${svc}.${env}.nebuleuse.fr"
          )
          tags = merge(local.tags_communs, { env = env, service = svc, equipe = s.equipe })
        }
      ]
    ]) : "${d.env}-${d.service}" => d
  }

  # 4. Hachage.
  storage_accounts = {
    for env in keys(local.environnements) :
    env => "st${local.societe}${env}${substr(sha256("${local.societe}-${env}"), 0, 6)}"
  }

  # 5. Encodage.
  tfvars = {
    for env, e in local.environnements : env => provider::terraform::encode_tfvars({
      region     = e.region
      noeuds     = e.noeuds
      taille_vm  = e.taille_vm
      aks_subnet = local.reseaux[env].aks
    })
  }

  # 6 et 7. Templates.
  rapport = templatefile("${path.module}/modeles/rapport.md.tftpl", {
    date           = formatdate("DD/MM/YYYY", local.date_rapport)
    utilisateurs   = local.utilisateurs
    environnements = local.environnements
    deploiements   = local.deploiements
  })

  script = templatefile("${path.module}/modeles/exporter.sh.tftpl", {
    tfvars  = local.tfvars
    rapport = local.rapport
  })
}
