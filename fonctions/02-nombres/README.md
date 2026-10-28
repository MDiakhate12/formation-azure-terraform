# 02. Nombres

Additionner des réplicas, arrondir un coût, dimensionner un pool de nœuds.

## Aide-mémoire

```hcl
# Opérateurs
7 / 2                     # 3.5  (pas de division entière)
7 % 2                     # 1    (reste)
2 * (3 + 1)               # 8

# Arrondis et valeur absolue
ceil(3.2)                 # 4    (au supérieur)
floor(3.8)                # 3    (à l'inférieur)
abs(-5)                   # 5
signum(-5)                # -1   (signe : -1, 0 ou 1)

# Minimum, maximum, somme
min(3, 1, 2)              # 1
max(80, 8080)             # 8080
max([80, 8080]...)        # 8080 (... déplie une liste en arguments)
sum([2, 3, 1])            # 6    (sum prend une liste)

# Puissances et logarithmes
pow(2, 8)                 # 256
log(256, 2)               # 8

# Conversions
tonumber("8080")          # 8080
parseint("ff", 16)        # 255  (texte dans une base donnée)
parseint("101", 2)        # 5
format("%.2f", 210.244)   # "210.24"  (arrondi à l'affichage)
format("%d", 42)          # "42"

# Condition
local.noeuds > 1 ? "haute dispo" : "simple"
```

À retenir :
- `min`, `max` attendent des arguments séparés : une liste se déplie avec `...` ;
- `sum` attend au contraire une liste ;
- pour arrondir à n décimales : `floor(x * 100) / 100`, ou `format("%.2f", x)` pour du texte.

## Exercice

Complétez les `null` de `exercice.tf`, puis `terraform apply -auto-approve`.
