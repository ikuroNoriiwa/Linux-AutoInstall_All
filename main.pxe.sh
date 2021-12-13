#!/usr/bin/bash

source ./disk.sh
source ./pxe.sh

main_pxe(){
    ./main.sh

    add_disk_to_lvroot
    fstab_modification

    pxe

    updatedb
    reboot
}

main_pxe