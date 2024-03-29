#!/usr/bin/env bash

#
# installer-tests: setup sh-automated-tests configuration
#

gcloud config configurations create sh-automated-tests
gcloud config set core/project sh-automated-tests
tmpfile="$(mktemp)"
key="$(kubectl get secret sh-playground-sa-perm --context dev --namespace werft -ojson \
| jq -r '.data["sh-sa.json"] | @base64d' | tee $tmpfile)"
gcloud auth activate-service-account "$(jq -r .client_email < $tmpfile)" --key-file <(echo "$key")
gcloud config set compute/zone europe-west1-d
