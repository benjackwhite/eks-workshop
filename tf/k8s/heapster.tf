resource "kubernetes_deployment" "monitoring_influxdb" {
  metadata {
    name      = "monitoring-influxdb"
    namespace = "kube-system"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        k8s-app = "influxdb"
      }
    }

    template {
      metadata {
        labels = {
          k8s-app = "influxdb"

          task = "monitoring"
        }
      }

      spec {
        volume {
          name = "influxdb-storage"
        }

        automount_service_account_token = true

        container {
          name  = "influxdb"
          image = "k8s.gcr.io/heapster-influxdb-amd64:v1.5.2"

          volume_mount {
            name       = "influxdb-storage"
            mount_path = "/data"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "monitoring_influxdb" {
  metadata {
    name      = "monitoring-influxdb"
    namespace = "kube-system"

    labels = {
      "kubernetes.io/cluster-service" = "true"

      "kubernetes.io/name" = "monitoring-influxdb"

      task = "monitoring"
    }
  }

  spec {
    port {
      port        = 8086
      target_port = "8086"
    }

    selector = {
      k8s-app = "influxdb"
    }
  }
}

resource "kubernetes_service_account" "heapster" {
  metadata {
    name      = "heapster"
    namespace = "kube-system"
  }
}

resource "kubernetes_deployment" "heapster" {
  metadata {
    name      = "heapster"
    namespace = "kube-system"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        k8s-app = "heapster"
      }
    }

    template {
      metadata {
        labels = {
          k8s-app = "heapster"

          task = "monitoring"
        }
      }

      spec {
        automount_service_account_token = true

        container {
          name              = "heapster"
          image             = "k8s.gcr.io/heapster-amd64:v1.5.4"
          command           = ["/heapster", "--source=kubernetes:kubernetes:https://kubernetes.default?useServiceAccount=true&kubeletHttps=true&kubeletPort=10250&insecure=true", "--sink=influxdb:http://monitoring-influxdb.kube-system.svc:8086"]
          image_pull_policy = "IfNotPresent"
        }

        service_account_name = "heapster"
      }
    }
  }
}

resource "kubernetes_service" "heapster" {
  metadata {
    name      = "heapster"
    namespace = "kube-system"

    labels = {
      "kubernetes.io/cluster-service" = "true"

      "kubernetes.io/name" = "Heapster"

      task = "monitoring"
    }
  }

  spec {
    port {
      port        = 80
      target_port = "8082"
    }

    selector = {
      k8s-app = "heapster"
    }
  }
}

resource "kubernetes_cluster_role" "node_stats_full" {
  metadata {
    name = "node-stats-full"
  }

  rule {
    verbs      = ["get", "watch", "list", "create"]
    api_groups = [""]
    resources  = ["nodes/stats"]
  }
}

resource "kubernetes_cluster_role_binding" "heapster_node_stats" {
  metadata {
    name = "heapster-node-stats"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "heapster"
    namespace = "kube-system"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "node-stats-full"
  }
}

resource "kubernetes_cluster_role_binding" "heapster" {
  metadata {
    name = "heapster"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "heapster"
    namespace = "kube-system"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:heapster"
  }
}

