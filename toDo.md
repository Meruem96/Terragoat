### 1 - Change location of every resources to an unique one
### 2 - Comment policies, rules and stuff like that to only create resources
### 3 - Add multiple creations on the 2 RG already created for tests
``` bash
cd terraform/aws/
export TF_VAR_environment = $TERRAGOAT_ENV
for i in $(seq 1 $TERRAGOAT_STACKS_NUM)
do
    export TF_VAR_environment=$TERRAGOAT_ENV$i
    terraform init \
    -backend-config="bucket=$TERRAGOAT_STATE_BUCKET" \
    -backend-config="key=$TF_VAR_company_name-$TF_VAR_environment.tfstate" \
    -backend-config="region=$TF_VAR_region"

    terraform destroy -auto-approve
done
```
### 4 - Make some tests
#### 4.1 - Change kubernetes version or location 
│ Error: creating Managed Kubernetes Cluster "terragoat-aks-dev" (Resource Group "RG_TP_Azure_Hardening_01"): containerservice.ManagedClustersClient#CreateOrUpdate: Failure sending request: StatusCode=400 -- Original Error: Code="AgentPoolK8sVersionNotSupported" Message="Version 1.18.19 is not supported in this region. Please use [az aks get-versions] command to get the supported version list in this region. For more information, please check https://aka.ms/supported-version-list"
│
│   with azurerm_kubernetes_cluster.k8s_cluster,
│   on aks.tf line 1, in resource "azurerm_kubernetes_cluster" "k8s_cluster":
│    1: resource azurerm_kubernetes_cluster "k8s_cluster" {
#### 4.2 - Change network watcher location 
│ Error: network.WatchersClient#CreateOrUpdate: Failure responding to request: StatusCode=400 -- Original Error: autorest/azure: Service returned an error. Status=400 Code="NetworkWatcherCountLimitReached" Message="Cannot create more than 1 network watchers for this subscription in this region." Details=[]
│
│   with azurerm_network_watcher.network_watcher,
│   on networking.tf line 74, in resource "azurerm_network_watcher" "network_watcher":
│   74: resource "azurerm_network_watcher" "network_watcher" {
#### 4.3 - Security write pricings error, not enough rights 
│ Error: Creating/updating Security Center Subscription pricing: security.PricingsClient#Update: Failure responding to request: StatusCode=403 -- Original Error: autorest/azure: Service returned an error. Status=403 Code="AuthorizationFailed" Message="The client 'clegoupil@beijaflorecyberrsoutlook.onmicrosoft.com' with object id '30cd8c2d-906b-450f-a540-5d6198cf2eea' does not have authorization to perform action 'Microsoft.Security/pricings/write' over scope '/subscriptions/a4038696-ce0f-492d-9049-38720738d4fe' or the scope is invalid. If access was recently granted, please refresh your credentials."
│
│   with azurerm_security_center_subscription_pricing.pricing,
│   on security_center.tf line 1, in resource "azurerm_security_center_subscription_pricing" "pricing":
│    1: resource azurerm_security_center_subscription_pricing "pricing" {
