WIP

# Conditionals
- Often the execution of a play/task may depend on the value of a variable, fact, or previous task result
- in some cases, the values of variables may depend on other variables
- this is easy to do in Ansible with the **when** clause, which contains a raw Jinja2 expression without double curly braces
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
```

A number of Jinja2 tests and filters can also be used in when statements

> **DEMO**: jinja tests
>
> ```yaml
> ---
> - hosts: localhost
>   connection: local
>   gather_facts: false
>
>   tasks:
>   - name: execute task and register the result
>     command: /usr/bin/false
>     register: result
>     ignore_errors: true
>
>   - name: execute task based on previous task result
>     debug:
>       msg: "{{ result }}"
>     when: result is failed
> ```

Variables defined in the playbooks or inventory can also be used:

> **DEMO**: var tests
>
> ```yaml
> ---
> - hosts: localhost
>   connection: local
>   gather_facts: false
>
>   vars:
>     epic: true
>     version: 2.3
>     app: "apache"
>
>   tasks:
>   - name: "this is epic"
>     shell: echo
>     when: epic
>
>   - name: "version check"
>     shell: echo
>     when: version > 2.0
>
>   - name: "application check"
>     shell: echo
>     when: app == "apache"
> ```

> **EXERCISE**:
> - create a **when.yml** playbook that runs against localhost
> - create a var named **deploy** and set it to false
> - task #1:
>   - use debug module to print out "Deploying ..."
>   - when **deploy** is true
> - execute the playbook without extra arguments
> - execute the playbook and override **deploy** as **true** in the command line

