#!/bin/bash

# vault-to-sealedsecret.sh demo /Users/yogeshhullatti/Documents/Solirius/cnp-flux-config/k8s/demo/pub-cert.pem em-bundling-test

env=aat
cert=/Users/yogeshhullatti/Documents/Solirius/cnp-flux-config/k8s/demo/pub-cert.pem
namespace=evidence-mment
secrets=(
    'ccd|dm-store-storage-account-primary-connection-string'
    'ccd|dm-store-storage-account-secondary-connection-string'
)

for i in "${secrets[@]}"; do
    vault=$(echo "$i" | awk -F'|' '{print $1}')-$env
    name=$(echo "$i" | awk -F'|' '{print $2}')
    secret=$(az keyvault secret show --vault-name $vault --name $name -o tsv --query value)

    # kubectl delete secret $vault-$name

    kubectl create secret generic $name \
        --from-literal key=$secret \
        --namespace $namespace \
        -o json > $name.json

    kubeseal --format=yaml --cert=$cert < $name.json > ../sealed-secrets/$name.yaml

    # rm -f $team-$name.json

done
