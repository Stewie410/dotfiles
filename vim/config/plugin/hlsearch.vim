nnoremap <expr> <CR> <SID>ToggleHlSearch()

function s:ToggleHlSearch()
    if &hlsearch
        set nohlsearch
        return ''
    else
        return '<CR>'
    end
endfunction
