#!/bin/bash

RESOURCE_GROUP=Azuredevops
MY_VM_NAME=myLinuxVM

IP_ADDRESS=$(az vm show --show-details --resource-group $RESOURCE_GROUP --name $MY_VM_NAME --query publicIps --output tsv)

if [[ -z "$IP_ADDRESS" ]]; then
  echo "Create VM ..."
  az vm create   \
  --resource-group $RESOURCE_GROUP \
  --name $MY_VM_NAME \
  --image '/subscriptions/4e780871-9657-43bf-b521-9c73706b76b1/resourceGroups/Azuredevops/providers/Microsoft.Compute/images/azgent-vm-image' \
  --size Standard_DS1_v2 \
  --admin-username devopsagent \
  --admin-password DevOpsAgent@123 \
  --public-ip-sku Standard \
  --nsg-rule SSH

  # Query IP again
  IP_ADDRESS=$(az vm show --show-details --resource-group $RESOURCE_GROUP --name $MY_VM_NAME --query publicIps --output tsv)
fi

IP_ADDRESS=$(echo $IP_ADDRESS | sed -z "s/\r\n//g")
  
# IP is not empty
if [[ -n "$IP_ADDRESS" ]]; then
  echo "VM IP: $IP_ADDRESS"
  
  # Install Docker and restart
#   ssh devopsagent@$IP_ADDRESS <<-'ENDSSH'
#       #commands to run on remote host
#       # Docker
#       sudo snap install docker
#       sudo groupadd docker
#       sudo usermod -aG docker $USER
#       exit
# ENDSSH

  ssh  devopsagent@$IP_ADDRESS PAT=$PAT <<-'ENDSSH'
    #commands to run on remote host
    sudo cp -R /home/packer/azagent ~/
    sudo chown devopsagent:devopsagent azagent
    cd ~/azgent
    ./config.sh --unattended --url https://dev.azure.com/udacitydevops --auth pat --token $PAT --pool myAgentPool --acceptTeeEula 
    sudo ./svc.sh install
    sudo ./svc.sh start

    sudo apt update -y
    sudo apt-get install python3.10-venv
    sudo apt-get install python3-pip
    sudo apt-get install python3.10-distutils
    sudo apt install -y zip

    pip install pylint==2.13.7
    pip show --files pylint
    echo $PATH
ENDSSH

fi

