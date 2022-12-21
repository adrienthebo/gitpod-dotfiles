#!/usr/bin/env bash

set -euo pipefail

kubectl get configmap gitpod-app -ojsonpath='{.data.app\.yaml}' | kubectl delete -f -

aws ssm delete-parameter --name /cell/$CELL_NAME/service/rds || true

leeway build bootstrap/lambdas:application
leeway run bootstrap/deployment/stages/05_lambdas:update-images
TF_ENFORCE=1 leeway run bootstrap/deployment/stages/04_services:run
TF_ENFORCE=1 leeway run bootstrap/deployment/stages/05_lambdas:run

export CELL_INSTALLER_IMAGE="eu.gcr.io/gitpod-core-dev/build/installer:aledbf-labels.17"

leeway run bootstrap/lambdas/application/addons/manifests:publish-addons-bundle   -DclusterName="${CELL_NAME}-meta" -DclusterType=meta

echo "Waiting 30s for addons to install"
sleep 30

leeway run bootstrap/lambdas/application:publish-installer-bundle   -DclusterName="${CELL_NAME}-meta" -DclusterType=meta   -Dkind=webapp   -Dimage=$CELL_INSTALLER_IMAGE