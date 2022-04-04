# Templates
- Configuration files deployed by Ansible may vary for each remote servers or each cluster.
- Creating static files for each of these configurations is not an efficient solution and it will take a lot more time and every time a new cluster is added you will have to add more files.
- This is where Ansible template modules come into play.
- Templates are simple text files which contains all your configuration parameters.
- During the playbook execution the variables will be replaced with the relevant values.
- We can do much more than replacing the variables with the help of [Jinja2 templating engine](https://jinja.palletsprojects.com/en/2.11.x/templates/).
- We can have conditional statements, loops, filters for transforming the data, do arithmetic calculations, etc.
- The template files will usually have the .j2 extension, which denotes the Jinja2 templating engine used.

```yaml
---
# template01.yml
- hosts: localhost
  connection: local

  vars:
    variable1: 'Simple template'
    variable2: 'This is a simple template file'

  tasks:
    - name: simple template
      template:
        src: simple.j2
        dest: simple.txt
```

```jinja
{# simple.j2 #}
{{ variable1 }}
No effects on this line
{{ variable2 }}
```

## Jinja delimiters
- ```{% ... %}``` for Statements (for, if)
- ```{{ ... }}``` for Expressions to print to the template output
- ```{# ... #}``` for Comments not included in the template output


## Examples
```yaml
---
# template02.yml
- hosts: localhost
  connection: local

  vars:
    paths:
      - /opt/dir01
      - /opt/my_dir
      - /opt/temp

    app:
      name: "my_application"
      version: 2.1
      type: "web-based"

    users:
      - firstname: John
        lastname: Doe
        uid: 2001
        role: Ops
      - firstname: Alice
        lastname: Mayflower
        uid: 2002
        role: Dev
      - firstname: Mike
        lastname: Smith
        uid: 2003
        role: DevOps

  tasks:
    - name: complex template
      template:
        src: complex.j2
        dest: complex.txt
```

```jinja
{# complex.j2 #}

# Print the 'app' dictionary:
{{ app.name }} is {{ app.type }} and version is {{ app.version }}.

# Loop through the 'paths' list and print each member:
{% for path in paths %}
  - {{ path }}
{% endfor %}

# Print comma separated list
paths=
{%- for path in paths %}
{{ path }}{% if not loop.last %},{% endif %}
{% endfor %}


# Loop through the 'users' hash
Users:
{% for user in users %}
  {{ loop.index }}. {{ user.firstname }} {{ user.lastname }} is a {{ user.role }}.
{% endfor %}
```

## Use facts in templates
- There are situations when you want to deploy a template on a server using facts/variables from other hosts
- In order to achieve this, Ansible needs to connect to the other hosts in order to discover the facts

```yaml
---
# template03.yml

- hosts: webservers

- hosts: localhost
  connection: local

  tasks:
  - name: copy template
    template:
        src: webservers.j2
        dest: webservers.txt
```

```jinja
{# webservers template #}

{% for host in groups['webservers'] %}
{{ loop.index }}: {{ host }}
      Distro name: {{ hostvars[host]['ansible_distribution'] }}
      Distro version: {{} hostvars[host]['ansible_distribution_version'] }}
{% endfor %}
```

> **LAB #09**
> - use 'git pull' (from master) and 'git merge master' (from your personal branch) to refresh the repo
> - on your local VM change your working directory to **labs/lab09**
> - use the inventory file from LAB #02
> - extend the template from previous example as follows:
>   - add an inner **for** loop that creates a list of mount points
>   - the format of mount points list is "   - DEVICE has SIZE and is mounted in MOUNT"
>   - convert size to human readable
> - execute the playbook
> - check the results on the target host
> - push your changes to Gitlab

