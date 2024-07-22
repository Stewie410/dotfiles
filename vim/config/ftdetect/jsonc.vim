augroup JsonFTDetect
    autocmd!
    autocmd BufRead,BufNewFile *.json :setlocal filetype=jsonc syntax=jsonc
augroup END
