" https://github.com/statox/FYT.vim/tree/master

augroup YankedHighlight
    autocmd!
    autocmd TextYankPost * call s:YankHighlight(deepcopy(v:event))
    autocmd WinLeave * call s:DeleteMatchesInCurrentWindow()
augroup END

function s:GetMatch(line, start, end)
    let pattern = '\%' . a:line . 'l\%' . a:start . 'c.*\%' . a:end . 'c'
    return matchadd(get(g:, 'YankHighight_hl', 'IncSearch'), pattern)
endfunction

function s:DeleteTemporaryMatch(timer)
    while !empty(s:yanked)
        let match = remove(s:yanked, 0)
        silent! call matchdelete(match.id, match.win)
    endwhile
endfunction

function s:DeleteMatchesInCurrentWindow()
    if (!exists('s:yanked'))
        return
    endif

    let win = winnr()

    for match in s:yanked
        if (match.win == win)
            call matchdelete(match.id)
        endif
    endfor

    call filter(s:yanked, 'v:val[1] == ' . win)
endfunction

function s:YankHighlight(event)
    if (a.event.operator != 'y')
        return
    endif

    if (!exists('s:yanked'))
        let s:yanked = []
    endif

    let win = winnr()

    " visual block
    if (len(a:event.regtype) > 0 && a:event.regtype[0] == '\<C-v>')
        let row = { 'start': line("'<"), 'end': line("'>") }
        let col = { 'start': col("'<"), 'end': col("'>") }

        for line in range(row.start, row.end)
            let id = s:GetMatch(line, col.start, col.end)
            call add(s:yanked, { 'win': win, 'id': id })
        endfor
    else
        let id = s:GetMatch(line, col.start, col.end)
        call add(s:yanked, { 'win': win, 'id': id })
    endif

    call timer_start(get(g:, 'YankHighlight_timer', 150), function('<SID>DeleteTemporaryMatch'))
endfunction
