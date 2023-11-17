#!/bin/bash

echo "###################"
echo "Java installation"
echo "###################"

sudo apt update
sudo apt install fontconfig openjdk-17-jre -y

echo "####################################"
java -version
echo "####################################"
sleep 5

echo "###################"
echo "Java installed"
echo "###################"

sleep 5

JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
tom_major_vers=10
tom_version=10.1.15
TOMCAT_URL=https://downloads.apache.org/tomcat/tomcat-${tom_major_vers}/v${tom_version}/bin/apache-tomcat-${tom_version}.tar.gz
folder_path=/opt/tomcat/10_1

function check_java_home {
    if [ -z ${JAVA_HOME} ]
    then
        echo 'Could not find JAVA_HOME. Please install Java and set JAVA_HOME'
        exit
    else
        echo 'JAVA_HOME found: '$JAVA_HOME
        if [ ! -e ${JAVA_HOME} ]
        then
            echo 'Invalid JAVA_HOME. Make sure your JAVA_HOME path exists'
            exit
        fi
    fi
}

echo "###########################"
echo 'Installing tomcat server...'
echo "###########################"
echo 'Checking for JAVA_HOME...'
check_java_home
sleep 3

echo "###################################"
echo "Downloading tomcat-${tom_version}..."
echo "$TOMCAT_URL"
echo "###################################"

sleep 5

if [ ! -f /etc/apache-tomcat-${tom_major_vers}*tar.gz ]
then
    curl -O $TOMCAT_URL
fi
echo 'Finished downloading...'

echo 'Creating install directories...'
sudo mkdir -p "${folder_path}"

if [ -d "${folder_path}" ]
then
    echo 'Extracting binaries to install directory...'
    sudo tar xzf apache-tomcat-${tom_major_vers}*tar.gz -C "${folder_path}" --strip-components=1
    echo 'Creating tomcat user group...'
    sudo groupadd tomcat
    sudo useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat

    echo 'Setting file permissions...'
    cd "${folder_path}"
    sudo chgrp -R tomcat "${folder_path}"
    sudo chmod -R g+r conf
    sudo chmod -R g+x conf

    # This should be commented out on a production server
    sudo chmod -R g+w conf

    sudo chown -R tomcat webapps/ work/ temp/ logs/
    
    echo "############################" 
    echo 'Setting up tomcat service...'
    echo "############################"

    sudo touch "tomcat.service"
    sudo chmod 777 tomcat.service


    cat <<EOF > tomcat.service
    [Unit]
    Description=Apache Tomcat Web Application Container
    After=network.target

    [Service]
    Type=forking

    Environment=JAVA_HOME=$JAVA_HOME
    Environment=CATALINA_PID=${folder_path}/temp/tomcat.pid
    Environment=CATALINA_HOME=${folder_path}
    Environment=CATALINA_BASE=${folder_path}
    Environment=CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC
    Environment=JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom

    ExecStart=${folder_path}/bin/startup.sh
    ExecStop=${folder_path}/bin/shutdown.sh

    User=tomcat
    Group=tomcat
    UMask=0007
    RestartSec=10
    Restart=always

    [Install]
    WantedBy=multi-user.target
EOF

    sudo mv tomcat.service /etc/systemd/system/tomcat.service
    sudo chmod 755 /etc/systemd/system/tomcat.service
    sudo systemctl daemon-reload

    echo 'Starting tomcat server....'
    sudo systemctl start tomcat
    exit
else
    echo 'Could not locate installation direcotry..exiting..'
    exit
fi

