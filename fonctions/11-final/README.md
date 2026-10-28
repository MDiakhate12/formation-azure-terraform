# 11. Exercice final : la plateforme Nébuleuse

Tous les thèmes réunis. À partir des trois fichiers de `donnees/`, préparez ce qu'un vrai projet Terraform consommerait ensuite : des maps prêtes pour des `for_each`, des noms conformes, des fichiers tfvars et un rapport.

Complétez les `null` de `exercice.tf` et le modèle `modeles/rapport.md.tftpl`, puis :

```bash
terraform init
terraform apply -auto-approve
```

`verification` contrôle quelques points de chaque partie. Pas d'indice cette fois : les aide-mémoires des thèmes 01 à 10 suffisent.

## 1. Les utilisateurs

Une map dont la clé est l'identifiant : le prénom en minuscules, sans accent.

```hcl
emile = {
  nom_complet = "Émile LAURENT"   # prénom bien écrit, nom en majuscules
  role        = "ops"
  ville       = "Lille"
  arrivee     = "01/06/2026"      # date au format français
  actif       = true              # un booléen, pas un texte
}
```

## 2. Les réseaux

Une map par environnement : l'espace d'adresses, le sous-réseau /24 numéro 1 pour AKS et le numéro 2 pour l'application.

```hcl
recette = { vnet = "10.20.0.0/16", aks = "10.20.1.0/24", app = "10.20.2.0/24" }
```

## 3. Les déploiements

Une entrée par couple (environnement, service), de clé `"<env>-<service>"`, soit 12 entrées.

```hcl
"prod-frontend" = {
  env         = "prod"
  service     = "frontend"
  nom         = "nebuleuse-prod-frontend"
  port        = 80
  replicas    = 4                                   # replicas x facteur_replicas
  sous_reseau = "10.30.2.0/24"                      # le sous-réseau app de l'environnement
  url         = "https://frontend.nebuleuse.fr"
  tags        = { societe = "nebuleuse", gere_par = "terraform", env = "prod", service = "frontend", equipe = "dev" }
}
```

L'`url` :
- `null` pour un service interne ;
- `https://<service>.nebuleuse.fr` en prod ;
- `https://<service>.<env>.nebuleuse.fr` ailleurs.

## 4. Les storage accounts

Un nom par environnement : `"st"`, la société, l'environnement, puis les 6 premiers caractères du sha256 de `"<société>-<env>"`. Exemple : `stnebuleusedeve94c92`. La `precondition` de l'output vérifie la règle Azure.

## 5. Les fichiers tfvars

Une map environnement => contenu d'un fichier tfvars, avec `region`, `noeuds`, `taille_vm` et `aks_subnet`. Pour le dev :

```hcl
aks_subnet = "10.10.1.0/24"
noeuds     = 1
region     = "swedencentral"
taille_vm  = "Standard_D2as_v6"
```

## 6. Le rapport

Complétez `modeles/rapport.md.tftpl`, puis appelez `templatefile` en lui passant ce dont il a besoin. La date du rapport vient de `local.date_rapport`. Les personnes inactives n'y figurent pas.

```markdown
## Équipe

| Personne | Rôle | Ville | Arrivée |
|---|---|---|---|
| Alain MARTIN | admin | Paris | 15/03/2023 |
...

## Déploiements

### dev : 10.10.0.0/16, 1 nœud(s) Standard_D2as_v6

- commandes : 3 réplica(s)
- factures : 1 réplica(s)
- frontend : 2 réplica(s), https://frontend.dev.nebuleuse.fr
- stock : 1 réplica(s)
```

Pour le relire : `terraform output -raw rapport`.

## 7. Le script

`modeles/exporter.sh.tftpl` est fourni : il attend `tfvars` et `rapport`. Une fois `script` rempli, Terraform écrit un script qui écrit à son tour les fichiers :

```bash
terraform output -raw script > exporter.sh
sh exporter.sh
```

Sous Windows, lancez ces deux commandes dans Git Bash. Le dossier `sortie/` contient alors `dev.tfvars`, `prod.tfvars`, `recette.tfvars` et `rapport.md`.

## Pour aller plus loin

- Changez `facteur_replicas` de la prod à 0,5 dans une copie de `environnements.json` : que dit le bloc `check` ?
- Ajoutez un service à `services.yaml` : tout suit, sauf le rapport si votre template n'est pas générique.
- Un vrai projet écrirait ces fichiers avec la ressource `local_file` du provider `hashicorp/local`, et utiliserait `local.deploiements` dans un `for_each`.
