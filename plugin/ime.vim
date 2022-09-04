let s:true = exists('v:true') ? v:true : 1
let s:false = exists('v:false') ? v:false : 0


" I want this option be set because it's related to my 'cancel' feature
setlocal completeopt+=menuone


if !exists('g:ime_toggle_english') || type(g:ime_toggle_english) != type('')
    let g:ime_toggle_english = ',,'
endif
if g:ime_toggle_english != ''
    execute 'inoremap <expr> '. g:ime_toggle_english .' (pumvisible() ? "<C-Y>" : "") . ime#toggle_english()'
endif


let g:ime_show_2nd_mode = s:true
if !exists('g:ime_switch_2nd') || type(g:ime_switch_2nd) != type('')
    let g:ime_switch_2nd = ',.'
endif
if g:ime_switch_2nd != ''
    execute 'inoremap <expr> '. g:ime_switch_2nd .' (pumvisible() ? "<C-Y>" : "") . ime#switch_2nd()'
endif


if !exists('g:ime_select_mode') || type(g:ime_select_mode) != type('')
    let g:ime_select_mode = ',m'
endif


function! s:ime_mode_menu ()
    if !exists('g:ime_select_mode_style')
        let g:ime_select_mode_style = 'window'
    endif

    if g:ime_select_mode_style == 'popup' && exists('##CompleteDone') && exists('v:completed_item')
        return (pumvisible() ? "\<C-Y>" : "") . "\<C-R>=ime#_mode_menu_popup()\<CR>"
    elseif g:ime_select_mode_style == 'interactive'
        return "\<C-\>\<C-o>:call ime#_mode_menu_interactive()\<CR>"
    else
        return "\<C-\>\<C-o>:call ime#_mode_menu_window()\<CR>"
    endif
endfunction
if g:ime_select_mode != ''
    execute 'inoremap <expr> '. g:ime_select_mode .' <SID>ime_mode_menu()'
endif


if !exists('g:ime_cancel_input') || type(g:ime_cancel_input) != type('')
    let g:ime_cancel_input = '<C-h>'
endif
if g:ime_cancel_input != ''
    execute 'inoremap <expr> '. g:ime_cancel_input .' pumvisible() ? "<C-E> " : "'. g:ime_cancel_input .'"'
endif


let s:cr_imap_save = maparg("<CR>", "i")
if empty(s:cr_imap_save)
    let s:cr_imap_save = "<CR>"
endif

execute "inoremap <Plug>IME_OriginCR ". s:cr_imap_save
imap <expr> <Plug>IME_DispatchCR (pumvisible() ? "\<C-Y>" : "\<Plug>IME_OriginCR")
imap <CR> <Plug>IME_DispatchCR

if !exists('g:ime_plugins') || type(g:ime_plugins) != type([])
    let g:ime_plugins = ['builtin_boshiamy', 'builtin_kana', 'builtin_chewing', 'builtin_unicode']
endif


if !exists('g:ime_menu') || type(g:ime_menu) != type('')
    let g:ime_menu = ';;'
endif
if g:ime_menu != ''
    execute 'inoremap '. g:ime_menu .' <C-\><C-o>:call ime#plugin_menu()<CR>'
endif


command! IMEExportBoshiamyCIN :call ime#boshiamy_export_cin_file()
