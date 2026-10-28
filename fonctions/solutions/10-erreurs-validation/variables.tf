variable "environnement" {
  type    = string
  default = "dev"

  validation {
    condition     = contains(["dev", "recette", "prod"], var.environnement)
    error_message = "environnement doit valoir dev, recette ou prod."
  }
}

variable "nouveau_service" {
  type = object({
    nom      = string
    port     = optional(number, 80)
    replicas = optional(number, 1)
  })
  default = {
    nom = "paiement"
  }
}
