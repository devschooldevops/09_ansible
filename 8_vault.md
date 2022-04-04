# Ansible vault
- Ansible Vault is a feature of ansible that allows you to keep sensitive data such as passwords or keys in encrypted files, rather than as plaintext in playbooks or roles.
- These vault files can then be distributed or placed in source control.
- File-level encryption
  - Ansible Vault can encrypt any structured data file used by Ansible.
  - This can include “group_vars/” or “host_vars/” inventory variables, variables loaded by “include_vars” or “vars_files”
  - Ansible tasks, handlers, and so on are also data so these can be encrypted with vault as well
  - Ansible Vault can also encrypt arbitrary files, even binary files. If a vault-encrypted file is given as the src argument to the copy, template, unarchive, script or assemble modules, the file will be placed at the destination on the target host decrypted (assuming a valid vault password is supplied when running the play).
- Variable-level encryption
  - Ansible Vault can encrypt single values inside a YAML file as well

```bash
# create a new encrypted file
ansible-vault create secrets.yml

# edit an encrypted file
ansible-vault edit secrets.yml

# view an encrypted file
ansible-vault view secrets.yml

# rekey an encrypted file
ansible-vault rekey secrets.yml

# decrypt an encrypted file
ansible-vault decrypt secrets.yml

# encrypt a regular file
ansible-vault encrypt secrets.yml

# encrypt a single variable
ansible-vault encrypt_string 'My-S3cret_pass' --name 'pass'
```

### Using vaults
```yaml
ansible-playbook --ask-vault-pass site.yml
```

> **LAB #11**
> - on your local VM change your working directory to **labs/lab11**
> - use the inventory file from LAB #02
> - create a **lab11.yml** playbook that runs agains **web01** host
> - create an encrypted vault file named **vault_vars.yml**
> - add **vault_vars.yml** in a var named **token** with "My_secret_T0ken" as value
> - include **vault_vars.yml** vars in the playbook
> - encrypt the value of a variable named **htpass**. Value is **123qaz** and add it to the playbook vars
> - use the **blockinfile** module to deploy a file named **secrets** in /tmp
> - **/tmp/secrets** should contain **token=<unecrypted_value>** and **htpass=<unecrypted_value>** on separate lines
> - execute the playbook
> - push your changes to Gitlab
