# 09. Réseau et hachage

Découper un espace d'adresses sans calcul à la main, produire un nom unique et stable.

## Aide-mémoire

```hcl
# Découper un espace d'adresses
cidrsubnet("10.10.0.0/16", 8, 1)          # "10.10.1.0/24"  (+8 bits de masque, sous-réseau n° 1)
cidrsubnet("10.10.0.0/16", 4, 2)          # "10.10.32.0/20"
cidrsubnets("10.10.0.0/16", 8, 8, 4)      # ["10.10.0.0/24", "10.10.1.0/24", "10.10.16.0/20"]
                                          # plusieurs sous-réseaux qui ne se chevauchent pas

# Adresses et masque
cidrhost("10.10.1.0/24", 4)               # "10.10.1.4"  (Azure réserve les 4 premières)
cidrhost("10.10.1.0/24", -2)              # "10.10.1.254" (en partant de la fin)
cidrnetmask("10.10.0.0/16")               # "255.255.0.0"

# Empreintes : toujours le même résultat pour la même entrée
md5("nebuleuse")
sha1("nebuleuse")
sha256("nebuleuse")
sha512("nebuleuse")
base64sha256("nebuleuse")                 # la forme attendue par certaines API

# Identifiants
uuidv5("dns", "frontend.nebuleuse.fr")    # stable : dérivé du nom
uuid()                                    # aléatoire, change à chaque exécution
bcrypt("motdepasse")                      # hachage de mot de passe, sel aléatoire
```

À retenir :
- dans un sous-réseau Azure, 5 adresses sont réservées : les 4 premières et la dernière ;
- `uuid()`, `bcrypt()` et `timestamp()` changent à chaque plan : à éviter dans un attribut de ressource ;
- pour un nom unique et stable, une empreinte courte d'une valeur fixe (`substr(sha256(...), 0, 6)`), ou le provider `random` dont le résultat est gardé dans le state.

## Exercice

Complétez les `null` de `exercice.tf`, puis `terraform apply -auto-approve`.
