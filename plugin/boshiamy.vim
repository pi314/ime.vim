" I want this option be set because it's related to my 'cancel' feature
setlocal completeopt+=menuone


if !exists('g:boshiamy_toggle_key') || type(g:boshiamy_toggle_key) != type('')
    let g:boshiamy_toggle_key = ',,'
endif
execute 'inoremap <expr> '. g:boshiamy_toggle_key .' (pumvisible() ? "<C-Y>" : "") . boshiamy#toggle()'


if !exists('g:boshiamy_select_key') || type(g:boshiamy_select_key) != type('')
    let g:boshiamy_select_key = ',m'
endif
execute 'inoremap <expr> '. g:boshiamy_select_key .' (pumvisible() ? "<C-Y>" : "") . "<C-R>=boshiamy#show_mode_menu()<CR>"'


if !exists('g:boshiamy_cancel_key') || type(g:boshiamy_cancel_key) != type('')
    let g:boshiamy_cancel_key = '<C-h>'
endif
execute 'inoremap <expr> '. g:boshiamy_cancel_key .' pumvisible() ? "<C-E> " : "'. g:boshiamy_cancel_key .'"'


let s:cr_imap_save = maparg("<CR>", "i")
if empty(s:cr_imap_save)
    let s:cr_imap_save = "<CR>"
endif
execute 'inoremap <expr> <CR> pumvisible() ? "<C-Y>" : "' . s:cr_imap_save . '"'


if !exists('g:boshiamy_braille_keys') || type(g:boshiamy_braille_keys) != type('') || len(g:boshiamy_braille_keys) != 8
    let g:boshiamy_braille_keys = '7uj8ikm,'
endif
