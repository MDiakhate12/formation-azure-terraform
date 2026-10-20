variable "prenom" {
  type        = string
  description = "Votre prénom, en minuscules et sans accent : il préfixe toutes vos ressources."

  validation {
    condition     = can(regex("^[a-z]{2,12}$", var.prenom))
    error_message = "2 à 12 lettres minuscules, sans accent ni tiret."
  }
}

variable "kube_context" {
  type        = string
  description = "Contexte kubectl du cluster (output kube_context du socle). Par défaut : aks-<prénom>."
  default     = null
}
