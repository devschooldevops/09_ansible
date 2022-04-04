# Creating reusable playbooks
- when developing complex playbooks, keeping all tasks in a single playbook file might be difficult to maintain
- also you may have some tasks that could be reused by different playbooks
- ansible has 3 ways to better organize things: **includes**, **imports**, and **roles**
- includes and imports allow users to break up large playbooks into smaller files, which can be used across multiple parent playbooks or even multiple times within the same playbook
- roles allow more than just tasks to be packaged together and can include variables, handlers, or even modules and other plugins

## Dynamic vs. static operations
- ansible has two modes of operation for reusable content: **dynamic** and **static**
- **dynamic** operations are implemented by **include** tasks (include_tasks, include_role)
  - evaluated when an *include* task is encountered
  - the parent task options (**tags**, **when** ) will not be copied to child tasks
  - *include* tasks can be looped. When a loop is used with an include, the included tasks or role will be executed once for each item in the loop
- **static** operations implemented by **import** tasks (import_tasks, import_role, import_playbook)
  - evaluated during playbook parsing time
  - the parent task options will be copied to all child tasks
  - **import** tasks cannot be used in loops

```yaml
---
# operations.yml
- hosts: loadbalancer
  gather_facts: false
  become: true

  tasks:
  - name: include_tasks
    include_tasks: include.yml
    tags: parent_include

  - name: import_tasks
    import_tasks: import.yml
    tags: parent_import

# include.yml
  - name: included
    debug:
      msg: "This task was included"
    tags:
      - child_include
      - debug

# import.yml
  - name: imported
    debug:
      msg: "This task was imported"
    tags:
      - child_import
      - debug
```

```bash
# static operations (import) are evaluated at playbook runtime
# imported tasks/tags will show up, included tasks/tags will not be visible
ansible-playbook -i hosts.ini operations.yml --list-tasks
ansible-playbook -i hosts.ini operations.yml --list-tags

# this affects playbook execution
ansible-playbook -i hosts.ini operations.yml
ansible-playbook -i hosts.ini operations.yml --tags=debug
```


# Roles
- roles are ways of automatically loading certain vars_files, tasks, and handlers based on a predefined file structure
- grouping content by roles also allows easy sharing of roles with other playbooks or even other users

## Role directory structure
```bash
site.yml
webservers.yml
dbservers.yml
roles/
    common/
        defaults/
        files/
        handlers/
        meta/
        tasks/
        templates/
        vars/
    webservers/
        defaults/
        handlers/
        tasks/
    dbservers/
        files/
        tasks/
        vars/
```

- roles expect files to be in certain directory names
- roles must include at least one of these directories, however it is perfectly fine to exclude any which are not being used
- when in use, each directory must contain a main.yml file, which contains the relevant content:
  - **tasks**: contains the main list of tasks to be executed by the role
  - **handlers**: contains handlers, which may be used by this role or even anywhere outside this role
  - **defaults**: default variables for the role
  - **vars**: other variables for the role
  - **files**: contains files which can be deployed via this role
  - **templates**: contains templates which can be deployed via this role
  - **meta**: defines some meta data for this role

## Using roles
### Using the **roles** directive
```yaml
---
- hosts: webservers
  roles:
    - common
    - webservers
```
When used in this manner, the order of execution for your playbook is as follows:
- Any **pre_tasks** defined in the play.
- Any handlers triggered so far will be run.
- Each role listed in roles will execute in turn. Any role dependencies defined in the roles meta/main.yml will be run first.
- Any tasks defined in the play.
- Any handlers triggered so far will be run.
- Any post_tasks defined in the play.
- Any handlers triggered so far will be run.

### Using using **import_role** or **include_role** directives
```yaml
---
- hosts: webservers
  tasks:
    - debug:
        msg: "before we run our role"
    - import_role:
        name: example
    - include_role:
        name: example
    - debug:
        msg: "after we ran our role"
```

### Role Search Path
Ansible will search for roles in the following way:
- A roles/ directory, relative to the playbook file
- By default, in /etc/ansible/roles

> **DEMO #05**
> - create **demo05.yml** playbook
>   - runs against **all** group
>   - executes a role named **common**
>   - executes pre_tasks, tasks and post_tasks
> - create the **common** role
>   - installs ntp, copies ntp.conf
>   - adds content to /etc/motd, use a var named **motd**
>   - customizes profiles: loop for alias, history and prompt
> - execute the playbook
> - change order of pre_task, execute again
> - push to GitLab

> **LAB #07**
> - on your local VM change your working directory to **labs/lab07**
> - copy the inventory file created in LAB #02
> - create a playbook named **lab07.yml** as follows:
>   - contains a single play that runs against the **webservers** group
>   - executes a role named **httpd** using the **import_role** directive
>   - has a task that uses the **lineinfile** module that:
>     - adds "Hello again" in **/var/www/html/index.html**
>     - sets owner and group to apache user
>     - sets permissions to 0644
> - create the **httpd** role as follows:
>   - contains **tasks/main.yml** tasks file that:
>     - installs Apache
>     - starts the service and enables it at boot
>   - contains a **handlers/main.yml** file that contains a handler for restarting the Apache service
> - execute the playbook
> - check the results in your browser (use PublicIP/wonderland/)
> - push your changes to Gitlab

