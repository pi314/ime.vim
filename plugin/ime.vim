" I want this option be set because it's related to my 'cancel' feature
setlocal completeopt+=menuone


if !exists('g:ime_toggle_english') || type(g:ime_toggle_english) != type('')
    let g:ime_toggle_english = ',,'
endif
execute 'inoremap <expr> '. g:ime_toggle_english .' (pumvisible() ? "<C-Y>" : "") . ime#toggle()'


if !exists('g:ime_select_mode_style') || index(['menu', 'input', 'dialog'], g:ime_select_mode_style) == -1
    let g:ime_select_mode_style = 'menu'
endif
if g:ime_select_mode_style == 'menu' && !exists('##CompleteDone')
    let g:ime_select_mode_style = 'input'
endif


if !exists('g:ime_select_mode') || type(g:ime_select_mode) != type('')
    let g:ime_select_mode = ',m'
endif
execute 'inoremap <expr> '. g:ime_select_mode .' (pumvisible() ? "<C-Y>" : "") . "<C-R>=ime#_show_mode_menu()<CR>"'


if !exists('g:ime_cancel_input') || type(g:ime_cancel_input) != type('')
    let g:ime_cancel_input = '<C-h>'
endif
execute 'inoremap <expr> '. g:ime_cancel_input .' pumvisible() ? "<C-E> " : "'. g:ime_cancel_input .'"'


let s:cr_imap_save = maparg("<CR>", "i")
if empty(s:cr_imap_save)
    let s:cr_imap_save = "<CR>"
endif
execute 'inoremap <expr> <CR> pumvisible() ? "<C-Y>" : "' . s:cr_imap_save . '"'

if !exists('g:ime_plugins') || type(g:ime_plugins) != type([])
    let g:ime_plugins = ['builtin-boshiamy', 'builtin-kana', 'builtin-chewing', 'builtin-unicode']
endif
