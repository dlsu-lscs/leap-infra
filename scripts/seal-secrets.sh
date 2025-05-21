#!/bin/bash
set -e

# Usage: ./seal-secrets.sh [environment] [component]
# Example: ./seal-secrets.sh staging backend
# Example: ./seal-secrets.sh production frontend

ENVIRONMENT=${1:-staging}
COMPONENT=${2:-backend}

if [ -z "$ENVIRONMENT" ]; then
    echo "Error: Environment is required"
    echo "Usage: $0 [environment] [component]"
    exit 1
fi

if [ "$ENVIRONMENT" != "staging" ] && [ "$ENVIRONMENT" != "production" ]; then
    echo "Error: Environment must be 'staging' or 'production'"
    exit 1
fi

if [ "$COMPONENT" != "backend" ] && [ "$COMPONENT" != "frontend" ]; then
    echo "Error: Component must be 'backend' or 'frontend'"
    exit 1
fi

ENV_FILE="overlays/$ENVIRONMENT/$COMPONENT/secrets/.env.$ENVIRONMENT"
SEALED_FILE="overlays/$ENVIRONMENT/$COMPONENT/secrets/.sealedenv.$ENVIRONMENT.yaml"

if [ ! -f "$ENV_FILE" ]; then
    echo "Error: Environment file $ENV_FILE does not exist"
    exit 1
fi

echo "Creating sealed secret for $COMPONENT in $ENVIRONMENT environment"

# Create a sealed secret using kubeseal
kubectl create secret generic leap25-$COMPONENT-secrets \
    --from-env-file=$ENV_FILE \
    --dry-run=client -o yaml |
    kubeseal --format yaml --cert .kubeseal-cert.pem >$SEALED_FILE

echo "Secret sealed successfully to $SEALED_FILE"
echo "You can now commit the sealed secret file to git."
