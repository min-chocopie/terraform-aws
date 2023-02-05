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
          resources {
            requests = {
              cpu = "250m" # 0.25vCPU
            }
            limits = {
              cpu = "250m"
            }
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

resource "kubernetes_horizontal_pod_autoscaler" "simple-client" {
  metadata {
    name = var.client_name
  }

  spec {
    max_replicas = 10
    min_replicas = 3

    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = var.client_name
    }

    target_cpu_utilization_percentage = 70
  }
}