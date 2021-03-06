#!/usr/bin/bash

source keycloak/util.keycloak.sh
source keycloak/keycloak.sh

DEFAULT_PASSWORD="password"
ADMIN_USERNAME="admin"
ADMIN_PASSWORD="admin"
MASTER_REALM="master"
ESGI_REALM="KOLLAB"
USER_DEFAULT_STATUS=true

main_keycloak(){
	download_openjdk
	install_keycloak "15.1.0"
	create_user_keycloak
	create_systemd_keycloak

	sleep 30
	#config sso 
	create_admin_user $ADMIN_USERNAME $ADMIN_PASSWORD $MASTER_REALM

	# Required for user to be used
	systemctl restart keycloak

	sleep 30

	## No host named add currently so only 127.0.0.1 will work
	config_credential_all https://sso.esgi.local/auth $MASTER_REALM $ADMIN_USERNAME $ADMIN_PASSWORD
	# config_credential_all http://127.0.0.1/auth $MASTER_REALM $ADMIN_USERNAME $ADMIN_PASSWORD
	create_realm $ESGI_REALM $USER_DEFAULT_STATUS

	create_user_on_realm KOLLAB nimda $DEFAULT_PASSWORD $USER_DEFAULT_STATUS
	create_user_on_realm KOLLAB esgi $DEFAULT_PASSWORD $USER_DEFAULT_STATUS

	create_client $ESGI_REALM bookstack $USER_DEFAULT_STATUS 
}

main_keycloak
