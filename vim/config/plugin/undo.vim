let s:parent = expand('~/.vim/undo')

call mkdir(s:parent, 'p')

let &undodir = s:parent
set undofile
set undolevels=1000
