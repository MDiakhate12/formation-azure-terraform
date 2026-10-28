# 05. Expressions for

L'équivalent des list comprehensions de Python. C'est l'outil qui prépare les données d'un `for_each`.

## Aide-mémoire

```hcl
# Liste vers liste
[for p in local.equipe : upper(p.ville)]
# ["PARIS", "LYON", "NANTES", "PARIS", "LILLE"]

# Avec l'indice
[for i, p in local.equipe : "${i}-${p.prenom}"]
# ["0-alain", "1-Bérénice", ...]

# Filtrer avec if
[for p in local.equipe : p.prenom if p.role == "ops"]
# ["David", "Émile"]

# Liste vers map : => entre la clé et la valeur
{ for p in local.equipe : p.prenom => p.ville }
# { alain = "Paris", "Bérénice" = "Lyon", ... }

# Map vers map
{ for nom, s in local.services : nom => s.port }
# { commandes = 8080, factures = 9090, frontend = 80, stock = 8081 }

# Regrouper : ... après la valeur quand plusieurs éléments ont la même clé
{ for p in local.equipe : p.ville => p.prenom... }
# { Lille = ["Émile"], Lyon = ["Bérénice"], Nantes = ["chloé"], Paris = ["alain", "David"] }

# Deux boucles imbriquées, aplaties : le motif classique du for_each
flatten([
  for env in keys(local.environnements) : [
    for svc in keys(local.services) : { env = env, svc = svc }
  ]
])

# Splat : raccourci pour lire un attribut
local.equipe[*].ville       # comme [for p in local.equipe : p.ville]
```

À retenir :
- crochets `[for ...]` pour une liste, accolades `{for ...}` pour une map ;
- dans une map, deux éléments avec la même clé provoquent une erreur, sauf avec `...` ;
- pour un `for_each`, construisez une map avec une clé lisible et stable (`"dev-frontend"`), pas un indice.

## Exercice

Complétez les `null` de `exercice.tf`, puis `terraform apply -auto-approve`.
