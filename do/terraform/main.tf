# Database infrastructure for LEAP25
terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.30.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

# Variables
variable "do_token" {
  description = "DigitalOcean API Token"
  type        = string
  sensitive   = true
}

variable "environment" {
  description = "Deployment environment (e.g. production, staging, development)"
  type        = string
  default     = "production"
}

variable "region" {
  description = "DigitalOcean region for resources"
  type        = string
  default     = "sgp1"
}

variable "db_size" {
  description = "Size of MySQL database cluster"
  type        = string
  default     = "db-s-2vcpu-4gb"
}

variable "redis_size" {
  description = "Size of Redis/Valkey database cluster"
  type        = string
  default     = "db-s-1vcpu-2gb"
}

resource "digitalocean_vpc" "leap25_vpc" {
  name     = "leap25-network-${var.environment}"
  region   = var.region
  ip_range = "10.10.10.0/24"
}

# MySQL database cluster
resource "digitalocean_database_cluster" "mysql" {
  name                 = "leap25-mysql-${var.environment}"
  engine               = "mysql"
  version              = "8"
  size                 = var.db_size
  region               = var.region
  node_count           = var.environment == "production" ? 1 : 1 # make 2 if have money lol
  private_network_uuid = digitalocean_vpc.leap25_vpc.id

  # configure backup settings
  maintenance_window {
    day  = "sunday"
    hour = "02:00:00"
  }
}

# database
resource "digitalocean_database_db" "leap25_db" {
  cluster_id = digitalocean_database_cluster.mysql.id
  name       = "leap25_${var.environment}"
}

# database user
resource "digitalocean_database_user" "leap25_user" {
  cluster_id = digitalocean_database_cluster.mysql.id
  name       = "leap25user"
}

# Redis/Valkey cluster
resource "digitalocean_database_cluster" "redis" {
  name                 = "leap25-redis-${var.environment}"
  engine               = "valkey"
  version              = "8"
  size                 = var.redis_size
  region               = var.region
  node_count           = var.environment == "production" ? 1 : 1 # make 2 if have money lol
  private_network_uuid = digitalocean_vpc.leap25_vpc.id
}



# # firewall rules to allow app platform to connect
# resource "digitalocean_database_firewall" "mysql_firewall" {
#   cluster_id = digitalocean_database_cluster.mysql.id
#
#   rule {
#     type  = "app"
#     value = "frontend-app-id"
#   }
#   rule {
#     type  = "app"
#     value = "backend-app-id"
#   }
# }
#
# resource "digitalocean_database_firewall" "redis_firewall" {
#   cluster_id = digitalocean_database_cluster.redis.id
#
#   rule {
#     type  = "app"
#     value = "f24b2e8a-7568-469e-a8ef-b670f940e9a4"
#   }
#   rule {
#     type  = "app"
#     value = "98e20fda-b13b-4658-86ab-c93b5d19f3f8"
#   }
# }

# Outputs
output "mysql_connection_string" {
  value     = digitalocean_database_cluster.mysql.uri
  sensitive = true
}

output "mysql_host" {
  value = digitalocean_database_cluster.mysql.host
}

output "mysql_port" {
  value = digitalocean_database_cluster.mysql.port
}

output "mysql_user" {
  value = digitalocean_database_user.leap25_user.name
}

output "mysql_password" {
  value     = digitalocean_database_user.leap25_user.password
  sensitive = true
}

output "mysql_database" {
  value = digitalocean_database_db.leap25_db.name
}

output "redis_connection_string" {
  value     = digitalocean_database_cluster.redis.uri
  sensitive = true
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

output "mysql_private_host" {
  value       = digitalocean_database_cluster.mysql.private_host
  description = "Private hostname for MySQL access within VPC"
}

output "redis_private_host" {
  value       = digitalocean_database_cluster.redis.private_host
  description = "Private hostname for Redis access within VPC"
}

output "vpc_id" {
  value       = digitalocean_vpc.leap25_vpc.id
  description = "VPC ID for connecting App Platform apps"
}
