command! -nargs=0 Format :call CocAction('format')
command! -nargs=? Fold :call CocAction('fold', <f-args>)
command! -nargs=0 OR :call CocAction('runCommad', 'editor.action.organizeImport')

autocmd CursorHold * silent call CocActionAsync('highlight')

augroup CocFormatting
    autocmd!
    autocmd FileType typescript,json setlocal formatexpr=CocAction('formatSelected')
    autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup END
