# Jour 2 : énoncés

Chaque TP est autonome et part d'un **nouveau dossier** (`~/formation/jour2/tp1`, `tp2`...). Rien ne dépend du travail d'hier.
Bloqué ? La solution de chaque TP est publiée juste après sa correction : `git pull`, puis copiez `jour2/solution/tpN`..

## Avant de commencer

```bash
az login --tenant <tenant>
export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
```

Sous Windows PowerShell : `$env:ARM_SUBSCRIPTION_ID = (az account show --query id -o tsv)`.

Rappels : préfixe par votre prénom, région `swedencentral`, taille `Standard_B2s_v2`, **aucune zone** sur les nœuds.

| TP | Sujet | Durée |
|---|---|---|
| [TP1](tp1.md) | Un state distant | 30 min |
| [TP2](tp2.md) | Importer et déplacer | 30 min |
| [TP3](tp3.md) | Une identité managée avec un rôle | 40 min |
| [TP4](tp4.md) | Premier pipeline | 30 min |
| [TP5](tp5.md) | Mon cluster AKS | 50 min |
| [Bonus](../bonus/README.md) | Un pipeline sans secret (OIDC) | 30 min |

**Avant de partir** : `terraform destroy` sur le cluster du TP5. Il coûte à l'heure, et demain le code du cluster est fourni.
