let s:true = exists('v:true') ? v:true : 1
let s:false = exists('v:false') ? v:false : 0


" I want this option be set because it's related to my 'cancel' feature
setlocal completeopt+=menuone


if !exists('g:ime_toggle_english') || type(g:ime_toggle_english) != type('')
    let g:ime_toggle_english = ',,'
endif
execute 'inoremap <expr> '. g:ime_toggle_english .' (pumvisible() ? "<C-Y>" : "") . ime#toggle_english()'


let g:ime_show_2nd_mode = s:true
if !exists('g:ime_switch_2nd') || type(g:ime_switch_2nd) != type('')
    let g:ime_switch_2nd = ',.'
endif
execute 'inoremap <expr> '. g:ime_switch_2nd .' (pumvisible() ? "<C-Y>" : "") . ime#switch_2nd()'


if !exists('g:ime_select_mode') || type(g:ime_select_mode) != type('')
    let g:ime_select_mode = ',m'
endif


function! s:ime_mode_menu ()
    if g:ime_select_mode_style == 'popup' && exists('##CompleteDone') && exists('v:completed_item')
        return (pumvisible() ? "\<C-Y>" : "") . "\<C-R>=ime#_popup_mode_menu()\<CR>"
    else
        return "\<C-\>\<C-o>:call ime#_interactive_mode_menu()\<CR>"
    endif
endfunction
execute 'inoremap <expr> '. g:ime_select_mode .' <SID>ime_mode_menu()'


if !exists('g:ime_cancel_input') || type(g:ime_cancel_input) != type('')
    let g:ime_cancel_input = '<C-h>'
endif
execute 'inoremap <expr> '. g:ime_cancel_input .' pumvisible() ? "<C-E> " : "'. g:ime_cancel_input .'"'


let s:cr_imap_save = maparg("<CR>", "i")
if empty(s:cr_imap_save)
    let s:cr_imap_save = "<CR>"
endif

execute "inoremap <Plug>IME_OriginCR ". s:cr_imap_save
imap <expr> <Plug>IME_DispatchCR (pumvisible() ? "\<C-Y>" : "\<Plug>IME_OriginCR")
imap <CR> <Plug>IME_DispatchCR

if !exists('g:ime_plugins') || type(g:ime_plugins) != type([])
    let g:ime_plugins = ['builtin-boshiamy', 'builtin-kana', 'builtin-chewing', 'builtin-unicode']
endif


if !exists('g:ime_menu') || type(g:ime_menu) != ''
    let g:ime_menu = ';;'
endif
execute 'inoremap '. g:ime_menu .' <C-\><C-o>:call ime#menu()<CR>'


command! IMEExportBoshiamyCIN :call ime#boshiamy_export_cin_file()
