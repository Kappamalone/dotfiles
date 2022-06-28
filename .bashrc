#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Startup 
clear
setfont ter-132n
paleofetch
PS1='\u@\h \W\$ '
# /Startup

# Aliases
alias ls='ls -a --color=auto'
alias rl='. ~/.bashrc'
alias vim=nvim
alias battery='cat /sys/class/power_supply/BAT0/capacity'
# /Aliases

# BTRFS
rollback() {
	sudo snapper --ambit classic rollback "$1"
}
# /BTRFS

# AUR
iaur() {
	cwd=$PWD
	git clone https://aur.archlinux.org/"$1" ~/aur/"$1"
	cd ~/aur/"$1"
	makepkg -si 
	cd "$cwd" 
}

uaur() {
	cwd=$PWD
	cd ~/aur/"$1"
	git pull
	makepkg -si
	cd "$cwd" 
}

daur() {
	sudo pacman -Rns "$1"
	rm -rf ~/aur/"$1"
}
# TODO: update aur packages
# /AUR

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


