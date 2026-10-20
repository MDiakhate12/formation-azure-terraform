variable "prenom" {
  type        = string
  description = "Votre prénom, en minuscules et sans accent : il préfixe toutes vos ressources."

  validation {
    condition     = can(regex("^[a-z]{2,12}$", var.prenom))
    error_message = "2 à 12 lettres minuscules, sans accent ni tiret."
  }
}

variable "location" {
  type    = string
  default = "westeurope"
}

variable "kubernetes_version" {
  type        = string
  description = "Une mineure avant la dernière, pour pratiquer la montée de version au TP3"
  default     = "1.35"
}
