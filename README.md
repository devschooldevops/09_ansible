# Ansible

## Prerequisites
- a Virtual Machine on your laptop/PC
  - Centos 7
  - no GUI
  - with internet access
  - ansible >= 2.7 installed
  - a ssh key pair to be used by ansible user
- azure-cli installed on your laptop/PC
- 3 virtual machines in Azure (see azure-cli instructions bellow)
  - VM names: **web01**, **web02** and **loadbalancer**
  - 1 CPU, 512MB RAM
  - accessible on ports 22 and 80 from your local VM
  - ansible user that can login with a SSH key

## azure-cli instructions
```bash
# sign in
az login         # it will load the Azure sign-in page in your default browser
az group list    # check if you have any resource groups

# create new resource group
az group create --name DevSchoolRG --location westeurope

# create a Network Security Group
az network nsg create -n DevSchoolNSG -g DevSchoolRG

# create a Network Security Group Rule to allow access on ports 22 and 80
az network nsg rule create --nsg-name DevSchoolNSG -g DevSchoolRG -n DevSchoolNSGRule \
  --priority 100 --protocol Tcp --destination-port-ranges 22 80

# create VMs ready for Ansible use, where VMNAME=[web01,web02,loadbalancer]
# use the ssh public key from your local VM
az vm create -n $VMNAME -g DevSchoolRG --image centos --size Standard_B1ls \
  --admin-username ansible --ssh-key-values ~/.ssh/id_rsa.pub --nsg DevSchoolNSG

# list VMs
az vm list --output table

# list VMs ip addresses
az vm list-ip-addresses --output table

# delete al resources from DevSchoolRG group
az group delete --name DevSchoolRG
```

