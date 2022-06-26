#!/bin/bash

# fool me once, shame on you. fool me twice...
if [ "$PWD" != "/home/$USER/dotfiles" ]; then
	echo "Please run this script in ~/dotfiles"
	exit
fi       

# TODO: learn regexp once and for all

# TODO: learn what this actually does 
shopt -s dotglob

# create symlinks for basic dotfiles in ~/
for dotfile in $(ls -d [.]*); do
	if [ -f "$dotfile" ]; then
		ln -s -f $PWD/$dotfile ~/$dotfile
		echo "Linked ~/dotfiles/$dotfile with ~/$dotfile"
	fi
done
echo

# link .config
cp -rsv -f ~/dotfiles/.config/* ~/.config/
echo "Linked ~/dotfiles with ~/.config"
