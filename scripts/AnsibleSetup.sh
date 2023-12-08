#!/bin/bash

#Variables
server_hostname=ansible-server
myuser=ansadmin
user_password=1234

#Changing hostname
cat << EOF > /etc/hostname
${server_hostname}
EOF

#Adding user
if grep -q 'Ubuntu\|Debian' /etc/issue; then
    sudo adduser ${myuser} --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password
    echo "${myuser}:${user_password}" | sudo chpasswd
else   
    sudo useradd ${myuser} --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password
    echo "${myuser}:${user_password}" | sudo chpasswd
fi
