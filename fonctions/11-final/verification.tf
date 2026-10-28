# Ne modifiez pas ce fichier : il vérifie quelques points de chaque partie.
locals {
  attendu = {
    c01_utilisateurs = ["alain", "berenice", "chloe", "david", "emile"]
    c02_emile        = { actif = true, arrivee = "01/06/2026", nom_complet = "Émile LAURENT", role = "ops", ville = "Lille" }
    c03_reseaux      = { aks = "10.20.1.0/24", app = "10.20.2.0/24", vnet = "10.20.0.0/16" }
    c04_nombre       = 12
    c05_prod_front = {
      env         = "prod"
      nom         = "nebuleuse-prod-frontend"
      port        = 80
      replicas    = 4
      service     = "frontend"
      sous_reseau = "10.30.2.0/24"
      tags        = { env = "prod", equipe = "dev", gere_par = "terraform", service = "frontend", societe = "nebuleuse" }
      url         = "https://frontend.nebuleuse.fr"
    }
    c06_url_dev     = "https://frontend.dev.nebuleuse.fr"
    c07_url_interne = null
    c08_storage     = { dev = "stnebuleusedeve94c92", prod = "stnebuleuseprod07319c", recette = "stnebuleuserecettec2b21e" }
    c09_tfvars_dev  = "aks_subnet = \"10.10.1.0/24\"\nnoeuds     = 1\nregion     = \"swedencentral\"\ntaille_vm  = \"Standard_D2as_v6\"\n"
    c10_rapport     = [true, true, false]
    c11_script      = true
  }
  reponses = {
    c01_utilisateurs = try(keys(local.utilisateurs), null)
    c02_emile        = try(local.utilisateurs["emile"], null)
    c03_reseaux      = try(local.reseaux["recette"], null)
    c04_nombre       = try(length(local.deploiements), null)
    c05_prod_front   = try(local.deploiements["prod-frontend"], null)
    c06_url_dev      = try(local.deploiements["dev-frontend"].url, null)
    c07_url_interne  = try(local.deploiements["dev-stock"].url, "absente")
    c08_storage      = local.storage_accounts
    c09_tfvars_dev   = try(local.tfvars["dev"], null)
    c10_rapport = try([
      strcontains(local.rapport, "| Émile LAURENT | ops | Lille | 01/06/2026 |"),
      strcontains(local.rapport, "- frontend : 4 réplica(s), https://frontend.nebuleuse.fr"),
      strcontains(local.rapport, "David"),
    ], null)
    c11_script = try(strcontains(local.script, "cat > sortie/prod.tfvars"), null)
  }
}

# jsonencode compare les valeurs sans tenir compte du type (liste, tuple, ensemble).
locals {
  resultats = { for q, v in local.attendu : q => jsonencode(local.reponses[q]) == jsonencode(v) }
}

output "reponses" {
  value = local.reponses
}

output "verification" {
  value = { for q, ok in local.resultats : q => ok ? "OK" : "à revoir" }
}

output "score" {
  value = "${length([for ok in values(local.resultats) : ok if ok])}/${length(local.resultats)}"
}
