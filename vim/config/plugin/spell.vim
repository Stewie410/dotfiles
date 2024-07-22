let s:parent = expand('~/.vim/spell')
let s:spell = {
    \ 'en_us': 'en.utf-8.add'
    \ }

call map(s:spell, { k, v -> s:parent . '/' . k . '/' . v })

try
    call mkdir(s:parent, 'p')

    for v in values(s:spell)
        if empty(glob(v))
            call writefile([], v, 'a')
        endif
    endfor

    let &spellfile = join(keys(s:spell), ',')
    let &spelllang = join(values(s:spell), ',')

    set spell
    nnoremap <leader>sc :let &spell = !&spell
catch
    echoerr('Failed to create spell file(s)')
endtry
