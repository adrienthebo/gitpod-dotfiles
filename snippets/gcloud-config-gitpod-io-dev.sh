#!/usr/bin/env bash

#
# saas: setup gitpod-io-dev configuration
#

gcloud config configurations create gitpod-io-dev || gcloud config configurations activate gitpod-io-dev
gcloud config set core/account adrien@gitpod.io
gcloud config set core/project gitpod-io-dev
gcloud config set compute/zone europe-west1-b
gcloud container clusters get-credentials deployment

echo "kubectl config modified, be sure to activate it"