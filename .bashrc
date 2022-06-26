#
# ~/.bashrc
#

# ARCH
alias rl='. ~/.bashrc'
alias vim=nvim
alias battery='cat /sys/class/power_supply/BAT0/capacity'


# Internet
# TODO: what do ethernet
lwifi() {
	nmcli device wifi list
}

cwifi() {
	sudo nmcli device wifi connect "$1" password "$2"
}

dwifi() {
	sudo nmcli device disconnect "$1"
}
# /Internet

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '
