# Conditionals
- Often the result of a play may depend on the value of a variable, fact, or previous task result.
- In some cases, the values of variables may depend on other variables.
- Sometimes you will want to skip a particular step on a particular host. This could be something as simple as not installing a certain package if the operating system is a particular version, or it could be something like performing some cleanup steps if a filesystem is getting full.
- This is easy to do in Ansible with the **when** clause, which contains a raw Jinja2 expression without double curly braces
- **when** clause can be applied to tasks, roles, imports and includes

```yaml
tasks:
  - name: "shut down Debian flavored systems"
    command: /sbin/shutdown -t now
    when: ansible_facts['os_family'] == "Debian"
    # note that all variables can be used directly in conditionals without double curly braces

# You can also use parentheses to group conditions
  - name: "shut down CentOS 6 and Debian 7 systems"
    command: /sbin/shutdown -t now
    when: (ansible_facts['distribution'] == "CentOS" and ansible_facts['distribution_major_version'] == "6") or
          (ansible_facts['distribution'] == "Debian" and ansible_facts['distribution_major_version'] == "7")

# Multiple conditions that all need to be true (a logical ‘and’) can also be specified as a list
  - name: "shut down CentOS 6 systems"
    command: /sbin/shutdown -t now
    when:
      - ansible_facts['distribution'] == "CentOS"
      - ansible_facts['distribution_major_version'] == "6"

# A number of Jinja2 “tests” and “filters” can also be used in when statements, some of which are unique and provided by Ansible
  - command: /bin/false
    register: result
    ignore_errors: True

  - command: /bin/something
    when: result is failed

  # In older versions of ansible use ``success``, now both are valid but succeeded uses the correct tense.
  - command: /bin/something_else
    when: result is succeeded

  - command: /bin/still/something_else
    when: result is skipped
```

Variables defined in the playbooks or inventory can also be used:
```yaml
vars:
  epic: true
  monumental: "yes"
  deploy: true

tasks:
    - shell: echo "This certainly is epic!"
      when: epic or monumental|bool

    - shell: echo "This certainly isn't epic!"
      when: not epic

- import_tasks: tasks/deploy.yml
  when: deploy | bool
```

> **LAB #10**
> - on your local VM change your working directory to **labs/lab10**
> - use the inventory file from LAB #02
> - create a **lab10.yml** playbook that runs agains **all** hosts
> - create a var named **deploy** and set it to false
> - task #1:
>   - use debug module to print out "Deploying ..."
>   - when **deploy** is true
> - task #2:
>   - use debug module to print out "Running on loadbalancer"
>   - when the target is **loadbalancer**
> - execute the playbook without extra arguments
> - execute the playbook and override **deploy** as **true** in the command line
> - push your changes to Gitlab

