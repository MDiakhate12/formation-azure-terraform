# 01. Chaînes de caractères

Mettre en forme des noms, découper, remplacer, tester. C'est le quotidien des noms de ressources Azure.

## Aide-mémoire

À essayer dans `terraform console`, depuis ce dossier.

```hcl
# Mettre en forme
format("%s-%s", "rg", "dev")              # "rg-dev"
format("%03d", 7)                         # "007"
format("%-10s|", "ab")                    # "ab        |"  (aligné à gauche sur 10)
formatlist("snet-%s", ["aks", "app"])     # ["snet-aks", "snet-app"]
"rg-${local.equipe[0].prenom}"            # interpolation : "rg-alain"

# Casse
upper("dev")                              # "DEV"
lower("ÉMILE")                            # "émile"  (les accents sont gérés)
title("jean-pierre")                      # "Jean-Pierre"

# Assembler et découper
join(", ", ["Paris", "Lyon"])             # "Paris, Lyon"
split(",", "web,nginx")                   # ["web", "nginx"]
length("nebuleuse")                       # 9

# Extraire
substr("2023-03-15", 0, 4)                # "2023"   (départ, longueur)
regex("^(\\d{4})-(\\d{2})", "2023-03-15") # ["2023", "03"]  (groupes capturés)
regexall("[0-9]+", "v1.35.8")             # ["1", "35", "8"]

# Remplacer et nettoyer
replace("rg_dev", "_", "-")               # "rg-dev"
replace("Bérénice", "/[éè]/", "e")        # "Berenice"  (entre /.../ : une expression régulière)
trimspace("  frontend \n")                # "frontend"
trim("--dev--", "-")                      # "dev"
trimprefix("rg-dev", "rg-")               # "dev"
trimsuffix("main.tf", ".tf")              # "main"
chomp("ligne\n")                          # "ligne"  (retire le saut de ligne final)
strrev("abc")                             # "cba"

# Tester
startswith("Standard_D2as_v6", "Standard_")   # true
endswith("main.tf", ".tf")                    # true
strcontains("swedencentral", "central")       # true

indent(2, "a\nb")                         # "a\n  b"  (indente à partir de la 2e ligne)
```

```hcl
# Texte sur plusieurs lignes, dans un bloc locals : <<- retire l'indentation commune
locals {
  texte = <<-EOT
    Bonjour
    Nébuleuse
  EOT
}
```

À retenir :
- une regex s'écrit entre `/.../` dans `replace`, mais sans barres dans `regex` et `regexall` ;
- dans une chaîne HCL, l'antislash se double : `"\\d"` ;
- `regex` échoue s'il ne trouve rien ; `regexall` renvoie une liste vide.

## Exercice

Complétez les `null` de `exercice.tf`, puis :

```bash
terraform apply -auto-approve
```

L'output `verification` affiche `OK` ou `à revoir` pour chaque question. Le résultat attendu est rappelé en commentaire.
