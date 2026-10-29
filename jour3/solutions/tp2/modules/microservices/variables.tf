variable "namespace" {
  type        = string
  description = "Namespace où déployer l'application"
}

variable "prenom" {
  type        = string
  description = "Sert à l'étiquette DNS du frontend"
}

variable "registry" {
  type        = string
  description = "Adresse du registre, par exemple acrformationtf.azurecr.io"
}

variable "tag" {
  type        = string
  description = "Tag des trois images : v1 ou v2"
  default     = "v1"
}

variable "replicas" {
  type        = number
  description = "Réplicas du frontend et du service A (le service B reste à 1 : son volume ne se partage pas)"
  default     = 2
}

variable "dns_label_enabled" {
  type        = bool
  description = "Donne au frontend le nom tf-<prénom>.<région>.cloudapp.azure.com"
  default     = false
}

variable "location" {
  type        = string
  description = "Région du cluster : elle fait partie du nom DNS fourni par Azure"
  default     = "swedencentral"
}

variable "node_selector" {
  type        = map(string)
  description = "Labels des nœuds sur lesquels placer les pods, par exemple { role = \"apps\" }"
  default     = {}
}
