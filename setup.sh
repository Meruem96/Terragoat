#!/bin/bash
export TERRAGOAT_RESOURCE_GROUP="TerraGoatRG"
export TERRAGOAT_STATE_STORAGE_ACCOUNT="terragoatsaclem"
export TERRAGOAT_STATE_CONTAINER="mydevsecops"
export TF_VAR_environment="dev"
export TF_VAR_region="westus"

# Create resource group
az group create --location $TF_VAR_region --name $TERRAGOAT_RESOURCE_GROUP >> setupoutput.log && echo "Resource group created"

# Create storage account
az storage account create --name $TERRAGOAT_STATE_STORAGE_ACCOUNT --resource-group $TERRAGOAT_RESOURCE_GROUP --location $TF_VAR_region --sku Standard_LRS --kind StorageV2 --https-only true --encryption-services blob >> setupoutput.log && echo "Storage account created"

# Get storage account key
ACCOUNT_KEY=$(az storage account keys list --resource-group $TERRAGOAT_RESOURCE_GROUP --account-name $TERRAGOAT_STATE_STORAGE_ACCOUNT --query [0].value -o tsv) >> setupoutput.log && echo "Storage account key retreived"

# Create blob container
az storage container create --name $TERRAGOAT_STATE_CONTAINER --account-name $TERRAGOAT_STATE_STORAGE_ACCOUNT --account-key $ACCOUNT_KEY >> setupoutput.log && echo "Blob container created"

echo "Terraform init ..."
terraform init -reconfigure -backend-config="resource_group_name=$TERRAGOAT_RESOURCE_GROUP" \
    -backend-config "storage_account_name=$TERRAGOAT_STATE_STORAGE_ACCOUNT" \
    -backend-config="container_name=$TERRAGOAT_STATE_CONTAINER" \
    -backend-config "key=$TF_VAR_environment.terraform.tfstate" >> setupoutput.log && echo "Initialisation complete"

echo "Terraform plan ..."
terraform plan > plan.tf && echo "Plan saved as plan.tf"

read -p "Apply ? [Y/N]" resp

if [ "$resp" == "Y" ]; then terraform apply; fi
if [ "$resp" == "y" ]; then terraform apply; fi
if [ "$resp" == "yes" ]; then terraform apply; fi

