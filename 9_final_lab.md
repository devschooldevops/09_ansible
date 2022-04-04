# Final lab

> **LAB #12**
> - on your local VM change your working directory to **labs/lab12**
> - use the inventory file from LAB #02

> - create variables:
>   - the **all** group has 3 variables: **cleanup: false**, **httpd: false**, **nginx: false**
>   - the **webservers** group has a variable **listen_port: 8080**

> - create a **common** role that
>   - installs epel-release and ntp
>   - ntp is started and enabled at boot
>   - **/etc/ntp.conf** configuration file uses **ntp.conf** file from **resources** directory
>   - tunes the kernel with the [sysctl](https://docs.ansible.com/ansible/latest/modules/sysctl_module.html) and sets the bellow parameters:
>     - vm.swappiness=1; vm.dirty_ratio=60; fs.file-max: 64000
>     - use a list of dictionaries for this task
>   - **firewalld** service is disabled

> - create a **httpd** role that:
>   - installs httpd
>   - starts httpd enables it at boot
>   - contains a handler for httpd service restart

> - create a **nginx** role that:
>   - installs nginx
>   - starts nginx enables it at boot
>   - contains a handler for nginx service restart

> - create a **cleanup.yml** play that
>   - runs against **all** hosts
>   - executed only when **cleanup** is set to **true**
>   - task #1: stop httpd, ntpd and nginx
>   - task #2: uninstall httpd, ntpd and nginx
>   - task #3: delete **/var/www/html** and **/etc/httpd** directories

> - create a **webservers.yml** play that:
>   - executed only when **httpd** is set to **true**
>   - deploys **common** and **httpd** roles
>   - configures **/etc/httpd/conf/httpd.conf** using a template (transform **resources/httpd.conf** into a template, replace LISTEN_PORT with the correct variable)
>   - **/var/www/html/index.html** contains the host name

> - create a **nginx.yml** play that:
>   - executed only when **nginx** is set to **true**
>   - deploys **common** and **nginx** roles
>   - configures **/etc/nginx/nginx.conf**,  use **resources/nginx.conf** as an example
>   - configures **/etc/nginx/conf.d/web.conf** use **resources/nginx.conf** as an example (transform it into a template, use a loop with hostvars to add the correct values)

> - create a **final.yml** playbook that imports the plays created earlier
> - execute the cleanup play
> - execute the nginx and httpd plays
> - test results in your browser
> - push your changes to Gitlab
