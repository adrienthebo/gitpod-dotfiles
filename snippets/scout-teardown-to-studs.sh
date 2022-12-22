#!/usr/bin/env bash

set -euo pipefail

bootstrap/deployment/util/stagehand:install

aws s3 rm --recursive s3://$(stagehand get control-bucket cluster)
aws s3 rm --recursive s3://$(stagehand get control-bucket application)

eksctl delete cluster --cluster $CELL_NAME-workspace
eksctl delete cluster --cluster $CELL_NAME-meta

TF_ENFORCE=2 leeway run bootstrap/deployment/stages/05_lambdas:run
TF_ENFORCE=2 leeway run bootstrap/deployment/stages/04_services:run
TF_ENFORCE=2 leeway run bootstrap/deployment/stages/03_ingress:run
TF_ENFORCE=2 leeway run bootstrap/deployment/stages/03_ingress:run
TF_ENFORCE=2 leeway run bootstrap/deployment/stages/02_vpc:run