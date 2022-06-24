# vstwsagent_preinstalled_ubuntu

# Terraform Scripts for creating a vm in Azure with agent preinstalled

Terraform script to create 4 vms, with one of them having Public IP for ssh Access


## Deployment

Prereq for running this script is an azure account & we are signed into azure cli. Ensure Terraform is installed on the machines. 
Ensure that the keypair bearing the name: swarmvm & swarmvm.pub is created in the folder that will run the terraform script. Also there needs to be an ado associated with your subscription where an agent pool has been created. 
Prior to running: 
Alter line 9 of script.sh:
```bash
runuser -l azureuser -c '/home/azureuser/myagent/config.sh --unattended  --url https://dev.azure.com/orgname --auth pat --token fillinPATtokendetailshere --pool youragentpool'
```
& run ```bash curl ifconfig.me ``` to identify your publicip, which is to be replaced in line 51 of main.tf 
```bash
      source_address_prefix      = "x.x.x.x"
```

To deploy this project run

```bash
  git clone https://github.com/barishandcloud/vstwsagent_preinstalled_ubuntu.git
  cd vstwsagent_preinstalled_ubuntu
  ssh-keygen -b 2048 -t rsa -f swarmvm
  chmod 400 swarmvm
  terraform init
  terraform plan
  terraform apply 
```
This provisions:
one resource group
4 nic - one with public ip
1 security group with rules allowing ssh 
nic to security group association
4 Ubuntu 18.04-LTS servers with Standard_B1s sizing in eastasia Region. The region can be modified in the variables.tf file. 

To change other parameters please alter main.tf accordingly.
terraform output yields the public ip of the machine to ssh.

In the ADO portal there will be a new agent visible in a min or so, which bears the vm name as the agent name.

In order to ssh into vm1
```bash
  ssh -i swarmvm azureuser@<public_ip>
```

## CLEANUP:
```bash
  terraform destroy
```
Remove the agent from the agent pool in ADO to get a fresh start in the next run.

