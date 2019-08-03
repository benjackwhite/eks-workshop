resource "kubernetes_ingress" "kube-dashboard-ingress" {
  metadata {
    name      = "kubernetes-dashboard"
    namespace = "kube-system"
  }

  spec {
    rule {
      host = "dashboard.${var.main_domain}"

      http {
        path {
          path = "/"

          backend {
            service_name = "kubernetes-dashboard"
            service_port = "80"
          }
        }
      }
    }
  }
}

