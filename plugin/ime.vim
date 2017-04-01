" I want this option be set because it's related to my 'cancel' feature
setlocal completeopt+=menuone


if !exists('g:ime_toggle_english') || type(g:ime_toggle_english) != type('')
    let g:ime_toggle_english = ',,'
endif
execute 'inoremap <expr> '. g:ime_toggle_english .' (pumvisible() ? "<C-Y>" : "") . ime#toggle()'


if !exists('g:ime_select_mode') || type(g:ime_select_mode) != type('')
    let g:ime_select_mode = ',m'
endif


if !exists('g:ime_select_mode_style') || type(g:ime_select_mode_style) != type('')
    let g:ime_select_mode_style = 'menu'
endif
if g:ime_select_mode_style == 'menu' && (!exists('##CompleteDone') || !exists('v:completed_item'))
    let g:ime_select_mode_style = 'fallback'
endif


if g:ime_select_mode_style == 'menu'
    execute 'inoremap <expr> '. g:ime_select_mode .' (pumvisible() ? "<C-Y>" : "") . "<C-R>=ime#_comp_mode_menu()<CR>"'
else
    execute 'inoremap '. g:ime_select_mode .' <C-\><C-o>:call ime#_fallback_mode_menu()<CR>'
endif


if !exists('g:ime_cancel_input') || type(g:ime_cancel_input) != type('')
    let g:ime_cancel_input = '<C-h>'
endif
execute 'inoremap <expr> '. g:ime_cancel_input .' pumvisible() ? "<C-E> " : "'. g:ime_cancel_input .'"'


let s:cr_imap_save = maparg("<CR>", "i")
if empty(s:cr_imap_save)
    let s:cr_imap_save = "<CR>"
endif
function s:SendCr ()
    if pumvisible()
        return "\<C-Y>"
    endif
    return s:cr_imap_save
endfunction
execute 'inoremap <expr> <CR> <SID>SendCr()'

if !exists('g:ime_plugins') || type(g:ime_plugins) != type([])
    let g:ime_plugins = ['builtin-boshiamy', 'builtin-kana', 'builtin-chewing', 'builtin-unicode']
endif
