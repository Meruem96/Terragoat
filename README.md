# terragoat

## Installation
### 1- clone repo
git clone https://github.com/Meruem96/terragoat.git </br>
### 2- log in azure portal 
az login </br>

## Execution
cd terragoat </br>
bash setup.sh </br>
Apply takes ≈ **7 minutes**

## Possibles error
#### Error like : subscription id not found 
open variables.tf then delete the '**object_id**' block
looks like :</br>
>variable "object_id" { </br>
 >&nbsp;&nbsp;&nbsp;&nbsp; type        = string</br>
 >&nbsp;&nbsp;&nbsp;&nbsp; description = "The object ID of the current user"</br>
 >&nbsp;&nbsp;&nbsp;&nbsp; default     = ***</br>
>}</br>
