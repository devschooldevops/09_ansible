# Inventory

Ansible can configure multiple **hosts** at the same time, using a list or group of lists known as **inventory**.
Once an inventory is defined, you use patterns to select the hosts or groups you want Ansible to run against.

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

[fullstack:children]
webservers
dbservers
```

## Inventory variables
- You can store variable values that relate to a specific host or group in inventory
- Variables can be defined directly in the inventory file
- As you add more and more managed nodes to your Ansible inventory, however, you will likely want to store variables in separate files.


```ini
# hosts.ini inventory file
localhost  ansible_connection=local ansible_user=ansible
mail       ansible_host=mail.example.com ansible_user=ansible timezone=UTC

[webservers]
web-01     ansible_host= foo.example.com environment=prod listen_port=443
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

- All hosts are automatically members of a default **all** group
- Host variables will override group variables
- A child group's variables will have a higher precedence over a parent group's variables
- You can assign hosts a friendly name known as **alias**

Although you can define variables in the main inventory file, storing separate host and group variables files may help you organize your variable values more easily.
Host and group variable files must use YAML syntax.

Ansible loads host and group variable files by searching paths relative to the inventory file.
If your inventory file at **/opt/ansible/my_playbook/hosts.ini** contains a host named **db-03** that belongs to the **dbservers** group, Ansible will also look for variables in YAML files at the following locations:

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


## Inventory setup example
When managing a complex infrastructure (multiple environments and  multiple applications) maintaing the layouts described above might not suitable.
Inventory files and associated variables can be split across multiple files per environments, per applications, or both.

```yaml
my_playbook/
    ├── inventories/
    │       ├── test/
    │       │   ├── hosts.ini
    │       │   ├── host_vars/
    │       │   │   ├── web01.yml
    │       │   │   ├── db01.yml
    │       │   └── group_vars/
    │       │       ├── all.yml
    │       │       ├── webservers.yml
    │       │       └── dbservers.yml
    │       ├── acceptance/
    │       │   ├── hosts.ini
    │       │   ├── host_vars/
    │       │   │   ├── web01.yml
    │       │   │   ├── web02.yml
    │       │   │   ├── db01.yml
    │       │   │   ├── db02.yml
    │       │   └── group_vars/
    │       │       ├── all.yml
    │       │       ├── webservers.yml
    │       │       └── dbservers.yml
    │       └── production/
    │           ├── hosts.ini
    │           ├── host_vars/
    │           │   ├── web01.yml
    │           │   ├── web02.yml
    │           │   ├── web03.yml
    │           │   ├── web04.yml
    │           │   ├── db01.yml
    │           │   ├── db02.yml
    │           └── group_vars/
    │               ├── all.yml
    │               ├── webservers.yml
    │               └── dbservers.yml
    └── site.yml
```

## Host patterns
- When you execute Ansible through an ad-hoc command or by running a playbook, you must choose which managed nodes or groups you want to execute against
- Patterns let you run commands and playbooks against specific hosts and/or groups in your inventory
- An Ansible pattern can refer to a single host, an IP address, an inventory group, a set of groups, or all hosts in your inventory
- Patterns are highly flexible - you can exclude or require subsets of hosts, use wildcards or regular expressions, and more


| Description       | Pattern example       |
| ----------------- | --------------------- |
| All hosts         | all                   |
| One host          | host1                 |
| Multiple hosts    | host1:host2           |
| One group         | webservers            |
| Multiple groups   | webservers:dbservers  |
| All hosts but one | !host2                |

## Connection variables
Ansible has a series of built-in variables that controls how it interacts with remote hosts. The most important ones:
- ```ansible_connection``` - Connection type to the host: **ssh**(default) or **local** (other types are available)
- ```ansible_host``` - The name of the host to connect to, if different from the alias
- ```ansible_user``` - The user name to use when connecting to the host
- ```ansible_password``` - The password to use to authenticate to the host (**never store this variable in plain text**)
- ```ansible_ssh_private_key_file``` - Private key file used by ssh. Useful if using multiple keys and you don’t want to use SSH agent.
- ```ansible_become``` - Allows to force privilege escalation
- ```ansible_become_user``` - Allows to set the user you become through privilege escalation
- ```ansible_become_password``` - Allows you to set the privilege escalation password (**never store this variable in plain text**)

## Ad-hoc commands
- An Ansible ad-hoc command uses the **ansible** command-line tool to automate a single task on one or more managed nodes
- quick and easy, but they are not reusable
- great for one-time tasks (reboot servers, copy files, manage packages/services/users, etc.)
- any Ansible module can be used in an ad-hoc task

```ansible <host-pattern> -m [module] -a "[module options]"```

### **DEMO**: inventory and ad-hoc commands
>
> - create inventory with 3 hosts and 2 groups
>   - demo-1 member of the ```loadbalancer``` group
>   - demo-2 and demo-3 members of the ```webservers``` group
>   - ```ansible_user``` variable for all hosts
>
> ```bash
> # Ad-hoc command examples
>
> ansible -i hosts.ini all -m ping
> ansible -i hosts.ini webservers -m command -a "touch mytest"
> ansible -i hosts.ini all -m shell -a "ls -l mytest"
> ansible -i hosts.ini loadbalancer -m file -a "path=mytest mode=0600"
> ansible -i hosts.ini all -m shell -a "ls -l mytest"
>
>
> # Best practice is to use privilege escalation
> ansible -i hosts.ini loadbalancer -m command -a "whoami"
> ansible --become -i hosts.ini loadbalancer -m command -a "whoami"
> ansible -i hosts.ini loadbalancer -m command -a "cat /etc/shadow"
> ansible --become -i hosts.ini loadbalancer -m command -a "cat /etc/shadow"
> ```


> **EXERCISE**:
>
> - clone our [Ansible git repo](https://github.com/devschooldevops/09_ansible)
> - on your local environment change your working directory to **09_ansible/exercises**
> - create an inventory file named *hosts.ini* that contains
>   - one group named **webservers**
>   - one host with *alias* **web01**, member of the **webservers** group (use your VM's IP for the ```ansible_host``` variable)
>   - the ```ansible_user``` variable for all hosts
>   -  the ```listen_port=80``` and ```doc_root=/opt/apache``` as variables for the **webservers** group
> - use the **ping** module to check that **all** hosts are running
> - use the [**file**](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/file_module.html) module against **webservers** group to
>   - create a file named **ansible_was_here** in /tmp
>   - user and group owner is *nobody*
>   - file permissions are: read+write for user, read for group and others
> - use the **shell** module to check the results

