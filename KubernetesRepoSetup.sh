#!/bin/bash
#set -x

# [META]
# About: Kubernetes utility for setting up getting up and many more 
# ReferenceUrl: https://kubernetes.io/blog/2023/08/15/pkgs-k8s-io-introduction/
# Supports: [k8s v1.24 or above] [DEB] [RH]

# ===========================================================script============================================================================

# Function to print messages
BLUE='\033[0;34m'
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
YELLOW='\033[1;33m'

# Display function 
display() {
  echo -e "${1}${2}${NC}"
}

# variables used globaly by the script 
PACKAGE_MANAGER=""

# ===========================================================checks============================================================================

# Package manager check
check_package_manager() {
  if [[ -e /etc/yum.repos.d ]]; then
    PACKAGE_MANAGER="yum"
  elif [[ -e /etc/apt ]]; then
    PACKAGE_MANAGER="apt"
  else
    display "$RED" "Script: Unsupported package manager"
    exit 1
  fi
  display "$YELLOW" "Script: Detected package manager: $PACKAGE_MANAGER"
}

# =========================================================dependencies==========================================================================

install_dependencies_script() {
  check_package_manager
  sudo ${PACKAGE_MANAGER} install -y curl gpg 2>&1 >> /dev/null
}

# ===========================================================setups============================================================================

# Setting up kubernetes repo running it might result in overwrite in case the repo name is same as 'kubernetes'
setup_kubernetes_repo() {
  install_dependencies_script
  echo -ne "${BLUE}Script: Input the desired Kubernetes version [ex 1.28]: ${NC}" ; read DESIRED_KUBERNETES_VERSION
  if [[ "$PACKAGE_MANAGER" == "yum" ]]; then
    KUBERNETES_REPO_CONFIG="/etc/yum.repos.d/kubernetes.repo"
    cat <<EOF | sudo tee "$KUBERNETES_REPO_CONFIG" 
[kubernetes]
name=kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v${DESIRED_KUBERNETES_VERSION}/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v${DESIRED_KUBERNETES_VERSION}/rpm/repodata/repomd.xml.key
EOF
  elif [[ "$PACKAGE_MANAGER" == "apt" ]]; then
    KUBERNETES_REPO_CONFIG="/etc/apt/sources.list.d/kubernetes.list"
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v${DESIRED_KUBERNETES_VERSION}/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${DESIRED_KUBERNETES_VERSION}/deb/ /" | sudo tee "$KUBERNETES_REPO_CONFIG"
  fi
  display "$GREEN" "Script: Kubernetes repository has been set up for version ${DESIRED_KUBERNETES_VERSION}"
}

setup_kubernetes_repo
# ============================================================end==================================================================
