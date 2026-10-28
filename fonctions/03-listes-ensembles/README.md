# 03. Listes et ensembles

Trier, dédoublonner, aplatir, combiner. Une liste est ordonnée et accepte les doublons ; un ensemble (`set`) n'a ni ordre ni doublon.

## Aide-mémoire

```hcl
# Accéder
local.equipe[0]                         # le premier élément
local.equipe[*].ville                   # splat : l'attribut ville de chaque élément
length(["a", "b"])                      # 2
element(["a", "b", "c"], 4)             # "b"   (reprend au début : 4 modulo 3 = 1)
index(["dev", "prod"], "prod")          # 1
contains(["dev", "prod"], "dev")        # true
one(["seul"])                           # "seul"  (null si vide, erreur si plus d'un)

# Découper et assembler
slice(["a", "b", "c", "d"], 1, 3)       # ["b", "c"]   (début inclus, fin exclue)
concat(["a"], ["b", "c"])               # ["a", "b", "c"]
flatten([["a", "b"], ["c"]])            # ["a", "b", "c"]
chunklist(["a", "b", "c"], 2)           # [["a", "b"], ["c"]]
range(3)                                # [0, 1, 2]
range(1, 7, 2)                          # [1, 3, 5]

# Trier et nettoyer
sort(["lyon", "brest"])                 # ["brest", "lyon"]
reverse(["a", "b"])                     # ["b", "a"]
distinct(["a", "b", "a"])               # ["a", "b"]
compact(["a", "", null, "b"])           # ["a", "b"]   (retire les chaînes vides et null)

# Première valeur non vide
coalesce("", null, "swedencentral")     # "swedencentral"
coalescelist([], ["dev"])               # ["dev"]

# Ensembles
toset(["a", "b", "a"])                  # toset(["a", "b"])
setunion(["a"], ["b"])                  # ["a", "b"]
setintersection(["a", "b"], ["b", "c"]) # ["b"]
setsubtract(["a", "b"], ["b"])          # ["a"]
setproduct(["dev", "prod"], ["web", "api"])
# [["dev", "web"], ["dev", "api"], ["prod", "web"], ["prod", "api"]]

# Tests sur toute une liste
alltrue([true, false])                  # false
anytrue([true, false])                  # true
```

À retenir :
- `sort` trie toujours du texte : `sort([80, 8080, 443])` donne `["443", "80", "8080"]` ;
- un ensemble n'a pas d'indice : `toset(...)[0]` est une erreur, passez par `tolist` ;
- `for_each` n'accepte pas une liste : `toset(...)` ou une map.

## Exercice

Complétez les `null` de `exercice.tf`, puis `terraform apply -auto-approve`.
