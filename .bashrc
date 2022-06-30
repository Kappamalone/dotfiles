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
alias recent='cat /var/log/pacman.log | grep "installed\|removed"'
alias battery='cat /sys/class/power_supply/BAT0/capacity'
alias rmlock='sudo rm /var/lib/pacman/db.lck'
# /Aliases

# BTRFS
snapperrollback() {
	sudo snapper-rollback "$1"
}

# For when booting from GRUB
# Run snappercopy, then snapperrollback #id
snappercopy() {
	sudo snapper --config root create --cleanup-algorithm number -d 'rw copy' --read-write 
}

snapperundo() {
	sudo snapper -v undochange "$1".."$2"
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


