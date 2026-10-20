# Jour 1 : énoncés

Un fil rouge sur la journée : un resource group, puis un réseau, puis un module réutilisable.
Travaillez dans **votre propre dossier** (par exemple `~/formation/jour1`), en dehors du clone du dépôt, et faites-le évoluer de TP en TP.

Bloqué ? La solution de chaque TP est publiée juste après sa correction : `git pull`, puis copiez `jour1/solution/tpN`. dans votre dossier et repartez de là.

## Avant de commencer

```bash
az login --tenant <tenant>              # id du tenant donné par le formateur
az account show -o table
export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
```

Sous Windows PowerShell : `$env:ARM_SUBSCRIPTION_ID = (az account show --query id -o tsv)`.

## Règles de la subscription partagée

- Préfixez **toutes** vos ressources par votre prénom, en minuscules et sans accent.
- Région unique : `swedencentral`. Taille de VM autorisée : `Standard_B2s_v2`. Une policy refuse le reste.
- Détruisez ce qui coûte (la VM du bonus) avant de partir.

| TP | Sujet | Durée |
|---|---|---|
| [TP1](tp1.md) | Mon premier resource group | 30 min |
| [TP2](tp2.md) | Variabiliser et nommer | 30 min |
| [TP3](tp3.md) | VNet et deux sous-réseaux | 40 min |
| [TP4](tp4.md) | NSG et règles avec `for_each` | 30 min |
| [TP5](tp5.md) | Module réseau | 50 min |
| [Bonus](../bonus/README.md) | Une VM configurée par cloud-init | 30 min |
