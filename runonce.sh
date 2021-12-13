#!/usr/bin/bash

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