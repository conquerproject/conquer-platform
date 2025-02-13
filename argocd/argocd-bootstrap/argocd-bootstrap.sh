#!/bin/bash

# https://gist.github.com/mohanpedala/1e2ff5661761d3abd0385e8223e16425
set -euo pipefail   # -u: unset variables cause an error.
                    # -e: abort execution if any command return exit code != 0
                    # -o pipefail: If any command in a pipeline fails, that return code will be used as the return code of the whole pipeline

argo_appset="$(git rev-parse --show-toplevel)/argocd/applicationsets/tools/argocd.yaml"
root_app="$(git rev-parse --show-toplevel)/argocd/applications/root.yaml"

namespace="$(yq -r ".metadata.namespace" "$argo_appset")"
chart_repo="$(yq -r ".spec.template.spec.sources[1].repoURL" "$argo_appset")"
chart_name="$(yq -r ".spec.template.spec.sources[1].chart" "$argo_appset")"
chart_version="$(yq -r ".spec.template.spec.sources[1].targetRevision" "$argo_appset")"
chart_values="$(git rev-parse --show-toplevel)/argocd/defaults/argocd/values.yaml"
helm_release="$(yq -r ".spec.template.spec.sources[1].helm.releaseName" "$argo_appset")"

# Install ArgoCD
install_argo() {
    helm upgrade "$helm_release" "$chart_name" --install \
      --values "$chart_values" \
      --version "$chart_version" \
      --dependency-update \
      --description "ArgoCD" \
      --output table \
      --wait \
      --wait-for-jobs \
      --repo "$chart_repo" \
      --namespace "$namespace" \
      --create-namespace
}

apply_root_app() {
    kubectl apply -f "$root_app"
}

# Get default admin password
output_admin_password() {
    echo "-------------------"
    echo "Initial ArgoCD Admin Password:"
    kubectl -n argocd get secret argocd-initial-admin-secret \
        -o jsonpath="{.data.password}" | base64 -d; echo
    echo "-------------------"
}

# expose argocd service and access it on https://localhost:8080
port_forward() {
    echo "ArgoCD Web UI accessible through http://localhost:8080"
    kubectl port-forward -n argocd service/argocd-server 8080:80
}


main() {
    install_argo
    apply_root_app
    output_admin_password
#    port_forward
}

main
