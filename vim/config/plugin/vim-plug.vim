let s:data_dir = expand('~/.vim')
let s:config_dir = expand(s:data_dir . '/vimplug')

function s:get_plug()
    let uri = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    let plug = s:data_dir . '/autoload/plug.vim'

    if empty(glob(plug))
        silent execute '!curl --force --Location --output ' . plug . ' --create-dirs ' . uri
        autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
    endif
endfunction

call plug#begin(s:data_dir . '/plugged')
    Plug 'tpope/vim-sensible'

    Plug 'ayu-theme/ayu-vim'

    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'

    Plug 'tpope/vim-fugitive'
    Plug 'tpope/mhinz/vim-signify', { 'tag': 'legacy' }

    Plug 'neoclide/coc.nvim', { 'branch': 'release' }
    Plug 'tpope/vim-endwise'
    Plug 'tpope/vim-surround'
    Plug 'tpope/vim-ragtag'
    Plug 'sheerun/vim-polyglot'

    Plug 'lervag/vimtex', { 'for': 'tex' }
    Plug 'pprovost/vim-ps1', { 'for': [ 'ps1', 'psd1', 'psm1' ]}
    Plug 'tpope/vim-markdown', { 'for': 'md' }
    Plug 'tpope/vim-jdaddy', { 'for': 'json' }

    Plug 'junegunn/vim-easy-align'
    Plug 'chrisbra/unicode.vim'
    Plug 'tpope/vim-characterize'
    Plug 'tpope/vim-repeat'
    Plug 'tpope/vim-eunuch'
    Plug 'tpope/vim-abolish'
    Plug 'tpope/vim-commentary'
    Plug 'tpope/vim-speeddating'
call plug#end()

let s:config_dir = s:data_dir . '/vimplug'
let s:configs = [
    \ s:config_dir . '/coc/init.vim',
    \ ]
call extend(s:configs, glob(s:config_dir . '*.vim', v:false, v:true))

for c in s:configs
    execute 'source ' . c
endfor


