resource "kubernetes_service_account" "external_dns" {
  metadata {
    name      = "external-dns"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role" "external_dns" {
  metadata {
    name = "external-dns"
  }

  rule {
    verbs      = ["get", "watch", "list"]
    api_groups = [""]
    resources  = ["services"]
  }

  rule {
    verbs      = ["get", "watch", "list"]
    api_groups = [""]
    resources  = ["pods"]
  }

  rule {
    verbs      = ["get", "watch", "list"]
    api_groups = ["extensions"]
    resources  = ["ingresses"]
  }

  rule {
    verbs      = ["list", "watch"]
    api_groups = [""]
    resources  = ["nodes"]
  }
}

resource "kubernetes_cluster_role_binding" "external_dns_viewer" {
  metadata {
    name = "external-dns-viewer"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "external-dns"
    namespace = "kube-system"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "external-dns"
  }
}

resource "kubernetes_deployment" "external_dns" {
  metadata {
    name      = "external-dns"
    namespace = "kube-system"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "external-dns"
      }
    }

    template {
      metadata {
        labels = {
          app = "external-dns"
        }
      }


      spec {

        automount_service_account_token = true

        container {
          name  = "external-dns"
          image = "registry.opensource.zalan.do/teapot/external-dns:latest"
          args = [
            "--source=service",
            "--source=ingress",
            "--domain-filter=${var.main_domain}",
            "--provider=aws",
            "--policy=upsert-only",
            "--aws-zone-type=public",
            "--registry=txt",
            "--txt-owner-id=${var.zone_id}"
          ]
        }

        service_account_name = "external-dns"
      }
    }

    strategy {
      type = "Recreate"
    }
  }
}

