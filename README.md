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
mkdir -p ~/.kube/configs
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
- dlsucso-leap.com
- api.dlsucso-leap.com
- staging.dlsucso-leap.com
- api-staging.dlsucso-leap.com

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
   vi overlays/production/backend/secrets/.env.production
   ```

2. Seal the secret:
   ```bash
   ./scripts/seal-secrets.sh production backend
   ```

3. Commit only the sealed secret:
   ```bash
   git add overlays/production/backend/secrets/.sealedenv.production.yaml
   git commit -m "chore: update production backend sealed secrets"
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

---

### Kubernetes Resources Installation (Optional)

- installs ingress-nginx, cert-manager, and sealed-secrets

> [!NOTE]
> This is **OPTIONAL** since these installations are handled in the Terraform configuration in `terraform/main.tf`

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

---

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
- Full Environment-specific (staging, production) deployments are triggered manually through the Actions tab (workflow is configured to run manually only)

See `.github/workflows/` for details on the deployment workflows.

## Networking

The infrastructure uses ingress-nginx as the Ingress Controller:
- Each service gets its own Ingress resource
- TLS certificates are automatically provisioned by cert-manager
- Both staging and production environments use separate domains and certificates

## Database Migrations

### Running Migrations Manually

While CI/CD handles migrations automatically during deployments, you can run them manually:

```bash
# Run migrations in staging
./scripts/apply.sh staging migrations sha-YOUR_COMMIT_HASH

# Run migrations in production
./scripts/apply.sh production migrations sha-YOUR_COMMIT_HASH
```

> [!IMPORTANT]
> Always specify the correct image tag (commit SHA) when running migrations to ensure compatibility with your database schema.

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

## To Scale New Nodes

- Edit `terraform.tfvars` file: 
```tfvars
min_nodes = 3  # Change from 1 to 3
max_nodes = 5  # Change from 2 to 5
```

- Then apply node pool changes:
```bash
cd terraform
terraform plan -out=003-scaled-nodes-tfplan
terraform apply 003-scaled-nodes-tfplan
```

This way nodes will be autoscaled, environment is preserved, and Load Balancer IP will still remain.

## Clean Up

To tear down the infrastructure:

```bash
cd terraform
terraform destroy
```

> [!WARNING]
> This will destroy all resources, including databases and volumes!

---

# Post-Cluster Installation Todos

### 1. Configure kubectl Context

```bash
# Export kubeconfig from terraform output
cd terraform
terraform output -raw kubeconfig > ~/.kube/configs/leap25-config
export KUBECONFIG=~/.kube/configs/leap25-config

# Verify connection to cluster
kubectl get nodes
kubectl get pods --all-namespaces
```

### 2. Verify Helm Installations

```bash
# Check if all helm releases are properly installed
helm ls --all-namespaces

# Verify specific components
kubectl get pods -n ingress-nginx
kubectl get pods -n cert-manager
kubectl get pods -n kube-system -l app.kubernetes.io/name=sealed-secrets
```

### 3. Apply Cluster Issuers for TLS Certificates

```bash
# Apply the cluster issuers for Let's Encrypt
kubectl apply -f k8s/cluster-issuer.yaml

# Verify the cluster issuers are created
kubectl get clusterissuers
kubectl describe clusterissuer letsencrypt-prod
```

### 4. Extract Sealed Secrets Certificate

```bash
# Get the certificate for creating sealed secrets
kubectl get secret -n kube-system -l sealedsecrets.bitnami.com/sealed-secrets-key -o yaml | \
  grep tls.crt | cut -d" " -f6 | base64 -d > .kubeseal-cert.pem

# Set proper permissions
chmod 600 .kubeseal-cert.pem

# Test the certificate works
echo -n "test" | kubectl create secret generic test-secret --dry-run=client --from-file=secret=/dev/stdin -o yaml | \
  kubeseal --cert .kubeseal-cert.pem --format yaml
```

### 5. Get Load Balancer IP

```bash
# Get the ingress controller's external IP
export INGRESS_IP=$(kubectl get service -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "Your Load Balancer IP is: $INGRESS_IP"
```

### 6. Configure DNS Records

Create the following DNS A records pointing to your load balancer IP:
- `leap25.com` → $INGRESS_IP
- `api.leap25.com` → $INGRESS_IP
- `staging.leap25.com` → $INGRESS_IP
- `api-staging.leap25.com` → $INGRESS_IP

You can do this through your domain registrar's control panel or using their API.

### 7. Generate Environment Files

```bash
# Generate environment files for both production and staging
cd scripts
./generate-env-files.sh production
./generate-env-files.sh staging

# Edit the generated files to add remaining secrets
# For production
nano ../overlays/production/backend/secrets/.env.production
nano ../overlays/production/frontend/secrets/.env.production

# For staging
nano ../overlays/staging/backend/secrets/.env.staging
nano ../overlays/staging/frontend/secrets/.env.staging
```

### 8. Create Sealed Secrets

```bash
# Seal the secrets for all environments and components
./seal-secrets.sh production backend
./seal-secrets.sh production frontend
./seal-secrets.sh staging backend
./seal-secrets.sh staging frontend

# Verify the sealed secrets were created
ls -la ../overlays/production/backend/secrets/.sealedenv.production.yaml
ls -la ../overlays/production/frontend/secrets/.sealedenv.production.yaml
ls -la ../overlays/staging/backend/secrets/.sealedenv.staging.yaml
ls -la ../overlays/staging/frontend/secrets/.sealedenv.staging.yaml
```

### 9. Deploy the Base Applications

```bash
# Deploy staging first to test
./apply.sh staging backend latest
./apply.sh staging frontend latest

# Once verified working, deploy production
./apply.sh production backend latest
./apply.sh production frontend latest
```

### 10. Set up GitHub Actions Secrets

Add the following secrets to your GitHub repository:
- `KUBE_CONFIG`: The output of `terraform output -raw kubeconfig`
- `REPO_ACCESS_TOKEN`: A GitHub personal access token with `repo` scope
- `DIGITALOCEAN_ACCESS_TOKEN`: Your DigitalOcean API token

### 11. Verify Deployed Applications

```bash
# Check if all deployments are running
kubectl get deployments --all-namespaces

# Check if ingresses are properly configured
kubectl get ingress --all-namespaces

# Check if HPAs are working
kubectl get hpa --all-namespaces

# Check certificate status
kubectl get certificates --all-namespaces
```

### 12. Test External Access

```bash
# Test staging endpoints
curl -Ik https://staging.leap25.com
curl -Ik https://api-staging.leap25.com/health/live

# Test production endpoints
curl -Ik https://leap25.com
curl -Ik https://api.leap25.com/health/live
```

### 13. Set Up Monitoring (Optional but Recommended)

```bash
# Create monitoring namespace
kubectl create namespace monitoring

# Add Prometheus Helm repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install Prometheus and Grafana
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set grafana.adminPassword=yourSecurePassword \
  --set grafana.service.type=ClusterIP

# Create an ingress for Grafana (example)
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: grafana
  namespace: monitoring
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  tls:
    - hosts:
        - monitoring.leap25.com
      secretName: grafana-tls
  rules:
    - host: monitoring.leap25.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: prometheus-grafana
                port:
                  number: 80
EOF

# Add another DNS record for monitoring.leap25.com -> $INGRESS_IP
```

### 14. Configure GitHub CI/CD Integration Tests

```bash
# Run the repository access test workflow
gh workflow run test-repo-access.yaml -f target_repo=dlsu-lscs/leap25-backend

# Verify it completes successfully
```

### 15. Backup Management (Recommended)

```bash
# Set up database backups with DigitalOcean's managed database feature
# Through the DigitalOcean console, enable automated backups for your MySQL database
```

### 16. Commit and Push Your Changes

```bash
git add .
git commit -m "Add sealed secrets and finalize cluster setup"
git push
```

### 17. Security Review (Recommended)

- Validate network policies are properly set up
- Ensure all secrets are properly encrypted
- Review RBAC permissions
- Validate TLS configuration on all ingresses

### 18. Document Runbooks (Recommended)

Create basic operational runbooks for common scenarios:
- How to roll back a deployment
- How to scale the cluster
- How to restart services
- How to rotate credentials
- How to access logs and monitoring

## Important Notes

1. **Certificate Provisioning**: After applying the ingress resources, it may take a few minutes for Let's Encrypt to issue the certificates. You can check the status with:
   ```bash
   kubectl get challenges --all-namespaces
   kubectl get certificates --all-namespaces
   ```

2. **Database Connections**: The first time your application connects to the database, ensure that the migrations have created all necessary tables.

3. **Resource Scaling**: Your HPA configurations will automatically scale pods based on CPU usage, but node scaling is separate and handled by the Digital Ocean node pool autoscaler.

4. **Sealed Secrets Backup**: Make sure to securely back up your `.kubeseal-cert.pem` file. If you lose this file and the controller is redeployed, you won't be able to decrypt existing sealed secrets.

5. **Disaster Recovery**: Consider setting up periodic exports of essential configurations and secrets to enable faster recovery in case of cluster failure.
