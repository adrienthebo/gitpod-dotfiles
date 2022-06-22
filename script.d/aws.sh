#!/bin/bash
#
# Set up AWS resources.




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

main() {
  setup
  echo "Install awscliv2"
  install_awscliv2
  echo "Install eksctl"
  install_eksctl
}
