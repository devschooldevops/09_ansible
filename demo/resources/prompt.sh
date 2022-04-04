###

if [ $(id -u) -eq 0 >/dev/null  2>&1 ]
  then
    export PS1="\[\e[;31m\][\u@\h \W]\$ \[\e[m\]"
  else
    export PS1="\[\e[;32m\][\u@\h \W]\$ \[\e[m\]"
fi

###
