#!/bin/bash

sudo su tamtt5

export AZ_DEVOPS_PAT="AZURE_PAT"

# Copy the agent source provided by VM Image
cp -R /home/packer/azagent ~/

cd ~/azagent

# export AGENT_ALLOW_RUNASROOT="1"

# Execute the file provided by VM Image to register Azure DevOps agent
bash ./setup_devops_agent.sh
