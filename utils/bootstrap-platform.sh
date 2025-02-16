#!/bin/bash

set -e

AZ_SUBSCRIPTION="conquerproject-dev"
RESOURCE_GROUP="rg-conquerplatform-dev-01"
AKS_NAME="aks-conquerproject-dev-01"
TERRAGRUNT_CONFIG="$(git rev-parse --show-toplevel)/infrastructure/azure/dev/ephemeral/aks/terragrunt.hcl"
BOOTSTRAP_ARGOCD="$(git rev-parse --show-toplevel)/argocd/argocd-bootstrap/argocd-bootstrap.sh"

# Set Azure Subscription
az account set --subscription "$AZ_SUBSCRIPTION"

usage() {
    echo "Usage: $0 [--apply] [--destroy]"
    exit 1
}

bootstrap_platform() {
    printf "Provisioning Conquer Platform...\n\n"
    terragrunt --terragrunt-config "$TERRAGRUNT_CONFIG" apply --auto-approve

    # TODO: Move to terraform
    # Create AZ managed identity for cert-manager
    export AZURE_DEFAULTS_GROUP="$RESOURCE_GROUP"
    export DOMAIN_NAME="conquerproject.io"
    export USER_ASSIGNED_IDENTITY_NAME="cert-manager"

    az identity create --name "${USER_ASSIGNED_IDENTITY_NAME}"

    # Grant it permission to manage DNS Zone records
    USER_ASSIGNED_IDENTITY_CLIENT_ID=$(az identity show --name "${USER_ASSIGNED_IDENTITY_NAME}" --query 'clientId' -o tsv)
    export USER_ASSIGNED_IDENTITY_CLIENT_ID
    az role assignment create \
        --role "DNS Zone Contributor" \
        --assignee "$USER_ASSIGNED_IDENTITY_CLIENT_ID" \
        --scope "$(az network dns zone show --name "$DOMAIN_NAME" -o tsv --query id)"

    # Add a federated identity for cert-manager
    export SERVICE_ACCOUNT_NAME=cert-manager # ℹ️ This is the default Kubernetes ServiceAccount used by the cert-manager controller.
    export SERVICE_ACCOUNT_NAMESPACE=cert-manager # ℹ️ This is the default namespace for cert-manager.

    SERVICE_ACCOUNT_ISSUER=$(az aks show --resource-group "$AZURE_DEFAULTS_GROUP" --name "$AKS_NAME" --query "oidcIssuerProfile.issuerUrl" -o tsv)
    export SERVICE_ACCOUNT_ISSUER
    az identity federated-credential create \
        --name "cert-manager" \
        --identity-name "${USER_ASSIGNED_IDENTITY_NAME}" \
        --issuer "${SERVICE_ACCOUNT_ISSUER}" \
        --subject "system:serviceaccount:${SERVICE_ACCOUNT_NAMESPACE}:${SERVICE_ACCOUNT_NAME}"


    # Create kubeconfig file
    az aks get-credentials --resource-group "$RESOURCE_GROUP" --name "$AKS_NAME" --overwrite-existing --admin

    # Deploy ArgoCD
    printf "\n\n" && printf "Deploying ArgoCD...\n"
    bash "$BOOTSTRAP_ARGOCD"
    sleep 30

    # Add azure credentials for external-dns
    # TODO: create sealed-secret
    kubectl apply -f "$(git rev-parse --show-toplevel)/argocd/defaults/external-dns/manifests/secrets/"
    kubectl delete pod -n kube-tools -l app.kubernetes.io/instance=external-dns
}

destroy_platform() {
    printf "Destroying AKS...\n\n"
    terragrunt --terragrunt-config "$TERRAGRUNT_CONFIG" destroy --auto-approve
}

main() {
    case "$1" in
        --apply) bootstrap_platform; shift;;
        --destroy) destroy_platform; shift;;
        *) usage;;
    esac
}

main "$1"
