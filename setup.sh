#!/bin/bash
## Init constant variables
export TERRAGOAT_STATE_CONTAINER="mydevsecops"
export TF_VAR_environment="dev"
export TF_VAR_region="francecentral"
export TERRAGOAT_STACKS_NUM=1

read -p "Init ? [Y/N] " resp
if ([ "$resp" == "Y" ] || [ "$resp" == "y" ] || [ "$resp" == "yes" ] || [ "$resp" == "Yes" ]); then
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

    TERRAGOAT_ID_STORAGE_ACCOUNT=$(az storage account show --name $TERRAGOAT_STATE_STORAGE_ACCOUNT --resource-group $TERRAGOAT_RESOURCE_GROUP --query id --output tsv) && echo "OK"

    # Retreive storage account key
    ACCOUNT_KEY=$(az storage account keys list --resource-group $TERRAGOAT_RESOURCE_GROUP --account-name $TERRAGOAT_STATE_STORAGE_ACCOUNT --query [0].value -o tsv) && echo "OK"
    
    # Create blob container
    if [[ "$(az storage container exists --account-name $TERRAGOAT_STATE_STORAGE_ACCOUNT --name $TERRAGOAT_STATE_CONTAINER --account-key $ACCOUNT_KEY)" == "true" ]]
    then 
    echo "Container already created."
    else
    az storage container create --name $TERRAGOAT_STATE_CONTAINER --account-name $TERRAGOAT_STATE_STORAGE_ACCOUNT --account-key $ACCOUNT_KEY && echo "OK"
    fi
    # Init terraform
    terraform init -reconfigure -backend-config="resource_group_name=$TERRAGOAT_RESOURCE_GROUP" \
            -backend-config="storage_account_name=$TERRAGOAT_STATE_STORAGE_ACCOUNT" \
            -backend-config="container_name=$TERRAGOAT_STATE_CONTAINER" \
            -backend-config="key=$TF_VAR_environment.terraform.tfstate"

    echo "" > tf_variables.tfvars
    echo 'sa_id = "'$TERRAGOAT_ID_STORAGE_ACCOUNT'"' >> tf_variables.tfvars
    echo 'rg_name = "'$TERRAGOAT_RESOURCE_GROUP'"' >> tf_variables.tfvars
            
    terraform plan -var-file=tf_variables.tfvars -out plan$i
    terraform apply -var-file=tf_variables.tfvars
    done
fi


read -p "Next step : Destroy. Continue ? [Y/N] " resp
if ! ([ "$resp" == "Y" ] || [ "$resp" == "y" ] || [ "$resp" == "yes" ] || [ "$resp" == "Yes" ]); then exit; fi


for i in $(seq 1 $TERRAGOAT_STACKS_NUM)
do
  export TERRAGOAT_RESOURCE_GROUP="RG_TP_Azure_Hardening_0"$i
  export TERRAGOAT_STATE_STORAGE_ACCOUNT="tpazureterragoatmodsa0"$i
  terraform init -reconfigure -backend-config="resource_group_name=$TERRAGOAT_RESOURCE_GROUP" \
    -backend-config="storage_account_name=$TERRAGOAT_STATE_STORAGE_ACCOUNT" \
    -backend-config="container_name=$TERRAGOAT_STATE_CONTAINER" \
    -backend-config="key=$TF_VAR_environment.terraform.tfstate"
    
    terraform destroy -var-file=tf_variables.tfvars


done



exit