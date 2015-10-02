" I want this option be set because it's related to my 'cancel' feature
set completeopt+=menuone

if !exists('g:boshiamy_toggle_key') || type(g:boshiamy_toggle_key) != type('')
    let g:boshiamy_toggle_key = ',,'
endif
execute 'inoremap <expr> '. g:boshiamy_toggle_key .' boshiamy#toggle()'

inoremap <space> <C-R>=boshiamy#send_key()<CR>

if !exists('g:boshiamy_leave_key') || type(g:boshiamy_leave_key) != type('')
    let g:boshiamy_leave_key = '<ESC><ESC>'
endif
execute 'nnoremap <expr> '. g:boshiamy_leave_key .' boshiamy#leave()'

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

if !exists('g:boshiamy_switch_braille') || type(g:boshiamy_switch_braille) != type('')
    let g:boshiamy_switch_braille = ',b,'
endif

if !exists('g:boshiamy_braille_keys') || type(g:boshiamy_braille_keys) != type('') || len(g:boshiamy_braille_keys) != 8
    let g:boshiamy_braille_keys = '7uj8ikm,'
endif
