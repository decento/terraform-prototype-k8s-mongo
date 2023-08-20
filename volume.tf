# use host dir for persistent volume
resource "kubernetes_persistent_volume" "mongodb_vol" {
  metadata { name = "mongodb-vol" }
  spec {
    access_modes = ["ReadWriteOnce"]
    capacity = {
      storage = "1Gi"
    }
    persistent_volume_source {
      host_path {
        path = "/tmp/mongodb"
      }
    }
    storage_class_name = var.storage_class_name
  }
}

# create pvc
resource "kubernetes_persistent_volume_claim" "mongodb_pvc" {
  metadata {
    name = "mongodb-pvc"
    namespace = var.namespace_name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
    volume_name = kubernetes_persistent_volume.mongodb_vol.metadata[0].name
    storage_class_name = var.storage_class_name
  }
}