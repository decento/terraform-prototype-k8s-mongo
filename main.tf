# local environment
variable "storage_class_name" { default="local-path" }
variable "namespace_name" { default = "mongodb" }
variable "mongo_username" { default = "mongo-admin" }
variable "mongo_password" { default = "password123" }
variable "mongo_express_url" { default = "https://mongodb.local" }
variable "mongo_express_username" { default = "admin" }
variable "mongo_express_password" { default = "admin" }

# docker desktop Kubernetes API server ~ change as needed
provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "docker-desktop"
}
