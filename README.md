# Terraform Azure Infrastructure and Kubernetes Deployment

This project uses Terraform to set up infrastructure on Azure and deploy applications to a Kubernetes cluster. The project includes:

- Azure Kubernetes Service (AKS)
- Network shared storage
- Azure MySQL Flexible Server
- WordPress deployment
- phpMyAdmin deployment
- MySQL deployment

## Instructions

### Prerequisites

1. **Terraform**: Ensure Terraform is installed on your system. You can download it from the [official Terraform website](https://www.terraform.io/downloads.html).

2. **Azure CLI**: Ensure the Azure CLI is installed and you are logged in to Azure. You can download it from the [official Azure CLI website](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).

### Setup

1. **Clone the Repository**

   ```bash
   git clone <your-repo-url>
   cd <your-repo-directory>

**Configure Terraform**

Edit the provider "azurerm" block in main.tf to include your Azure subscription ID if not already set.

provider "azurerm" {
  features {}
  subscription_id = "<your-subscription-id>"
}

**Initialize Terraform**
Run the following command to initialize the Terraform configuration and download the necessary provider plugins:
terraform init

**Plan the Deployment**
Generate an execution plan to review the changes Terraform will make:
terraform plan

**Apply the Configuration** 
Apply the Terraform configuration to create the resources in Azure:
terraform apply (You will be prompted to confirm. Type yes and press Enter.)

**Accessing Applications**
WordPress: After deployment, access your WordPress site via the external IP address provided by the LoadBalancer service for WordPress.

phpMyAdmin: Access phpMyAdmin via the external IP address provided by the LoadBalancer service for phpMyAdmin.

**Outputs**
After applying the Terraform configuration, the following outputs will be displayed:

aks_cluster_name: The name of the Azure Kubernetes Service cluster.
mysql_server_name: The name of the Azure MySQL Flexible Server.
storage_account_name: The name of the Azure Storage Account.
files_share_name: The name of the Azure File Share.


Resources Created
Resource Group: A resource group named my-resource-group in the eastus region.
Virtual Network: A virtual network named my-vnet with subnets for AKS and MySQL.
Kubernetes Cluster: An Azure Kubernetes Service cluster named stastestakscluster.
Storage Account: An Azure Storage Account named stasteststorageacct.
Storage Share: An Azure File Share named myfileshare.
Azure MySQL Flexible Server: A MySQL server named stastestsqlserver.
Kubernetes Deployments and Services:
WordPress deployment and service
phpMyAdmin deployment and service
MySQL deployment and service


**Cleanup**
To delete the resources created by Terraform, run:
terraform destroy (Confirm the action by typing yes when prompted.)



