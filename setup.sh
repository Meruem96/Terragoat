#!/bin/bash
export TERRAGOAT_RESOURCE_GROUP="TerraGoatRG"
export TERRAGOAT_STATE_STORAGE_ACCOUNT="terragoatsaclem"
export TERRAGOAT_STATE_CONTAINER="mydevsecops"
export TF_VAR_environment="dev"
export TF_VAR_region="westus"

# Create resource group
echo -n "Resource group ..."
az group create --location $TF_VAR_region --name $TERRAGOAT_RESOURCE_GROUP >> setupoutput.log && echo "OK"

# Create storage account
echo -n "Storage account ..."
az storage account create --name $TERRAGOAT_STATE_STORAGE_ACCOUNT --resource-group $TERRAGOAT_RESOURCE_GROUP --location $TF_VAR_region --sku Standard_LRS --kind StorageV2 --https-only true --encryption-services blob >> setupoutput.log && echo "OK"

# Get storage account key
echo -n "Storage account key ..."
ACCOUNT_KEY=$(az storage account keys list --resource-group $TERRAGOAT_RESOURCE_GROUP --account-name $TERRAGOAT_STATE_STORAGE_ACCOUNT --query [0].value -o tsv) >> setupoutput.log && echo "OK"

# Create blob container
echo -n "Blob container ..."
az storage container create --name $TERRAGOAT_STATE_CONTAINER --account-name $TERRAGOAT_STATE_STORAGE_ACCOUNT --account-key $ACCOUNT_KEY >> setupoutput.log && echo "OK"

# Fetch object_id
objectId=$(az ad signed-in-user show --query objectId)
if [ -f "variables.tf" ] && [ $(cat "variables.tf" | grep 'object_id' | wc -l) -eq 1 ]
then
        echo -n "objectId variable already exists, updating ..."
        sed -i 's/default.*/default     = '$objectId'/g' variables.tf && echo "OK"
else
        echo -n "Pushing objectId into variables.tf ..."
        echo '
variable "object_id" {
  type        = string
  description = "The object ID of the current user"
  default     = '$objectId'
}' >> variables.tf && echo "OK"
fi

echo "Terraform init ..."
terraform init -reconfigure -backend-config="resource_group_name=$TERRAGOAT_RESOURCE_GROUP" \
    -backend-config "storage_account_name=$TERRAGOAT_STATE_STORAGE_ACCOUNT" \
    -backend-config="container_name=$TERRAGOAT_STATE_CONTAINER" \
    -backend-config "key=$TF_VAR_environment.terraform.tfstate" >> setupoutput.log && echo "OK"

echo "Terraform plan ..."
terraform plan > plan.log && echo "OK (saved as plan.log)"

read -p "Apply ? [Y/N]" resp

if [ "$resp" == "Y" ] || [ "$resp" == "y" ] || [ "$resp" == "yes" ]
then
    terraform apply >> creationtime.log
else
    exit
fi

read -p "Destroy resource group ? [Y/N]" resp

if [ "$resp" == "Y" ] || [ "$resp" == "y" ] || [ "$resp" == "yes" ] 
then
    az group delete --resource-group $TERRAGOAT_RESOURCE_GROUP --yes
    az group delete --resource-group "terragoat-"$TF_VAR_environment --yes 
    az group delete --resource-group "NetworkWatcherRG" --yes
fi

