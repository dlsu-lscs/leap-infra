terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.30.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_ssh_key" "terraform" {
  name = "seraphim-key"
}

# Create a Digital Ocean Kubernetes cluster
resource "digitalocean_kubernetes_cluster" "leap25_cluster" {
  name    = "leap25-${var.environment}"
  region  = var.region
  version = var.kubernetes_version
  ha      = true

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
  node_count = var.environment == "production" ? 1 : 1 # make 2 if have money lol
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
  engine     = "valkey"
  version    = "8"
  size       = var.redis_size
  region     = var.region
  node_count = var.environment == "production" ? 1 : 1 # make 2 if have money
}

# Install ingress-nginx with Helm
resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  # Optimize for high traffic
  set {
    name  = "controller.resources.requests.cpu"
    value = "200m"
  }

  set {
    name  = "controller.resources.requests.memory"
    value = "256Mi"
  }

  set {
    name  = "controller.resources.limits.cpu"
    value = "500m"
  }

  set {
    name  = "controller.resources.limits.memory"
    value = "512Mi"
  }
}

# Install cert-manager with Helm
resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true

  set {
    name  = "installCRDs"
    value = "true"
  }
}

# Install MySQL Operator for Kubernetes (free)
resource "helm_release" "mysql_operator" {
  name             = "mysql-operator"
  repository       = "https://mysql.github.io/mysql-operator"
  chart            = "mysql-operator"
  namespace        = "mysql-operator"
  create_namespace = true

  set {
    name  = "replicas"
    value = "1"
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
  value     = digitalocean_kubernetes_cluster.leap25_cluster.endpoint
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

# Output LoadBalancer IP (for DNS configuration)
output "load_balancer_ip" {
  value = <<-EOT
    To get LoadBalancer IP after deployment:
    kubectl get service -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
  EOT
}

output "backend_db_connection_string" {
  value       = "mysql://${digitalocean_database_user.leap25_user.name}:${digitalocean_database_user.leap25_user.password}@${digitalocean_database_cluster.mysql.host}:${digitalocean_database_cluster.mysql.port}/${digitalocean_database_db.leap25_db.name}"
  sensitive   = true
  description = "MySQL connection string for backend service"
}

output "backend_redis_connection_string" {
  value       = "redis://default:${digitalocean_database_cluster.redis.password}@${digitalocean_database_cluster.redis.host}:${digitalocean_database_cluster.redis.port}"
  sensitive   = true
  description = "Redis/Valkey connection string for backend service"
}

output "kubernetes_internal_backend_url" {
  value       = "${var.environment == "production" ? "http://leap25-backend" : "http://staging-leap25-backend"}.default.svc.cluster.local"
  description = "Kubernetes internal URL for backend service"
}
