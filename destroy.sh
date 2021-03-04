#!/bin/bash
source exports

az group delete --resource-group $TERRAGOAT_RESOURCE_GROUP --yes
az group delete --resource-group "terragoat-"$TF_VAR_environment --yes 
az group delete --resource-group "NetworkWatcherRG" --yes
