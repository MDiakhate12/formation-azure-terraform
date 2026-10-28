# 06. Types et encodage

Convertir un type, lire et produire du JSON, du YAML, du CSV, du base64. C'est ainsi que `donnees.tf` lit les fichiers du fil rouge.

Ce thème demande un `terraform init` (rien n'est téléchargé) pour les fonctions `provider::terraform::*`.

## Aide-mémoire

```hcl
# Connaître le type (console uniquement)
type(local.equipe)                       # list(object({ actif = string, ... }))

# Convertir
tostring(8080)                           # "8080"
tonumber("8080")                         # 8080
tobool("true")                           # true
tolist(toset(["b", "a", "b"]))           # ["a", "b"]
toset(["b", "a", "b"])                   # toset(["a", "b"])
tomap({ a = "1" })                       # map(string)

# JSON
jsonencode({ service = "frontend", port = 80 })   # "{\"port\":80,\"service\":\"frontend\"}"
jsondecode("{\"port\": 80}").port                 # 80

# YAML
yamlencode({ nom = "frontend" })         # "\"nom\": \"frontend\"\n"
yamldecode("port: 80").port              # 80

# CSV : une liste de maps, toutes les valeurs sont du texte
csvdecode("nom,port\nfrontend,80")       # [{ nom = "frontend", port = "80" }]

# base64 et URL
base64encode("nebuleuse")                # "bmVidWxldXNl"
base64decode("bmVidWxldXNl")             # "nebuleuse"
base64gzip("texte long")                 # compressé puis encodé (cloud-init, par exemple)
urlencode("a b&c")                       # "a+b%26c"

# Produire du HCL (provider intégré terraform)
provider::terraform::encode_tfvars({ region = "swedencentral", noeuds = 1 })
# "noeuds = 1\nregion = \"swedencentral\"\n"
provider::terraform::decode_tfvars("noeuds = 1")   # { noeuds = 1 }
provider::terraform::encode_expr(["a", 1])         # "[\"a\", 1]"
```

À retenir :
- `csvdecode` ne devine aucun type : `"true"` et `"80"` restent du texte ;
- `jsonencode` trie les clés : pratique pour comparer deux valeurs ;
- `yamldecode` sur un document de plusieurs `---` échoue : un seul document par appel.

## Exercice

Complétez les `null` de `exercice.tf`, puis `terraform init` et `terraform apply -auto-approve`.
