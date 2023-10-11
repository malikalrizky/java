resource "kubernetes_namespace" "registry" {
  metadata {
    name = "registry"
  }
}

resource "kubernetes_service" "registry" {
  depends_on = [
    kubernetes_namespace.registry
  ]
  metadata {
    namespace  = kubernetes_namespace.registry.id
    name   = "registry"
    labels = {
      app = "registry"
    }
  }

  spec {
    port {
      port        = 5000
      target_port = 5000
      node_port   = 30400
      name        = "registry"
    }

    selector = {
      app = "registry"
    }

    type = "NodePort"
  }
}

resource "kubernetes_service" "registry_ui" {
  depends_on = [
    kubernetes_namespace.registry
  ]
  metadata {
    namespace  = kubernetes_namespace.registry.id
    name   = "registry-ui"
    labels = {
      app = "registry"
    }
  }

  spec {
    port {
      port        = 8080
      target_port = 8080
    }

    selector = {
      app = "registry"
    }

    type = "NodePort"
  }
}

resource "kubernetes_deployment" "registry" {
  depends_on = [
    kubernetes_namespace.registry
  ]
  metadata {
    namespace  = kubernetes_namespace.registry.id
    name   = "registry"
    labels = {
      app = "registry"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "registry"
      }
    }

    strategy {
      type = "Recreate"
    }

    template {
      metadata {
        labels = {
          app = "registry"
        }
      }

      spec {
        container {
          image = "registry:2"
          name  = "registry"

          port {
            container_port = 5000
            name           = "registry"
          }

          volume_mount {
            name       = "docker"
            mount_path = "/var/run/docker.sock"
          }
        }

        container {
          image = "hyper/docker-registry-web"
          name  = "registryui"

          port {
            container_port = 5000
          }

          env {
            name  = "REGISTRY_URL"
            value = "http://localhost:5000/v2"
          }

          env {
            name  = "REGISTRY_NAME"
            value = "cluster-registry"
          }
        }

        volume {
          name = "docker"

          host_path {
            path = "/var/run/docker.sock"
          }
        }
      }
    }
  }
}
