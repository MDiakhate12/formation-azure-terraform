# Bonus 2 : une infrastructure en équipe

[Sommaire du jour 2](../enonce.md) · [Se connecter à Azure](../enonce.md#avant-de-commencer)

**Objectif** : construire **à plusieurs** une même infrastructure, avec un code commun sur git et un state commun sur Azure. **Durée** : 30 minutes.
**Dossier de travail** : le dépôt d'équipe, cloné à côté de celui de la formation.

## Où on en est, où on va

Jusqu'ici, chacun avait son code et son state. En entreprise, une équipe partage les deux : c'est là que naissent les vraies difficultés.
Le formateur a posé un serveur Azure SQL. Chacun va y ajouter **sa** base, comme les couches d'un lakehouse :

| Couche | Qui | Fichier |
|---|---|---|
| `bronze` (données brutes) | Titouan | `bronze.tf` |
| `silver` (données nettoyées) | Alain | `silver.tf` |
| `gold` (données prêtes à l'usage) | Jean-Erwan | `gold.tf` |

Vous allez vivre trois situations réelles : le **verrou**, le **code pas à jour**, et le **module partagé**.

## Étape 1 : cloner le dépôt d'équipe et l'initialiser

Acceptez d'abord l'invitation GitHub reçue par e-mail : elle vous donne le droit de pousser sur le dépôt.

**À lancer** :

```bash
# À côté du dépôt de la formation, pas dedans
cd ..
git clone https://github.com/MDiakhate12/formation-equipe-sql.git
cd formation-equipe-sql
# Le backend pointe vers le state commun : il est téléchargé, pas créé
terraform init
terraform plan
```

**Vérifier** : `No changes`. Vous n'avez rien créé, mais Terraform connaît déjà le serveur : il lit le **même state** que le formateur.

## Étape 2 : écrire votre base

Chacun dans **son** fichier : deux personnes ne modifient jamais le même, ce qui évite les conflits git.

**À écrire**, d'après la documentation de [`azurerm_mssql_database`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_database) :

| Spec | Valeur |
|---|---|
| Ressource | `azurerm_mssql_database`, nommée dans le code comme votre couche (`bronze`, `silver` ou `gold`) |
| Nom dans Azure | `db-<couche>` |
| Serveur | Le serveur de `main.tf`, **par référence** |
| Taille | `sku_name = "Basic"`, `max_size_gb = 2` (la moins chère) |
| Tag | `owner` = votre prénom |
| Output | `<couche>_id` : l'identifiant de votre base |

**N'appliquez pas encore** : on avance à tour de rôle.

## Étape 3 : le verrou

Personne n'a encore rien créé. Titouan et Jean-Erwan lancent `terraform apply` **en même temps**, et ne répondent pas à la question.

**Vérifier** : l'un des deux obtient `Error acquiring the state lock`. Lisez le message : il dit **qui** tient le verrou et **depuis quand**.
L'autre lit son plan, qui n'annonce que **sa** base, puis répond `no` : le verrou est libéré.

## Étape 4 : Titouan applique et publie

**À lancer** (Titouan) :

```bash
terraform plan
terraform apply
git add bronze.tf
git commit -m "Base bronze"
git push
```

**Vérifier** : le plan annonce `1 to add`. Dans le portail, `rg-equipe-sql`, le serveur `sql-equipe-...`, menu **SQL databases** : `db-bronze`.

## Étape 5 : le code pas à jour

Alain n'a pas encore récupéré le travail de Titouan.

**À lancer** (Alain, **sans** `git pull`) :

```bash
terraform plan
```

**Vérifier** : le plan veut **créer** `silver`… et **détruire** `bronze`. N'appliquez surtout pas.

> **Explication.** Le state sait que `bronze` existe, mais le code d'Alain ne le décrit pas : pour Terraform, une ressource absente du code est une ressource à supprimer.
> Un state partagé exige un code partagé **et à jour**.

**À lancer** (Alain) :

```bash
# Récupère bronze.tf
git pull
# Ne crée plus que silver
terraform plan
terraform apply
git add silver.tf
git commit -m "Base silver"
git push
```

`git push` refusé (`rejected`, `fetch first`) ? Quelqu'un a poussé entre-temps : `git pull --rebase`, puis `git push`.

## Étape 6 : Jean-Erwan termine

**À lancer** (Jean-Erwan) : `git pull`, `terraform plan` (qui ne doit annoncer que `gold`), `apply`, puis `git add`, `commit` et `push` de `gold.tf`.

**Vérifier** : après un `git pull`, `terraform plan` affiche `No changes` **chez tout le monde**. Le code, le state et Azure sont alignés.

## Étape 7 : le module, depuis git (démonstration du formateur)

Le dossier `modules/sql` du dépôt décrit le même lakehouse : un serveur et une base par couche. Le formateur le marque d'une version, puis l'appelle depuis un autre dossier, **par son URL git** :

```hcl
module "lakehouse" {
  source = "git::https://github.com/MDiakhate12/formation-equipe-sql.git//modules/sql?ref=v1"
  # ...
}
```

> **Explication.** `//modules/sql` désigne le sous-dossier du dépôt, `?ref=v1` le tag git. Avec un tag, la configuration ne change pas quand le dépôt évolue : on choisit quand passer à `v2`.

## Étape 8 : tout détruire

Le formateur lance `terraform destroy` dans le dépôt d'équipe.

**Vérifier** : **les trois bases** et le serveur disparaissent, d'un seul geste.

## Questions

- Pourquoi le plan d'Alain voulait-il détruire `bronze` ?
- Que protège le verrou, et que ne protège-t-il pas ?
- Pourquoi un fichier par personne ?
- Pourquoi `?ref=v1` dans l'URL du module ?
- Une seule personne a tout détruit : comment l'éviter en entreprise ?

---

Précédent : [Bonus : un pipeline sans secret (OIDC)](../bonus/README.md) · [Sommaire du jour 2](../enonce.md)
