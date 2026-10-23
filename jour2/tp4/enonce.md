# TP4 : premier pipeline

**Objectif** : faire tourner `fmt`, `init` et `validate` automatiquement sur une pull request. **Durée** : 30 minutes.

Il vous faut un dépôt GitHub à vous, avec un peu de Terraform dedans (par exemple votre TP2 d'hier, ou `jour1/tp2/solution`).

## Étapes

1. Créez `.github/workflows/terraform.yml` avec un job `validate` sur `ubuntu-latest` :
   - déclenché sur `pull_request` et sur `push` vers `main` ;
   - étapes `actions/checkout@v7`, `hashicorp/setup-terraform@v4` ;
   - puis `terraform fmt -check -recursive`, `terraform init -backend=false`, `terraform validate`.
2. Poussez sur une branche et ouvrez une pull request.
3. Suivez l'exécution dans l'onglet **Actions**.
4. Cassez le format d'un fichier (indentation), poussez : le pipeline doit échouer. Corrigez avec `terraform fmt`.

## Questions

- Pourquoi `-backend=false` ?
- Le pipeline parle-t-il à Azure ? De quoi aurait-il besoin pour un `plan` ?

## Pour aller plus loin

Ajoutez un job `plan` (modèle dans `jour2/tp4/plan-job.yml`) avec les quatre secrets `ARM_*` fournis par le formateur.
