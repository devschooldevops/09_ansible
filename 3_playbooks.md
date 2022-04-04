# Playbooks
- a completely different way to use ansible than in ad-hoc task execution mode
- the basis for a really simple configuration management and multi-machine deployment system
- very well suited to deploying complex applications
- usually kept in source control and used to push out your configuration or assure the configurations of your remote systems are in spec
- written in **YAML** format
- have a minimum of syntax, which intentionally tries to not be a programming language or script, but rather a model of a configuration or a process

- each playbook is composed of one or more **plays** in a list
- the goal of a play is to map a group of hosts to specific **tasks**
- at a basic level, a **task** is nothing more than a call to an ansible **module**
- by composing a playbook of multiple **plays**, it is possible to orchestrate multi-machine deployments, running certain steps on all machines in the *webservers* group, then certain steps on the *loadbalancer* host, then more commands back on the *webservers* group, etc.

```yaml
---
# oneplay.yml

- hosts: webservers
  gather_facts: true
  become: true

  tasks:
  - name: ensure latest version of apache is installed
    yum:
      name: httpd
      state: latest

  - name: ensure apache is running
    service:
      name: httpd
      state: started
```

```yaml
---
# twoplays.yml

# first play
- hosts: webservers
  gather_facts: true
  become: true

  tasks:
  - name: ensure latest version of apache is installed
    yum:
      name: httpd
      state: latest
  - name: ensure apache is running
    service:
      name: httpd
      state: started

# second play
- hosts: loadbalancer
  gather_facts: true
  become: true

  tasks:
  - name: install EPEL yum repository
    yum:
      name: epel-release
      state: present
  - name: ensure latest version of nginx is installed
    yum:
      name: nginx
      state: latest
  - name: ensure nginx is running
    service:
      name: nginx
      state: started
```

Playbooks are executed with the **ansible_playbook** command:
```ansible-playbook -i <inventory-file> <playbook_name.yml>```

> **LAB #03**
> - on your local VM change your working directory to **labs/lab03**
> - copy the inventory file created in LAB #02
> - create a directory named **files**
> - copy *resources/index.html* in the **files** directory
> - create an ansible playbook named **site.yml** as follows:
>   - contains a single play that runs against the **web01** host
>   - fact gathering is disabled
>   - installs Apache using the [**package**](https://docs.ansible.com/ansible/latest/modules/package_module.html) module
>   - copies the **index.html** file in Apache's DocumentRoot directory (**/var/www/html**) using the [**copy**](https://docs.ansible.com/ansible/latest/modules/copy_module.html) module. Set owner and group to **apache** and file permissions to **644** for the **index.html** file
>   - the Apache service is running and it is set to start on boot. Use the [**service**](https://docs.ansible.com/ansible/latest/modules/service_module.html) module
> - execute the playbook
> - check the results by typing in your browser the **web01** server' public IP
> - push your changes to Gitlab


## Hosts and users
- for each play in a playbook, you get to choose which machines in your inventory to target and what remote user to run the tasks as
- the hosts line is a list of one or more groups or host patterns
- the remote_user is the username used to connect to the host
- remote_user can be set at play level or at task level

> **DEMO #01**
> - create **no_ansible_user.ini** inventory file
> - create **demo01.yml** playbook
> - contains a play that runs agains **web01**
>   - **remote_user** is **ansible**
>   - task that runs **whoami**, register command output
>   - task that displays the previous command' output (debug var)
> - contains a play that runs against **db01**
>   - **remote_user** is **dbadmin**
>   - task that runs **whoami**, register command output
>   - task that displays the previous command' output (debug msg)
> - execute the playbook
> - push to GitLab

```The connection variable ansible_user will always override remote_user```

## Privilege escalation
- Ansible uses existing privilege escalation systems to execute tasks with root privileges or with another user’s permissions
- the **become** keyword leverages existing privilege escalation tools like **sudo**, **su**, **runas** and others
- you can control the use of **become** with play or task directives, connection variables, or at the command line

### Become directives
- **become**: set to **true** or **yes** to activate privilege escalation
- **become_user**: set to user with desired privileges — the user you become, NOT the user you login as. Does NOT imply become: yes, to allow it to be set at host level. Default value is root.
- **become_method**: (at play or task level) overrides the default method (sudo), set to use any of the Become Plugins (sudo, su, runas, enable, etc)
- **become_flags**: (at play or task level) permit the use of specific flags for the tasks or role. One common use is to change the user to nobody when the shell is set to no login.

### Become connection variables
You can define different become options for each managed node or group. You can define these variables in inventory or use them as normal variables.
- **ansible_become**: equivalent of the become directive, decides if privilege escalation is used or not.
- **ansible_become_method**: which privilege escalation method should be used
- **ansible_become_user**: set the user you become through privilege escalation; does not imply ansible_become: yes
- **ansible_become_password**: set the privilege escalation password. Avoid having secrets in plain text (use ansible vault files, discussed later)

> **DEMO #02**
> - create **demo02.yml** playbook
> - contains a play that runs agains **web01**
> - create a user named **alice**, register module output
> - showcase **user** module output: uid, shell, home (debug msg)
> - run 'touch wonderland; ls -laR' as user **alice**, register output
> - showcase **shell** module output (debug var, stdout and stdout_lines)
> - execute the playbook
> - push to GitLab

> **LAB #04**
> - use 'git pull' (from master) and 'git merge stable' from your personal branch to refresh the repo
> - on your local VM change your working directory to **labs/lab04**
> - copy the inventory file created in LAB #02
> - create an ansible playbook named **john.yml** as follows:
>   - contains a single play that runs against the **web01** host
>   - fact gathering is disabled
>   - using the [**user**](https://docs.ansible.com/ansible/latest/modules/user_module.html) module:
>     - create a user named **john**
>     - generate a ssh key for john in the same task
>     - register the task' output in a variable named **user**
>   - using the [**lineinfile**](https://docs.ansible.com/ansible/latest/modules/lineinfile_module.html) module:
>     - run the task as user **john**
>     - create a file named **john_key** in /tmp/
>     - use the previous task' output to add john's public key in the **john_key** file
>     - hints: **lineinfile** parameters needed for this tasks are: path, state, create and line
>   - use the **command** and **debug** modules to display the contents of **john_key** in the playbook execution output
> - execute the playbook
> - push your changes to Gitlab


## Facts
- ansible collects pretty much all the information about the remote hosts as it runs a playbook
- the details collected are generally known as **facts** or variables
- facts can be obtained manually using an Ansible ad-hoc command and a specialized module named **setup**
- ansible playbooks call this setup module by default to perform the *Gathering Facts* task when **gather_facts** is true
- the facts can be used by ansible playbooks to configure the remote host

```bash
# get facts for the "loadbalancer" host
ansible -i hosts.ini loadbalancer -m setup

# use the "debug" module to print inventory/connection variables
ansible -i hosts.ini web01 -m debug -a "var=ansible_host"
ansible -i hosts.ini web01 -m debug -a "var=inventory_hostname"

# debug module cannot be used to print discovered facts
```

> **LAB #05**
> - on your local VM change your working directory to **labs/lab05**
> - copy the inventory file created in LAB #02
> - create an ansible playbook named **facts.yml** as follows:
>   - contains a single play that runs against the **loadbalancer** host
>   - task 1: use the **debug** module to display os family, distribution name and distribution major version
>   - task 2: use the **debug** module to display the host's private ip assigned to eth0
> - execute the playbook
> - push your changes to Gitlab


## Tags
- if you have a large playbook, it may become useful to be able to run only a specific part of it rather than running everything in the playbook
- this can be achieved by using **tags**
- tags can be applied to specific tasks, imported tasks, plays and roles
- when you execute a playbook, you can filter tasks based on tags with the **--tags** or **--skip-tags** options


> **DEMO #03**
> - create **demo03.yml** playbook with the contents bellow
> - show tags usage by executing the playbook

```yaml
---
# tags.yml

- name: Showcase tags
  hosts: webservers
  gather_facts: true
  become: true
  tags: showcase

  tasks:
  - name: debug var1
    debug:
      var: ansible_default_ipv4.interface
    tags: debug

  - name: install ntp
    yum:
      name: ntp
      state: present
    tags:
      - install-ntp
      - ntp

  - name: start and enable ntp
    service:
      name: ntpd
      state: started
      enabled: true
    tags:
      - enable-ntp
      - ntp

  - name: check if ntp is running
    command: systemctl status ntpd
    tags:
      - check-ntp
      - ntp
```

```bash
ansible-playbook -i hosts.ini tags.yml --list-hosts
ansible-playbook -i hosts.ini tags.yml --list-tasks
ansible-playbook -i hosts.ini tags.yml --list-tags

ansible-playbook -i hosts.ini tags.yml --tags "debug"
ansible-playbook -i hosts.ini tags.yml --tags "install-ntp,enable-ntp"
ansible-playbook -i hosts.ini tags.yml --tags "check-ntp"

ansible-playbook -i hosts.ini tags.yml --skip-tags "ntp"
```


## Handlers
- **handlers** are special type of tasks
- a handler can be invoked by another task upon completion (e.g. restart a service when its configuration file was changed)
- referenced by a globally unique name
- invoked by tasks with the **notify** argument
- regardless of how many tasks notify a handler, it will run only once, after all of the tasks complete in a particular play (to avoid unnecessary restarts)

> **DEMO #04**
> - create **demo04.yml** playbook
> - contains a play that runs agains **web01**
> - task that uses the **lineinfile** module to change Apache listening port to 8080 (use **regexp** parameter)
> - handler that restarts Apache
> - execute the playbook
> - push to GitLab

> **LAB #06**
> - on your local VM change your working directory to **labs/lab06**
> - copy the inventory file created in LAB #02
> - create a directory named **files**
> - copy the *resources/wonderland.conf* file in the **files** directory
> - create an ansible playbook named **wonderland.yml** as follows:
>   - contains a single play that runs against the **webservers** group
>   - installs Apache; the service is started and enabled at boot
>   - copies the **wonderland.conf** file in the **/etc/httpd/conf.d/**; this is an Apache configuration file and the service needs to be restarted
>   - creates the **/opt/httpd/wonderland** directory using the **file** module. Set owner and group to **apache** and directory permissions to **0750**
>   - using the [**blockinfile**](https://docs.ansible.com/ansible/latest/modules/blockinfile_module.html) module:
>     - create a file named **index.html** in the **/opt/httpd/wonderland/** directory
>     - set owner and group to **apache** and file permissions to **0640**
>     - **index.html** contains:
>       - ```<h1>Hello from Wonderland!</h1>``` on the first line
>       - ```<p>Private IP is IPv4ADDRESS</p>``` on the second line (replace IPv4ADDRESS with the correct ansible variable)
>       - ```<p>Last updated on WEEKDAY, DATE</p>``` on the second line (replace WEEKDAY and DATE with the correct ansible variables)
>     - use ```<!-- {mark} ANSIBLE MANAGED BLOCK -->``` as **marker**
> - execute the playbook
> - check the results in your browser (use PublicIP/wonderland/)
> - push your changes to Gitlab
