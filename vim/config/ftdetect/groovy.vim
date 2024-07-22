augroup GroovyFTDetect
    autocmd!
    autocmd BufRead,BufNewFile *.groovy,*.gvy,*.gy,*.gsh :setlocal filetype=groovy syntax=java
augroup END
