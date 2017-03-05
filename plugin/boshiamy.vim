" I want this option be set because it's related to my 'cancel' feature
setlocal completeopt+=menuone


if !exists('g:boshiamy_toggle_english') || type(g:boshiamy_toggle_english) != type('')
    let g:boshiamy_toggle_english = ',,'
endif
execute 'inoremap <expr> '. g:boshiamy_toggle_english .' (pumvisible() ? "<C-Y>" : "") . boshiamy#toggle()'


if !exists('g:boshiamy_select_mode_style') || index(['menu', 'input', 'dialog'], g:boshiamy_select_mode_style) == -1
    let g:boshiamy_select_mode_style = 'menu'
endif
if g:boshiamy_select_mode_style == 'menu' && !exists('##CompleteDone')
    let g:boshiamy_select_mode_style = 'input'
endif


if !exists('g:boshiamy_select_mode') || type(g:boshiamy_select_mode) != type('')
    let g:boshiamy_select_mode = ',m'
endif
execute 'inoremap <expr> '. g:boshiamy_select_mode .' (pumvisible() ? "<C-Y>" : "") . "<C-R>=boshiamy#_show_mode_menu()<CR>"'


if !exists('g:boshiamy_cancel_input') || type(g:boshiamy_cancel_input) != type('')
    let g:boshiamy_cancel_input = '<C-h>'
endif
execute 'inoremap <expr> '. g:boshiamy_cancel_input .' pumvisible() ? "<C-E> " : "'. g:boshiamy_cancel_input .'"'


let s:cr_imap_save = maparg("<CR>", "i")
if empty(s:cr_imap_save)
    let s:cr_imap_save = "<CR>"
endif
execute 'inoremap <expr> <CR> pumvisible() ? "<C-Y>" : "' . s:cr_imap_save . '"'

let g:boshiamy_plugins = ['wide', 'runes', 'braille', 'emoji']
