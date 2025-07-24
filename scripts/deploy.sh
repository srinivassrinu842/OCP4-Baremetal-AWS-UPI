#!/bin/bash

set -e

ENVIRONMENT=${1:-dev}

echo "Deploying OpenShift cluster for environment: $ENVIRONMENT"

# Initialize Terraform
terraform init

# Plan the deployment
terraform plan -var-file="environments/$ENVIRONMENT/terraform.tfvars"

# Apply the configuration
read -p "Do you want to apply these changes? (yes/no): " confirm
if [[ $confirm == "yes" ]]; then
    terraform apply -var-file="environments/$ENVIRONMENT/terraform.tfvars"
else
    echo "Deployment cancelled."
fi