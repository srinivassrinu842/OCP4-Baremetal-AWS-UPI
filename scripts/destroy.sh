#!/bin/bash

set -e

ENVIRONMENT=${1:-dev}

echo "Destroying OpenShift cluster for environment: $ENVIRONMENT"

# Destroy the infrastructure
read -p "Are you sure you want to destroy the infrastructure? (yes/no): " confirm
if [[ $confirm == "yes" ]]; then
    terraform destroy -var-file="environments/$ENVIRONMENT/terraform.tfvars"
else
    echo "Destruction cancelled."
fi