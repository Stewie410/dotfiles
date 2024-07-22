let s:cfg_root = expand('~/.vim/vimplug/coc')
let s:configs = [
    \ 'vars',
    \ 'commands',
    \ 'keymap'
    \ ]

for cfg in s:configs
    execute 'source ' . s:cfg_root . '/' . cfg . '.vim'
endfor
