augroup GroffFTDetect
    autocmd!
    autocmd BufRead,BufNewFile *.ms,*.me,*.mom,*.man :setlocal filetype=groff syntax=groff
augroup END
