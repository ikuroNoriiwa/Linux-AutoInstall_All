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
	
cat > /etc/systemd/system/keycloak.service <<EOF

[Unit]
Description=Keycloak
After=network.target

[Service]
Type=idle
User=keycloak
Group=keycloak
ExecStart=/opt/keycloak/bin/standalone.sh -b 0.0.0.0
TimeoutStartSec=600
TimeoutStopSec=600

[Install]
WantedBy=multi-user.target
EOF
	systemctl daemon-reload
	systemctl enable keycloak
	systemctl start keycloak

}

