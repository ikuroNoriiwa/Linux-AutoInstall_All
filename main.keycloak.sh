#!/usr/bin/bash

main_keycloak(){
	download_openjdk
	install_keycloak "15.1.0"
	create_user_keycloak
	create_systemd_keycloak
}

main_keycloak
