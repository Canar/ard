#!/bin/sh
echo .profile loaded.
HOME=/data/data/jackpal.androidterm/app_HOME
export HOME
SSHC=$HOME/.ssh/ssh_config

f="-F $SSHC"
ip=50.69.10.41
un=user
sl=$un@$ip

_ssh(){
	echo using .profile ssh
	/system/bin/ssh $f "$@"	
}
ssh(){ _ssh "$@" ; }
home(){ ssh $f -p 22$1 $sl "${@:2}" ;}
reg(){ cat .ssh/id_rsa.pub | "$@" 'cat >> ~/.ssh/authorized_keys' ;}
g(){ home 0 "$@" ; }
i(){ home 1 "$@" ; }
v(){ ssh user@192.168.0.6 ; }


alias scp="scp $f"
alias vi="vim"
