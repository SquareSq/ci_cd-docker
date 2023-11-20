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
tom_version=10.1.16
TOMCAT_URL=https://dlcdn.apache.org/tomcat/tomcat-${tom_major_vers}/v${tom_version}/bin/apache-tomcat-${tom_version}.tar.gz
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
   
    sudo touch context.xml
    cat <<EOF > context.xml
<?xml version="1.0" encoding="UTF-8"?>
<!--
  Licensed to the Apache Software Foundation (ASF) under one or more
  contributor license agreements.  See the NOTICE file distributed with
  this work for additional information regarding copyright ownership.
  The ASF licenses this file to You under the Apache License, Version 2.0
  (the "License"); you may not use this file except in compliance with
  the License.  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
-->
<Context antiResourceLocking="false" privileged="true" >
  <CookieProcessor className="org.apache.tomcat.util.http.Rfc6265CookieProcessor"
                   sameSiteCookies="strict" />
<!--  <Valve className="org.apache.catalina.valves.RemoteAddrValve"
         allow="127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1" /> -->
  <Manager sessionAttributeValueClassNameFilter="java\.lang\.(?:Boolean|Integer|Long|Number|String)|org\.apache\.catalina\.filters\.CsrfPreventionFilter\$LruCache(?:\$1)?|java\.util\.(?:Linked)?HashMap"/>
</Context>    
EOF
    sudo cp context.xml ${folder_path}/webapps/host_manager/META_INF
    sudo chmod 640 ${folder_path}/webapps/host_manager/META_INF/context.xml
    sudo mv context.xml ${folder_path}/webapps/manager/META_INF
    sudo chmod 640 ${folder_path}/webapps/host_manager/META_INF/context.xml

    sudo touch tomcat-users.xml
    cat <<EOF > tomcat-users.xml
<?xml version="1.0" encoding="UTF-8"?>
<!--
  Licensed to the Apache Software Foundation (ASF) under one or more
  contributor license agreements.  See the NOTICE file distributed with
  this work for additional information regarding copyright ownership.
  The ASF licenses this file to You under the Apache License, Version 2.0
  (the "License"); you may not use this file except in compliance with
  the License.  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
-->
<tomcat-users xmlns="http://tomcat.apache.org/xml"
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
              xsi:schemaLocation="http://tomcat.apache.org/xml tomcat-users.xsd"
              version="1.0">
<!--
  By default, no user is included in the "manager-gui" role required
  to operate the "/manager/html" web application.  If you wish to use this app,
  you must define such a user - the username and password are arbitrary.

  Built-in Tomcat manager roles:
    - manager-gui    - allows access to the HTML GUI and the status pages
    - manager-script - allows access to the HTTP API and the status pages
    - manager-jmx    - allows access to the JMX proxy and the status pages
    - manager-status - allows access to the status pages only

  The users below are wrapped in a comment and are therefore ignored. If you
  wish to configure one or more of these users for use with the manager web
  application, do not forget to remove the <!.. ..> that surrounds them. You
  will also need to set the passwords to something appropriate.
-->
<!--
  <user username="admin" password="<must-be-changed>" roles="manager-gui"/>
  <user username="robot" password="<must-be-changed>" roles="manager-script"/>
-->
<!--
  The sample user and role entries below are intended for use with the
  examples web application. They are wrapped in a comment and thus are ignored
  when reading this file. If you wish to configure these users for use with the
  examples web application, do not forget to remove the <!.. ..> that surrounds
  them. You will also need to set the passwords to something appropriate.
-->
<role rolename="manager-gui"/>
<role rolename="manager-script"/>
<role rolename="manager-jmx"/>
<role rolename="manager-status"/>
<user username="admin" password="1234" roles="manager-gui, manager-script, manager-jmx, manager-status"/>
<user username="deployer" password="1234" roles="manager-script"/>
<user username="tomcat" password="1234" roles="manager-gui"/>
</tomcat-users>
EOF
    sudo mv tomcat-users.xml ${folder_path}/conf
    sudo chmod 670 ${folder_path}/conf/tomcat_users.xml
    sudo systemctl daemon-reload

    echo 'Starting tomcat server....'
    sudo systemctl start tomcat
    exit
else
    echo 'Could not locate installation direcotry..exiting..'
    exit
fi

