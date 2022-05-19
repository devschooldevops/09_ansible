# Loops
- sometimes you want to repeat a task multiple times
- in computer programming, this is called a loop
- common Ansible loops include changing ownership on several files and/or directories with the file module, creating multiple users with the user module, repeating a polling step until a certain result is reached.
- this can be achieved with the **loop** keyword


## Iterating over a simple list

> **DEMO**: list iteration
>
> ```yaml
> ---
> - hosts: localhost
>   connection: local
>
>
>   tasks:
>   - name: loop directly over a list
>     debug:
>       msg: "{{ item }}"
>     loop:
>        - cat
>        - dog
>        - rabbit
>
>   - name: loop over a list variable
>     vars:
>       fruits:
>         - Apple
>         - Orange
>         - Strawberry
>         - Mango
>     debug:
>       msg: "{{ item }} is a fruit"
>     loop: "{{ fruits }}"
> ```

## Iterating over a dictionary
The **loop** directive cannot iterate directly over a dictionary.
The **dict2items** filter must be used to transform a dictionary into a list of items suitable for looping.

> **DEMO**: dictionary iteration
>
> ```yaml
> ---
> - hosts: localhost
>   connection: local
>   gather_facts: false
>   vars:
>     user:
>       firstname: John
>       lastname: Doe
>       age: 27
>
>   tasks:
>   - name: print the dictionary
>     debug:
>       msg:
>       - "No transformation: {{ user }}"
>       - "With dict2items: {{ user | dict2items }}"
>
>   - name: loop with dict2items filter
>     debug:
>       msg: "key: {{ item.key }}, value: {{ item.value }}"
>     loop: "{{ user | dict2items }}"
> ```

## Iterating over a list of dictionaries

> **DEMO**: hash iteration
>
> ```yaml
> ---
> - hosts: localhost
>   connection: local
>   gather_facts: false
>
>   vars:
>     tech:
>       - name: joe
>         role: dev
>         skill: advanced
>       - name: alice
>         role: devops
>         skill: expert
>       - { name:  mike, role: ops, skill: beginner }
>
>   tasks:
>   - name: loop
>     debug:
>       msg: "{{ item.name }}'s role is {{ item.skill }} {{ item. role }}"
>     loop: "{{ tech }}"
> ```

> **EXERCISE**
>
> - use the iventory file created in previous exercise
> - in the **vars** directory create a file named **loop_vars.yml** that contains:
> - in **loop_vars.yml**:
>   - create a list named **paths** containing the following elements: **/opt/dir01**, **/opt/my_dir**, **/opt/temp**
>   - create a dictionary named **app** whith the following keys and values:
>     - name: my_application
>     - version: 2.1
>     - type: web-based
>   - create list of dictionaries named **users**
>     - each dictionary should have **firstname**, **lastname**, **uid**  and **role** as **keys**
>     - use John, Alice and Mike as values for the **firstname** key
>     - use Doe, Mayflower and Smith as values for the **lastname** key
>     - use 2001, 2002 and 2003 as values for the **uid** key
>     - use Ops, Dev and DevOps as values for the **role** key
> - create a playbook named **loops.yml** as follows:
>   - contains a single play that runs against the **web01** host
>   - includes variables from **vars/loop_vars.yml**
>   - task #1: loop through the **paths** variable to create the directories using the **file** module
>   - task #2: create a file named **app.conf** in **/opt/**:
>     - contains the key/value pairs from the **app** variable
>     - each key/value pair is in the **key=value** format, one per line
>     - loop is not necessary for this task
>   - task #3: loop through the **users** hash and create users on the taget host as follows:
>     - use the [**user**](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/user_module.html) module
>     - user name is **firstname_lastname**, all lowercase
>     - user uid set to **uid**
>     - set user description to "**firstname lastname - role**"
> - execute the playbook
> - check the results on the target host

