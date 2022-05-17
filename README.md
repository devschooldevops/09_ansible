# Ansible

## Prerequisites
- **control node** - the machine that will execute Ansible commands
  - a local virtual machine with Linux (recommended) or Windows with WSL
  - ansible >= 2.7 installed
  - with internet access
  - a ssh key pair used for SSH passwordless login into the managed node

- **managed node** - the machine that will be configured with Ansible
  - a virtual machine (local or in a public cloud)
  - with Centos or RHEL 7, no GUI
  - accessible on ports 22 and 80 from the control node
  - with internet access
  - SSH passwordless login configured for the root user
