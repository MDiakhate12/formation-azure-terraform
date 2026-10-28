# Solution du thème 09.
locals {
  q01 = cidrsubnet(local.environnements.dev.espace_adresses, 8, 1)
  q02 = zipmap(["gateway", "bastion", "aks"], cidrsubnets(local.environnements.prod.espace_adresses, 8, 8, 4))
  q03 = cidrhost("10.10.1.0/24", 4)
  q04 = cidrnetmask(local.environnements.dev.espace_adresses)
  q05 = { for env, e in local.environnements : env => cidrsubnet(e.espace_adresses, 8, 1) }
  q06 = pow(2, 32 - 24) - 5

  nom = "nebuleuse-dev"
  q07 = "st${replace(local.nom, "-", "")}${substr(sha256(local.nom), 0, 6)}"

  q08 = uuidv5("dns", "frontend.nebuleuse.fr")
}
