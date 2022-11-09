#!/usr/bin/env bash

#
# saas: setup workspace-clusters configuration
#

gcloud config configurations create workspace-clusters || gcloud config configurations activate workspace-cluster
gcloud config set core/account adrien@gitpod.io
gcloud config set core/project workspace-clusters
