variable "do_token" {
  description = "Digital Ocean API Token"
  type        = string
  sensitive   = true
}

variable "environment" {
  description = "Deployment environment (staging or production)"
  type        = string
  default     = "staging"
  
  validation {
    condition     = contains(["staging", "production"], var.environment)
    error_message = "Environment must be either 'staging' or 'production'."
  }
}

variable "region" {
  description = "Digital Ocean region"
  type        = string
  default     = "nyc3"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.27.4-do.0"
}

variable "node_size" {
  description = "Size of the Kubernetes nodes"
  type        = string
  default     = "s-2vcpu-4gb"
}

variable "min_nodes" {
  description = "Minimum number of nodes in the cluster"
  type        = number
  default     = 2
}

variable "max_nodes" {
  description = "Maximum number of nodes in the cluster"
  type        = number
  default     = 5
}

variable "db_size" {
  description = "Size of the MySQL database"
  type        = string
  default     = "db-s-1vcpu-1gb"
}

variable "redis_size" {
  description = "Size of the Redis instance"
  type        = string
  default     = "db-s-1vcpu-1gb"
}
