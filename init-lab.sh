#!/bin/bash

# This script create the lab resources from scratch
# - Packer Image
# - Init ENV vars
# - Apply terraform

SCRIPT_DIR=$(dirname $0)

# Init vars
source $SCRIPT_DIR/init-vars.sh

# Build image
cd $SCRIPT_DIR/packer
packer init ./server.pkr.hcl
packer build ./server.pkr.hcl

# Terraform
cd $SCRIPT_DIR

terraform init
terraform apply