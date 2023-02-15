# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

clear 

# Adds this to $PATH
export PATH=~/.local/bin/:/home/uzman/.cargo/bin:~/.emacs.d/bin/:~/programming/ps2/ps2dev/ee/bin/:$PATH

export CC="/usr/bin/clang"
export CXX="/usr/bin/clang++"
export CMAKE_GENERATOR="Ninja"
export MOZ_USE_XINPUT2=1

# Aliases
alias ls='ls --color=auto'
alias rl='exec zsh'
alias vim=lvim
alias fzfvim='lvim $(find ~/* | fzf)'
alias fzfcd='cd $(find ~/* -type d | fzf)'
alias fzfcat='cat $(find ~/* | fzf)'
alias ghidra='_JAVA_AWT_WM_NONREPARENTING=1 ~/Ghidra/ghidra_10.2.2_PUBLIC/ghidraRun'
alias recent='cat /var/log/pacman.log | grep "installed\|removed"'
alias battery='cat /sys/class/power_supply/BAT0/capacity'
alias wattage="awk '{print \$1*10^-6 \" W\"}' /sys/class/power_supply/BAT0/power_now"
alias gbuds="bluetoothctl connect 80:9F:F5:0D:C1:A4"
alias gbudsr="bluetoothctl disconnect && gbuds"
# /Aliases

# Misc
cleanexec () {
	chmod +x "$1" && "$1" && chmod 644 "$1"
}

addwallpaper () {
	cp "$1" ~/dotfiles/wallpapers/
}

histsearch () {
    cat ~/.cache/zsh/history | grep "$1"
}

extractarchive() {
    bsdtar -xzvf "$1"
}
# /Misc

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


# ZSH Config (taken from Luke Smith's)

# Enable colors and change prompt:
autoload -U colors && colors
# PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}$%b "

# History in cache directory:
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.cache/zsh/history

# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)		# Include hidden files.

# vi mode
bindkey -v
export KEYTIMEOUT=1

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# Change cursor shape for different vi modes.
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'
  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

# TODO: change this to not suck
# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line

zle-fzfvim() {
    fzfvim
}
zle -N  zle-fzfvim
bindkey '^f' zle-fzfvim

# zsh-autosuggestions
bindkey '^ ' autosuggest-accept

# Prompt
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Plugins
plugindir='/usr/share/zsh/plugins'
source "$plugindir"/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null
source "$plugindir"/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
