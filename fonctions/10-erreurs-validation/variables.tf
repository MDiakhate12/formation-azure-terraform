variable "environnement" {
  type    = string
  default = "dev"

  # Partie 2 : ajoutez ici un bloc validation.
}

variable "nouveau_service" {
  # Q06 : écrivez le type, un objet dont port (80) et replicas (1) sont facultatifs.
  default = {
    nom = "paiement"
  }
}
