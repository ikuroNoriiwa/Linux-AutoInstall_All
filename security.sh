#!/usr/bin/bash

requirements(){

    setenforce 0
    sed -i 's/enforcing/disabled/g' /etc/selinux/config
    systemctl stop firewalld
    systemctl disable firewalld 
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
    sed -iE 's/#Port[[:blank:]][0-9]{1,4}/Port ${SSH_PORT:-2222}/' /etc/ssh/sshd_config
    sed -i 's/#UseDNS[[:blank:]]yes/UseDNS NO/' /etc/ssh/sshd_config
    
}

hardening(){

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