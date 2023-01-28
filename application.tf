resource "kubernetes_config_map" "simple-server" {
  metadata {
    name = "simple-server"
  }

  data = {
    PORT = local.server_port
  }
}

resource "kubernetes_secret" "simple-server" {
  metadata {
    name = "simple-server"
  }

  data = {
    DATABASE_URL = "mysql://${var.db_username}:${var.db_password}@${aws_db_instance.rds.endpoint}/eks"
  }
}

resource "kubernetes_deployment" "simple-server" {
  metadata {
    name = local.server_name
  }
  spec {
    replicas = 3
    selector {
      match_labels = {
        app = local.server_name
      }
    }
    template {
      metadata {
        labels = {
          app = local.server_name
        }
      }
      spec {
        container {
          image = var.server_registry
          name  = local.server_name
          env_from {
            config_map_ref {
              name = "simple-server"
            }
          }
          env_from {
            secret_ref {
              name = "simple-server"
            }
          }
          port {
            container_port = local.server_port
          }
        }
        # node_selector = {
        #   tier = "backend"
        # }
      }
    }
  }
}

resource "kubernetes_service" "simple-server" {
  metadata {
    name = local.server_name
  }
  spec {
    selector = {
      app = local.server_name
    }
    port {
      port        = local.server_port
      target_port = local.server_port
    }
  }
}

resource "kubernetes_deployment" "simple-client" {
  metadata {
    name = local.client_name
  }
  spec {
    replicas = 3
    selector {
      match_labels = {
        app = local.client_name
      }
    }
    template {
      metadata {
        labels = {
          app = local.client_name
        }
      }
      spec {
        container {
          image = var.client_registry
          name  = local.client_name
          port {
            container_port = 80
          }
        }
        # node_selector = {
        #   tier = "frontend"
        # }
      }
    }
  }
}

resource "kubernetes_service" "simple-client" {
  metadata {
    name = local.client_name
  }
  spec {
    selector = {
      app = local.client_name
    }
    port {
      port        = local.client_port
      target_port = local.client_port
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
              name = local.client_name
              port {
                number = 80
              }
            }
          }
          path = "/*"
        }
      }
    }
  }
}