#!/usr/bin/bash

# Version     :   v3



requirements(){

    #sentenforce 0
    sed -i 's/enforcing/disabled/g' /etc/selinux/config
    systemctl stop firewalld
    systemctl disable firewalld 
}

download_rpm(){
    package_name=$1
    dest=$2


    yumdownloader $package_name --destdir $dest
}
update_install_remove(){
    yum update -y
    yum remove -y iwl* bluez* telnet
    yum install epel-release -y
    yum config-manager --set-enabled powertools
    yum install vim mlocate tmux zip dstat iotop git psmisc tree mc curl  openssl lynis pigz glibc-all-langpacks rsync htop glances net-tools bash-completion lynx figlet rkhunter -y
    localectl set-locale LANG=fr_FR.utf8
    localectl set-keymap fr

}

setup_bashrc(){

    cat >> /tmp/.bashrc << EOF
    HISTOCONTROL=ignoreboth
    HISTSIZE=100000
    HISTFILESIZE=100000
    export PROMPT_COMMAND='history -a;history -n;history -w'
    export PS1='\n\e[0;31m\[******************************\n[\t] \u@\h \w \\$ \e[m'
    alias ll='ls -lh'
    alias la='ls -lha'
    alias l='ls -CF'
    alias em='emacs -nw'
    alias dd='dd status=progress'
    alias _='sudo'
    alias _i='sudo -i'
    alias please='sudo'
    alias fucking='sudo'
    alias df="df -hT --total -x devtmpfs -x tmpfs"
    alias rm="rm -iv --preserve-root"
    alias grep="grep --color=auto"
    alias vi="vim"
    alias ll="ls -l"
    alias cp="cp -i"                          # confirm before overwriting something
    alias free='free -m'                      # show sizes in MB
    alias more='less'
    alias chmod="chmod -v --preserve-root"
    alias reboot="shutdown -r"
    alias off="shutdown -h"
    alias grep="grep --color"
    alias more="less"
    alias chown="chown -v --preserve-root"
    alias chgrp="chgrp -v --preserve-root"
    alias plantu="netstat -plantu"
    alias lz="ll -z"
    alias pz="ps -faxZ"
    alias plantuZ="plantu -Z"

EOF


    mv /root/.bashrc /root/.bashrc_old
    cp /tmp/.bashrc /root/.bashrc
    chmod 770 /root/.bashrc

    user=$(grep bash /etc/passwd|tail -1| cut -d: -f1)


    mv /home/$user/.bashrc /home/$user/.bashrc_old
    cp /tmp/.bashrc /home/$user/.bashrc
    chown $user /home/$user/.bashrc
    chmod 770 /home/$user/.bashrc
    cat >> /home/$user/.bashrc << EOF
    export PS1="\[\e[32m\][\[\e[m\]\[\e[31m\]\u\[\e[m\]\[\e[33m\]@\[\e[m\]\[\e[32m\]\h\[\e[m\]:\[\e[36m\]\w\[\e[m\]\[\e[32m\]]\[\e[m\]\[\e[32;47m\]\\$\[\e[m\] "
EOF
}

setup_issue(){

    cat > /etc/issue.net << EOF
    *********************************************************************************
    *                                                                               *
    *   NOTICE TO USERS                                                             *
    *                                                                               *
    *   This computer system is the private property of its owner, whether          *
    *   individual, corporate or government.  It is for authorized use only.        *
    *   Users (authorized or unauthorized) have no explicit or implicit             *
    *   expectation of privacy.                                                     *
    *                                                                               *
    *   Any or all uses of this system and all files on this system may be          *
    *   intercepted, monitored, recorded, copied, audited, inspected, and           *
    *   disclosed to your employer, to authorized site, government, and law         *
    *   enforcement personnel, as well as authorized officials of government        *
    *   agencies, both domestic and foreign.                                        *
    *                                                                               *
    *   By using this system, the user consents to such interception, monitoring,   *
    *   recording, copying, auditing, inspection, and disclosure at the             *
    *   discretion of such personnel or officials.  Unauthorized or improper use    *
    *   of this system may result in civil and criminal penalties and               *
    *   administrative or disciplinary action, as appropriate. By continuing to     *
    *   use this system you indicate your awareness of and consent to these terms   *
    *   and conditions of use. LOG OFF IMMEDIATELY if you do not agree to the       *
    *   conditions stated in this warning.                                          *
    *                                                                               *
    *********************************************************************************
EOF

    cp /etc/issue.net /etc/motd
    figlet READ_ABOVE_STATEMENT >>/etc/motd
    \cp /etc/issue.net /etc/issue

}

password_expiration(){
    sed -i '/PASS_MAX_DAYS/s/99999/180/' /etc/login.defs
    sed -i '/PASS_MIN_LEN/s/5/12/' /etc/login.defs
    sed -i '/PASS_WARN_AGE/s/7/12/' /etc/login.defs
    sed -i '/PASS_MIN_DAYS/s/0/1/' /etc/login.defs
    sed -i '/UMASK/s/022/0077/' /etc/login.defs
    sed -i '/umask/s/002/0077/' /etc/profile
    sed -i '/umask/s/022/0077/' /etc/profile
    
    cat >> /etc/login.defs << EOF
#change encrypt method
SHA_CRYPT_MIN_ROUNDS 99999
#nb de secondes avoir de pouvoir refaire une tentive
FAIL_DELAY 5
#log les fail login
FAILLOG_ENAB yes
#log les connexion reussies
LOG_OK_LOGINS yes
#afficher les users fail avecun user inconnu
LOG_UNKFAIL_ENAB yes
#tentative de connexion en cas de mauvais mdp
LOGIN_RETRIES 3
#avertir d'un maucais mdp
PASS_ALWAYS_WARN yes
#activer des check lors du changement de mdp
OBSCURE_CHECKS_ENAB yes

EOF
}

grub_modification(){

    cat >> /etc/default/grub << EOF
GRUB_DISABLE_RECOVERY="true"
GRUB_DISABLE_SUBMENU="true"
EOF


    #############################
    #                           #
    #   grub setup timeout      #
    #                           #
    #############################
    sed -i 's/=5/=30/' /etc/default/grub


    #############################
    #                           #
    #   grub  video quality     #
    #                           #
    #############################

    sed -i 's/quiet/vga=791/' /etc/default/grub
    sed -i "/GRUB_GFXMODE/s/^#//" /etc/default/grub
    sed -i "/GRUB_GFXMODE/s/640x480/1920x1080/" /etc/default/grub

    #############################
    #                           #
    #   grub setup password     #
    #                           #
    #############################


    sed -i '$a set superusers="grub"' /etc/grub.d/40_custom
    grub_mdp_hash=`echo -e "grub\ngrub" | grub2-mkpasswd-pbkdf2 | grep grub | awk -F " " '{ print $7}'`

    sed -i '$a password_pbkdf2 grub HASH' /etc/grub.d/40_custom
    sed -i "/HASH/s/HASH/$grub_mdp_hash/" /etc/grub.d/40_custom


    sed -i 's/--class os/--class os --unrestricted/g' /etc/grub.d/10_linux

    grub2-mkconfig -o "$(readlink -e /etc/grub2.cfg)"

}

ssh_key_creation(){
    #############################
    #                           #
    #   creat ssh key for root  #
    #                           #
    #############################


    mkdir -v ~/.ssh
    chmod -v 700 ~/.ssh

    ssh-keygen -t ed25519 -f /root/.ssh/id_ed25519 -q -N ""
    cat /root/.ssh/id_ed25519.pub >> /root/.ssh/authorized_keys
    echo ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGqyToSio/QdJELe8irhi1Yy9zBC4LVSWJr3OQRYIYLf root@MXLINUX >> /root/.ssh/authorized_keys

    #############################
    #                           #
    #   creat ssh key for user  #
    #                           #
    #############################


    mkdir -v /home/$user/.ssh
    chmod -v 700 /home/$user/.ssh
    ssh-keygen -t ed25519 -f /home/$user/.ssh/id_ed25519 -q -N ""
    chmod -v 700 /home/$user

    #test
    chown -R $user:$user /home/$user/.ssh

}
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

last_ssh_login(){

        cat >> /etc/profile << EOF
    last | head -n 5
EOF
}

disable_usb(){
    cat >> /etc/modprobe.conf << EOF
install usb-storage : 
install tipc /bin/true
install rds /bin/true
install sctp /bin/true
install dccp /bin/true
install firewire-core /bin/true
EOF

    echo 'install usb-storage /bin/true' >> disable-usb-storage.conf
    modprobe -r usb-storage
    mv -v /lib/modules/$(uname -r)/kernel/drivers/usb/storage/usb-storage.ko* /root

    cat >> /etc/modprobe.d/blacklist.conf << EOF
blacklist usb-storage
blacklist tipc
blacklist rds
blacklist sctp
blacklist dccp
blacklist firewire-core
EOF

}

ssh_configuration_hardening(){
    
    #sed -i 's/PASS_MIN_LEN[[:blank:]]5/PASS_MIN_LEN 12/g' /etc/login.defs
    sed -i 's/#AllowTcpForwarding[[:blank:]]yes/AllowTcpForwarding NO/g' /etc/ssh/sshd_config
    sed -i 's/#ClientAliveCountMax[[:blank:]]3/ClientAliveCountMax 2/g' /etc/ssh/sshd_config
    sed -i 's/#Compression[[:blank:]]delayed/Compression NO/g' /etc/ssh/sshd_config
    sed -i 's/#LogLevel[[:blank:]]INFO/LogLevel VERBOSE/g' /etc/ssh/sshd_config
    sed -i 's/#MaxAuthTries[[:blank:]]6/MaxAuthTries 3/g' /etc/ssh/sshd_config
    sed -i 's/#MaxSessions[[:blank:]]10/MaxSessions 2/g' /etc/ssh/sshd_config
    sed -i '/PermitRootLogin/s/yes/without-password/' /etc/ssh/sshd_config
    sed -i '/X11Forwarding/s/yes/NO/' /etc/ssh/sshd_config
    sed -i 's/#AllowAgentForwarding[[:blank:]]yes/AllowAgentForwarding NO/g' /etc/ssh/sshd_config
    sed -i 's/#TCPKeepAlive[[:blank:]]yes/TCPKeepAlive NO/g' /etc/ssh/sshd_config
    #sed -i 's/#Port[[:blank:]]22/Port 2222/' /etc/ssh/sshd_config
    sed -i 's/#UseDNS[[:blank:]]yes/UseDNS NO/' /etc/ssh/sshd_config
    
    
    cat >> /etc/security/limits.conf << EOF
* hard core 0
* soft core 0
EOF
	
	cat >> /etc/sysctl.d/9999-disable-core-dump.conf << EOF
fs.suid_dumpable=0
kernel.core_pattern=|/bin/false
EOF

	sysctl -p /etc/sysctl.d/9999-disable-core-dump.conf
    
    sysctl -a > /tmp/sysctl-defaults.conf
    
    cat >> /etc/sysctl.d/80-lynis.conf << EOF
kernel.kptr_restrict = 2
kernel.sysrq = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.default.log_martians = 1
#net.ipv4.tcp_timestamps = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0    
EOF
sysctl --system
rkhunter --update
rkhunter --propupd
    
}
clean_hostname(){
    hostname="SERVEUR.PXE"
    domain=".esgi.local"
    echo "$hostname$domain" > /etc/hostname
    ip=`ip -o -4 addr list | grep 2: | awk '{print $4}' | cut -d/ -f1`
    
    echo "$ip	$hostname	$hostname$domain" > /etc/hosts
	echo "127.0.0.1	$hostname	$hostname$domain" >> /etc/hosts
}

change_time(){

timedatectl set-ntp off
#set good time zonel
timedatectl set-timezone Europe/Paris
#NTP
timedatectl set-ntp on 
}

set_static_ip(){
    ip=`hostname -I`
    gw=`ip r | grep default | awk '{ print $3}'`
    it=`ip a | grep "state UP" | awk -F ": " '{ print $2 }'`

    cat > /etc/sysconfig/network-scripts/ifcfg-$it << EOF
DEVICE=$it
ONBOOT=yes
IPADDR=$ip
PREFIX=24
GATEWAY=$gw
DNS1=1.1.1.1
DNS2=8.8.8.8
IPV6_PRIVACY=no
EOF


}

install_dnsmasq(){
cat >> /etc/sysconfig/network-scripts/ifcfg-enp0s8 << EOF
# Generated by parse-kickstart
TYPE=Ethernet
DEVICE=enp0s8
ONBOOT=yes
BOOTPROTO=static
IPV6INIT=no
PROXY_METHOD=none
BROWSER_ONLY=no
IPV4_FAILURE_FATAL=no
IPV6_AUTOCONF=no
IPV6_DEFROUTE=no
IPV6_FAILURE_FATAL=no
NAME="System enp0s8"
IPADDR=192.168.0.1
NETMASK=255.255.255.0
EOF

dnf install dnsmasq -y
mv /etc/dnsmasq.conf  /etc/dnsmasq.conf.backup

cat >> /etc/dnsmasq.conf << EOF
interface=enp0s8,lo
#bind-interfaces
domain=SERVEUR.PXE.esgi.local
# DHCP range-leases
dhcp-range= enp0s8,192.168.0.3,192.168.0.253,255.255.255.0,1h
# PXE
dhcp-boot=pxelinux.0,pxeserver,192.168.0.1
# Gateway
#dhcp-option=3,192.168.0.255
# DNS
#dhcp-option=6,192.168.0.1, 8.8.8.8
server=8.8.4.4
# Broadcast Address
#dhcp-option=28,192.168.0.255
# NTP Server
dhcp-option=42,0.0.0.0
pxe-prompt="Press F8 for menu.", 60
pxe-service=x86PC, "Install CentOS 8 from network server 192.168.0.1", pxelinux
enable-tftp
tftp-root=/var/lib/tftpboot
EOF

dnf install syslinux -y
dnf install tftp-server -y
cp -r /usr/share/syslinux/* /var/lib/tftpboot
mkdir /var/lib/tftpboot/pxelinux.cfg
touch /var/lib/tftpboot/pxelinux.cfg/default

cat >> /var/lib/tftpboot/pxelinux.cfg/default << EOF
default menu.c32
prompt 0
timeout 300
ONTIMEOUT local

menu title ########## PXE Boot Menu ##########

label 1
menu label ^1) Install Rocky Linux 8 x64 
kernel rocky8/vmlinuz
append initrd=rocky8/initrd.img method=ftp://192.168.0.1/pub/data/rocky8/ devfs=nomount ip=dhcp

label 2
menu label ^2) Install Rocky Linux 8 AUTO ON
kernel rocky8/vmlinuz
append initrd=rocky8/initrd.img method=ftp://192.168.0.1/pub/data/rocky8/ devfs=nomount ip=dhcp ramdisk=32768 inst.ks=ftp://192.168.0.1/pub/data/rocky8/ks.cfg

EOF

#wget https://download.rockylinux.org/pub/rocky/8/isos/x86_64/Rocky-8.4-x86_64-dvd1.iso -O /data/rocky8.iso
# 
mount /dev/sr0 /mnt
mkdir /var/lib/tftpboot/rocky8
cp /mnt/images/pxeboot/vmlinuz /var/lib/tftpboot/rocky8
cp /mnt/images/pxeboot/initrd.img /var/lib/tftpboot/rocky8
chmod 755 -R /var/lib/tftpboot/rocky8

##snapchot iso

mkdir -p /data/rocky8/AppStream


cat >> /data/rocky8/ks.cfg << EOF
# Set the authentication options for the system
# auth --passalgo=sha512 --useshadow
# Install OS instead of upgrade
# install
graphical
# License agreement
eula --agreed
# Use network installation
# cdrom
#repo --name="AppStream" --baseurl="ftp://192.168.0.1/pub/data/rocky8/"

url --url="ftp://192.168.0.1/pub/data/rocky8/BaseOS/"

# Use text mode install
text
# Disable Initial Setup on first boot
firstboot --disable
# Keyboard layout
keyboard --vckeymap=fr --xlayouts='fr'
# System language
lang en_US.UTF-8
# Network information
network --onboot=yes --bootproto=dhcp --device=link --activate --nameserver=1.0.0.1,1.1.1.1
## --noipv6
# Root password
rootpw V@grant1

firewall --enabled --ssh --http --dns --https
#--service=ssh

# SELinux configuration
#selinux --enforcing
selinux --permissive
# Do not configure the X Window System
skipx
# System timezone
timezone Europe/Paris --isUtc
# Add a user named packer
# user --name=vagrant --groups=wheel --password=V@grant1 --plaintext

# # System bootloader configuration
# bootloader --location=mbr --append="crashkernel=auto"
# # Clear the Master Boot Record
# zerombr
# # Remove partitions
# clearpart --all --initlabel
# # Automatically create partitions using LVM
# # autopart --type=lvm

zerombr
clearpart --all --initlabel
#part /boot --fstype="xfs" --size=1024
#part pv.0 --fstype="lvmpv" --size=1 --grow
#volgroup VGROOT pv.0
#logvol swap --fstype="swap" --size=500 --name=swap --vgname=VGROOT
#logvol / --fstype="xfs" --size=5120 --name=root --vgname=VGROOT

part raid.sda0 --fstype="mdmember" --ondisk=sda --size=1025
part raid.sbd0 --fstype="mdmember" --ondisk=sdb --size=1025
part raid.sda1 --fstype="mdmember" --ondisk=sda --size=1 --grow
part raid.sdb1 --fstype="mdmember" --ondisk=sdb --size=1 --grow

raid /boot --device=boot --fstype="xfs" --level=RAID1 --label=BOOT raid.sda0 raid.sdb0
raid pv.00 --device=pv00 --fstype="lvmpv" --level=RAID1 --encrypted --passphrase="Ertyuiop" --luks-version=luks2 raid.sda1 raid.sdb1

volgroup VGCRYPT pv.00

logvol / --fstype="xfs" --size=6144 --label="RACINE" --name=root --vgname=VGCRYPT
logvol /tmp --fstype="ext4" --size=1024 --label="TMP" --name=tmp --vgname=VGCRYPT
logvol /var --fstype="xfs" --size=10240 --label="VAR" --name=var --vgname=VGCRYT
logvol /home --fstype="xfs" --size=1024 --label="HOME" --name=home --vgname=VGCRYPT
logvol swap --fstype="swap" --size=512 --label="SWAP" --name=swap --vgname=VGCRYPT


# Reboot after successful installation
reboot



# Reboot after successful installation
reboot

%packages --ignoremissing
# dnf group info minimal-environment
@^minimal-environment
%end

%post --log=/var/log/kickstart_post.log

curl ftp://anonymous:@192.168.0.1/pub/data/rocky8/client.sh -o /tmp/client.sh
chmod +x /tmp/client.sh
/tmp/hardern.sh 2>/var/log/client.sh.err.log | tee /var/log/client.sh.log

%end

EOF

cp -R /mnt/AppStream/* /data/rocky8/AppStream/

### Get script
# cp $(readlink -f $0) /data/rocky8/harden.sh
# sed -iE "s/^(.*# function.*)$//g" /data/rocky8/harden.sh
sudo dnf install yum-utils -y
var="lynx lynis epel-release glances htop mlocate"

for app in $var; do 
    echo $app
    download_rpm $app /data/rocky8/AppStream/Packages 
done

cp /root/client.sh /data/rocky8/

chmod -R 775 /data
umount /mnt

dnf install vsftpd -y
mkdir /var/ftp/pub/data

grep " /data " /etc/fstab | sed "s|/data|/var/ftp/pub/data|g" >> /etc/fstab
mount -a

sed -i '/anonymous_enable/s/NO/YES/' /etc/vsftpd/vsftpd.conf

chmod -R 755 /var/ftp/pub


systemctl restart dnsmasq
#systemctl status dnsmasq
systemctl restart vsftpd
#systemctl status vsftpd
systemctl enable dnsmasq
systemctl enable vsftpd

}



main(){

    requirements # function
    update_install_remove
    setup_bashrc
    setup_issue
    password_expiration
    grub_modification
    ssh_key_creation
    ssh_configuration_hardening
    #add_vg_data
    add_disk_to_lvroot # function
    fstab_modification
    last_ssh_login
    disable_usb
    clean_hostname # function
    change_time
    set_static_ip # function
    install_dnsmasq # function
    updatedb
    reboot
}

main

