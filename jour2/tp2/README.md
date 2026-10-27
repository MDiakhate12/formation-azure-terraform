# TP2 : importer et déplacer

[Sommaire du jour 2](../enonce.md) · [Se connecter à Azure](../enonce.md#avant-de-commencer)

**Objectif** : faire adopter par Terraform une ressource créée à la main, puis la renommer dans le code sans la recréer. **Durée** : 15 minutes.
**Dossier de travail** : `jour2/tp2/` (le fichier `versions.tf` y est déjà)

## Où on en est, où on va

En entreprise, beaucoup de ressources existent déjà, créées à la main dans le portail. Terraform ne les connaît pas.
À la fin de ce TP, vous aurez fait **adopter** un resource group existant par Terraform (`import`), puis vous l'aurez renommé dans le code sans le détruire (`moved`).

## Étape 1 : se placer dans le dossier, reprendre les variables

**À lancer** :

```bash
# Depuis la racine du dépôt cloné
cd jour2/tp2
# Reprend les variables et les valeurs du TP1
cp ../tp1/variables.tf ../tp1/dev.tfvars .
```

## Étape 2 : créer une ressource à la main

On simule une ressource créée hors de Terraform, comme un collègue l'aurait fait dans le portail.

**À lancer** :

```bash
# Crée un resource group avec la CLI Azure, sans Terraform
az group create -n rg-<prénom>-manuel -l swedencentral
```

## Étape 3 : décrire la ressource et l'importer

Pour adopter une ressource, il faut deux choses : le bloc `resource` qui la décrit, et un bloc `import` qui donne son identifiant Azure.

**À compléter** dans un nouveau fichier `main.tf` :

```hcl
data "azurerm_subscription" "current" {}

import {
  to = azurerm_resource_group.legacy
  id = "${data.azurerm_subscription.current.id}/resourceGroups/rg-${...}-manuel"   # À COMPLÉTER : la variable du prénom
}

resource "azurerm_resource_group" "legacy" {
  name     = "rg-${var.prenom}-manuel"
  location = ...                                                                     # À COMPLÉTER : la variable de la région
}
```

> **Explication.**
> - `data "azurerm_subscription" "current"` **lit** la subscription courante, sans rien créer. Son `id` vaut `/subscriptions/<id>`.
> - `import` : `to` est l'adresse dans le code, `id` l'identifiant de la ressource dans Azure. Rien n'est importé avant l'`apply` : vous pouvez lire le plan d'abord.
> - Le bloc `resource` doit décrire la ressource **telle qu'elle est** : sinon le plan proposera de la modifier.

**À lancer** :

```bash
terraform init
# Le plan doit annoncer une importation, aucune création
terraform plan -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars
```

**Vérifier** : le plan annonce `1 to import, 0 to add, 0 to change, 0 to destroy`.

## Étape 4 : renommer dans le code, sans recréer

Le nom `legacy` ne vous plaît plus : vous voulez `manuel`. Renommer un bloc fait croire à Terraform qu'une ressource disparaît et qu'une autre apparaît.

**À faire** dans `main.tf` :
1. Renommez le bloc `resource "azurerm_resource_group" "legacy"` en `"manuel"`.
2. **Supprimez** le bloc `import` : l'import est fait, la ressource est dans le state, il ne sert plus.

**À compléter** à la suite, dans `main.tf` :

```hcl
moved {
  from = ...   # À COMPLÉTER : l'ancienne adresse, azurerm_resource_group puis l'ancien nom du bloc
  to   = ...   # À COMPLÉTER : la nouvelle adresse, avec le nouveau nom
}
```

> **Explication.**
> - `moved` dit à Terraform : « c'est la même ressource, elle a seulement changé d'adresse dans le code ».
> - Un `import` est un geste ponctuel : une fois la ressource dans le state, on retire le bloc. S'il restait et visait encore `legacy`, Terraform refuserait le `moved` (`Moved object still exists`).

**À lancer** :

```bash
# Le plan doit annoncer un déplacement, sans destruction
terraform plan -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars
```

**Vérifier** : le plan affiche `has moved to azurerm_resource_group.manuel` et `0 to add, 0 to change, 0 to destroy`.

## Étape 5 : lire une ressource qu'on ne gère pas

Un `data` lit une ressource existante sans jamais la modifier : ici, le resource group partagé créé par le formateur.

**À écrire** à la fin de `main.tf` : un `data "azurerm_resource_group" "shared"` dont le `name` est `rg-formation-partage`.

**À compléter** dans un nouveau fichier `outputs.tf` :

```hcl
output "manuel_id" {
  value = ...                                      # À COMPLÉTER : l'id du resource group importé
}

output "shared_resource_group" {
  value = {
    id       = data.azurerm_resource_group.shared.id
    location = ...                                 # À COMPLÉTER : la région du resource group partagé
  }
}
```

**À lancer** :

```bash
terraform apply -var-file=dev.tfvars
```

**Vérifier** : les deux outputs s'affichent, avec `swedencentral` comme région du resource group partagé.

## Étape 6 : vérifier dans le portail

1. **Resource groups** (Groupes de ressources) : `rg-<prénom>-manuel` existe toujours, avec la même date de création : il n'a jamais été recréé.
2. `rg-formation-partage` est visible, mais il n'apparaît pas dans `terraform state list` : Terraform ne fait que le lire.

## Documentation

- [Le bloc `import`](https://developer.hashicorp.com/terraform/language/import)
- [Le bloc `moved`](https://developer.hashicorp.com/terraform/language/modules/develop/refactoring)
- [Data source `azurerm_resource_group`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group)

## Questions

- Que se passerait-il au `plan` de l'étape 4 sans le bloc `moved` ?
- Pourquoi `apply` ne détruira jamais `rg-formation-partage` ?

## Pour aller plus loin

Laissez Terraform écrire lui-même le bloc `resource` d'une ressource à importer.

1. **À lancer** : un second resource group, créé à la main.

   ```bash
   az group create -n rg-<prénom>-genere -l swedencentral
   ```

2. **À écrire** dans `main.tf` : un bloc `import` seul, sans bloc `resource`, avec `to = azurerm_resource_group.genere` et l'identifiant de ce resource group.

3. **À lancer** :

   ```bash
   # Écrit dans generated.tf le bloc resource de la ressource à importer
   terraform plan -var-file=dev.tfvars -generate-config-out=generated.tf
   ```

4. Lisez `generated.tf`, puis `apply` : le plan annonce `1 to import`. Supprimez ensuite le bloc `import`, comme à l'étape 4.

> **Explication.** `-generate-config-out` ne fonctionne que pour une ressource visée par un `import` et absente du state : c'est pourquoi il faut un nouveau resource group.

---

Précédent : [TP1 : un state distant](../tp1/README.md) · Suivant : [TP3 : une identité managée avec un rôle](../tp3/README.md) · [Sommaire du jour 2](../enonce.md)
