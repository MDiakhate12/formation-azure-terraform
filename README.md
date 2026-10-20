# Formation Azure Terraform : Infrastructure Automation

Classe virtuelle du 26 au 28 octobre 2026, 9h-17h. Supports et code des TP.

**Avant le premier jour : préparez votre poste avec [PREREQUIS.md](PREREQUIS.md).**

Supports de cours : <https://mdiakhate12.github.io/formation-azure-terraform/>

| Jour | Chapitres | Fil rouge |
|---|---|---|
| J1 | Introduction, HCL, réseau, modules | Resource group, VNet, sous-réseaux, NSG, puis un module réseau |
| J2 | Terraform en profondeur, AKS | State distant, import et moved, identités, pipeline GitHub Actions, cluster AKS |
| J3 | Exploiter AKS, troubleshooting | Application sur AKS, Service LoadBalancer, volume, autoscaler, montée de version, pannes |

## Organisation

Chaque jour est autonome : le code du jour N+1 ne dépend pas de votre travail de la veille.

| Dossier | Contenu |
|---|---|
| `jourN/enonce/` | Les consignes de chaque TP, à suivre dans votre propre dossier de travail |
| `jourN/solution/` | Vide au départ : chaque solution est publiée juste après sa correction (`git pull`) |
| `jourN/bonus/` | Un TP supplémentaire pour les plus rapides |
| `jour3/socle`, `jour3/app`, `jour3/pannes` | Le code fourni du jour 3 |
| `docs/` | Les supports de cours publiés |
