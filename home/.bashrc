#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias sway='dbus-run-session sway'

PS1='[\u@\h \W]\$ '

EDITOR=nano;   	export EDITOR
PAGER=less;  	export PAGER

# Iniciar sway automaticamente no tty1 (Arch Linux)
if [ "$(tty)" = "/dev/tty1" ]; then
  exec sway -d > /tmp/sway.log 2>&1
fi
