#!/bin/bash
echo "Execute your super awesome commands here!"
mkdir -p /home/azureuser/myagent/ /home/azureuser/Downloads 
cd /home/azureuser/Downloads
wget https://vstsagentpackage.azureedge.net/agent/2.204.0/vsts-agent-linux-x64-2.204.0.tar.gz
cd /home/azureuser/myagent/
tar zxvf /home/azureuser/Downloads/vsts-agent-linux-x64-2.204.0.tar.gz
sudo chmod -R 777 /home/azureuser/myagent/
runuser -l azureuser -c '/home/azureuser/myagent/config.sh --unattended  --url https://dev.azure.com/username --auth pat --token fillinPATtokendetailshere --pool youragentpool'
sudo /home/azureuser/myagent/svc.sh install
sudo /home/azureuser/myagent/svc.sh start
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
exit 0


