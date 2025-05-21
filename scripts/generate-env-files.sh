#!/bin/bash
set -e

# Usage: ./generate-env-files.sh [environment]
# Example: ./generate-env-files.sh staging

ENVIRONMENT=${1:-staging}

if [ -z "$ENVIRONMENT" ]; then
    echo "Error: Environment is required"
    echo "Usage: $0 [environment]"
    exit 1
fi

if [ "$ENVIRONMENT" != "staging" ] && [ "$ENVIRONMENT" != "production" ]; then
    echo "Error: Environment must be 'staging' or 'production'"
    exit 1
fi

# Navigate to terraform directory
cd ../terraform

# Ensure we have the latest state
terraform refresh

# Create backend environment file
echo "Generating backend .env.$ENVIRONMENT file..."
cat >"../overlays/$ENVIRONMENT/backend/secrets/.env.$ENVIRONMENT" <<EOF
PORT=3000
DB_HOST=$(terraform output -raw database_host)
DB_PORT=$(terraform output -raw database_port)
DB_USER=$(terraform output -raw database_user)
DB_PASS=$(terraform output -raw database_password)
DB_DATABASE=$(terraform output -raw database_name)
REDIS_CONNECTION_URL=$(terraform output -raw backend_redis_connection_string)

# You'll need to add these values manually
SESSION_SECRET=replace_with_secure_session_secret
JWT_SECRET=replace_with_secure_jwt_secret
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
CONTENTFUL_SPACE_ID=your_contentful_space_id
CONTENTFUL_ENVIRONMENT=master
CONTENTFUL_ACCESS_TOKEN=your_contentful_access_token
EOF

echo "Backend environment file created at: ../overlays/$ENVIRONMENT/backend/secrets/.env.$ENVIRONMENT"
echo "Please update the remaining values (SESSION_SECRET, JWT_SECRET, etc.) manually."

# Create frontend environment file
echo "Generating frontend .env.$ENVIRONMENT file..."
cat >"../overlays/$ENVIRONMENT/frontend/secrets/.env.$ENVIRONMENT" <<EOF
# Connect to backend via internal Kubernetes DNS for better performance
# Or use the external URL if you prefer
NODE_ENV=$ENVIRONMENT
PUBLIC_API_URL=$(terraform output -raw kubernetes_internal_backend_url)
EOF

echo "Frontend environment file created at: ../overlays/$ENVIRONMENT/frontend/secrets/.env.$ENVIRONMENT"

# Reminder to seal the secrets
echo "Remember to seal these secrets with:"
echo "./seal-secrets.sh $ENVIRONMENT backend"
echo "./seal-secrets.sh $ENVIRONMENT frontend"

cd ../scripts/
