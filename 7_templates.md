# Templates
- configuration files deployed by Ansible may vary for each remote servers
- creating static files for host is not an efficient solution as every time a new host is added you will have to create more files
- this is where Ansible template modules come into play
- templates are simple text files which contain all your configuration parameters
- during the playbook execution the variables will be replaced with the relevant values
- we can do much more than replacing the variables with the help of [Jinja2 templating engine](https://jinja.palletsprojects.com/en/2.11.x/templates/)
- we can have conditional statements, loops, filters for transforming the data, do arithmetic calculations, etc.
- the template files will usually have the .j2 extension, which denotes the Jinja2 templating engine used
- deployed with the Ansible [**template**](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_module.html) module
## Jinja syntax
- ```{# ... #}``` for Comments not included in the template output
- ```{{ ... }}``` for Expressions to print to the template output
- ```{% ... %}``` for Statements (for, if)


> **DEMO**: simple template
>
> ```yaml
> ---
> - hosts: localhost
>   connection: local
>   gather_facts: false
>
>   vars:
>     variable1: "This is a simple template file"
>     variable2: "just a text"
>
>   tasks:
>     - name: simple template
>       template:
>         src: simple.j2
>         dest: simple.txt
> ```



> **DEMO**: complex template
> ```yaml
> ---
> - hosts: localhost
>   connection: local
>   gather_facts: false
>
>   vars_files:
>     - vars/loop_vars.yml
>
>   tasks:
>     - name: complex template
>       template:
>         src: complex.j2
>         dest: complex.txt
> ```


> **EXERCISE**:
> - extend the template from previous example as follows:
>   - add a **for** loop that creates a list of mount points
>   - the template output format must be "   - DEVICE has SIZE and is mounted in MOUNT"
>   - convert size to human readable format
> - execute the playbook
