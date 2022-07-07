set tabstop=4 
set softtabstop=4
set shiftwidth=4
set expandtab
set smartindent
set exrc
set relativenumber
set nu
set nohlsearch
set hidden
set noerrorbells
set nowrap
set noswapfile
set nobackup
set undodir=~/vim/undodir
set undofile
set incsearch
set scrolloff=8

call plug#begin('~/.vim/plugged')
" TODO: test nvim-cmp
" Plug 'ms-jpq/coq_nvim', {'branch': 'coq'}
" Plug 'ms-jpq/coq.artifacts', {'branch': 'artifacts'}
call plug#end()

