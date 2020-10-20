echo ${1} | passwd --stdin root >/dev/null 2>&1
echo "export TERM=xterm" >> /etc/bashrc
