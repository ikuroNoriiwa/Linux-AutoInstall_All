#!/usr/bin/bash

source ./run_once.sh
source ./security.sh
source ./utils.sh

main(){
    requirements
    update_package
    required_package
    language

    ## package

    set_static_ip_form_dhcp_eth0
    clean_hostname wiki .esgi.local
    change_time

    setup_issue

    password_expiration
    grub_modification
    disable_usb
    ssh_configuration_hardening
    hardening

    ssh_key_creation
    run_once_setup_bashrc
    run_once_last_ssh_login

    ## single command
    updatedb
}

main