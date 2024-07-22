function s:Customize()
    setlocal nonumber
    setlocal norelativenumber
    setlocal scrolloff=0
    setlocal sidescrolloff=0
    setlocal nospell
endfunction

augroup TerminalChanges
    autocmd!
    " TerminalOpen TerminalWinOpen
    autocmd TerminalOpen,TerminalWinOpen * call s:Customize()
augroup END

tnoremap <Esc><Esc> <C-\><C-n>
nnoremap <silent> <leader>ot :call s:Customize()
