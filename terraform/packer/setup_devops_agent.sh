#!/bin/bash

set -e

# This script require environment variable AZ_DEVOPS_PAT

# Setup Azure DevOps Environment VM
# mkdir -p azagent;cd azagent
# curl -fkSL -o vstsagent.tar.gz https://vstsagentpackage.azureedge.net/agent/3.238.0/vsts-agent-linux-x64-3.238.0.tar.gz
# tar -zxvf vstsagent.tar.gz
if [ -x "$(command -v systemctl)" ]; then 
  ./config.sh --unattended --environment --environmentname "Test" --acceptteeeula --agent $HOSTNAME \
              --url https://dev.azure.com/udacitydevops/ --work _work --projectname 'ensure-quality-releases' \
              --auth PAT --token ${AZ_DEVOPS_PAT} --runasservice \
              --addvirtualmachineresourcetags --virtualmachineresourcetags "selenium"
  sudo ./svc.sh install
  sudo ./svc.sh start
else 
  ./config.sh --unattended --environment --environmentname "Test" --acceptteeeula \
            --agent $HOSTNAME --url https://dev.azure.com/udacitydevops/ \
            --work _work --projectname 'ensure-quality-releases' \
            --auth PAT --token ${AZ_DEVOPS_PAT} \
            --addvirtualmachineresourcetags --virtualmachineresourcetags "selenium"
  ./run.sh; 
fi

