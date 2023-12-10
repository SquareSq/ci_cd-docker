#!/bin/bash

#Variables
server_hostname=ansible-server
myuser=ansadmin
user_password=1234
key_name=mykey

sudo apt update

#Changing hostname
cat << EOF > /etc/hostname
${server_hostname}
EOF

#Adding user
if grep -q 'Ubuntu\|Debian' /etc/issue; then
    sudo adduser ${myuser} --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password
    echo "${myuser}:${user_password}" | sudo chpasswd
    sudo apt install ansible
    ssh-keygen -t rsa -N "" -f ${key_name}.key
else   
    sudo useradd ${myuser} --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password
    echo "${myuser}:${user_password}" | sudo chpasswd
fi
