# Leap25 Infrastructure

This repository contains the Kubernetes manifests and Terraform configuration for the Leap25 platform infrastructure on Digital Ocean.

## Repository Structure

- `base/`: Base Kubernetes manifests
  - `backend/`: Backend API service
  - `frontend/`: Frontend web application
  - `migrations/`: Database migration jobs
- `overlays/`: Environment-specific configurations
  - `staging/`: Staging environment
  - `production/`: Production environment
- `scripts/`: Utility scripts for deployment
- `terraform/`: Infrastructure as Code with Terraform

## Prerequisites

Before starting, make sure you have the following tools installed:

- [Terraform](https://www.terraform.io/downloads.html) (version >= 1.0.0)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [kustomize](https://kubectl.docs.kubernetes.io/installation/kustomize/)
- [kubeseal](https://github.com/bitnami-labs/sealed-secrets#installation)
- [Digital Ocean CLI](https://docs.digitalocean.com/reference/doctl/how-to/install/)

## Infrastructure Setup

### Kubernetes Resources Installation

While Terraform handles most infrastructure provisioning, you can also manually install or upgrade the Kubernetes components:

#### Ingress-NGINX Controller

```bash
# Add the Helm repository
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Install the controller
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.service.type=LoadBalancer \
  --set controller.metrics.enabled=true
```

#### Cert-Manager

```bash
# Add the Helm repository
helm repo add jetstack https://charts.jetstack.io
helm repo update

# Install cert-manager with CRDs
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set installCRDs=true
  
# Apply the cluster issuers after installation
kubectl apply -f k8s/cluster-issuer.yaml
```

#### Sealed Secrets

```bash
# Add the Helm repository
helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets
helm repo update

# Install sealed-secrets controller
helm install sealed-secrets sealed-secrets/sealed-secrets \
  --namespace kube-system

# Export the certificate for encrypting secrets
kubectl get secret -n kube-system -l sealedsecrets.bitnami.com/sealed-secrets-key -o yaml | \
  grep tls.crt | cut -d" " -f6 | base64 -d > .kubeseal-cert.pem
```


### Step 1: Initialize Terraform

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your Digital Ocean API token and preferences
terraform init
```

### Step 2: Deploy Infrastructure

```bash
terraform plan -out=tfplan
terraform apply tfplan
```

This will create:
1. A Digital Ocean Kubernetes cluster
2. A managed MySQL database
3. A managed Redis instance
4. Deploy ingress-nginx, cert-manager, and sealed-secrets controllers

### Step 3: Configure kubectl

```bash
terraform output -raw kubeconfig > ~/.kube/configs/leap25-config
export KUBECONFIG=~/.kube/configs/leap25-config
```

### Step 4: Setup DNS Records

Create DNS records pointing to the Load Balancer IPs:

```bash
# Get the Ingress Controller Load Balancer IP
kubectl get service -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

Create A records for:
- leap25.com
- api.leap25.com
- staging.leap25.com
- api-staging.leap25.com

### Step 5: Get Sealed Secrets Certificate

```bash
# Download the certificate used for encryption
kubectl get secret -n kube-system -l sealedsecrets.bitnami.com/sealed-secrets-key -o yaml | grep tls.crt | cut -d" " -f6 | base64 -d > .kubeseal-cert.pem
```

## Secret Management

Secrets are managed using SealedSecrets:

### Creating or Updating Secrets

1. Create or edit a plain text secret file:
   ```bash
   vi overlays/staging/backend/secrets/.env.staging
   ```

2. Seal the secret:
   ```bash
   ./scripts/seal-secrets.sh staging backend
   ```

3. Commit only the sealed secret:
   ```bash
   git add overlays/staging/backend/secrets/.sealedenv.staging.yaml
   git commit -m "Update staging backend sealed secrets"
   ```

### Example Secret Files

**Backend Environment Variables**:
```env
# Database configuration
DB_HOST=your-db-host-from-terraform-output
DB_USER=leap25user
DB_PASS=your-db-password-from-terraform-output
DB_DATABASE=leap25_staging
DB_PORT=25060

# Application secrets
SESSION_SECRET=random-session-secret
JWT_SECRET=random-jwt-secret

# Redis configuration
REDIS_CONNECTION_URL=redis://default:your-redis-password@your-redis-host:your-redis-port

# Other service connections
CONTENTFUL_SPACE_ID=your-contentful-space-id
CONTENTFUL_ENVIRONMENT=master
CONTENTFUL_ACCESS_TOKEN=your-contentful-access-token
```

## Deployment

### Initial Cluster Setup

After infrastructure is provisioned, apply the LetsEncrypt ClusterIssuers:

```bash
kubectl apply -f k8s/cluster-issuer.yaml
```

### Standard Deployments

To deploy components to environments:

```bash
./scripts/apply.sh [environment] [component] [image-tag]
```

Examples:
```bash
# Deploy backend to staging with a specific image tag
./scripts/apply.sh staging backend sha-abc123

# Deploy frontend to production
./scripts/apply.sh production frontend sha-xyz789

# Deploy all components to staging
./scripts/apply.sh staging all
```

## CI/CD Integration

This repository is integrated with CI/CD through GitHub Actions workflows:

- Backend deployments are triggered by the `backend-update` repository dispatch event
- Frontend deployments are triggered by the `frontend-update` repository dispatch event

See `.github/workflows/` for details on the deployment workflows.

## Networking

The infrastructure uses ingress-nginx as the Ingress Controller:
- Each service gets its own Ingress resource
- TLS certificates are automatically provisioned by cert-manager
- Both staging and production environments use separate domains and certificates

## Database Migrations

migrations for leap infra:

┌─────────────────┐     ┌─────────────────┐     ┌──────────────────┐
│  Migration Job  │────▶│  Database Ready │────▶│ Application Pods │
│    (one-time)   │     │     Signal      │     │     (scaled)     │
└─────────────────┘     └─────────────────┘     └──────────────────┘

qs for migrations:
- no need to run the migrations in config/database.ts?
- when want to run another migrations (like db/model change for example), we just create a .sql file inside the migrations folder? Then will the kubernetes job auto run the run-migrations script?

- for the caching middleware (Cache-Control header), how does it work really?

- if the database is a managed database (from digital ocean), how do i ensure that the job for running migrations is run from my kubernetes (digital ocean kubernetes)? Also since i have managed redis also, how does this connect? 

### Running Migrations Manually

While CI/CD handles migrations automatically during deployments, you can run them manually:

```bash
# Run migrations in staging
./scripts/apply.sh staging migrations sha-YOUR_COMMIT_HASH

# Run migrations in production
./scripts/apply.sh production migrations sha-YOUR_COMMIT_HASH
```

**Important**: Always specify the correct image tag (commit SHA) when running migrations to ensure compatibility with your database schema.

### Migration Process

The CI/CD workflow handles migrations as follows:

1. When a backend update is triggered with migrations, the workflow:
   - Downloads the migrations artifact from the backend build
   - Applies the migrations as a Kubernetes job
   - Waits for the migration to complete before updating the backend deployment

For manual testing or debugging, you can inspect migration logs:

```bash
# View staging migration logs
kubectl logs job/staging-leap25-db-migration

# View production migration logs
kubectl logs job/leap25-db-migration
```

## Monitoring and Observability

For monitoring your Digital Ocean Kubernetes cluster, consider adding:

1. Prometheus and Grafana:
   ```bash
   helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
   helm install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace
   ```

2. Loki for logs:
   ```bash
   helm repo add grafana https://grafana.github.io/helm-charts
   helm install loki grafana/loki-stack --namespace monitoring
   ```

## Clean Up

To tear down the infrastructure:

```bash
cd terraform
terraform destroy
```

**Warning**: This will destroy all resources, including databases and volumes!
```
