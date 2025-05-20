#!/bin/bash
set -e

# Usage: ./apply.sh [environment] [component] [image-tag]
# Example: ./apply.sh staging backend sha-abc123
# Example: ./apply.sh production frontend sha-xyz789

ENVIRONMENT=${1:-staging}
COMPONENT=${2:-all} # all, backend, frontend, migrations
IMAGE_TAG=${3}

if [ -z "$ENVIRONMENT" ]; then
    echo "Error: Environment is required"
    echo "Usage: $0 [environment] [component] [image-tag]"
    exit 1
fi

if [ "$ENVIRONMENT" != "staging" ] && [ "$ENVIRONMENT" != "production" ]; then
    echo "Error: Environment must be 'staging' or 'production'"
    exit 1
fi

apply_component() {
    local component=$1
    local image_tag=$2

    echo "Applying $component in $ENVIRONMENT environment..."

    if [ -n "$image_tag" ]; then
        echo "Updating image tag to $image_tag..."
        cd "overlays/$ENVIRONMENT/$component"
        kustomize edit set image ghcr.io/dlsu-lscs/leap25-$component=ghcr.io/dlsu-lscs/leap25-$component:$image_tag
        cd ../../../
    fi

    if [ "$component" == "migrations" ]; then
        # for migrations, use base directory with name prefix
        kubectl apply -k "base/migrations"

        # wait for migration job to complete before deploying (prevent data corruption and race conditions)
        if [ "$ENVIRONMENT" == "production" ]; then
            kubectl wait --for=condition=complete job/leap25-db-migration --timeout=300s
        else
            kubectl wait --for=condition=complete job/staging-leap25-db-migration --timeout=300s
        fi

        if [ "$ENVIRONMENT" == "production" ]; then
            kubectl logs job/leap25-db-migration
        else
            kubectl logs job/staging-leap25-db-migration
        fi
    else
        kubectl apply -k "overlays/$ENVIRONMENT/$component"

        # if it's backend and there's a deployment, then we wait for rollout
        if [ "$component" == "backend" ] || [ "$component" == "frontend" ]; then
            if [ "$ENVIRONMENT" == "production" ]; then
                kubectl rollout status "deployment/leap25-$component"
            else
                kubectl rollout status "deployment/staging-leap25-$component"
            fi
        fi
    fi

}

if [ "$COMPONENT" == "all" ]; then
    apply_component "backend" "$IMAGE_TAG"
    apply_component "frontend" "$IMAGE_TAG"
else
    apply_component "$COMPONENT" "$IMAGE_TAG"
fi

echo "Deployment to $ENVIRONMENT completed successfully!"
