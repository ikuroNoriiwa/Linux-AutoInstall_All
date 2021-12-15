#!/usr/bin/bash

source keycloak.sh
source util.keycloak.sh

main_keycloak(){
	download_openjdk
	install_keycloak "15.1.0"
	create_user_keycloak
	create_systemd_keycloak
	create_admin_user admin admin master
       	create_realm KOLLAB true	
}

main_keycloak
