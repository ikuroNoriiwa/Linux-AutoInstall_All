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
