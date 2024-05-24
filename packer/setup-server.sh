#!/bin/bash
sudo apt-get update -y
sudo apt-get install -y openjdk-17-jdk python3-pip unzip chromium-browser
sudo pip3 install selenium

mkdir -p azagent
cd azagent

curl -fkSL -o vstsagent.tar.gz https://vstsagentpackage.azureedge.net/agent/3.238.0/vsts-agent-linux-x64-3.238.0.tar.gz

tar -zxf vstsagent.tar.gz

# if [ -x "$(command -v systemctl)" ]; then 
#   ./config.sh --unattended --environment --environmentname "Test" --acceptteeeula --agent $HOSTNAME \
#               --url https://dev.azure.com/udacitydevops/ --work _work --projectname 'ensure-quality-releases' \
#               --auth PAT --token ${AZ_DEVOPS_PAT} --runasservice \
#               --replace \
#               --addvirtualmachineresourcetags --virtualmachineresourcetags "selenium"
#   sudo ./svc.sh install
#   sudo ./svc.sh start
# else 
#   ./config.sh --unattended --environment --environmentname "Test" --acceptteeeula \
#             --agent $HOSTNAME --url https://dev.azure.com/udacitydevops/ \
#             --work _work --projectname 'ensure-quality-releases' \
#             --auth PAT --token ${AZ_DEVOPS_PAT} \
#             --replace \
#             --addvirtualmachineresourcetags --virtualmachineresourcetags "selenium"
#   ./run.sh; 
# fi

