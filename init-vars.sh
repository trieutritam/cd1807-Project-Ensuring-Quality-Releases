#!/usr/bin/env bash

SOURCE=${BASH_SOURCE[0]}
while [ -L "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
  SOURCE=$(readlink "$SOURCE")
  [[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
SCRIPT_DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )


export TF_VAR_subscription_id=$(sed '2!d' $SCRIPT_DIR/labinfo.txt | sed -z "s/\r\n//g")
export TF_VAR_client_id=$(sed '6!d' $SCRIPT_DIR/labinfo.txt | sed -z "s/\r\n//g")
export TF_VAR_client_secret=$(sed '8!d' $SCRIPT_DIR/labinfo.txt | sed -z "s/\r\n//g")
export TF_VAR_tenant_id=$(sed '4!d' $SCRIPT_DIR/labinfo.txt | sed -z "s/\r\n//g")


export TF_VAR_azure_devops_pat=$(sed '17!d' $SCRIPT_DIR/labinfo.txt | sed -z "s/\r\n//g")

# create storage account
echo "Create/Update storage account..."

storage_account_res=`$SCRIPT_DIR/terraform/environments/test/configure-tfstate-storage-account.sh | tail -n 1`

storage_account_res=${storage_account_res/ACCOUNT_KEY=/}


export ARM_ACCESS_KEY=$storage_account_res