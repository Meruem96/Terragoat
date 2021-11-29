#!/bin/bash
export TERRAGOAT_RESOURCE_GROUP="RG_TP_Azure_Hardening_02"
export TERRAGOAT_STATE_CONTAINER="mydevsecops"
export TERRAGOAT_STATE_STORAGE_ACCOUNT="terragoatmodsa"
export TF_VAR_environment="dev"
export TERRAGOAT_RESOURCE_GROUP_ID=`az group show --name $TERRAGOAT_RESOURCE_GROUP --query id --output tsv`
export TF_VAR_region="francecentral"
