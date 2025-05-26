# LEAP25 App Platform Deployment Guide
<!-- 2025-05-26 21:13 -->
This guide provides step-by-step instructions for deploying the LEAP25 application on DigitalOcean App Platform.

## Prerequisites

- A DigitalOcean account
- GitHub repositories for both frontend and backend
- DigitalOcean API token with write access
- GitHub personal access token with repo scope
- DigitalOcean CLI (doctl) installed

## Step 1: Install and Configure doctl

```bash
# Install doctl (macOS example using Homebrew)
brew install doctl

# Install on Ubuntu/Debian
# sudo snap install doctl

# Authenticate doctl with your API token
doctl auth init
```

## Step 2: Prepare Your App Specification

Create a file named `app.yaml` with the following content:

```yaml
---
name: leap25
region: sgp1
services:
  # frontend
  - name: leap25-frontend
    environment_slug: node-js
    github:
      repo: dlsu-lscs/leap25-frontend
      branch: main
      deploy_on_push: true
    build_command: npm install && npm run build
    run_command: npx next start
    http_port: 3000
    instance_size_slug: basic-xs
    instance_count: 1
    autoscaling:
      min_instance_count: 1
      max_instance_count: 3
      metrics:
        - type: cpu_utilization
          deployment_target_percent: 70
        - type: memory_utilization
          deployment_target_percent: 70
    envs:
      - key: NODE_ENV
        value: production
      - key: NEXT_PUBLIC_API_URL
        value: ${app.leap25-backend.PUBLIC_URL}
      - key: NEXTAUTH_URL
        value: ${_self.PUBLIC_URL}
      - key: NEXTAUTH_SECRET
        type: SECRET
        value: "your-nextauth-secret"
      - key: NEXT_PUBLIC_GOOGLE_CLIENT_ID
        type: SECRET
        scope: RUN_AND_BUILD_TIME
      - key: NEXT_PUBLIC_GOOGLE_CLIENT_SECRET
        type: SECRET
        scope: RUN_AND_BUILD_TIME
    routes:
      - path: /
    alerts:
      - rule: DEPLOYMENT_FAILED
      - rule: DOMAIN_FAILED
      - rule: CPU_UTILIZATION
        value: 90
      - rule: MEM_UTILIZATION
        value: 90

  # backend API
  - name: leap25-backend
    environment_slug: node-js
    github:
      repo: dlsu-lscs/leap25-backend
      branch: main
      deploy_on_push: true
    build_command: npm install && npm run build
    run_command: node dist/main.js
    http_port: 3000
    instance_size_slug: professional-xs
    instance_count: 1
    autoscaling:
      min_instance_count: 1
      max_instance_count: 3
      metrics:
        - type: cpu_utilization
          deployment_target_percent: 70
        - type: memory_utilization
          deployment_target_percent: 70
    envs:
      - key: NODE_ENV
        value: production
      - key: PORT
        value: 3000
      - key: DB_HOST
        value: ${db.leap25-mysql.HOSTNAME}
      - key: DB_PORT
        value: ${db.leap25-mysql.PORT}
      - key: DB_DATABASE
        value: ${db.leap25-mysql.DATABASE}
      - key: DB_USER
        value: ${db.leap25-mysql.USERNAME}
      - key: DB_PASS
        value: ${db.leap25-mysql.PASSWORD}
      - key: REDIS_CONNECTION_URL
        value: redis://default:${db.leap25-redis.PASSWORD}@${db.leap25-redis.HOSTNAME}:${db.leap25-redis.PORT}
      - key: SESSION_SECRET
        type: SECRET
        value: "your-session-secret"
      - key: JWT_SECRET
        type: SECRET
        value: "your-jwt-secret"
      - key: CORS_ORIGIN
        value: ${app.leap25-frontend.PUBLIC_URL}
      - key: GOOGLE_CLIENT_ID
        type: SECRET
        scope: RUN_AND_BUILD_TIME
      - key: GOOGLE_CLIENT_SECRET
        type: SECRET
        scope: RUN_AND_BUILD_TIME
      - key: CONTENTFUL_SPACE_ID
        type: SECRET
        scope: RUN_AND_BUILD_TIME
      - key: CONTENTFUL_ACCESS_TOKEN
        type: SECRET
        scope: RUN_AND_BUILD_TIME
      - key: CONTENTFUL_ENVIRONMENT
        value: master
    health_check:
      http_path: /health/live
      initial_delay_seconds: 10
      period_seconds: 5
      success_threshold: 1
    routes:
      - path: /
        preserve_path_prefix: true
    alerts:
      - rule: DEPLOYMENT_FAILED
      - rule: DOMAIN_FAILED
      - rule: CPU_UTILIZATION
        value: 90
      - rule: MEM_UTILIZATION
        value: 90

databases:
  # MySQL
  - engine: mysql
    name: leap25-mysql
    production: true
    cluster_name: leap25-mysql-cluster
    db_name: leap25_db
    db_user: leap25user
    version: "8"
    size: db-s-2vcpu-4gb

  # Redis/Valkey for caching
  - engine: redis
    name: leap25-redis
    production: true
    version: "7"
    size: db-s-1vcpu-2gb

jobs:
  - name: leap25-db-migrations
    github:
      repo: dlsu-lscs/leap25-backend
      branch: main
      deploy_on_push: false
    build_command: npm install && npm run build
    run_command: node dist/migrations/run-migrations.js
    envs:
      - key: DB_HOST
        value: ${db.leap25-mysql.HOSTNAME}
      - key: DB_PORT
        value: ${db.leap25-mysql.PORT}
      - key: DB_DATABASE
        value: ${db.leap25-mysql.DATABASE}
      - key: DB_USER
        value: ${db.leap25-mysql.USERNAME}
      - key: DB_PASS
        value: ${db.leap25-mysql.PASSWORD}
      - key: NODE_ENV
        value: production
    kind: PRE_DEPLOY
    run_on: COMPONENT_UPDATES

domains:
  - domain: dlsucso-leap.com
    type: PRIMARY
    zone: dlsucso-leap.com
    services:
      - name: leap25-frontend
  
  - domain: api.dlsucso-leap.com
    type: PRIMARY
    zone: dlsucso-leap.com
    services:
      - name: leap25-backend
```

## Step 3: Create App with App Specification

```bash
# Create the app using the specification file
doctl apps create --spec app.yaml
```

This will begin the deployment process for your infrastructure.

## Step 4: Monitor Deployment Progress

```bash
# List your apps
doctl apps list

# Get your app ID
APP_ID=$(doctl apps list --format ID --no-header)

# Monitor the deployment
doctl apps get $APP_ID
```

## Step 5: Update Secrets for Applications

While the app is being created, you'll need to update the secret values. You can do this via the DigitalOcean console or with the CLI:

```bash
# Replace these with your actual secret values
NEXTAUTH_SECRET="your-secure-nextauth-secret"
SESSION_SECRET="your-secure-session-secret"
JWT_SECRET="your-secure-jwt-secret"
GOOGLE_CLIENT_ID="your-google-client-id"
GOOGLE_CLIENT_SECRET="your-google-client-secret"
CONTENTFUL_SPACE_ID="your-contentful-space-id"
CONTENTFUL_ACCESS_TOKEN="your-contentful-access-token"

# Update the frontend secrets
doctl apps update-service $APP_ID leap25-frontend \
  --env NEXTAUTH_SECRET=$NEXTAUTH_SECRET \
  --env NEXT_PUBLIC_GOOGLE_CLIENT_ID=$GOOGLE_CLIENT_ID \
  --env NEXT_PUBLIC_GOOGLE_CLIENT_SECRET=$GOOGLE_CLIENT_SECRET

# Update the backend secrets
doctl apps update-service $APP_ID leap25-backend \
  --env SESSION_SECRET=$SESSION_SECRET \
  --env JWT_SECRET=$JWT_SECRET \
  --env GOOGLE_CLIENT_ID=$GOOGLE_CLIENT_ID \
  --env GOOGLE_CLIENT_SECRET=$GOOGLE_CLIENT_SECRET \
  --env CONTENTFUL_SPACE_ID=$CONTENTFUL_SPACE_ID \
  --env CONTENTFUL_ACCESS_TOKEN=$CONTENTFUL_ACCESS_TOKEN
```

## Step 6: Setup DNS Records

If you're managing your domain outside of DigitalOcean, you'll need to add CNAME records that point to your App Platform URLs.

1. First, get your App Platform URLs:

```bash
# Get your app's info including URLs
doctl apps get $APP_ID
```

2. Create CNAME records in your DNS provider:
   - `dlsucso-leap.com` → [app-platform-frontend-url]
   - `api.dlsucso-leap.com` → [app-platform-backend-url]

If you're using DigitalOcean Domains, you can add the domain directly:

```bash
# Add your domain to DigitalOcean Domains service
doctl domains create dlsucso-leap.com

# Check DNS propagation
dig dlsucso-leap.com
dig api.dlsucso-leap.com
```

## Step 7: Run Initial Database Migration

Before your application can fully function, you need to run the database migration:

```bash
# Trigger the database migration job
doctl apps run-job $APP_ID leap25-db-migrations
```

Monitor the job logs to ensure the migration completes successfully:

```bash
# Get job ID of the most recent run
JOB_ID=$(doctl apps list-job-runs $APP_ID --format ID --no-header | head -1)

# View job logs
doctl apps get-job-run $APP_ID $JOB_ID
```

## Step 8: Verify Deployment Status

```bash
# Check the overall status of your app
doctl apps get $APP_ID

# Get logs for the frontend service
doctl apps logs $APP_ID leap25-frontend

# Get logs for the backend service
doctl apps logs $APP_ID leap25-backend
```

## Step 9: Setup GitHub Actions for CI/CD (Optional)

Create a GitHub Actions workflow file in your backend repository at `.github/workflows/deploy.yml`:

```yaml
name: Deploy to DigitalOcean App Platform

on:
  push:
    branches:
      - main
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Install doctl
        uses: digitalocean/action-doctl@v2
        with:
          token: ${{ secrets.DIGITALOCEAN_ACCESS_TOKEN }}
      
      - name: Trigger App Platform deployment
        run: |
          APP_ID=$(doctl apps list --format ID --no-header)
          doctl apps create-deployment $APP_ID
```

Create a similar workflow for your frontend repository.

## Step 10: Monitor Application Health

After deployment, regularly check the health of your applications:

```bash
# View app metrics
doctl apps get $APP_ID --format Metrics

# View recent deployments
doctl apps list-deployments $APP_ID
```

## Database Management

### Connect to the database

```bash
# Get database connection info
doctl databases get leap25-mysql

# Connect with MySQL client
mysql -u leap25user -p -h [host] -P [port] leap25_db
```

### Backup the database

```bash
# Create a database backup
doctl databases backup leap25-mysql

# List database backups
doctl databases backups list leap25-mysql
```

## Scaling Your Application

Monitor your application's performance and scale resources as needed:

```bash
# Update the backend instance count (manual scaling)
doctl apps update-service $APP_ID leap25-backend --instance-count 2

# Update the frontend instance size
doctl apps update-service $APP_ID leap25-frontend --instance-size-slug basic-s
```

## Troubleshooting

### Check Application Logs

```bash
# View live logs for backend
doctl apps logs $APP_ID leap25-backend --follow

# View live logs for frontend
doctl apps logs $APP_ID leap25-frontend --follow
```

### Restart a Service

```bash
# Restart the backend service
doctl apps restart-service $APP_ID leap25-backend
```

### Re-run Database Migrations

```bash
# Run the database migration job again
doctl apps run-job $APP_ID leap25-db-migrations
```

### Deployment Issues

If deployments fail, check for build errors:

```bash
# Get the recent deployment ID
DEPLOYMENT_ID=$(doctl apps list-deployments $APP_ID --format ID --no-header | head -1)

# View the detailed deployment logs
doctl apps get-deployment $APP_ID $DEPLOYMENT_ID
```

## Maintenance Tasks

### Update App Specification

```bash
# Get the current spec
doctl apps get $APP_ID --format Spec > updated-app.yaml

# Edit the updated-app.yaml file
# Then update the app with the new spec
doctl apps update $APP_ID --spec updated-app.yaml
```

### Database Maintenance

```bash
# View database connection pool
doctl databases pool list leap25-mysql

# Resize the database cluster
doctl databases resize leap25-mysql --size db-s-4vcpu-8gb
```

## Cost Management

Monitor your resource usage and adjust as needed to stay within budget:

```bash
# View app metrics including resource usage
doctl apps get $APP_ID
```

You can also set up billing alerts in the DigitalOcean console to notify you when approaching your budget limit.

## Security Best Practices

1. **Rotate secrets regularly**: Update all secrets at least quarterly.
2. **Enable 2FA** for your DigitalOcean account.
3. **Use restrictive policies** for your API tokens.
4. **Review access logs** in the DigitalOcean console regularly.

## Backup Strategy

1. **Database backups**: Automated daily backups are included with managed databases.
2. **Code backups**: Ensure your GitHub repositories have branch protection rules.
3. **Environment variables**: Periodically export and securely store your environment configuration.

## Conclusion

You've successfully deployed the LEAP25 application on DigitalOcean App Platform. This infrastructure setup provides a scalable, reliable foundation for your application with automated deployments, managed databases, and comprehensive monitoring.

For further assistance, refer to the [DigitalOcean App Platform Documentation](https://docs.digitalocean.com/products/app-platform/) or reach out to DigitalOcean support.
