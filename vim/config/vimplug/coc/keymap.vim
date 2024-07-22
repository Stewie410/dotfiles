inoremap <silent><expr> <Tab> <SID>tab()
inoremap <silent><expr> <S-Tab> <SID>s_tab()

inoremap <silent><expr> <C-@> coc#refresh()

nnoremap <silent> [d <Plug>(coc-diagnostic-prev)
nnoremap <silent> ]d <Plug>(coc-diagnostic-next)

nnoremap <silent> gd <Plug>(coc-definition)
nnoremap <silent> <leader>D <Plug>(coc-type-definition)
nnoremap <silent> gI <Plug>(coc-implementation)
nnoremap <silent> gr <Plug>(coc-references)

nnoremap <silent> K :call <SID>hover()<CR>

nnoremap <leader>rn <Plug>(coc-rename)

xnoremap <leader>fr <Plug>(coc-format-selected)
nnoremap <leader>fr <Plug>(coc-format-selected)

xnoremap <leader>ca <Plug>(coc-codeaction-selected)
nnoremap <leader>ca <Plug>(coc-codeaction-cursor)
nnoremap <leader>sa <Plug>(coc-codeaction-source)

nnoremap <leader>qf <Plug>(coc-fix-current)

nnoremap <silent> <leader>r <Plug>(coc-codeaction-refactor)
nnoremap <silent> <leader>re <Plug>(coc-codeaction-refactor-selected)
xnoremap <silent> <leader>re <Plug>(coc-codeaction-refactor-selected)

nnoremap <silent> <leader>cl <Plug>(coc-codelens-action)

xnoremap <leader>if <Plug>(coc-funcobj-i)
onoremap <leader>if <Plug>(coc-funcobj-i)
xnoremap <leader>af <Plug>(coc-funcobj-a)
onoremap <leader>af <Plug>(coc-funcobj-a)

xnoremap <leader>ic <Plug>(coc-classobj-i)
onoremap <leader>ic <Plug>(coc-classobj-i)
xnoremap <leader>ac <Plug>(coc-classobj-a)
onoremap <leader>ac <Plug>(coc-classobj-a)

if has('path-8.2.0750')
    nnoremap <silent><nowait><expr> <C-b> <SID>scroll('rev')
    inoremap <silent><nowait><expr> <C-b> <SID>scroll('rev')
    vnoremap <silent><nowait><expr> <C-b> <SID>scroll('rev')
    nnoremap <silent><nowait><expr> <C-f> <SID>scroll('fwd')
    inoremap <silent><nowait><expr> <C-f> <SID>scroll('fwd')
    vnoremap <silent><nowait><expr> <C-f> <SID>scroll('fwd')
endif

nnoremap <silent> <C-s> <Plug>(coc-range-select)
xnoremap <silent> <C-s> <Plug>(coc-range-select)

nnoremap <silent><expr> <leader>ld <SID>lists('d')
nnoremap <silent><expr> <leader>le <SID>lists('e')
nnoremap <silent><expr> <leader>lc <SID>lists('c')
nnoremap <silent><expr> <leader>lo <SID>lists('o')
nnoremap <silent><expr> <leader>lj <SID>lists('j')
nnoremap <silent><expr> <leader>lk <SID>lists('k')
nnoremap <silent><expr> <leader>lp <SID>lists('p')

function s:tab()
    if coc#pum#visible()
        return coc#pum#next(1)
    elseif s:check_backspace()
        return '\<Tab>'
    else
        return coc#refresh()
    endif
endfunction

function s:s_tab()
    if coc#pum#visible()
        return coc#pum#prev(1)
    else
        return '\<C-h>'
    endif
endfunction

function s:check_backspace()
    let col = col('.') - 1
    return !col || getline('.')[col - 1] =~# '\s'
endfunction

function s:hover()
    if CocAction('hasProvider', 'hover')
        call CocActionAsync('doHover')
    else
        call feedkeys('K', 'in')
    endif
endfunction

function s:scroll(direction)
    let delta = a:direction == 'fwd' ? v:true :
        \ a:direction == 'rev' ? v:false :
        \ v:null

    if (delta == v:null)
        return ''
    elseif !coc#float#has_scroll()
        let keys = mode() == 'v' ? ['\<Left>','\<Right>'] : ['\<C-b>','\<C-f>']
        return keys[delta]
    endif

    call coc#float_scroll(delta)
endfunction

function s:lists(key)
    let args = {
        \ 'd': [ 'CocList', 'diagnostics' ],
        \ 'e': [ 'CocList', 'extensions' ],
        \ 'c': [ 'CocList', 'commands' ],
        \ 'o': [ 'CocList', 'outline' ],
        \ 's': [ 'CocList', '-I', 'symbols' ],
        \ 'j': [ 'CocNext' ],
        \ 'k': [ 'CocPrev' ],
        \ 'p': [ 'CocListResume' ]
        \ }

    if (!has_key(args, key))
        echoerr('No list action available: ' . key)
        return
    endif

    execute '\<C-u>' . join(args[key], ' ') . '\<CR>'
endfunction
