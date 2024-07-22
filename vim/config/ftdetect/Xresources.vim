augroup XorgFTDetect
    autocmd!
    " func()
    autocmd BufRead,BufNewFile *.Xresources,*.Xdefaults,*.Xmodmap :setlocal filetype=xdefaults syntax=xdefaults
augroup END
