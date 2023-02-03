resource "kubernetes_deployment" "simple-client" {
  metadata {
    name = var.client_name
  }
  spec {
    replicas = 3
    selector {
      match_labels = {
        app = var.client_name
      }
    }
    template {
      metadata {
        labels = {
          app = var.client_name
        }
      }
      spec {
        container {
          image = var.client_registry
          name  = var.client_name
          port {
            container_port = var.client_port
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "simple-client" {
  metadata {
    name = var.client_name
  }
  spec {
    selector = {
      app = var.client_name
    }
    port {
      port        = var.client_port
      target_port = var.client_port
    }
    type = "NodePort"
  }
}

resource "kubernetes_ingress_v1" "alb" {
  metadata {
    name = "alb"
    annotations = {
      "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
      "alb.ingress.kubernetes.io/target-type" = "instance"
    }
  }
  spec {
    ingress_class_name = "alb"
    rule {
      http {
        path {
          backend {
            service {
              name = var.client_name
              port {
                number = var.client_port
              }
            }
          }
          path = "/*"
        }
      }
    }
  }
}
