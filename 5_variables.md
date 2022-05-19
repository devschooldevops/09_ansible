# Variables

- Ansible uses variables to manage differences between systems
- Variables can be defined in playbooks, inventory, in re-usable files or roles, or at the command line
- Also variables can be created during the execution of a playbook by registering the return value or values of a task as a new variable
- Ansible facts are variables which are automatically discovered and set by Ansible during the execution of a playbook

The types of variables that Ansible supports are String, Numbers, Float, Boolean, List, and Dictionary.
Variables can also be nested.

## Creating valid variable names
- Before you start using variables, it’s important to know what are valid variable names.
- Variable names should be letters, numbers, and underscores. Variables should always start with a letter.
- **foo**, **foo_bar**, **bar5** are valid variable names.
- **foo-port**, **foo port**, **foo.port** and **12** are not valid variable names.


## Referencing simple variables
To reference simple variable values, the Jinja2 syntax is used, which encloses the variable names inside double curly braces.

> **DEMO**: simple variables
>
> ```yaml
> ---
> - hosts: localhost
>   connection: local
>
>   vars:         # vars defined at playbook level
>     app_name: httpd
>     app_version: 4.2
>     app_dir: "/etc/httpd"
>   vars_files:   # vars included from external files
>     - vars/external_vars.yml
>
>   tasks:
>   - name: print vars defined at playbook level
>     debug:
>       msg:
>       - Application name is {{ app_name }}
>       - Application directory is {{ app_dir }}
>       - Application version is {{ app_version }}
>
>   - name: print vars defined at playbook level
>     debug:
>       msg: "{{ user }} is an {{ description }}, {{ age }} years old, and {{ height }}m tall"
>
>   - name: print vars defined at the task level
>     vars:
>       os_distro: RHEL
>       os_version: 8
>     debug:
>       msg: OS is {{ os_distro }} {{ os_version }}
> ```

## Referencing list variables
A list variable combines a variable name with multiple values.
The multiple values can be stored as an itemized list or in square brackets [], separated with commas.

> **DEMO**: lists
>
> ```yaml
> ---
> - hosts: localhost
>   connection: local
>
>   vars:
>     fruits:
>       - Apple
>       - Orange
>       - Strawberry
>       - Mango
>     users: [ Alice, Bob, John, Mary ] # lists can also be specified on a single line
>
>   tasks:
>   - name: print fruits list
>     debug:
>       msg: "{{ fruits }}"
>   - name: print users list
>     debug:
>       msg: "{{ users }}"
>   - name: print list item by index
>     debug:
>       msg: "Value at index 0 is {{ users[0] }}"


## Referencing dictionary variables
A dictionary stores the data in key-value pairs.
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

> **DEMO**: dictionaries
>
> ```yaml
> ---
> - hosts: localhost
>   connection: local
>
>   vars:
>     employee:
>       name: Martin
>       job: Developer
>       skill: Advanced
>     cidr_blocks:    # nested dict
>        production:
>          vpc_cidr: "172.31.0.0/16"
>        staging:
>          vpc_cidr: "10.0.0.0/24"
>
>   tasks:
>   - name: print employee dict
>     debug:
>       msg: " {{ employee.name }} is an {{ employee.skill }} {{ employee['job'] }}"
>   - name: print nested dict
>     debug:
>       var: cidr_blocks.production.vpc_cidr
> ```

More complicated data structures are possible, such as lists of dictionaries, dictionaries whose values are lists or a mix of both
```yaml
employees:
  - name: Alice
    job: Developer
    skills:
      - Java
      - Spring
      - Node
  - name: Bob
    job: Ops
    skills:
      - Linux
      - Ansible
      - Python

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

## Variable precedence
You can set multiple variables with the same name in many different places.
When you do this, Ansible loads every possible variable it finds, then chooses the variable to apply based on variable precedence.
In other words, the different variables will override each other in a certain order.
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


## Transforming variables
Variables can be transformed/processed using [Jinja2 filters](http://jinja.pocoo.org/docs/templates/#builtin-filters) or [Ansible supplied filters](https://docs.ansible.com/ansible/latest/user_guide/playbooks_filters.html#playbooks-filters).

> **DEMO**: transforms
>
> ```yaml
> ---
> # transform.yml
>
> - hosts: localhost
>   connection: local
>   gather_facts: false
>
>   vars:
>     change_case: "This Is a STRING"
>     list1: [ 0, 10, 3, 25 ]
>
>   tasks:
>   - name: change to upper case
>     debug:
>       msg: "{{ change_case | lower }}"
>     tags: case
>
>   - name: get maximum value from list
>     debug:
>       msg: "{{ list1 | max }}"
>     tags: max
> ```

> **EXERCISE**:
>
> - in the **vars** directory create a file named **my_vars.yml** that contains:
>     - a variable named *topic* with the value *ansible*
>     - a list variable named *numbers* that contains *25, 4, 7, 12* as members
>     - a dictionary variable named *lotr* that contains:
>         - a key named *author* with the value *J.R.R. Tolkien*
>         - a key named *books* that contains *The Fellowship of the Ring*, *The Two Towers* and *The Return of the King* as members of a list
> - create a playbook named *playground.yml* as follows:
>   - is executed against **localhost**
>   - imports the variables from the file created earlier
>   - a task that prints the message "Today we're learning TOPIC" - replace TOPIC with the value of the *topic* variable, in upper case
>   - a task that prints the minumum value from the *numbers* list
>   - a task that prints "AUTHOR wrote: BOOKS" - replace AUTHOR and BOOKS with the correct variables, join the *books* list in a comma-separated string
