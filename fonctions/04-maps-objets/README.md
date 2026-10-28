# 04. Maps et objets

Lire une clé, fusionner des tags, construire un dictionnaire à partir de deux listes.

Une map a des valeurs toutes du même type (`map(string)`). Un objet a des attributs de types différents (`object({ port = number, tags = list(string) })`). Dans la console, `type(local.services)` montre la différence.

## Aide-mémoire

```hcl
# Lire
local.environnements.dev.region           # notation pointée
local.environnements["dev"].region        # notation crochets, utile avec une variable
keys({ b = 2, a = 1 })                    # ["a", "b"]  (toujours triées)
values({ b = 2, a = 1 })                  # [1, 2]      (dans l'ordre des clés)
lookup({ a = 1 }, "b", 0)                 # 0           (valeur par défaut si la clé manque)
contains(keys(local.services), "stock")   # true

# Construire et fusionner
zipmap(["a", "b"], [1, 2])                # { a = 1, b = 2 }
merge({ env = "dev", a = 1 }, { env = "prod" })
# { a = 1, env = "prod" }  (la dernière map gagne)
tomap({ a = "1", b = "2" })               # map(string)

# Retourner une map de listes
transpose({ frontend = ["web"], api = ["web", "python"] })
# { python = ["api"], web = ["api", "frontend"] }

# Garder les éléments d'une liste selon une autre liste
matchkeys(["vm1", "vm2", "vm3"], ["dev", "prod", "dev"], ["dev"])
# ["vm1", "vm3"]
```

À retenir :
- `merge` est superficiel : une sous-map de la seconde remplace entièrement celle de la première ;
- `lookup` lit un seul niveau ; pour un chemin plus profond qui peut manquer, utilisez `try` (thème 10) ;
- l'ordre de `keys` est alphabétique, ce qui rend les plans stables.

## Exercice

Complétez les `null` de `exercice.tf`, puis `terraform apply -auto-approve`.
