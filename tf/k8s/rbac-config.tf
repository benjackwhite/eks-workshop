resource "kubernetes_service_account" "eks_admin" {
  metadata {
    name      = "eks-admin"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role_binding" "eks_admin" {
  metadata {
    name = "eks-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "eks-admin"
    namespace = "kube-system"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
}


resource "kubernetes_role" "workshop_administrator" {
  metadata {
    name      = "workshop-administrator"
    namespace = "default"
  }

  rule {
    verbs      = ["*"]
    api_groups = ["", "extensions", "apps", "batch", "rbac.authorization.k8s.io"]
    resources  = ["*"]
  }
}

resource "kubernetes_cluster_role" "workshop_administrator_cluster_role" {
  metadata {
    name = "workshop-administrator-cluster-role"
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["nodes", "namespaces", "persistentvolumes"]
  }
}


resource "kubernetes_service_account" "workshop_administrator" {
  metadata {
    name      = "workshop-administrator"
    namespace = "default"
  }
}

resource "kubernetes_role_binding" "workshop_administrator_binding" {
  metadata {
    name      = "workshop-administrator-binding"
    namespace = "default"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "workshop-administrator"
    namespace = "default"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "workshop-administrator"
  }
}

resource "kubernetes_cluster_role_binding" "workshop_administrator_cluster_binding" {
  metadata {
    name = "workshop-administrator-cluster-binding"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "workshop-administrator"
    namespace = "default"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "workshop-administrator-cluster-role"
  }
}

resource "kubernetes_role" "workshop_viewer" {
  metadata {
    name      = "workshop-viewer"
    namespace = "default"
  }

  rule {
    verbs      = ["get", "list"]
    api_groups = ["", "extensions", "apps", "batch"]
    resources  = ["*"]
  }
}

resource "kubernetes_service_account" "workshop_viewer" {
  metadata {
    name      = "workshop-viewer"
    namespace = "default"
  }
}

resource "kubernetes_role_binding" "workshop_viewer_binding" {
  metadata {
    name      = "workshop-viewer-binding"
    namespace = "default"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "workshop-viewer"
    namespace = "default"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "workshop-viewer"
  }
}

