#!/bin/bash

set -e

# Load environment variables from root .env file
ROOT_DIR="$(dirname "$(dirname "$0")")"
ENV_FILE="$ROOT_DIR/.env"

if [ -f "$ENV_FILE" ]; then
  # shellcheck disable=SC1091
  source "$ENV_FILE"
else
  echo "Warning: .env file not found at '$ENV_FILE', environment variables must be set manually."
fi

usage() {
  echo "Usage: $0 {create|delete}"
  echo "Requires environment variables: CLUSTER_NAME, AWS_REGION, INSTANCE_TYPE, NODEGROUP_NAME"
  exit 1
}

if [ $# -ne 1 ]; then
  usage
fi

ACTION=$1

# Check required environment variables
required_vars=(CLUSTER_NAME AWS_REGION INSTANCE_TYPE NODEGROUP_NAME)

for var in "${required_vars[@]}"; do
  if [ -z "${!var}" ]; then
    echo "Error: Please set the environment variable '$var'."
    exit 1
  fi
done

# Template file located in the same directory as this script
SCRIPT_DIR="$(dirname "$0")"
TEMPLATE_FILE="$SCRIPT_DIR/cluster-config-template.yaml"

if [ ! -f "$TEMPLATE_FILE" ]; then
  echo "Error: Template file '$TEMPLATE_FILE' not found."
  exit 1
fi

# Generate temporary config file with values filled in
CONFIG_FILE=$(mktemp)

sed \
  -e "s/{{CLUSTER_NAME}}/$CLUSTER_NAME/g" \
  -e "s/{{REGION}}/$AWS_REGION/g" \
  -e "s/{{INSTANCE_TYPE}}/$INSTANCE_TYPE/g" \
  -e "s/{{NODEGROUP_NAME}}/$NODEGROUP_NAME/g" \
  "$TEMPLATE_FILE" > "$CONFIG_FILE"

# Run eksctl command
case "$ACTION" in
  create)
    echo "Creating cluster '$CLUSTER_NAME' in region '$AWS_REGION'..."
    eksctl create cluster -f "$CONFIG_FILE"
    ;;
  delete)
    echo "Deleting cluster '$CLUSTER_NAME' in region '$AWS_REGION'..."
    eksctl delete cluster --name "$CLUSTER_NAME" --region "$AWS_REGION"
    ;;
  *)
    usage
    ;;
esac

# Clean up temp config
rm "$CONFIG_FILE"
