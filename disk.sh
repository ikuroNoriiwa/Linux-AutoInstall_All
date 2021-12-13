#!/usr/bin/bash

add_vg_data(){


lvcreate --name data -l 100%FREE VGROOT
mkfs --type xfs /dev/mapper/VGROOT-data
mkdir /data
#mount /dev/mapper/VGROOT-data /data
echo "/dev/mapper/VGROOT-data /data xfs defaults 0 0" >> /etc/fstab
mount -a
}

add_disk_to_lvroot(){

echo "n
p



w
"|fdisk /dev/sda
pvcreate /dev/sda3
vgextend VGROOT /dev/sda3
add_vg_data

}

fstab_modification(){
    
    lv=`ls /dev/mapper | grep VG`
    cp -vip /etc/fstab /etc/fstab.bak 
    for i in $lv; do 
        uid=`blkid /dev/mapper/$i -s UUID -o value`
        sed -ie "s/\/dev\/mapper\/$i/UUID=$uid/g" /etc/fstab
    done

}