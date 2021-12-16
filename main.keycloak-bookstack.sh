#!/usr/bin/bash

main_keycloak-bookstack(){

    ./main.sh

    ./main.keycloak.sh
    ./main.bookstack.sh
}

main_keycloak-bookstack