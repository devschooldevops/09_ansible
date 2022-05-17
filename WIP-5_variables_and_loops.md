WIP: shorten content

# Variables and loops

## Creating valid variable names
- Before you start using variables, it’s important to know what are valid variable names.
- Variable names should be letters, numbers, and underscores. Variables should always start with a letter.
- **foo**, **foo_bar**, **bar5** are valid variable names.
- **foo-port**, **foo port**, **foo.port** and **12** are not valid variable names.

YAML also supports dictionaries which map keys to values. For instance:
```yaml
foo:
  field1: one
  field2: two
```
You can then reference a specific key in the dictionary using either bracket notation or dot notation:
```yaml
foo['field1']
foo.field1
```

- If you choose to use dot notation be aware that some keys can cause problems because they collide with attributes and methods of python dictionaries
- You should use bracket notation instead of dot notation if
  - you use keys which start and end with two underscores (these are reserved for special meanings in python)
  - variable names or key names are any of the known public attributes (just a few examples: add, append, replace, split, pop, lower, update, format, encode, decode, join, keys, values, etc.)


## Types of variables
The types of variables that Ansible supports are String, Numbers, Float, Boolean, List, and Dictionary.

```yaml
user: Alice
description: "Employee in Accounting"

ram: 1024
perc: 0.99

create_key: yes
needs_agent: no
knows_oop: True
likes_emacs: TRUE
uses_cvs: false

# All members of a list are lines beginning at the same indentation level starting with a -  (a dash and a space)
fruits:
  - Apple
  - Orange
  - Strawberry
  - Mango

# A dictionary is represented in a simple key: value  form (the colon must be followed by a space)
martin:
  name: Martin
  job: Developer
  skill: Advanced

```

More complicated data structures are possible, such as lists of dictionaries, dictionaries whose values are lists or a mix of both
```yaml
employees:
  - martin:
    name: Martin D'vloper
    job: Developer
    skills:
      - python
      - perl
      - pascal
  - tabitha:
    name: Tabitha Bitumen
    job: Developer
    skills:
      - lisp
      - fortran
      - erlang

network:
  addresses:
    private_ext:
      - type: fixed
        addr: 172.16.2.100
    private_man:
      - type: fixed
        addr: 172.16.1.100
      - type: floating
        addr: 10.90.80.10
```

## Variable location
- inventory, group_vars/, host_vars/
- playbooks, roles
- included files and roles
- command line


```yaml
- hosts: localhost
  connection: local

  vars:     # vars defined at playbook level
    app_dir: "/etc/httpd"
    app_version: 4.2
    app_name: httpd
  vars_files:
    - vars/external_vars.yml

  tasks:
  - include_role:
      name: app
    vars:   # vars defined at include level
      app_name: haproxy
      app_version: 2.2.1
      app_enabled: true
```

```bash
# pass variables via cli at playbook execution
ansible-playbook release.yml --extra-vars "version=1.23.45 other_variable=foo"
ansible-playbook release.yml -e version=1.23.45 -e other_variable=foo
```

## Transforming variables
Variables can be transformed/processed using [Jinja2 filters](http://jinja.pocoo.org/docs/templates/#builtin-filters) or [Ansible supplied filters](https://docs.ansible.com/ansible/latest/user_guide/playbooks_filters.html#playbooks-filters).

```yaml
---
# transform.yml

- hosts: localhost
  connection: local
  gather_facts: false

  vars:
    change_case: "This Is a STRING"
    list1: [ 0, 10, 3, 25 ]


  tasks:
  - name: change to upper case
    debug:
      msg: "{{ change_case | upper }}"
    tags: case

  - name: undefined variable
    debug:
      msg: "{{ undefined }}"
    ignore_errors: true
    tags: undef

  - name: undefined variable
    debug:
      msg: "{{ undefined | default('now_is_ok') }}"
    tags: undef

  - name: get maximum value from list
    debug:
      msg: "{{ list1 | max }}"
    tags: max
```

## Variable precedence
If multiple variables of the same name are defined in different places, they get overwritten in a certain order (last listed wins):
- role defaults
- inventory vars
- inventory group_vars
- inventory host_vars
- playbook group_vars
- playbook host_vars
- host facts
- registered vars
- set_facts
- play vars
- play vars_prompt
- play vars_files
- role and include vars
- block vars (only for tasks in block)
- task vars (only for the task)
- extra vars

REMOVE MENTIONS ABOUT with_ loops
# Loops
- Sometimes you want to repeat a task multiple times.
- In computer programming, this is called a loop.
- Common Ansible loops include changing ownership on several files and/or directories with the file module, creating multiple users with the user module, and repeating a polling step until a certain result is reached.
- Ansible offers two keywords for creating loops: **loop** and **with_\***.
- **loop** was introduced in Ansible 2.5. It is not yet a full replacement for **with_\***, but it is recommended for most use cases.
- **with_\*** loops: with_list, with_items, with_indexed_items, with_flattened, with_dict, with_sequence

## Iterating over a simple list
Repeated tasks can be written as standard loops over a simple list of strings. You can define the list directly in the task:

```yaml
---
# loop1.yml

- hosts: localhost
  connection: local

  tasks:
  - name: loop over a simple list
    debug:
      msg: "{{ item }}"
    loop:
       - my_string
       - "Another string"
       - something_else
```

You can define the list in a variables file, or in the **vars** section of your play, then refer to the name of the list in the task:
```yaml
---
# loop2.yml

- hosts: localhost
  connection: local

  vars:
    my_list:
    - my_string
    - "Another string"
    - something_else

  tasks:
  - name: with_items
    debug:
      msg: "{{ item }}"
    with_items: "{{ my_list }}"

  - name: loop
    debug:
      msg: "{{ item }}"
    loop: "{{ my_list }}"
```

## Iterating over a dictionary
- When using **with_dict** the dictionay can be used as is
- When using **loop** a transformation needs to be performed on the variable using Ansible [filters](https://docs.ansible.com/ansible/latest/user_guide/playbooks_filters.html)

```yaml
---
# loop3.yml

- hosts: localhost
  connection: local
  gather_facts: false
  vars:
    my_dict:
      firstname: John
      lastname: Doe
      age: 27

  tasks:
  - name: with_dict
    debug:
      msg: "key: {{ item.key }}, value: {{ item.value }}"
    with_dict: "{{ my_dict }}"

  - name: loop with dict2items filter
    debug:
      msg: "key: {{ item.key }}, value: {{ item.value }}"
    loop: "{{ my_dict|dict2items }}"
```

## Iterating over hashes (list of dictionaries)

```yaml
---
# loop4.yml

- hosts: localhost
  connection: local
  gather_facts: false

  tasks:
  - name: with_dict
    debug:
      msg: "key: {{ item.key }}, value: {{ item.value }}"
    with_dict:
    - { name: 'joe', groups: 'dev' }
    - { name: 'bob', groups: 'ops' }

  - name: loop
    debug:
      msg: "key: {{ item.name }}, value: {{ item.groups }}"
    loop:
    - { name: 'joe', groups: 'dev' }
    - { name: 'bob', groups: 'ops' }
```

> **LAB #08** ADJUST FOR 2022
> - use 'git pull' (from master) and 'git merge master' (from your personal branch) to refresh the repo
> - on your local VM change your working directory to **labs/lab08**
> - copy the inventory file created in LAB #02
> - create a directoy named **vars** and a file named **my_vars.yml**
> - in **my_vars.yml**:
>   - create a list named **paths** containing the following elements: **/opt/dir01**, **/opt/my_dir**, **/opt/temp**
>   - create a dictionary named **app** whith the following keys and values:
>     - name: my_application
>     - version: 2.1
>     - type: web-based
>   - create a hash (list of dictionaries) named **users**
>     - each dictionary should have **firstname**, **lastname**, **uid**  and **role** as **keys**
>     - use John, Alice and Mike as values for the **firstname** key
>     - use Doe, Mayflower and Smith as values for the **lastname** key
>     - use 2001, 2002 and 2003 as values for the **uid** key
>     - use Ops, Dev and DevOps as values for the **role** key
> - create a playbook named **loops.yml** as follows:
>   - contains a single play that runs against the **web02** host
>   - includes variables from **vars/my_vars.yml**
>   - task #1: loop through the **paths** variable to create the directories using the **file** module, tag the task as "paths"
>   - task #2: create a file named **app.conf** in **/opt/**:
>     - contains the key/value pairs from the **app** variable
>     - each key/value pair is in the **key=value** format, one per line
>     - loop is not necessary for this task
>     - tag the task as "app"
>   - task #3: loop through the **users** hash and create users on the taget host as follows:
>     - user name is **firstname_lastname**, all lowercase
>     - user uid set to **uid**
>     - set user description to "**firstname lastname - role**"
>     - tag the task as "users"
> - execute the playbook
> - check the results on the target host
> - push your changes to Gitlab

