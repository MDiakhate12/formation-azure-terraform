# Jour 2 : solutions

Chaque dossier est autonome. Remplacez `prenom` dans `dev.tfvars`, puis `terraform init` et `terraform plan -var-file=dev.tfvars`.
Les TP2 et TP5 lisent `rg-formation-partage` et `acrformationtf`, créés par le bootstrap du formateur.

## TP1

- Plan initial : 3 ressources.
- `backend.tf` n'est ajouté qu'après le premier `apply` : le stockage doit exister avant d'y écrire le state.
- Après la migration, le `terraform.tfstate` local est vide et un `terraform.tfstate.backup` reste : le state vit dans le blob `jour2.tfstate`.
- Verrou : `Error acquiring the state lock`, avec l'identifiant du verrou et son auteur. `terraform force-unlock <id>` existe, à n'utiliser que si personne ne travaille.

## TP2

- Sans `moved`, le plan détruirait `legacy` et créerait `manuel`, donc supprimerait puis recréerait le resource group.
- Le bloc `import` est supprimé une fois l'import fait. S'il restait en visant `legacy`, le `moved` échouerait (`Moved object still exists`).
- Pour aller plus loin : `-generate-config-out` n'écrit du code que pour une ressource visée par un `import` et absente du state, d'où le second resource group `rg-<prénom>-genere`. Le faire supprimer ensuite (`terraform destroy` ou `az group delete`).
- Un `data` ne fait que lire : `rg-formation-partage` n'est pas dans le state, `destroy` ne le connaît pas.

## TP3

- Plan : 3 ressources.
- L'identité n'a pas de mot de passe : Azure lui délivre des jetons courts.
- `principal_id` : l'objet dans Entra ID, à qui l'on donne des rôles. `client_id` : l'identifiant utilisé pour se connecter.
- Retirer l'attribution : le plan annonce 1 to destroy, l'identité reste.
- `Contributor` est refusé (`AuthorizationFailed`) : la condition posée par le formateur limite les rôles attribuables.

## TP4

- `-backend=false` : le pipeline n'a pas d'accès Azure, il vérifie seulement la syntaxe et les providers.
- Pour un `plan`, il faut une identité Azure : un service principal avec secret (`plan-job.yml`) ou, mieux, OIDC (bonus).

## TP5

- Plan : 2 ressources (resource group et cluster), plus la lecture du registre.
- Les nœuds sont dans un second resource group créé par AKS : `MC_rg-<prénom>-aks_aks-<prénom>_swedencentral`.
- `node_count` de 1 à 2 : modification en place (`~`), un nœud est ajouté, le cluster n'est pas recréé.

## Bonus OIDC

- Plan : 5 ressources.
- `az group list` ne montre que `rg-<prénom>-oidc` : le rôle de lecture (`Lecteur formation`) est limité à ce resource group.
- Depuis une autre branche, la connexion échoue (`AADSTS700213`, avec le subject reçu dans le message) : le `subject` du jeton ne correspond à aucune identité fédérée.

## Bonus OIDC, pour aller plus loin : plan et apply depuis le pipeline

- Plan local de `pipeline.tf` : 2 ressources (les deux attributions de rôle). Le `plan` du pipeline annonce 1 ressource, l'`apply` après fusion la crée.
- Le state ne peut pas rester local : chaque exécution démarre sur un runner neuf, le fichier serait perdu à la fin du job.
- L'identité ne peut rien créer hors de `rg-<prénom>-oidc` : son rôle « Contributeur formation » est attribué sur ce seul resource group. Moindre privilège.
- Storage Blob Data Contributor sur le seul conteneur `oidc` : l'identité lit et verrouille son state sans clé de stockage (`ARM_USE_AZUREAD`), et ne peut pas toucher au compte.
- Nettoyage dans l'ordre : `destroy` dans `ci/` d'abord (ressource créée par le pipeline, inconnue du state local), puis dans `jour2/bonus/`. Sinon le resource group refuse d'être supprimé : il contient encore une ressource.

## Bonus 2 : une infrastructure en équipe

- `terraform plan` affiche `No changes` dès le clone : le backend pointe vers le state commun, qui connaît déjà le serveur.
- Le plan d'Alain voulait détruire `bronze` : la ressource est dans le state mais absente de son code. Pour Terraform, absent du code signifie à supprimer. D'où la règle : `git pull` avant chaque `plan`.
- Le verrou empêche deux écritures simultanées dans le state. Il ne protège pas d'un code périmé : Alain aurait pu détruire `bronze` sans aucun conflit de verrou.
- Un fichier par personne évite les conflits git : chacun modifie le sien, les fusions sont automatiques.
- `?ref=v1` fige la version du module : le dépôt peut évoluer sans changer ceux qui l'utilisent.
- En entreprise : `apply` réservé au pipeline après relecture du plan en pull request, states séparés par équipe ou par composant, droits limités, verrou de suppression sur les ressources critiques.

