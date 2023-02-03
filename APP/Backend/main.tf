resource "kubernetes_config_map" "simple-server" {
  metadata {
    name = var.server_name
  }

  data = {
    PORT = var.server_port
  }
}

resource "kubernetes_secret" "simple-server" {
  metadata {
    name = var.server_name
  }

  data = {
    DATABASE_URL = "mysql://${var.db_username}:${var.db_password}@${data.terraform_remote_state.rds.outputs.rds_endpoint}/eks"
  }
}

resource "kubernetes_deployment" "simple-server" {
  metadata {
    name = var.server_name
  }
  spec {
    replicas = 3
    selector {
      match_labels = {
        app = var.server_name
      }
    }
    template {
      metadata {
        labels = {
          app = var.server_name
        }
      }
      spec {
        container {
          image = var.server_registry
          name  = var.server_name
          env_from {
            config_map_ref {
              name = var.server_name
            }
          }
          env_from {
            secret_ref {
              name = var.server_name
            }
          }
          port {
            container_port = var.server_port
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "simple-server" {
  metadata {
    name = var.server_name
  }
  spec {
    selector = {
      app = var.server_name
    }
    port {
      port        = var.server_port
      target_port = var.server_port
    }
  }
}
