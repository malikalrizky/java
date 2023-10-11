resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = "jenkins"
  }
}

resource "kubernetes_service_account" "jenkins" {
  depends_on = [
    kubernetes_namespace.jenkins
  ]
  metadata {
    name      = "jenkins"
    namespace  = kubernetes_namespace.jenkins.id
  }
}

resource "kubernetes_cluster_role" "jenkins" {
  metadata {
    name = "jenkins"
    annotations = {
      "rbac.authorization.kubernetes.io/autoupdate" = "true"
    }
    labels = {
      "kubernetes.io/bootstrapping" = "rbac-defaults"
    }
  }
  rule {
    api_groups = ["*"]
    resources = [
      "statefulsets", "services", "replicationcontrollers", "replicasets", "podtemplates",
      "podsecuritypolicies", "pods", "pods/log", "pods/exec", "podpreset", "poddisruptionbudget",
      "persistentvolumes", "persistentvolumeclaims", "jobs", "endpoints", "deployments",
      "deployments/scale", "daemonsets", "cronjobs", "configmaps", "namespaces", "events", "secrets"
    ]
    verbs = ["create", "get", "watch", "delete", "list", "patch", "update"]
  }
  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["get", "list", "watch", "update"]
  }
}

resource "kubernetes_cluster_role_binding" "jenkins" {
  metadata {
    name = "jenkins"
    annotations = {
      "rbac.authorization.kubernetes.io/autoupdate" = "true"
    }
    labels = {
      "kubernetes.io/bootstrapping" = "rbac-defaults"
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.jenkins.metadata[0].name
  }
  subject {
    kind      = "Group"
    name      = "system:serviceaccounts:jenkins"
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "helm_release" "jenkins" {
  depends_on = [
    kubernetes_service_account.jenkins
  ]
  name       = "jenkins"
  namespace  = kubernetes_namespace.jenkins.id
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  values     = [file("./values/values.yaml")]
  timeout    = 600
}