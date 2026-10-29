# Le kubeconfig est écrit par : az aks get-credentials (voir l'output get_credentials du socle).
provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = coalesce(var.kube_context, "aks-${var.prenom}")
}
