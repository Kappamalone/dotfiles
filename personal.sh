# source this in ~/.bashrc
#
# dependencies: need an nvim 11.0+ alias

# alias zawahirtools="PATH=$HOME/cmake-bin/bin:$PATH"
# alias nvim="VIMRUNTIME=~/neovim/runtime ~/neovim/build/bin/nvim"

# git aliases
alias gds="git diff --staged"
alias ggs="git status"

# prompt
parse_git_branch() {
  git branch 2>/dev/null | sed -n '/\* /s///p'
}

git_branch_segment() {
  local b
  b=$(parse_git_branch)
  if [ -n "$b" ]; then
    printf ' (%s)' "$b"
  fi
}

export PS1="\[\e[32m\]\u@\h \[\e[33m\]\w\[\e[36m\]\$(git_branch_segment)\[\e[0m\]\$ "

USR_BIN="$HOME/usr/bin"
export PATH="$USR_BIN:$PATH"
