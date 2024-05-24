#!/bin/bash

export AZ_DEVOPS_PAT="AZURE_PAT"

# Execute the file provided by VM Image to register Azure DevOps agent
cd  /home/vmuser
chown vmuser:vmuser ./setup_devops_agent.sh

cd  /home/vmuser/azagent
sudo -H -u vmuser ../setup_devops_agent.sh
