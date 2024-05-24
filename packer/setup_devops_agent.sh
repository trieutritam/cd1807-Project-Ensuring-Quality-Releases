#!/bin/bash

# add pub key to allow build agent connect
# sudo cat /home/packer/azuredevops_rsa.pub >> ~/.ssh/authorized_keys

if [ -x "$(command -v systemctl)" ]; then 
  ./config.sh --unattended --environment --environmentname "Test" --acceptteeeula --agent $HOSTNAME \
              --url https://dev.azure.com/udacitydevops/ --work _work --projectname 'ensure-quality-releases' \
              --auth PAT --token ${AZ_DEVOPS_PAT} --runasservice \
              --replace \
              --addvirtualmachineresourcetags --virtualmachineresourcetags "selenium"
  sudo ./svc.sh install
  sudo ./svc.sh start
else 
  ./config.sh --unattended --environment --environmentname "Test" --acceptteeeula \
            --agent $HOSTNAME --url https://dev.azure.com/udacitydevops/ \
            --work _work --projectname 'ensure-quality-releases' \
            --auth PAT --token ${AZ_DEVOPS_PAT} \
            --replace \
            --addvirtualmachineresourcetags --virtualmachineresourcetags "selenium"
  ./run.sh; 
fi

