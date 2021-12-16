#!/usr/bin/bash

source ./bookstack.sh

main_bookstack(){

    ssl_keys
    requirements_bookstack_mariadb_php
    conf_mariadb
    conf_nginx
    bookstack_env
    conf_bookstack_for_SSO
}

main_bookstack
