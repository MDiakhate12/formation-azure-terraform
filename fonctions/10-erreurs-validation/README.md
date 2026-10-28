# 10. Erreurs et validation

Lire une valeur qui peut manquer, vérifier une saisie, arrêter un plan avec un message clair.

## Aide-mémoire

```hcl
# Rattraper une erreur
try(local.services.frontend.planification, "aucune")   # "aucune" : l'attribut n'existe pas
try(tonumber("abc"), 0)                                 # 0
can(regex("^[a-z0-9]{3,24}$", "st-dev"))               # false : la regex ne trouve rien

# Valeurs absentes
coalesce(null, "defaut")                                # "defaut"
one([])                                                 # null
nonsensitive(sensitive("x"))                            # retire la marque sensible
issensitive(sensitive("x"))                             # true
```

```hcl
# Valider une variable
variable "environnement" {
  type    = string
  default = "dev"

  validation {
    condition     = contains(["dev", "recette", "prod"], var.environnement)
    error_message = "environnement doit valoir dev, recette ou prod."
  }
}

# Attributs facultatifs, avec valeur par défaut
variable "service" {
  type = object({
    nom  = string
    port = optional(number, 80)
  })
}

# Bloquer un output si une condition n'est pas remplie
output "url" {
  value = "http://${local.nom}"

  precondition {
    condition     = local.nom != ""
    error_message = "Le nom est vide."
  }
}

# Vérifier sans bloquer : un avertissement à chaque plan
check "replicas" {
  assert {
    condition     = local.replicas >= 2
    error_message = "Moins de 2 réplicas : pas de haute disponibilité."
  }
}
```

À retenir :
- `try` rattrape une erreur d'accès ou de conversion, pas une faute de syntaxe ;
- `validation` contrôle une variable, `precondition` une ressource ou un output, `check` avertit sans bloquer ;
- un output qui contient une valeur sensible doit déclarer `sensitive = true` ; `terraform output -raw` l'affiche quand même.

## Exercice

### Partie 1 : vérifiée automatiquement

Complétez les `null` de `exercice.tf` et le type de `nouveau_service` dans `variables.tf`, puis `terraform apply -auto-approve`.

### Partie 2 : à observer

1. Dans `variables.tf`, ajoutez une `validation` à `environnement` : dev, recette ou prod. Testez :
   ```bash
   terraform apply -auto-approve -var environnement=preprod
   ```
   Le plan doit s'arrêter avec votre message.
2. Ajoutez un output `url_frontend` (`http://frontend.nebuleuse.fr`) avec une `precondition` : le frontend doit être exposé publiquement. Passez `exposition` à `interne` dans une copie de `services.yaml` pour la voir échouer, ou inversez la condition.
3. Ajoutez un bloc `check` : chaque service doit avoir au moins 2 réplicas. L'apply passe, avec un avertissement.
4. Ajoutez un output `en_tete` qui vaut `local.en_tete_auth`. Lisez l'erreur, corrigez avec `sensitive = true`, puis affichez la valeur :
   ```bash
   terraform output -raw en_tete
   ```
