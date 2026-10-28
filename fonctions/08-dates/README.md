# 08. Dates

Formater une date, ajouter une durée, comparer deux dates. Terraform manipule les dates au format RFC 3339 : `2026-10-28T09:00:00Z`.

## Aide-mémoire

```hcl
# Maintenant
timestamp()                                          # change à chaque exécution
plantimestamp()                                      # fixé pour tout un plan (pas dans la console)

# Formater
formatdate("DD/MM/YYYY", "2026-10-28T09:00:00Z")     # "28/10/2026"
formatdate("YYYY-MM-DD hh:mm", "2026-10-28T09:00:00Z")  # "2026-10-28 09:00"
formatdate("EEEE DD MMMM YYYY", "2026-10-28T09:00:00Z") # "Wednesday 28 October 2026"  (en anglais)
formatdate("YYYYMMDD", timestamp())                  # pour un suffixe de nom

# Ajouter une durée : h, m, s seulement (pas de jours)
timeadd("2026-10-28T09:00:00Z", "48h")               # "2026-10-30T09:00:00Z"
timeadd("2026-10-28T09:00:00Z", "-30m")              # "2026-10-28T08:30:00Z"

# Comparer : -1 (avant), 0 (égal), 1 (après)
timecmp("2025-01-01T00:00:00Z", "2026-01-01T00:00:00Z")   # -1

# Une date seule devient RFC 3339 en ajoutant l'heure
"${local.equipe[0].arrivee}T00:00:00Z"               # "2023-03-15T00:00:00Z"
```

À retenir :
- `timestamp()` dans une ressource crée une différence à chaque plan ; pour une date figée, le provider `hashicorp/time` (`time_static`) ou `ignore_changes` ;
- aucune fonction ne calcule l'écart entre deux dates ;
- au format `AAAA-MM-JJ`, l'ordre alphabétique est l'ordre chronologique : `sort` suffit.

## Exercice

Complétez les `null` de `exercice.tf`, puis `terraform apply -auto-approve`. L'output `maintenant` montre l'heure de l'exécution, différente à chaque fois.
