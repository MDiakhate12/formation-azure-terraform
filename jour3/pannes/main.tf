locals {
  registry = "acrformationtf.azurecr.io"
  tag      = "v1"
}

resource "kubernetes_namespace_v1" "pannes" {
  metadata {
    name = "pannes"
  }
}

resource "kubernetes_deployment_v1" "frontend" {
  wait_for_rollout = false

  metadata {
    name      = "frontend"
    namespace = kubernetes_namespace_v1.pannes.metadata[0].name
    labels    = { app = "frontend" }
  }

  spec {
    replicas = 1

    selector {
      match_labels = { app = "frontend" }
    }

    template {
      metadata {
        labels = { app = "frontend" }
      }

      spec {
        container {
          name  = "frontend"
          image = "${local.registry}/frontend:v3"

          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment_v1" "service_a" {
  wait_for_rollout = false

  metadata {
    name      = "service-a"
    namespace = kubernetes_namespace_v1.pannes.metadata[0].name
    labels    = { app = "service-a" }
  }

  spec {
    replicas = 2

    selector {
      match_labels = { app = "service-a" }
    }

    template {
      metadata {
        labels = { app = "service-a" }
      }

      spec {
        container {
          name  = "service-a"
          image = "${local.registry}/service-a:${local.tag}"

          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "frontend" {
  metadata {
    name      = "frontend"
    namespace = kubernetes_namespace_v1.pannes.metadata[0].name
  }

  spec {
    selector = { app = "frontend" }

    port {
      port        = 80
      target_port = 8080
    }
  }
}

resource "kubernetes_service_v1" "service_a" {
  metadata {
    name      = "service-a"
    namespace = kubernetes_namespace_v1.pannes.metadata[0].name
  }

  spec {
    selector = { app = "servicea" }

    port {
      port        = 8080
      target_port = 8080
    }
  }
}
