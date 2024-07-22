nnoremap <leader>lt :call s:LoadTemplate()

function s:GetRootDirectory()
    let p = '$XDG_CONFIG_HOME'
    if expand(p) == p
        if has('win32')
            p = '$LOCALAPPDATA'
        else
            p = '~/.config'
        endif
    endif
    return expand(p . '/' . 'templates')
endfunction

function s:GetTemplatePath(filetype, extension)
    for p in [filetype, extension]
        if !empty(glob(p))
            return p
        endif
    endfor
    return v:null
endfunction

function s:LoadTemplate()
    let root = s:GetRootDirectory() . '/templates'
    silent! call mkdir(root, 'p')

    let t = s:GetTemplatePath(root . '/' . &ft, root . '/' . expand('%:e'))
    if t == v:null
        echoerr('No template for ' . expand('%:e') . '/' . &ft)
        return
    endif

    execute 'silent 0r ' . t
endfunction
