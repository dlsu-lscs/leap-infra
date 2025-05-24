#!/bin/bash
set -e

# Usage: ./apply.sh [environment] [component] [image-tag]
# Example: ./apply.sh staging backend sha-abc123
# Example: ./apply.sh production frontend sha-xyz789

ENVIRONMENT=${1:-staging}
COMPONENT=${2:-all} # all, backend, frontend, migrations
IMAGE_TAG=${3-latest}

if [ -z "$ENVIRONMENT" ]; then
    echo "Error: Environment is required"
    echo "Usage: $0 [environment] [component] [image-tag]"
    exit 1
fi

if [ "$ENVIRONMENT" != "staging" ] && [ "$ENVIRONMENT" != "production" ]; then
    echo "Error: Environment must be 'staging' or 'production'"
    exit 1
fi

# Function to check pod status and logs
check_deployment_status() {
    local component=$1
    local prefix=$2
    local deployment="${prefix}leap25-${component}"

    echo "Checking status of deployment ${deployment}..."
    kubectl get deployment ${deployment} -o wide

    # Check for failed pods
    echo "Checking for failed pods..."
    FAILED_PODS=$(kubectl get pods -l app=leap25-${component} -o jsonpath='{.items[?(@.status.phase=="Failed")].metadata.name}')
    if [ ! -z "$FAILED_PODS" ]; then
        echo "Found failed pods: $FAILED_PODS"
        for pod in $FAILED_PODS; do
            echo "==== Logs for failed pod $pod ===="
            kubectl logs $pod
            echo "==== End logs for $pod ===="
            echo "==== Describe for failed pod $pod ===="
            kubectl describe pod $pod
            echo "==== End describe for $pod ===="
        done
    fi

    # Check for pending pods
    PENDING_PODS=$(kubectl get pods -l app=leap25-${component} -o jsonpath='{.items[?(@.status.phase=="Pending")].metadata.name}')
    if [ ! -z "$PENDING_PODS" ]; then
        echo "Found pending pods: $PENDING_PODS"
        for pod in $PENDING_PODS; do
            echo "==== Describe for pending pod $pod ===="
            kubectl describe pod $pod
            echo "==== End describe for $pod ===="
        done
    fi

    # Check nodes status and capacity
    echo "Checking node status and capacity..."
    kubectl get nodes
    kubectl describe nodes | grep -A 5 "Allocated resources"
}

apply_component() {
    local component=$1
    local image_tag=$2
    local prefix=""

    if [ "$ENVIRONMENT" == "staging" ]; then
        prefix="staging-"
    fi

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

        # wait for migration job to complete before deploying
        echo "Waiting for migration job ${prefix}leap25-db-migration to complete (timeout: 5m)..."
        if ! kubectl wait --for=condition=complete job/${prefix}leap25-db-migration --timeout=300s; then
            echo "Migration job failed or timed out. Checking logs..."
            kubectl logs job/${prefix}leap25-db-migration
            exit 1
        fi

        echo "Migration completed successfully"
        kubectl logs job/${prefix}leap25-db-migration
    else
        echo "Applying kustomization for $component..."
        kubectl apply -k "overlays/$ENVIRONMENT/$component"

        # if it's backend or frontend, then we wait for rollout with increased timeout
        if [ "$component" == "backend" ] || [ "$component" == "frontend" ]; then
            echo "Waiting for deployment ${prefix}leap25-${component} rollout (timeout: 10m)..."

            # Try rollout status with increased timeout
            if ! kubectl rollout status "deployment/${prefix}leap25-${component}" --timeout=600s; then
                echo "Deployment failed or timed out. Checking status..."
                check_deployment_status "$component" "$prefix"

                echo "Attempting to get more information about the deployment..."
                kubectl describe "deployment/${prefix}leap25-${component}"

                echo "Checking events in the namespace..."
                kubectl get events --sort-by='.lastTimestamp'

                echo "Deployment failed. Would you like to:"
                echo "1) Retry the deployment"
                echo "2) Rollback the deployment"
                echo "3) Exit"
                read -p "Enter your choice (1-3): " choice

                case $choice in
                1)
                    echo "Retrying deployment..."
                    kubectl rollout restart "deployment/${prefix}leap25-${component}"
                    kubectl rollout status "deployment/${prefix}leap25-${component}" --timeout=600s
                    ;;
                2)
                    echo "Rolling back deployment..."
                    kubectl rollout undo "deployment/${prefix}leap25-${component}"
                    kubectl rollout status "deployment/${prefix}leap25-${component}" --timeout=300s
                    exit 1
                    ;;
                *)
                    echo "Exiting without further action"
                    exit 1
                    ;;
                esac
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
