
resource "kubernetes_namespace" "mongodb_ns" {
  metadata { name = var.namespace_name }
}

resource "kubernetes_service" "mongo_service" {
  metadata {
    name = "mongo"
    namespace = kubernetes_namespace.mongodb_ns.metadata[0].name
  }
  spec {
    selector = {
      app = "mongo"
    }
    port {
      port = 27017
      target_port = 27017
      protocol = "TCP"
    }
  }
}

resource "kubernetes_secret" "mongo_secret" {
  metadata {
    name = "mongo-env"
    namespace = kubernetes_namespace.mongodb_ns.metadata[0].name
  }
  data = {
    "MONGO_INITDB_ROOT_USERNAME" = var.mongo_username
    "MONGO_INITDB_ROOT_PASSWORD" = var.mongo_password
  }
}

resource "kubernetes_stateful_set" "mongo_statefulset" {
  metadata {
    name = "mongo"
    namespace = kubernetes_namespace.mongodb_ns.metadata[0].name
    labels = { app = "mongo" }
  }
  spec {
    replicas = 1
    selector {
      match_labels = { app = "mongo" }
    }
    service_name = kubernetes_service.mongo_service.metadata[0].name
    template {
      metadata {
        labels = {
          app = "mongo"
        }
      }
      spec {
        container {
          name = "mongo"
          image = "mongo"
          volume_mount {
            mount_path = "/data/db"
            name = "vol-mongo-data"
          }
          env_from {
            secret_ref {
              name = kubernetes_secret.mongo_secret.metadata[0].name
            }
          }
          port { container_port = 27017 }
        }
        volume {
          name = "vol-mongo-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.mongodb_pvc.metadata[0].name
          }
        }
      }
    }
  }
}

