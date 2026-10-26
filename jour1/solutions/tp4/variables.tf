variable "prenom" {
  type        = string
  description = "Votre prénom, en minuscules et sans accent : il préfixe toutes vos ressources."

  validation {
    condition     = can(regex("^[a-z]{2,12}$", var.prenom))
    error_message = "2 à 12 lettres minuscules, sans accent ni tiret."
  }
}

variable "location" {
  type        = string
  description = "Région Azure"
  default     = "swedencentral"
}

variable "environment" {
  type        = string
  description = "Nom de l'environnement"
  default     = "dev"

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Valeurs permises : dev ou prod."
  }
}

variable "address_space" {
  type        = list(string)
  description = "Plage d'adresses du VNet"
  default     = ["10.0.0.0/16"]
}

variable "nsg_rules" {
  type = map(object({
    priority = number
    port     = string
    access   = string
  }))
  description = "Règles entrantes du NSG de snet-app, indexées par leur nom"
  default = {
    allow-https = { priority = 100, port = "443", access = "Allow" }
    deny-ssh    = { priority = 200, port = "22", access = "Deny" }
  }
}

variable "enable_data_nsg" {
  type        = bool
  description = "Crée un NSG pour snet-data"
  default     = false
}
