TerraGoat is Bridgecrew's "Vulnerable by Design" Terraform repository.</br>
This TerraGoat's version is designed to be deployed on free subscription account.
# Terragoat
![terragoat-logo](https://user-images.githubusercontent.com/61518622/110116638-0ff37500-7db8-11eb-94f6-8e7151f0112a.png)

## Important notes
* Where to get help: the [Bridgecrew Community Slack](https://slack.bridgecrew.io/?utm_source=github&utm_medium=organic_oss&utm_campaign=terragoat) </br>

Before you proceed please take a not of these warning: </br>

>**⚠️ TerraGoat creates intentionally vulnerable resources into your account. DO NOT deploy TerraGoat in a production environment or alongside any sensitive resources.**

## Requirements
* Terraform 0.12
* azure cli

## Installation
### [1] clone repo
git clone https://github.com/Meruem96/terragoat.git </br>
### [2] log in azure portal 
az login </br>

## Execution
* cd terragoat </br>
* bash setup.sh </br>
>**Apply takes ≈ 7 minutes**

## Possible errors
**For every possible error, re apply terraform after a minute may correct it**

#### [1] Error: retrieving `contact` for KeyVault
wait a minute then : </br>
terraform apply

#### [1] Error like : subscription id not found 
open variables.tf then delete the '**object_id**' block :</br>
>variable "object_id" { </br>
 >&nbsp;&nbsp;&nbsp;&nbsp; type        = string</br>
 >&nbsp;&nbsp;&nbsp;&nbsp; description = "The object ID of the current user"</br>
 >&nbsp;&nbsp;&nbsp;&nbsp; default     = ***</br>
>}</br>

