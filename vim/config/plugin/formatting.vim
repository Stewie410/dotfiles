augroup FormatOnSave
    autocmd!
    autocmd BufWritePre * :silent! call s:TrimTrailingWhitespace()
augroup END

function s:TrimTrailingWhitespace()
    let v = winsaveview()
    keeppatterns %s/\s\+$//e
    call winrestview(v)
endfunction
