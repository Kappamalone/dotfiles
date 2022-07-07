# Profile file. Runs on login. Environmental variables are set here

# Adds this to $PATH
export PATH=~/.local/bin/:$PATH

# Default Programs
export EDITOR="nvim"
export TERMINAL="kitty"
export BROWSER="firefox"

# startx on login
if [ -z "${DISPLAY}" ] && [ "${XDG_VTNR}" -eq 1 ]; then
	exec startx
fi
