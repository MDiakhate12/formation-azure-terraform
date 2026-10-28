# Aucun provider à télécharger. Le provider « terraform » est intégré à Terraform :
# il apporte les fonctions provider::terraform::*. Un terraform init suffit.
terraform {
  required_version = ">= 1.15.0"

  required_providers {
    terraform = {
      source = "terraform.io/builtin/terraform"
    }
  }
}
