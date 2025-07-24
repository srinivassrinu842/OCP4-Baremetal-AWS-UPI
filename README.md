# OpenShift UPI on AWS with Terraform

This project provides a production-grade, modular Terraform configuration to deploy OpenShift Container Platform (OCP) cluster on Amazon Web Services (AWS) using the User-Provisioned Infrastructure (UPI) method.

## Architecture Overview

The infrastructure consists of the following components:

- **VPC**: A dedicated Virtual Private Cloud (VPC) to isolate the cluster resources
- **Subnets**: Public and private subnets across multiple Availability Zones for high availability
- **Bastion Host**: A bastion host in the public subnet that acts as a NAT gateway, load balancer (using HAProxy), and access point for managing the cluster
- **OpenShift Nodes**: Bootstrap and master nodes deployed in private subnets
- **Route 53**: A private hosted zone for internal DNS resolution within the cluster

### Architecture Diagram

Below is a Mermaid diagram representing the architecture:

```mermaid
graph TD
    subgraph "AWS Cloud"
        subgraph "VPC (10.0.0.0/16)"
            subgraph "Public Subnet (10.0.1.0/24)"
                Bastion[Bastion Host<br/>NAT Gateway<br/>HAProxy<br/>10.0.1.10]
            end

            subgraph "Private Subnet 1 (10.0.2.0/24)"
                Bootstrap[Bootstrap Node<br/>10.0.2.10]
                Master1[Master Node 1<br/>10.0.2.11]
            end

            subgraph "Private Subnet 2 (10.0.3.0/24)"
                Master2[Master Node 2<br/>10.0.3.11]
            end

            subgraph "Private Subnet 3 (10.0.4.0/24)"
                Master3[Master Node 3<br/>10.0.4.11]
            end

            InternetGateway[Internet Gateway]
            RouteTablePublic[Public Route Table]
            RouteTablePrivate[Private Route Table]
            Route53[Route 53 Private Zone]
        end
    end

    User["👤 User"] --> Bastion
    Internet["🌐 Internet"] --> InternetGateway
    InternetGateway --> RouteTablePublic
    RouteTablePublic --> Bastion
    Bastion --> RouteTablePrivate
    RouteTablePrivate --> Bootstrap
    RouteTablePrivate --> Master1
    RouteTablePrivate --> Master2
    RouteTablePrivate --> Master3
    Route53 --> Bootstrap
    Route53 --> Master1
    Route53 --> Master2
    Route53 --> Master3

    Bootstrap --> Master1
    Bootstrap --> Master2
    Bootstrap --> Master3
```

## Project Structure

The project follows a modular Terraform structure:

## Prerequisites

Before you begin, ensure you have the following:

1.  **AWS Account**: An AWS account with the necessary permissions to create the resources defined in the Terraform configuration.
2.  **Terraform**: Terraform installed on your local machine. You can download it from the [official Terraform website](https://www.terraform.io/downloads.html).
3.  **AWS CLI**: The AWS Command Line Interface configured with your credentials. See the [AWS CLI documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html) for instructions.
4.  **OpenShift Pull Secret**: A valid OpenShift pull secret. You can get this from the [Red Hat OpenShift Cluster Manager](https://console.redhat.com/openshift/install/pull-secret).
5.  **SSH Key Pair**: An SSH key pair created in the AWS region where you plan to deploy the cluster.

## Deployment Steps

1.  **Clone the Repository**

    ```bash
    git clone <your-repository-url>
    cd <repository-name>
    ```

2.  **Configure Your Environment**

    - Rename the `terraform.tfvars.example` file to `terraform.tfvars`.
    - Open `terraform.tfvars` and update the values for your environment. Pay special attention to `region`, `key_name`, and other project-specific variables.

3.  **Provide the Pull Secret**

    - Create a file named `pull-secret.oneline.txt` in the root of the project.
    - Paste your OpenShift pull secret into this file. Ensure it is a single line of JSON.

4.  **Initialize Terraform**

    Run the following command to initialize the Terraform workspace and download the required providers:

    ```bash
    terraform init
    ```

5.  **Plan the Deployment**

    Generate an execution plan to preview the changes that Terraform will make:

    ```bash
    terraform plan
    ```

6.  **Apply the Configuration**

    Deploy the infrastructure:

    ```bash
    terraform apply
    ```

    Enter `yes` when prompted to confirm the deployment.

## Post-Deployment

Once the `terraform apply` command completes, the OpenShift cluster will be up and running. The outputs will display important information, such as the bastion host's public IP and the private IPs of the cluster nodes.

You can SSH into the bastion host to manage the cluster using `oc` and `kubectl` commands, which are pre-installed and configured by the `user_data` script.

## Cleaning Up

To destroy all the resources created by this Terraform configuration, run:

```bash
terraform destroy
```

Enter `yes` when prompted to confirm the deletion.


## Environment Configuration

This project uses environment-specific configurations located in the `environments` directory:

```plaintext
environments/
├── dev/
│   └── terraform.tfvars    # Development environment variables
└── prod/
    └── terraform.tfvars    # Production environment variables
```

### Environment Variables (terraform.tfvars)

Each environment's `terraform.tfvars` contains the following configuration:

```hcl
region                = "us-east-1"              # AWS region
environment           = "dev"                   # Environment name
vpc_cidr              = "10.0.0.0/16"           # VPC CIDR block
public_subnet_cidr    = "10.0.1.0/24"           # Public subnet CIDR
private_subnet_cidrs  = [                       # Private subnet CIDRs
  "10.0.2.0/24",
  "10.0.3.0/24", 
  "10.0.4.0/24"
]
availability_zones    = [                       # AWS availability zones
  "us-east-1a",
  "us-east-1b",
  "us-east-1c"
]
domain_name           = "ocp.lan"               # Internal domain name
bastion_ami           = "ami-0dfc569a8686b9320" # Bastion host AMI
bastion_instance_type = "t3.medium"             # Bastion instance type
ocp_version           = "4.16.40"              # OpenShift version
key_name              = "your-key-pair"         # AWS SSH key pair name
bastion_private_ip    = "10.0.1.10"            # Bastion host private IP
bootst1_private_ip    = "10.0.2.10"            # Bootstrap node private IP
master1_private_ip    = "10.0.2.11"            # Master 1 private IP
master2_private_ip    = "10.0.3.11"            # Master 2 private IP
master3_private_ip    = "10.0.4.11"            # Master 3 private IP
create_nodes          = false                   # Flag to create nodes
node_ami              = "ami-03ca8605aa130b597" # Node AMI ID
bootstrap_instance_type = "t3.xlarge"          # Bootstrap instance type
master_instance_type   = "t3.xlarge"           # Master node instance type
pull_secret            = "pull-secret.oneline.txt" # Path to pull secret file
```

## Deployment Scripts

The project includes two automation scripts in the `scripts` directory for easy deployment and cleanup:

### deploy.sh

This script automates the deployment process for a specific environment:

```bash
# Deploy development environment (default)
./scripts/deploy.sh

# Deploy specific environment
./scripts/deploy.sh dev
./scripts/deploy.sh prod
```

The script performs the following actions:
1. Initializes Terraform (`terraform init`)
2. Creates an execution plan using environment-specific variables
3. Prompts for confirmation before applying changes
4. Applies the Terraform configuration with the specified environment's `terraform.tfvars`

### destroy.sh

This script safely tears down the infrastructure:

```bash
# Destroy development environment (default)
./scripts/destroy.sh

# Destroy specific environment
./scripts/destroy.sh dev
./scripts/destroy.sh prod
```

The script:
1. Prompts for confirmation before proceeding with destruction
2. Uses the environment-specific `terraform.tfvars` for proper resource identification
3. Executes `terraform destroy` to remove all resources

⚠️ **Warning**: The destroy script will permanently delete all resources. Ensure you have backed up any important data before proceeding.