#!/bin/bash

export AZ_DEVOPS_PAT="AZURE_PAT"

# Copy the agent source provided by VM Image
cp -R /home/packer/azagent /home/tamtt5
chown -R tamtt5:tamtt5 /home/tamtt5/azagent
cd /home/tamtt5/azagent

# export AGENT_ALLOW_RUNASROOT="1"

# Execute the file provided by VM Image to register Azure DevOps agent
sudo -H -u tamtt5 bash ./setup_devops_agent.sh
