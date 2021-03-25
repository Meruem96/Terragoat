# Terragoat

![terragoat-logo](https://user-images.githubusercontent.com/61518622/110116638-0ff37500-7db8-11eb-94f6-8e7151f0112a.png)

## Important notes

* Where to get help: the [Bridgecrew Community Slack](https://slack.bridgecrew.io/?utm_source=github&utm_medium=organic_oss&utm_campaign=terragoat) </br>

TerraGoat is Bridgecrew's "Vulnerable by Design" Terraform repository.</br>

This TerraGoat's version is designed to be deployed on free subscription account.

Before you proceed please take a not of these warning: </br>

>**⚠️ TerraGoat creates intentionally vulnerable resources into your account. DO NOT deploy TerraGoat in a production environment or alongside any sensitive resources.**

## Requirements

### **Azure portal**</br>

* Cloud shell (top right)</br>

### **Other**

* A shell with:</br>
  * [_installation_](https://learn.hashicorp.com/tutorials/terraform/install-cli) Terraform 0.12
  * [_installation_](https://docs.microsoft.com/fr-fr/cli/azure/install-azure-cli) azure cli
  * [_installation_](https://git-scm.com/book/fr/v2/D%C3%A9marrage-rapide-Installation-de-Git) git

## Installation

>**If you are on Azure portal, open a Cloud Shell by clicking on the cmd logo (top right).**</br>
>**If you are on a personnal computer, open a shell.**

### [1] clone repo

git clone <https://github.com/Meruem96/terragoat.git> </br>

### [2] log in azure portal

az login </br>

## Execution

* cd terragoat </br>
* bash setup.sh </br>

>If you are ready to build the env respond Y to "Apply"</br>
>**Apply takes ≈ 10 minutes**

## Deletion

* If the apply succeded without any mistake use the destroy option : bash setup.sh destroy
* If errors occurend and you want to start again from scratch purge every resource : bash setup.sh purge

## Logs

In analyse purpose, logs can be found in '.logs' folder

* setupoutput.log :: every resource created with azure cli
* clearTextplan.log :: plan output of terraform scripts

## Possible errors

>**For every possible error, re apply**

### [1] Restart the script

* Error: retrieving **contact** for KeyVault
* Error loading state: Error retrieving keys for Storage Account
* Error about a resource name already taken

>every case sensitive resource names are created with a random value at the end to avoid this error, but sometimes you can be out of luck ... </br>
>restarting the script will correct the error

### [2] Error like : subscription id not found

>open variables.tf then delete the '**object_id**' block :</br>
>~~variable "object_id" { </br>
 >&nbsp;&nbsp;&nbsp;&nbsp; type        = string</br>
 >&nbsp;&nbsp;&nbsp;&nbsp; description = "The object ID of the current user"</br>
 >&nbsp;&nbsp;&nbsp;&nbsp; default     = *** </br>
 >}~~</br>
