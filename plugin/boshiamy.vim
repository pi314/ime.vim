" I want this option be set because it's related to my 'cancel' feature
set completeopt+=menuone

if !exists('g:boshiamy_cancel_key') || type(g:boshiamy_cancel_key) != type('')
    let g:boshiamy_cancel_key = '<C-h>'
endif
execute 'inoremap <expr> '. g:boshiamy_cancel_key .' pumvisible() ? "<C-e> " : "'. g:boshiamy_cancel_key .'"'

if !exists('g:boshiamy_switch_boshiamy') || type(g:boshiamy_switch_boshiamy) != type('')
    let g:boshiamy_switch_boshiamy = ',t,'
endif

if !exists('g:boshiamy_switch_kana') || type(g:boshiamy_switch_kana) != type('')
    let g:boshiamy_switch_kana = ',j,'
endif

if !exists('g:boshiamy_switch_wide') || type(g:boshiamy_switch_wide) != type('')
    let g:boshiamy_switch_wide = ',w,'
endif

if !exists('g:boshiamy_switch_rune') || type(g:boshiamy_switch_rune) != type('')
    let g:boshiamy_switch_rune = ',r,'
endif
