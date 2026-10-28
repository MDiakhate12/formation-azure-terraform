# 07. Fichiers et templates

Lire des fichiers, les lister, et produire du texte à partir d'un modèle : un cloud-init, un fichier de configuration, un rapport.

## Aide-mémoire

```hcl
# Chemins
path.module                              # le dossier du fichier .tf en cours
path.root                                # le dossier où l'on lance terraform
abspath(path.module)                     # le chemin absolu
basename("donnees/equipe.csv")           # "equipe.csv"
dirname("donnees/equipe.csv")            # "donnees"
pathexpand("~/.ssh/id_rsa.pub")          # remplace ~ par le dossier personnel

# Lire
file("${path.module}/../donnees/equipe.csv")       # le contenu en texte
fileexists("${path.module}/absent.txt")            # false
filebase64("${path.module}/image.png")             # pour un fichier binaire
filesha256("${path.module}/script.sh")             # empreinte : relancer quand le fichier change

# Lister (chemins relatifs au dossier donné)
fileset("${path.module}/../donnees", "*.json")     # ["environnements.json"]
fileset("${path.module}/../donnees", "**")         # récursif
fileset("${path.module}/../donnees", "*.{json,yaml}")

# Template dans un fichier .tftpl
templatefile("${path.module}/modeles/bienvenue.txt.tftpl", {
  prenom  = "Chloé"
  societe = "Nébuleuse"
})

# Template dans une variable ou un local (le modèle doit être une référence)
local.modele = "rg-$${societe}-$${env}"       # $${ } : écrit ${ } sans l'interpréter
templatestring(local.modele, { societe = "nebuleuse", env = "dev" })   # "rg-nebuleuse-dev"
```

Les directives d'un template :

```
Bonjour ${prenom}                         interpolation
%{ if admin }Accès complet%{ else }Lecture%{ endif }
%{ for nom, s in services ~}              boucle ; ~ retire le saut de ligne voisin
- ${nom} : ${s.port}
%{ endfor ~}
```

À retenir :
- `file` et `templatefile` lisent au moment du plan : le fichier doit exister avant ;
- sans `~`, chaque ligne `%{ for }` et `%{ endfor }` laisse une ligne vide ;
- un fichier `.tftpl` se termine en général par un saut de ligne, que l'on retrouve dans le résultat (`chomp` le retire).

## Exercice

Complétez les `null` de `exercice.tf` et la ligne à compléter de `modeles/services.md.tftpl`, puis `terraform apply -auto-approve`.

Pour voir un résultat comme un vrai fichier :

```bash
terraform output -raw q05
```
