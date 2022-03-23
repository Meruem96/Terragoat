
#!/bin/bash
export TERRAGOAT_STATE_CONTAINER="mydevsecops"
export TF_VAR_environment="dev"
export TF_VAR_region="francecentral"
export TERRAGOAT_STACKS_NUM=3

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
            
    #terraform plan -var sa_id=$TERRAGOAT_ID_STORAGE_ACCOUNT -var rg_name=$TERRAGOAT_RESOURCE_GROUP -out plan$i
    terraform apply -var sa_id=$TERRAGOAT_ID_STORAGE_ACCOUNT -var rg_name=$TERRAGOAT_RESOURCE_GROUP
    done
fi


read -p "Next step : Destroy. Continue ? [Y/N] " resp
if ! ([ "$resp" == "Y" ] || [ "$resp" == "y" ] || [ "$resp" == "yes" ] || [ "$resp" == "Yes" ]); then exit; fi


for i in $(seq 1 $TERRAGOAT_STACKS_NUM)
do
  export TERRAGOAT_RESOURCE_GROUP="RG_TP_Azure_Hardening_0"$i
  export TERRAGOAT_STATE_STORAGE_ACCOUNT="tpazureterragoatmodsa0"$i
  terraform init -migrate-state -backend-config="resource_group_name=$TERRAGOAT_RESOURCE_GROUP" \
    -backend-config="storage_account_name=$TERRAGOAT_STATE_STORAGE_ACCOUNT" \
    -backend-config="container_name=$TERRAGOAT_STATE_CONTAINER" \
    -backend-config="key=$TF_VAR_environment.terraform.tfstate"
    
    terraform destroy -var sa_id=$TERRAGOAT_ID_STORAGE_ACCOUNT -var rg_name=$TERRAGOAT_RESOURCE_GROUP


done



exit
"""
#!/bin/bash

export TERRAGOAT_RESOURCE_GROUP="RG_TP_Azure_Hardening_01"
export TERRAGOAT_STATE_CONTAINER="mydevsecops"
export TERRAGOAT_STATE_STORAGE_ACCOUNT="terragoatmodsa"
export TF_VAR_environment="dev"
export TERRAGOAT_RESOURCE_GROUP_ID=`az group show --name $TERRAGOAT_RESOURCE_GROUP --query id --output tsv`
export TF_VAR_region="francecentral"


function init {
    # Create resource group, storage account & backend configuration
    read -p "Init ? (Initialisation of TerraGoat environment) [Y/N] " resp
    if ! ([ "$resp" == "Y" ] || [ "$resp" == "y" ] || [ "$resp" == "yes" ] || [ "$resp" == "Yes" ]); then exit; fi

    # Create the storage account if it not already exists
    # Change this part to check if a storage account containing "terragoatmodsa"1234 already exists -> use it or create it
    echo "Storage account :"
    # create storage account if storage account does not exists else change storage account name then create it
    if [[ "$(az storage account check-name --name $TERRAGOAT_STATE_STORAGE_ACCOUNT --query "nameAvailable")" == "false" ]]
    then 
    echo "Storage account already created."
    else
    az storage account create --name $TERRAGOAT_STATE_STORAGE_ACCOUNT --resource-group $TERRAGOAT_RESOURCE_GROUP --location $TF_VAR_region --sku Standard_LRS --kind StorageV2 --https-only true --encryption-services blob && echo "Storage account ...OK"
    fi  
    
    # Get storage account key
    echo -n "Storage account key ..."
    ACCOUNT_KEY=$(az storage account keys list --resource-group $TERRAGOAT_RESOURCE_GROUP --account-name $TERRAGOAT_STATE_STORAGE_ACCOUNT --query [0].value -o tsv) && echo "OK"

    # Create blob container
    echo -n "Blob container ..."; echo "Blob container : " 
    az storage container create --name $TERRAGOAT_STATE_CONTAINER --account-name $TERRAGOAT_STATE_STORAGE_ACCOUNT --account-key $ACCOUNT_KEY && echo "OK"

    # Start terraform init with backend configuration
    echo -n "Terraform init ..."; echo "Terraform init : "
    terraform init -reconfigure -backend-config="resource_group_name=$TERRAGOAT_RESOURCE_GROUP" \
        -backend-config "storage_account_name=$TERRAGOAT_STATE_STORAGE_ACCOUNT" \
        -backend-config="container_name=$TERRAGOAT_STATE_CONTAINER" \
        -backend-config "key=$TF_VAR_environment.terraform.tfstate" && echo "OK"
    
    # Import the resource group
    terraform plan -var "rg_name=$TERRAGOAT_RESOURCE_GROUP" -out plan
}

function apply {
    # Apply = create resources
    read -p "Apply ? (Launch scripts = create the environement) [Y/N] " resp
    if ! ([ "$resp" == "Y" ] || [ "$resp" == "y" ] || [ "$resp" == "yes" ] || [ "$resp" == "Yes" ]); then exit; fi
    start=`date +%s`
    terraform apply -var "rg_name=$TERRAGOAT_RESOURCE_GROUP" -auto-approve
    end=`date +%s`
    echo "Apply took $((end-start))s"

}

function destroy {
    # Destroy what has been applied + all ressource groups : just to be sure 
    read -p "Destroy ? (Erase everything terraform created)[Y/N] " resp
    if ! ([ "$resp" == "Y" ] || [ "$resp" == "y" ] || [ "$resp" == "yes" ] || [ "$resp" == "Yes" ]); then exit; fi
    terraform destroy -var "rg_name=$TERRAGOAT_RESOURCE_GROUP" -auto-approve && echo "Terraform destroy complete" || echo -e "Probleme with terraform destroy. \n! Do not delete resource groups, re destroy !\n"

    read -p "Delete resource groups ? (N: If you plan to re apply) [Y/N] " resp
    if [ "$resp" == "Y" ] || [ "$resp" == "y" ] || [ "$resp" == "yes" ] || [ "$resp" == "Yes" ]
    then
        if [[ "$(az group exists --name $TERRAGOAT_RESOURCE_GROUP)" != "false" ]]; then az group delete --resource-group $TERRAGOAT_RESOURCE_GROUP --yes && echo "Resource group erased: $TERRAGOAT_RESOURCE_GROUP "; fi
            
        if [[ "$(az group exists --name terragoat-$TF_VAR_environment)" != "false" ]]; then az group delete --resource-group "terragoat-"$TF_VAR_environment --yes && echo "Resource group erased: terragoat-$TF_VAR_environment"; fi

        if [[ "$(az group exists --name "NetworkWatcherRG")" != "false" ]]; then az group delete --resource-group "NetworkWatcherRG" --yes && echo "Resource group erased: NetworkWatcherRG "; fi
    fi
}

function purge {
    # Force erase every resource
    read -p "Purge ? (If you had any error, cancel the apply or you want to clean the env respond Y) [Y/N] " resp
    if ! ([ "$resp" == "Y" ] || [ "$resp" == "y" ] || [ "$resp" == "yes" ] || [ "$resp" == "Yes" ]); then exit; fi
    
    # Delete if resource groups still exists else pass
    if [[ "$(az group exists --name $TERRAGOAT_RESOURCE_GROUP)" != "false" ]]; then az group delete --resource-group $TERRAGOAT_RESOURCE_GROUP --yes && echo "Resource group erased 1/3"; fi
    
    if [[ "$(az group exists --name terragoat-$TF_VAR_environment)" != "false" ]]; then az group delete --resource-group "terragoat-"$TF_VAR_environment --yes && echo "Resource group erased 2/3"; fi
    
    if [[ "$(az group exists --name "NetworkWatcherRG")" != "false" ]]; then az group delete --resource-group "NetworkWatcherRG" --yes && echo "Resource group erased 3/3"; fi

    # Delete log-profiles if still exists else pass
    az monitor log-profiles list --query "[].{id:id, name:name}" > log_profiles
    log_profile_count=$(cat log_profiles | grep "id" | grep -i "terragoat" | wc -l)
    if [[ $log_profile_count -ge 1 ]]; then az monitor log-profiles delete --name $(cat log_profiles | grep 'id' -A1 | grep 'name' | tr -d ' ' | cut -d':' -f2 | tr -d '"') ; fi
    rm log_profiles

    # delete policies, roles, security contact
    az policy assignment delete --name "terragoat-policy-assignment-dev"  
    az policy definition delete --name "terragoat-policy-dev" 

    az role definition list --query "[].{description:description, name:name}" > tmproles
    nb_roles=$(cat tmproles | grep 'This is a custom role created via Terraform' -A1 | grep 'name' | tr -d ' ' | cut -d':' -f2 | wc -l)
    roles=$(cat tmproles | grep 'This is a custom role created via Terraform' -A1 | grep 'name' | tr -d ' ' | cut -d':' -f2)
    rm tmproles
    for nb in $(seq 1 $nb_roles)
    do
        az role definition delete --name $(echo $roles | cut -d' ' -f$nb | tr -d ' ' | tr -d '"') 
    done
    

    az security contact delete --name "default1"  
    echo "Purge complete."
}

# Verify if .logs directory exists
#if ! [ -d .logs ]; then
#    mkdir .logs
#fi

if [ "$1" == "init" ] || [ "$1" == "-i" ]; then init && apply 
elif [ "$1" == "apply" ] || [ "$1" == "-a" ]; then apply
elif [ "$1" == "destroy" ] || [ "$1" == "-d" ]; then destroy    
elif [ "$1" == "purge" ] || [ "$1" == "-p" ]; then purge
else
    #### OPTION MESSAGE
    echo -e "Usage:"
    echo -e "\tStart init process : bash setup.sh [init / -i]"
    echo -e "\tStart setup process: bash setup.sh [apply / -a]"
    echo -e "\tDestroy environment: bash setup.sh [destroy / -d]"
    echo -e "\tPurge environment  : bash setup.sh [purge / -p]"
    echo -e "*********************************************************"
fi
"""


