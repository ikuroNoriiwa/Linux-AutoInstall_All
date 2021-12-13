#!/usr/bin/bash

download_openjdk(){
	yum install -y java-1.8.0-openjdk

}

install_keycloak(){
	# $1 : keycloack version (ex : 15.1.0)
	wget https://github.com/keycloak/keycloak/releases/download/$1/keycloak-$1.zip
	unzip keycloak-$1.zip -d /opt
	mv /opt/keycloak-$1 /opt/keycloak
}

create_user_keycloak(){
	groupadd keycloak
	useradd -r -g keycloak -d /opt/keycloak -s /bin/nologin keycloak
	chown -R keycloak: /opt/keycloak
	chmod o+x /opt/keycloak/bin/
}


create_systemd_keycloak(){
	mkdir /etc/keycloak
	cp /opt/keycloak/docs/contrib/scripts/systemd/wildfly.conf /etc/keycloak/keycloak.conf
	cp /opt/keycloak/docs/contrib/scripts/systemd/launch.sh /opt/keycloak/bin/
	chown keycloak: /opt/keycloak/bin/launch.sh
	sed -i "s/wildfly/keycloak/g" /opt/keycloak/bin/launch.sh
	
	cat >> /etc/systemd/system/keycloak.service << EOF
[Unit]
Description=The Keycloak Server
After=syslog.target network.target
Before=httpd.service
[Service]
Environment=LAUNCH_JBOSS_IN_BACKGROUND=1
EnvironmentFile=/etc/keycloak/keycloak.conf
User=keycloak
Group=keycloak
LimitNOFILE=102642
PIDFile=/var/run/keycloak/keycloak.pid
ExecStart=/opt/keycloak/bin/launch.sh $WILDFLY_MODE $WILDFLY_CONFIG $WILDFLY_BIND
StandardOutput=null
[Install]
WantedBy=multi-user.target
EOF

	systemctl daemon-reload
	systemctl enable keycloak
	systemctl start keycloak

}

main_keycloak(){
	download_openjdk
	install_keycloak "15.1.0"
	create_user_keycloak
	create_systemd_keycloak
	

}

