let g:coc_global_extension = [
    \ 'coc-docker',
    \ 'coc-emmet',
    \ 'coc-eslint',
    \ 'coc-git',
    \ 'coc-highlight',
    \ 'coc-html',
    \ 'coc-json',
    \ 'coc-ltex',
    \ 'coc-markdownlint',
    \ 'coc-marketplace',
    \ '@yaegassy/coc-nginx',
    \ 'coc-snippets',
    \ 'coc-pairs',
    \ 'coc-powershell',
    \ 'coc-prettier',
    \ 'coc-sh',
    \ 'coc-spell-checker',
    \ 'coc-sql',
    \ 'coc-texlab',
    \ 'coc-tsserver',
    \ 'coc-vimlsp',
    \ 'coc-yaml',
    \ 'coc-yank',
    \ ]

let g:coc_disable_startup_warning = v:true
let g:coc_filetype_map = {
    \ 'tex': 'latex',
    \ }

if has_key(plugs, 'vim-airline')
    let g:airline#extensions#coc#enabled = v:true
    let g:airline#extensions#coc#show_coc_status = v:true
    let g:airline#extensions#coc#error_symbol = ''
    let g:airline#extensions#coc#warning_symbol = ''
    " let g:airline#extensions#coc#stl_format_err = '%C(L%L)'
    " let g:airline#extensions#coc#stl_format_warn = '%C(L%L)'
else
    set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}
endif
