resource "kubernetes_service" "mongo_express_service" {
  metadata {
    name = "mongo-express"
    namespace = kubernetes_namespace.mongodb_ns.metadata[0].name
  }
  spec {
    selector = {
      app = "mongo-express"
    }
    port {
      port = 8081
      target_port = 8081
      protocol = "TCP"
    }
  }
}

resource "kubernetes_secret" "mongo_express_secret" {
  metadata {
    name = "mongo-express-env"
    namespace = kubernetes_namespace.mongodb_ns.metadata[0].name
  }
  data = {
    "ME_CONFIG_MONGODB_SERVER" = kubernetes_service.mongo_service.metadata[0].name
    "ME_CONFIG_MONGODB_ADMINUSERNAME" = var.mongo_username
    "ME_CONFIG_MONGODB_ADMINPASSWORD" = var.mongo_password
    "ME_CONFIG_BASICAUTH_USERNAME" = var.mongo_express_username
    "ME_CONFIG_BASICAUTH_PASSWORD" = var.mongo_express_password
  }
}

resource "kubernetes_deployment" "mongo_express_deployment" {
  metadata {
    name = "mongo-express"
    namespace = kubernetes_namespace.mongodb_ns.metadata[0].name
    labels = {
          app = "mongo-express"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "mongo-express"
      }
    }
    template {
      metadata {
        labels = {
          app = "mongo-express"
        }
      }
      spec {
        container {
          name = "mongo-express"
          image = "mongo-express"
          env_from {
            secret_ref {
              name = kubernetes_secret.mongo_express_secret.metadata[0].name
            }
          }
          port {
            container_port = 8081
          }
        }
      }
    }
  }
}

resource "kubernetes_ingress_v1" "mongo_express_ingress" {
  metadata {
    name = "mongo-express-ingress"
    namespace = var.namespace_name
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      http {
        path {
          path = "/"
          backend {
            service {
              name = kubernetes_service.mongo_express_service.metadata[0].name
              port {
                number = 8081
              }
            }
          }
        }
      }
      host = split("//", var.mongo_express_url)[1]
    }
    tls {
      hosts = [ split("//", var.mongo_express_url)[1]  ]
    }
  }
}
