let s:pref = 'ayu'
let s:fb = 'slate'

try
    set termguicolors
    execute 'colorscheme ' . s:pref
catch /^Vim\%((\a\+)\)\=:E185/
    echomsg('Failed to set colorscheme: ' . s:pref)
    echomsg('Setting fallback colorscheme: ' . s:fb)

    set notermguicolors
    execute 'colorscrhem ' . s:fb
endtry
