#!/bin/bash

export AZ_DEVOPS_PAT="AZURE_PAT"

# Execute the file provided by VM Image to register Azure DevOps agent
cd  /home/vmuser
chown vmuser:vmuser ./setup_devops_agent.sh
chmod +x ./setup_devops_agent.sh

cd  /home/vmuser/azagent
sudo -H -E -u vmuser ../setup_devops_agent.sh

# Register Analytic Agent, command from 
# -w: Worksplace ID
# -s: Primary key
wget https://raw.githubusercontent.com/Microsoft/OMS-Agent-for-Linux/master/installer/scripts/onboard_agent.sh && \
    sh onboard_agent.sh -w bbd2f46c-af01-4e5f-9480-13ab9069661b \
        -s SrZBJz+gm+AbvLrrO7pAt2IKzlzsxBQp2CtkRfiahLRFvqUkrtKf8Jq5Z7V0SdwBV13592+IuukVazyDPA3ypQ== \
        -d opinsights.azure.com