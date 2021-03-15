#!/bin/bash
export TERRAGOAT_RESOURCE_GROUP="TerraGoatRG"
export TERRAGOAT_STATE_STORAGE_ACCOUNT="terragoatmodsa"
export TERRAGOAT_STATE_CONTAINER="mydevsecops"
export TF_VAR_environment="dev"
export TF_VAR_region="westus"
racine=".logs/"
setupoutput=$racine"setupoutput.log"
tfplan=$racine"tfplan"

# Verify if .logs directory exists
if ! [ -d .logs ]; then
    mkdir .logs
fi

# Create resource group
echo -n "Resource group ..."; echo "Resource group :" >> $setupoutput
az group create --location $TF_VAR_region --name $TERRAGOAT_RESOURCE_GROUP >> $setupoutput && echo "OK"

# Create storage account
echo "Storage account :" >> $setupoutput
az storage account create --name $TERRAGOAT_STATE_STORAGE_ACCOUNT --resource-group $TERRAGOAT_RESOURCE_GROUP --location $TF_VAR_region --sku Standard_LRS --kind StorageV2 --https-only true --encryption-services blob >> $setupoutput && echo "Storage account ...OK"

# Get storage account key
echo -n "Storage account key ..."
ACCOUNT_KEY=$(az storage account keys list --resource-group $TERRAGOAT_RESOURCE_GROUP --account-name $TERRAGOAT_STATE_STORAGE_ACCOUNT --query [0].value -o tsv) >> $setupoutput && echo "OK"
echo "Storage account key : $ACCOUNT_KEY" >> $setupoutput

# Create blob container
echo -n "Blob container ..."; echo "Blob container : " >> $setupoutput
az storage container create --name $TERRAGOAT_STATE_CONTAINER --account-name $TERRAGOAT_STATE_STORAGE_ACCOUNT --account-key $ACCOUNT_KEY >> $setupoutput && echo "OK"

# Fetch object_id
objectId=$(az ad signed-in-user show --query objectId)
if [ -f "variables.tf" ] && [ $(cat "variables.tf" | grep 'object_id' | wc -l) -eq 1 ]
then
        echo "objectId variable already exists."
else
        echo -n "Pushing objectId into variables.tf ..."
        echo '
variable "object_id" {
  type        = string
  description = "The object ID of the current user"
  default     = '$objectId'
}' >> variables.tf && echo "OK"
fi


# Start terraform init with backend configuration
echo -n "Terraform init ..."; echo "Terraform init : " >> $setupoutput
terraform init -reconfigure -backend-config="resource_group_name=$TERRAGOAT_RESOURCE_GROUP" \
    -backend-config "storage_account_name=$TERRAGOAT_STATE_STORAGE_ACCOUNT" \
    -backend-config="container_name=$TERRAGOAT_STATE_CONTAINER" \
    -backend-config "key=$TF_VAR_environment.terraform.tfstate" >> $setupoutput && echo "OK"


# Exporting plan to $tfplan path, that will be used to apply
echo -n "Exporting plan ..."
terraform plan -out=$tfplan > ".logs/testplan" && echo "OK"

# Apply = create resources annonced in the plan

read -p "Apply ? (Launch scripts = create the environement) [Y/N] " resp
if [ "$resp" == "Y" ] || [ "$resp" == "y" ] || [ "$resp" == "yes" ] || [ "$resp" == "Yes" ]
then
    start=`date +%s`
    terraform apply $tfplan
    end=`date +%s`
    echo "Apply took $((end-start))s"

fi

# Destroy what has been applied + all ressource groups : just to be sure 
read -p "Destroy ? (Erase everything you just created)[Y/N] " resp
if [ "$resp" == "Y" ] || [ "$resp" == "y" ] || [ "$resp" == "yes" ] || [ "$resp" == "Yes" ]
then
    terraform destroy -auto-approve
    az group delete --resource-group $TERRAGOAT_RESOURCE_GROUP --yes
    az group delete --resource-group "terragoat-"$TF_VAR_environment --yes 
    az group delete --resource-group "NetworkWatcherRG" --yes
fi

