; TODO: see config docs for digitalocean 
terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.30.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.23.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = "~> 2.11.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

# Create a Digital Ocean Kubernetes cluster
resource "digitalocean_kubernetes_cluster" "leap25_cluster" {
  name     = "leap25-${var.environment}"
  region   = var.region
  version  = var.kubernetes_version
  
  node_pool {
    name       = "worker-pool"
    size       = var.node_size
    auto_scale = true
    min_nodes  = var.min_nodes
    max_nodes  = var.max_nodes
  }
}

# Configure providers with cluster credentials
provider "kubernetes" {
  host                   = digitalocean_kubernetes_cluster.leap25_cluster.endpoint
  token                  = digitalocean_kubernetes_cluster.leap25_cluster.kube_config[0].token
  cluster_ca_certificate = base64decode(digitalocean_kubernetes_cluster.leap25_cluster.kube_config[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = digitalocean_kubernetes_cluster.leap25_cluster.endpoint
    token                  = digitalocean_kubernetes_cluster.leap25_cluster.kube_config[0].token
    cluster_ca_certificate = base64decode(digitalocean_kubernetes_cluster.leap25_cluster.kube_config[0].cluster_ca_certificate)
  }
}

# Create a managed MySQL database
resource "digitalocean_database_cluster" "mysql" {
  name       = "leap25-mysql-${var.environment}"
  engine     = "mysql"
  version    = "8"
  size       = var.db_size
  region     = var.region
  node_count = var.environment == "production" ? 2 : 1
}

# Create a database
resource "digitalocean_database_db" "leap25_db" {
  cluster_id = digitalocean_database_cluster.mysql.id
  name       = "leap25_${var.environment}"
}

# Create a database user
resource "digitalocean_database_user" "leap25_user" {
  cluster_id = digitalocean_database_cluster.mysql.id
  name       = "leap25user"
}

# Create a Redis cluster
resource "digitalocean_database_cluster" "redis" {
  name       = "leap25-redis-${var.environment}"
  engine     = "redis"
  version    = "7"
  size       = var.redis_size
  region     = var.region
  node_count = var.environment == "production" ? 2 : 1
}

# Install ingress-nginx with Helm
resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "ingress-nginx"
  create_namespace = true
  
  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }
}

# Install cert-manager with Helm
resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "cert-manager"
  create_namespace = true
  
  set {
    name  = "installCRDs"
    value = "true"
  }
}

# Install sealed-secrets with Helm
resource "helm_release" "sealed_secrets" {
  name       = "sealed-secrets"
  repository = "https://bitnami-labs.github.io/sealed-secrets"
  chart      = "sealed-secrets"
  namespace  = "kube-system"
}

# Output details for connection
output "kubernetes_cluster_name" {
  value = digitalocean_kubernetes_cluster.leap25_cluster.name
}

output "kubernetes_endpoint" {
  value = digitalocean_kubernetes_cluster.leap25_cluster.endpoint
  sensitive = true
}

output "kubeconfig" {
  value     = digitalocean_kubernetes_cluster.leap25_cluster.kube_config[0].raw_config
  sensitive = true
}

output "database_host" {
  value = digitalocean_database_cluster.mysql.host
}

output "database_port" {
  value = digitalocean_database_cluster.mysql.port
}

output "database_user" {
  value = digitalocean_database_user.leap25_user.name
}

output "database_password" {
  value     = digitalocean_database_user.leap25_user.password
  sensitive = true
}

output "database_name" {
  value = digitalocean_database_db.leap25_db.name
}

output "redis_host" {
  value = digitalocean_database_cluster.redis.host
}

output "redis_port" {
  value = digitalocean_database_cluster.redis.port
}

output "redis_password" {
  value     = digitalocean_database_cluster.redis.password
  sensitive = true
}
