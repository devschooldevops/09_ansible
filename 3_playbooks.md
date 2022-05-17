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
## twoplays.yml

- name: "first play"
  hosts: webservers
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

- name: "second play"
  hosts: loadbalancer
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
```ansible-playbook -i <inventory-file> <playbook-file>```

> **EXERCISE**
>
> - use the inventory file created in the previous exercise
> - create an ansible playbook named **apache.yml** as follows:
>   - contains a single play that runs against the **web01** host
>   - fact gathering is disabled
>   - installs *httpd* using the [**package**](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/package_module.html) module
>   - copies the *index.html* file in Apache's DocumentRoot directory (**/var/www/html/**) using the [**copy**](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html) module:
>     - set owner and group to **apache**
>     - set file permissions to **644**
>   - the Apache service is running and it is set to start on boot. Use the [**service**](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/service_module.html#examples) module
> - execute the playbook
> - check the results by typing in your browser the **web01** server's IP




## Facts
- ansible collects pretty much all the information about the remote hosts as it runs a playbook
- the details collected are generally known as **facts** and stored in memory as variables
- facts can be obtained manually using an Ansible ad-hoc command and a specialized module named **setup**
- ansible playbooks call this setup module by default to perform the *Gathering Facts* task when **gather_facts** is true
- the facts can be used by ansible playbooks to configure the remote host


> **DEMO**: facts
>
> ```bash
> # get facts for the "web01" host
> ansible -i hosts.ini web01 -m setup
>
> # use the "debug" module to print inventory/connection variables
> ansible -i hosts.ini web01 -m debug -a "var=ansible_host"
> ansible -i hosts.ini web01 -m debug -a "var=inventory_hostname"
>
> # debug module cannot be used to print discovered facts
> ```

> **EXERCISE**:
>
> - use the inventory file created in the first exercise
> - create an ansible playbook named **facts.yml** as follows:
>   - contains a single play that runs against the **loadbalancer** group
>   - fact gathering is enabled
>   - task 1: use the [**debug**](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/debug_module.html) module with the *msg* parameter to display OS family, distribution name and distribution version
>   - task 2: use the [**debug**](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/debug_module.html) module with the *var* parameter to display the host's ipv4 address assigned to eth0
> - execute the playbook



## Handlers
- **handlers** are special type of tasks
- a handler can be invoked by another task upon completion (e.g. restart a service when its configuration file was changed)
- referenced by a globally unique name
- invoked by tasks with the **notify** argument
- regardless of how many tasks notify a handler, it will run only once, after all of the tasks complete in a particular play (to avoid unnecessary restarts)

> **DEMO**: handlers
>
> - create **handlers.yml** playbook
> - contains a play that runs against **web01**
> - task that uses the [**lineinfile**](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/lineinfile_module.html) module to change Apache listening port to 8080 (use **regexp** parameter)
> - handler that restarts Apache
> - execute the playbook
> - push to GitLab

> **EXERCISE**:
>
> - create an ansible playbook named **wonderland.yml** as follows:
>   - contains a single play that runs against the **webservers** group
>   - installs Apache; the service is started and enabled at boot
>   - copies the **wonderland.conf** file in the **/etc/httpd/conf.d/** directory; this is an Apache configuration file and the service needs to be restarted
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
