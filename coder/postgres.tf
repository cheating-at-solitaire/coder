# Minimal Postgres for local/dev use only. Not sized, backed up, or
# hardened for anything beyond a single-node WSL dev cluster.

resource "kubernetes_persistent_volume_claim" "postgres" {
  count = var.deploy_inbuilt_postgres ? 1 : 0

  metadata {
    name      = "coder-postgres-data"
    namespace = kubernetes_namespace.coder.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "5Gi"
      }
    }
  }
}

resource "kubernetes_secret" "postgres" {
  count = var.deploy_inbuilt_postgres ? 1 : 0

  metadata {
    name      = "coder-postgres-credentials"
    namespace = kubernetes_namespace.coder.metadata[0].name
  }
  data = {
    POSTGRES_USER     = "coder"
    POSTGRES_PASSWORD = var.postgres_password
    POSTGRES_DB       = "coder"
  }
  type = "Opaque"
}

resource "kubernetes_deployment" "postgres" {
  count = var.deploy_inbuilt_postgres ? 1 : 0

  metadata {
    name      = "coder-postgres"
    namespace = kubernetes_namespace.coder.metadata[0].name
    labels    = { app = "coder-postgres" }
  }
  spec {
    replicas = 1
    selector {
      match_labels = { app = "coder-postgres" }
    }
    strategy {
      type = "Recreate"
    }
    template {
      metadata {
        labels = { app = "coder-postgres" }
      }
      spec {
        container {
          name  = "postgres"
          image = "postgres:16"

          env_from {
            secret_ref {
              name = kubernetes_secret.postgres[0].metadata[0].name
            }
          }

          port {
            container_port = 5432
          }

          volume_mount {
            name       = "data"
            mount_path = "/var/lib/postgresql/data"
            sub_path   = "postgres"
          }
        }
        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.postgres[0].metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "postgres" {
  count = var.deploy_inbuilt_postgres ? 1 : 0

  metadata {
    name      = "coder-postgres"
    namespace = kubernetes_namespace.coder.metadata[0].name
  }
  spec {
    selector = { app = "coder-postgres" }
    port {
      port        = 5432
      target_port = 5432
    }
  }
}

locals {
  # In-cluster DSN, only valid when deploy_inbuilt_postgres = true
  inbuilt_postgres_url = var.deploy_inbuilt_postgres ? "postgresql://coder:${var.postgres_password}@coder-postgres.${var.coder_namespace}.svc.cluster.local:5432/coder?sslmode=disable" : ""

  effective_postgres_url = var.deploy_inbuilt_postgres ? local.inbuilt_postgres_url : var.postgres_url
}
