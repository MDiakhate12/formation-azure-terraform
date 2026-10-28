# Les fonctions Terraform : aide-mémoire et exercices

Terraform ne sert pas qu'à créer des ressources : sans aucun provider, il lit des fichiers, transforme des données et produit du texte. Ces exercices passent en revue ses fonctions par thème, pour savoir les reconnaître dans un projet et les écrire soi-même.

Tout s'exécute en local : pas de compte Azure, rien à payer.

## Le fil rouge

Vous rejoignez l'équipe plateforme de la société fictive Nébuleuse. Avant d'écrire la moindre ressource, vous préparez ses données. Elles sont dans `donnees/` et chaque thème les lit (`donnees.tf`) :

| Fichier | Contenu | Dans Terraform |
|---|---|---|
| `equipe.csv` | 5 personnes, avec une casse et des accents à nettoyer | `local.equipe` |
| `services.yaml` | 4 microservices : port, réplicas, exposition, tags | `local.services` |
| `environnements.json` | dev, recette, prod : réseau, nœuds, taille de VM | `local.environnements` |

## Les thèmes

| Dossier | Fonctions |
|---|---|
| [01-chaines](01-chaines/) | `format`, `join`, `split`, `replace`, `regex`, `substr`, `trimspace`, `startswith` |
| [02-nombres](02-nombres/) | `sum`, `min`, `max`, `ceil`, `floor`, `parseint`, `pow` |
| [03-listes-ensembles](03-listes-ensembles/) | `flatten`, `distinct`, `sort`, `element`, `range`, `chunklist`, `setproduct`, `setsubtract` |
| [04-maps-objets](04-maps-objets/) | `keys`, `values`, `lookup`, `merge`, `zipmap`, `transpose` |
| [05-expressions-for](05-expressions-for/) | `[for ...]`, `{for ...}`, `if`, regroupement `...`, boucles imbriquées pour un `for_each` |
| [06-types-encodage](06-types-encodage/) | `tobool`, `toset`, `jsonencode`, `yamldecode`, `csvdecode`, `base64encode`, `encode_tfvars` |
| [07-fichiers-templates](07-fichiers-templates/) | `file`, `fileset`, `fileexists`, `templatefile`, `templatestring`, `path.module` |
| [08-dates](08-dates/) | `timestamp`, `formatdate`, `timeadd`, `timecmp` |
| [09-reseau-hachage](09-reseau-hachage/) | `cidrsubnet`, `cidrsubnets`, `cidrhost`, `sha256`, `uuidv5` |
| [10-erreurs-validation](10-erreurs-validation/) | `try`, `can`, `validation`, `optional`, `precondition`, `check`, `sensitive` |
| [11-final](11-final/) | Tout à la fois : la plateforme Nébuleuse |

Les thèmes se suivent mais restent indépendants : commencez par ceux que vous connaissez le moins.

## Mode d'emploi

Dans chaque dossier, un `README.md` (l'aide-mémoire, puis l'exercice), un `exercice.tf` à compléter et un `verification.tf` à ne pas toucher.

```bash
cd fonctions/01-chaines
terraform init                    # rien n'est téléchargé
terraform console                 # pour essayer les exemples de l'aide-mémoire
terraform apply -auto-approve     # pour vérifier vos réponses
```

Le résultat :

```
reponses     = { q01 = "NÉBULEUSE", q02 = null, ... }
score        = "1/10"
verification = { q01 = "OK", q02 = "à revoir", ... }
```

Quelques conseils :
- essayez d'abord une expression dans `terraform console`, puis recopiez-la dans `exercice.tf` ;
- dans la console, `type(...)` donne le type d'une valeur et `local.equipe` affiche les données ;
- `-auto-approve` est sans risque ici : aucune ressource n'existe, seul le state local des outputs est écrit ;
- la documentation de chaque fonction : <https://developer.hashicorp.com/terraform/language/functions>.
