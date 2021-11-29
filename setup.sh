#!/bin/bash
export TERRAGOAT_STATE_CONTAINER="mydevsecops"
export TF_VAR_environment="dev"
export TF_VAR_region="francecentral"
export TERRAGOAT_STACKS_NUM=1

for i in $(seq 1 $TERRAGOAT_STACKS_NUM)
do
  export TERRAGOAT_RESOURCE_GROUP="RG_TP_Azure_Hardening_0"$i
  export TERRAGOAT_STATE_STORAGE_ACCOUNT="tpazureterragoatmodsa0"$i
  # create storage account if storage account does not exists else change storage account name then create it
  if [[ "$(az storage account check-name --name $TERRAGOAT_STATE_STORAGE_ACCOUNT --query "nameAvailable")" == "false" ]]
  then 
  echo "Storage account already created."
  else
  az storage account create --name $TERRAGOAT_STATE_STORAGE_ACCOUNT --resource-group $TERRAGOAT_RESOURCE_GROUP --location $TF_VAR_region --sku Standard_LRS --kind StorageV2 --https-only true --encryption-services blob && echo "Storage account ...OK"
  fi  

  # Retreive storage account key
  ACCOUNT_KEY=$(az storage account keys list --resource-group $TERRAGOAT_RESOURCE_GROUP --account-name $TERRAGOAT_STATE_STORAGE_ACCOUNT --query [0].value -o tsv) >> $setupoutput && echo "OK"
  
  # Create blob container
  az storage container create --name $TERRAGOAT_STATE_CONTAINER --account-name $TERRAGOAT_STATE_STORAGE_ACCOUNT --account-key $ACCOUNT_KEY >> $setupoutput && echo "OK"
  
  # Init terraform
  terraform init -reconfigure -backend-config="resource_group_name=$TERRAGOAT_RESOURCE_GROUP" \
        -backend-config "storage_account_name=$TERRAGOAT_STATE_STORAGE_ACCOUNT" \
        -backend-config="container_name=$TERRAGOAT_STATE_CONTAINER" \
        -backend-config "key=$TF_VAR_environment.terraform.tfstate"
        
  terraform plan -var "rg_name=$TERRAGOAT_RESOURCE_GROUP" -out "plan$i"
  terraform apply -var "rg_name=$TERRAGOAT_RESOURCE_GROUP"
  
done
