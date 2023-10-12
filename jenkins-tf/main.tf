resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = "jenkins"
  }
}

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


resource "helm_release" "jenkins" {
  depends_on = [
    kubernetes_deployment.registry
  ]
  name       = "jenkins"
  namespace  = kubernetes_namespace.jenkins.id
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  values     = [file("./values/values.yaml")]
  timeout    = 600
}

resource "helm_release" "jenkins2" {

  name       = "jenkins"
  # namespace  = kubernetes_namespace.jenkins.id
  repository = "https://charts.jenkins.io"
  chart      = "stable/jenkins"
  # values     = [file("./values/values.yaml")]
  timeout    = 600
  set {
    name = "JENKINS_USER"
    value = "admin"
  }
    set {
    name = "JENKINS_PASS"
    value = "admin1234"
  }
}

# resource "kubernetes_service_account" "jenkins" {
#   depends_on = [
#     kubernetes_namespace.jenkins
#   ]
#   metadata {
#     name      = "jenkins"
#     namespace  = kubernetes_namespace.jenkins.id
#   }
# }

# resource "kubernetes_cluster_role" "jenkins" {
#   metadata {
#     name = "jenkins"
#     annotations = {
#       "rbac.authorization.kubernetes.io/autoupdate" = "true"
#     }
#     labels = {
#       "kubernetes.io/bootstrapping" = "rbac-defaults"
#     }
#   }
#   rule {
#     api_groups = ["*"]
#     resources = [
#       "statefulsets", "services", "replicationcontrollers", "replicasets", "podtemplates",
#       "podsecuritypolicies", "pods", "pods/log", "pods/exec", "podpreset", "poddisruptionbudget",
#       "persistentvolumes", "persistentvolumeclaims", "jobs", "endpoints", "deployments",
#       "deployments/scale", "daemonsets", "cronjobs", "configmaps", "namespaces", "events", "secrets"
#     ]
#     verbs = ["create", "get", "watch", "delete", "list", "patch", "update"]
#   }
#   rule {
#     api_groups = [""]
#     resources  = ["nodes"]
#     verbs      = ["get", "list", "watch", "update"]
#   }
# }

# resource "kubernetes_cluster_role_binding" "jenkins" {
#   metadata {
#     name = "jenkins"
#     annotations = {
#       "rbac.authorization.kubernetes.io/autoupdate" = "true"
#     }
#     labels = {
#       "kubernetes.io/bootstrapping" = "rbac-defaults"
#     }
#   }
#   role_ref {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "ClusterRole"
#     name      = "jenkins"
#   }
#   subject {
#     kind      = "Group"
#     name      = "system:serviceaccounts:jenkins"
#     api_group = "rbac.authorization.k8s.io"
#   }
# }