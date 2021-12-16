#!/usr/bin/bash

KEYCLOAK=/opt/keycloak
create_realm(){
	# $1 : Realm name 
	# $2 : 

	$KEYCLOAK/bin/kcadm.sh create realms -s realm=$1 -s enabled=$2

}


create_admin_user(){
	# $1 : admin username
	# $2 : admin password
	# $3 : realm name

	$KEYCLOAK/bin/add-user-keycloak.sh -r $3 -u $1 -p $2
}

create_user_on_realm(){
	# $1 : realm name 
	# $2 : username
	# $3 : password 
	# $4 : enabled 

	$KEYCLOAK/bin/kcadm.sh create users -s username=$2 -s enabled=$4 -r $1
	$KEYCLOAK/bin/kcadm.sh set-password -r $1 --username $2 --new-password $3

}
config_credential_all(){
	# $1 : server name
	# $2 : realm name
	# $3 : user
	# $4 : password
	
	$KEYCLOAK/bin/kcadm.sh --server $1 --realm $2 --user $3 --password $4

}

create_client(){
	# $1 : realm name 
	# $2 : client ID 
	# $3 : status 

	$KEYCLOAK/bin/kcadm.sh -r $1 -s clientId=$2 -s enabled=$3
}

