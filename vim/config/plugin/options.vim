let s:tabstop = 4
let s:scroll = 10

set encoding=UTF-8
set number
" set ruler
set mouse=a
set showmode
set smarttab
set smartindent
set breakindent
set wrap
set expandtab
set emoji
set wildmode=longest,list,full
set splitright
set splitbelow
set splitkeey=screen
set signcolumn=yes
set foldcolumn=1
" set updatetime=c
set hlsearch
set pumheight=10
set termguicolors
set timeoutlen=300
" set nobackup
set cursorline
set hidden
" set noswapfile
set colorcolumn=80
" set clipboard=unnamedplus
set inccommand=split
set smartcase
set ignorecase
set list
set listchars=tab:>·,trail:·,eol:$,extends:»,precedes:«,nbsp:░

let &tabstop = s:tabstop
let &softtabstop = s:tabstop
let &shiftwidth = s:tabstop
let &scrolloff = s:scroll
let &sidescrolloff = s:scroll

let g:gitblame_enabled = v:false
let g:have_nerd_font = v:true
let g:loaded_netrw = v:true
let g:loaded_netrwPlugin = v:true
let g:showbreak = '↪'
let g:showmatch = true

let mapleader = '\<Space>'
