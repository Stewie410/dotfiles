augroup AutoHotKeyFTDetect
    autocmd!
    autocmd BufRead,BufNewFile *.ahk,*.autohotkey,*.ah1,*.ah2,*.ahk1,*.ahk2 :setlocal filetype=autohotkey syntax=autohotkey
augroup END
