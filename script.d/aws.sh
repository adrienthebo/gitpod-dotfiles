#!/bin/bash
#
# Set up AWS resources.

set -x



cleanup() {
  if [[ $WORKDIR != "" ]]; then
    rm -rf "$WORKDIR"
  fi
}

setup() {
  WORKDIR="$(mktemp -d)"
  cd $WORKDIR
  trap cleanup EXIT
}

install_awscliv2() {
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
}

install_eksctl() {
  curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" \
  | tar -xzf - -O \
  | sudo tee /usr/local/bin/eksctl > /dev/null
  sudo chmod +x /usr/local/bin/eksctl
}

create_awsconfig() {
  if [ ! -d ~/.aws ]; then
    mkdir ~/.aws
  fi

  if [[ $AWS_SSO_URL != "" ]]; then
    cat <<- AWSFILE > ~/.aws/config
    [default]
    sso_start_url = ${AWS_SSO_URL}
    sso_region = ${AWS_SSO_REGION}
    sso_account_id = ${AWS_ACCOUNT_ID}
    sso_role_name = ${AWS_ROLE_NAME}
    region = eu-west-1
    AWSFILE
  fi
}

main() {
  setup
  echo "Install awscliv2"
  install_awscliv2
  echo "Install eksctl"
  install_eksctl
  echo "Create aws config"
  create_awsconfig
}


