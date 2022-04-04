# Inventory
Ansible works against multiple **hosts** in your infrastructure at the same time, using a list or group of lists know as **inventory**.
Once your inventory is defined, you use patterns to select the hosts or groups you want Ansible to run against.

Inventory can be **static** (flat files on the control node) or **dynamic** (pulled from cloud sources).


## Inventory basics: formats, hosts, and groups
The most common formats for inventory files are **INI** and **YAML**. A basic INI inventory file might look like this:

```ini
# inventory file
mail.example.com

[webservers]
foo.example.com
bar.example.com

[dbservers]
one.example.com
two.example.com
three.example.com

[prod]
foo.example.com
one.example.com
two.example.com

[test]
bar.example.com
three.example.com

[fullstack:children]
webservers
dbservers

```

- Brackets define a group
- Hosts can be member of multiple groups
- Hosts can be without a group
- Groups can be nested


## Inventory variables
You can store variable values that relate to a specific host or group in inventory. To start with, you may add variables directly to the hosts and groups in your main inventory file. As you add more and more managed nodes to your Ansible inventory, however, you will likely want to store variables in separate host and group variable files.

```ini
# hosts.ini inventory file
localhost  ansible_connection=local ansible_user=ansible
mail       ansible_host=mail.example.com ansible_user=ansible timezone=UTC

[webservers]
web-01     ansible_host= foo.example.com environment=prod
web-02     ansible_host=bar.example.com environment=test

[dbservers]
db-01      ansible_host=one.example.com environment=prod
db-02      ansible_host=two.example.com environment=prod
db-03      ansible_host=three.example.com environment=test max_connections=10

[webservers:vars]
ansible_user=httpd
listen_port=80

[dbservers:vars]
ansible_user=mysql
db_admin=superuser
max_connections=50

[all:vars]
timezone=CET
motd="Access restricted to authorized personnel only"
audit_enabled=true
```

- Hosts can be in multiple groups, but there will only be one instance of a host, merging the data from the multiple groups
- All hosts are automatically members of a default **all** group
- Host variables will override group variables
- A child group's variables will have a higher precedence over a parent group's variables
- You can assign hosts a friendly name known as **alias**

Although you can define variables in the main inventory file, storing separate host and group variables files may help you organize your variable values more easily.
Host and group variable files must use YAML syntax.

Ansible loads host and group variable files by searching paths relative to the inventory file.
If your inventory file at **/opt/ansible/my_playbook/hosts.ini** contains a host named **db-03** that belongs to the **dbservers** group, that host will use variables in YAML files at the following locations:

```
/opt/ansible/my_playbook/group_vars/dbservers.yml
/opt/ansible/my_playbook/host_vars/db-03.yml
```

```yaml
---

# /opt/ansible/my_playbook/group_vars/dbservers.yml vars file
db_admin: "superuser"
max_connections: 50

# /opt/ansible/my_playbook/host_vars/db-03.yml vars file
environment: "test"
max_connections: 10
```

> **LAB #01**
> - clone this repo on your local VM
> - create a new branch named **firstname.lastname**
> - change your working directory to **labs/lab01**
> - for the **hosts.ini** exemple mentioned above change the layout as follows:
>   - keep all ansi_* variables in *hosts.ini*
>   - move the other variables in the corresponding *group_vars* and *host_vars* yml files
> - push your changes to Gitlab


## Connection variables
Ansible has a series of built-in variables that controls how it interacts with remote hosts. The most important ones:
- ```ansible_connection``` - Connection type to the host: **ssh**(default) or **local** (other types are available)
- ```ansible_host``` - The name of the host to connect to, if different from the alias
- ```ansible_port``` - The connection port number, if not the default (22 for ssh)
- ```ansible_user``` - The user name to use when connecting to the host
- ```ansible_password``` - The password to use to authenticate to the host (**never store this variable in plain text**)
- ```ansible_ssh_host``` - The hostname or IP used to access the host with SSH if defined in the inventory
- ```ansible_ssh_private_key_file``` - Private key file used by ssh. Useful if using multiple keys and you don’t want to use SSH agent.
- ```ansible_become``` - Allows to force privilege escalation
- ```ansible_become_user``` - Allows to set the user you become through privilege escalation
- ```ansible_become_password``` - Allows you to set the privilege escalation password (**never store this variable in plain text**)


## Inventory setup example
When managing a complex infrastructure (multiple environments and  multiple applications) maintaing the layouts described above might not suitable.
Inventory files and associated variables can be split across multiple files per environments, per applications, or both.

```yaml
my_playbook/
├── inventories/
│   ├── development/
│   │   ├── hosts.ini
│   │   ├── host_vars/
│   │   │   ├── web01.yml
│   │   │   └── db01.yml
│   │   └── group_vars/
│   │       ├── all.yml
│   │       ├── webservers.yml
│   │       └── dbservers.yml
│   ├── test/
│   │   ├── hosts.ini
│   │   ├── host_vars/
│   │   │   ├── web01.yml
│   │   │   ├── web02.yml
│   │   │   ├── db01.yml
│   │   │   └── db02.yml
│   │   └── group_vars/
│   │       ├── all.yml
│   │       ├── webservers.yml
│   │       └── dbservers.yml
│   ├── acceptance/
│   │   ├── hosts.ini
│   │   ├── host_vars/
│   │   │   ├── web01.yml
│   │   │   ├── web02.yml
│   │   │   ├── web03.yml
│   │   │   ├── web04.yml
│   │   │   ├── db01.yml
│   │   │   ├── db02.yml
│   │   │   ├── db03.yml
│   │   │   └── db04.yml
│   │   └── group_vars/
│   │       ├── all.yml
│   │       ├── webservers.yml
│   │       └── dbservers.yml
│   └── production/
│       ├── hosts.ini
│       ├── host_vars/
│       │   ├── web01.yml
│       │   ├── web02.yml
│       │   ├── web03.yml
│       │   ├── web04.yml
│       │   ├── db01.yml
│       │   ├── db02.yml
│       │   ├── db03.yml
│       │   └── db04.yml
│       └── group_vars/
│           ├── all.yml
│           ├── webservers.yml
│           └── dbservers.yml
└── site.yml
```


## Host patterns
- When you execute Ansible through an ad-hoc command or by running a playbook, you must choose which managed nodes or groups you want to execute against
- Patterns let you run commands and playbooks against specific hosts and/or groups in your inventory
- An Ansible pattern can refer to a single host, an IP address, an inventory group, a set of groups, or all hosts in your inventory
- Patterns are highly flexible - you can exclude or require subsets of hosts, use wildcards or regular expressions, and more


| Description     | Pattern example              | Target                                             |
| --------------- | ---------------------------- | -------------------------------------------------- |
| All hosts       | all (or *)                   | all hosts defined in the inventory                 |
| One host        | host1                        | a specific host defined in the inventory           |
| Multiple hosts  | host1:host2 (or host1,host2) | multiple inventory hosts                           |
| One group       | webservers                   | all hosts from a specific inventory group          |
| Multiple groups | webservers:dbservers         | all hosts all hosts from specific inventory groups |


## Ad-hoc commands
- An Ansible ad-hoc command uses the **ansible** command-line tool to automate a single task on one or more managed nodes
- quick and easy, but they are not reusable
- great for one-time tasks (reboot servers, copy files, manage packages/services/users, etc.)
- any Ansible module can be used in an ad-hoc task

```ansible <host-pattern> -m [module] -a "[module options]"```

```bash
# Ad-hoc command examples (create hosts.ini for Azure VMs)

ansible -i hosts.ini all -m ping
ansible -i hosts.ini loadbalancer -m command -a "touch mytest"
ansible -i hosts.ini loadbalancer -m shell -a "ls -l mytest"
ansible -i hosts.ini loadbalancer -m shell -a "whoami"


# privilege escalation
ansible --become -i hosts.ini loadbalancer -m shell -a "whoami"
ansible --become -i hosts.ini loadbalancer -m shell -a "systemctl restart crond"
ansible --become -i hosts.ini all -m yum -a "name=telnet state=present"
ansible --become -i hosts.ini webservers -m copy -a "src=hosts.ini dest=/tmp/inventory"
```

> **LAB #02**
> - from your laptop/PC run ```az vm list-ip-addresses --output table```
> - on your local VM change your working directory to **labs/lab02**
> - create the **hosts.ini** inventory file for your Azure VMs as follows:
>   - ansible **alias** set as *VirtualMachine*, **ansible_host** variable set to *PublicIPAddresses*
>   - **loadbalancer** as stand-alone host (not belonging to any custom group)
>   - **web01** and **web02** as members of the **webservers** group
>   - **ansible_user** variable set to *ansible* for **all** group
> - use the **ping** module to check that **all** hosts are running (save results on your local VM in a file named ping.log)
> - use the **command** module against **webservers** group to create a file named **ansible_was_here** in /root
> - run ```ls -l /root/``` with the **shell** module and save the result to a file named lsroot.log
> - push your changes to Gitlab

