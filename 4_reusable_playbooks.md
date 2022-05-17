# Roles
- roles are ways of automatically loading certain variables, tasks, and handlers based on a predefined file structure
- grouping content by roles also allows easy sharing of roles with other playbooks or even other users

## Role directory structure
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

## Using roles
Roles can be executed with the **roles**, **import_role** or **include_role** directives
