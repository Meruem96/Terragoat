#!/bin/bash
source exports

az group delete --resource-group $TERRAGOAT_RESOURCE_GROUP 2>&1 destroyoutput.log && echo "$TERRAGOAT_RESOURCE_GROUP resource group deleted"
az group delete --resource-group "terragoat-"$TF_VAR_environment 2>&1 destroyoutput.log && echo "terragoat-"$TF_VAR_environment" resource group deleted"
az group delete --resource-group "NetworkWatcherRG" 2>&1 destroyoutput.log && echo "NetworkWatcherRG resource group deleted 
