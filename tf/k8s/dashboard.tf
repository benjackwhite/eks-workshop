resource "kubernetes_service_account" "kubernetes_dashboard" {
  metadata {
    name      = "kubernetes-dashboard"
    namespace = "kube-system"

    labels = {
      k8s-app = "kubernetes-dashboard"
    }
  }
}

resource "kubernetes_role" "kubernetes_dashboard_minimal" {
  metadata {
    name      = "kubernetes-dashboard-minimal"
    namespace = "kube-system"
  }

  rule {
    verbs      = ["create"]
    api_groups = [""]
    resources  = ["secrets"]
  }

  rule {
    verbs      = ["create"]
    api_groups = [""]
    resources  = ["configmaps"]
  }

  rule {
    verbs          = ["get", "update", "delete"]
    api_groups     = [""]
    resources      = ["secrets"]
    resource_names = ["kubernetes-dashboard-key-holder"]
  }

  rule {
    verbs          = ["get", "update"]
    api_groups     = [""]
    resources      = ["configmaps"]
    resource_names = ["kubernetes-dashboard-settings"]
  }

  rule {
    verbs          = ["proxy"]
    api_groups     = [""]
    resources      = ["services"]
    resource_names = ["heapster"]
  }

  rule {
    verbs          = ["get"]
    api_groups     = [""]
    resources      = ["services/proxy"]
    resource_names = ["heapster", "http:heapster:", "https:heapster:"]
  }
}

resource "kubernetes_role_binding" "kubernetes_dashboard_minimal" {
  metadata {
    name      = "kubernetes-dashboard-minimal"
    namespace = "kube-system"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "kubernetes-dashboard"
    namespace = "kube-system"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "kubernetes-dashboard-minimal"
  }
}

resource "kubernetes_deployment" "kubernetes_dashboard" {
  metadata {
    name      = "kubernetes-dashboard"
    namespace = "kube-system"

    labels = {
      k8s-app = "kubernetes-dashboard"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        k8s-app = "kubernetes-dashboard"
      }
    }

    template {
      metadata {
        labels = {
          k8s-app = "kubernetes-dashboard"
        }
      }

      spec {
        volume {
          name = "tmp-volume"
        }

        automount_service_account_token = true

        container {
          name  = "kubernetes-dashboard"
          image = "k8s.gcr.io/kubernetes-dashboard-amd64:v1.10.1"

          args = [
            "--enable-insecure-login"
          ]

          port {
            container_port = 9090
            protocol       = "TCP"
          }

          volume_mount {
            name       = "tmp-volume"
            mount_path = "/tmp"
          }

          liveness_probe {
            http_get {
              path = "/"
              port = "9090"
            }

            initial_delay_seconds = 30
            timeout_seconds       = 30
          }
        }

        service_account_name = "kubernetes-dashboard"

        toleration {
          key    = "node-role.kubernetes.io/master"
          effect = "NoSchedule"
        }
      }
    }

    revision_history_limit = 10
  }
}

resource "kubernetes_service" "kubernetes_dashboard" {
  metadata {
    name      = "kubernetes-dashboard"
    namespace = "kube-system"

    labels = {
      k8s-app = "kubernetes-dashboard"
    }
  }

  spec {
    port {
      port        = 80
      target_port = "9090"
    }

    selector = {
      k8s-app = "kubernetes-dashboard"
    }
  }
}

