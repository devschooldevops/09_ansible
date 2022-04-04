# Ansible

## What is Ansible?
Ansible is an IT automation tool. It can configure systems, deploy software, and orchestrate more advanced IT tasks such as continuous deployments or zero downtime rolling updates.
At its core, Ansible is a declarative system. You describe the state in which you expect your parts of the system to be in, and Ansible tries to get the system there.

- Agentless architecture, push-based via SSH
- Easy-to-read syntax (YAML)
- Very fast learning curve, no special coding skills required
- Full power at the CLI (open source)
- More features available in enterprise (Ansible Tower)

Ansible Tower is an enterprise framework for controlling, securing and managing Ansible automation with a UI and RESTful API.

## Ansible concepts

### Idempotency
**Idempotence** is a term given to certain operations in mathematics and computer science whereby:
- an operation which, when performed multiple times, has no further effect on its subject after the first time it is performed.
- an operation is idempotent if the result of performing it once is exactly the same as the result of performing it repeatedly without any intervening actions

For Ansible it means after one run of a task or set of tasks to set a system to a desired state, further runs of the same task(s) should result in zero changes.

### Control node
- Any machine with Ansible installed
- You can run commands and tasks, invoking **ansible** or **ansible-playbook**, from any control node
- You can use any computer that has Python installed on it as a control node - laptops, shared desktops, and servers can all run Ansible
- However, you cannot use a Windows machine as a control node
- You can have multiple control nodes

### Managed nodes
- The systems you manage with Ansible
- Managed nodes are also called **hosts**
- Ansible is not installed on managed nodes.
- A managed node can be (but not limited to) a server, a network device, etc

### Inventory
- A collection of hosts (managed nodes) with associated data (variables)
- Hosts can be organized in groups, groups can be nested, allowing for easier scaling
- Ansible uses a file in a simple INI or YAML format that describes the hosts and groups

### Modules
- Modules are the **units of code** that Ansible ships out to remote machines
- Once executed on remote machines, they are removed, so no long-running daemons are used
- Ansible refers to the collection of available modules as a library
- Each module has a particular use (administer users/services, install packages, copy files, etc.)
- You can invoke a single module with a task, or invoke several different modules in a playbook
- Ansible contains by default many [modules](https://docs.ansible.com/ansible/latest/modules/modules_by_category.html#modules-by-category)

### Tasks
- Tasks are the **units of action** in Ansible
- You can be executed with an ad-hoc command or from a playbook
- A task has a name, executes a module action, completes with either success / failure / skipped

### Playbooks
- **Playbooks** are an ordered list of tasks, saved so you can run those tasks in that order repeatedly
- Can include variables as well as tasks
- Playbooks are written in YAML and are easy to read, write, share and understand
- Can be split in multiple sets of tasks, called **plays**

### Roles
- **Roles** provide a framework for fully independent, or interdependent collections of variables, tasks, files, templates, and modules
- Used to simplify complex playbooks
- Allows you to logically break the playbook into reusable components
- Roles are not playbooks, there is no way to directly execute a role
- Can be used only within playbooks

### Variables
- **Variables** are names of values that can be used in inventories, tasks, playbooks, templates, etc
- They can be simple scalar values (integers, booleans, strings) or complex ones (dictionaries/hashes, lists)
- Can be assigned per host or per group

### Facts
- Facts are host properties automatically discovered by Ansible when running plays
- They can be used in playbooks and templates just like variables
- If not needed, facts collection can be disabled to decrease execution time

### Conditionals
- Expressions that evaluate to true or false
- Can be used to decide whether a given task is executed on a given machine or not

### Tags
- Keywords assigned to tasks
- Useful to run only a subset of a playbook

