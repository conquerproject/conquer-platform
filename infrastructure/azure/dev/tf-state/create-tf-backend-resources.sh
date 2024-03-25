#!/bin/bash

set -o nounset                              # Treat unset variables as an error

subscription_id="$(grep  "^subscription_id" ../az-dev-constants.yaml | awk '{print $2}' | sed 's/"//g')"
environment="$(grep  "^environment" ../az-dev-constants.yaml | awk '{print $2}' | sed 's/"//g')"
region="$(grep  "^region" ../az-dev-constants.yaml | awk '{print $2}' | sed 's/"//g')"
app="tfstate"

resourceGroupName="rg-$app-$environment-$region-001"
storageAccountName="stg${app}${environment}${region}001"
containerName="$app"
location="$region"

# Select conquerproject Subscription
az account set --subscription "$subscription_id"

# Create a resource group
if [[ "$(az group list --output json | jq -r --arg rg "$resourceGroupName" '.[] | select(.name == $rg) | .name')" != "$resourceGroupName" ]]; then
    az group create --name "$resourceGroupName" --location "$location"
    az group wait --create --name "$resourceGroupName"
    echo "Resource Group $resourceGroupName created"
else
    echo "RG $resourceGroupName already in place"
fi

# Create a storage account
if [[ ! "$(az storage account list -o json | jq -r --arg stg "$storageAccountName" '.[] | select(.name == $stg) | .name')" ]]; then
    az storage account create --name $storageAccountName --resource-group $resourceGroupName --sku Standard_LRS

    while [[ "$(az storage account show --name $storageAccountName --resource-group $resourceGroupName --query "provisioningState" -o tsv)" != "Succeeded" ]]; do
        echo "Waiting for storage account creation to complete..."
        sleep 3
    done
    echo "Storage Account $storageAccountName created"
else
    echo "Storage Account $storageAccountName already in place"
fi

# Create Storage Container
accountKey=$(az storage account keys list --resource-group $resourceGroupName --account-name $storageAccountName --query "[0].value" --output tsv)

if [[ "$(az storage container list --account-name $storageAccountName --account-key "$accountKey" | jq -r --arg containerName "$containerName" '.[] | select(.name == $containerName) | .name')" != "$containerName" ]]; then
    az storage container create --account-name "$storageAccountName" --account-key "$accountKey" --name "$containerName"
    echo "Storage Container $containerName created"
else
    echo "Storage Container already in place"
fi
printf "\n Azure resources created successfully!"
