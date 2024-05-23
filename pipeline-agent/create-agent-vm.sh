#!/bin/bash

RESOURCE_GROUP=Azuredevops
MY_VM_NAME=myLinuxVM
LOCATION=eastus

IP_ADDRESS=$(az vm show --show-details --resource-group $RESOURCE_GROUP --name $MY_VM_NAME --query publicIps --output tsv)

if [[ -z "$IP_ADDRESS" ]]; then
  echo "Create VM ..."
  
  az vm create   \
  --resource-group $RESOURCE_GROUP --location $LOCATION \
  --name $MY_VM_NAME \
  --image 'azgent-vm-image' \
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

  sshpass -p DevOpsAgent@123 ssh devopsagent@$IP_ADDRESS <<-'ENDSSH'
      sudo cp /home/packer/azuredevops_rsa ~/.ssh/id_rsa
      sudo cp /home/packer/azuredevops_rsa.pub ~/.ssh/id_rsa.pub
      sudo cat /home/packer/azuredevops_rsa.pub >> ~/.ssh/authorized_keys
      sudo chown devopsagent:devopsagent ~/.ssh/*
      sudo chmod 600 ~/.ssh/id_rsa
      sudo chmod 600 ~/.ssh/id_rsa.pub
ENDSSH

  # Install Docker and restart
  ssh -i ../packer/sshkey/azuredevops_rsa devopsagent@$IP_ADDRESS "echo export PAT=$TF_VAR_azure_devops_pat >> ~/.bashrc"

  # Install Docker and restart
  ssh -i ../packer/sshkey/azuredevops_rsa devopsagent@$IP_ADDRESS <<-'ENDSSH'
      sudo snap install docker
      sudo groupadd docker
      sudo usermod -aG docker $USER


      sudo apt update -y
      sudo apt install -y python3.10-venv
      sudo apt install -y python3-pip
      sudo apt install -y python3.10-distutils
      sudo apt install -y zip

      pip install pylint==2.13.7
      pip show --files pylint
      echo $PATH

      sudo snap install terraform --classic

      sudo reboot
ENDSSH

  while ! ssh -i ../packer/sshkey/azuredevops_rsa devopsagent@$IP_ADDRESS 'echo OK'
  do
    echo "Wait for ssh..."
    sleep 5
  done

  ssh -i ../packer/sshkey/azuredevops_rsa devopsagent@$IP_ADDRESS <<-'ENDSSH'
    #commands to run on remote host
    sudo cp -R /home/packer/azagent ~/
    sudo chown devopsagent:devopsagent azagent
    cd ~/azagent
    ./config.sh --unattended --url https://dev.azure.com/udacitydevops --auth pat --token $PAT --replace --pool myAgentPool --acceptTeeEula 
    sudo ./svc.sh install
    sudo ./svc.sh start
ENDSSH

fi
