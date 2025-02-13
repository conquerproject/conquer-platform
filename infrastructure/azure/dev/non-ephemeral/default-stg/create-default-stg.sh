#!/bin/bash

set -o nounset                              # Treat unset variables as an error

constants_file="$(git rev-parse --show-toplevel)/infrastructure/azure/dev/constants.yaml"

get_value_from_constants() {
    local key="$1"
    grep "^$key" "$constants_file" | awk '{print $2}'
}

subscription_id="$(get_value_from_constants subscription_id)"
default_rg="$(get_value_from_constants default_rg)"
default_stg="$(get_value_from_constants default_stg)"
stg_container="tfstate"

# Select conquerproject Subscription
az account set --subscription "$subscription_id"

# Create a storage account
if [[ ! "$(az storage account list -o json | jq -r --arg stg "$default_stg" '.[] | select(.name == $stg) | .name')" ]]; then
    echo "Creating default Storage Account..."
    az storage account create --name "$default_stg" --resource-group "$default_rg" --sku Standard_LRS

    while [[ "$(az storage account show --name "$default_stg" --resource-group "$default_rg" --query "provisioningState" -o tsv)" != "Succeeded" ]]; do
        echo "Waiting for storage account creation to complete..."
        sleep 3
    done
    echo "Storage Account $default_stg created"
else
    echo "Storage Account $default_stg already in place"
fi

# Create Storage Container
accountKey=$(az storage account keys list --resource-group "$default_rg" --account-name "$default_stg" --query "[0].value" --output tsv)

if [[ "$(az storage container list --account-name "$default_stg" --account-key "$accountKey" | jq -r --arg containerName "$stg_container" '.[] | select(.name == $containerName) | .name')" != "$stg_container" ]]; then
    echo "Creating container for tfstate..."
    az storage container create --account-name "$default_stg" --account-key "$accountKey" --name "$stg_container"
    echo "Storage Container $stg_container created"
else
    echo "Storage Container already in place"
fi
printf "\n Azure resources created successfully!"
