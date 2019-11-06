" vim:fdm=marker
" ============================================================================
" File:        ime.vim
" Description: A input method engine plugin for vim
" Maintainer:  Pi314 <michael66230@gmail.com>
" License:     This program is free software. It comes without any warranty,
"              to the extent permitted by applicable law. You can redistribute
"              it and/or modify it under the terms of the Do What The Fuck You
"              Want To Public License, Version 2, as published by Sam Hocevar.
"              See http://sam.zoy.org/wtfpl/COPYING for more details.
" ============================================================================
let s:true = exists('v:true') ? v:true : 1
let s:false = exists('v:false') ? v:false : 0


" Plugin struct
" {
"   'name': <name>
"   'type': 'standalone' / 'embedded'
"   'icon': <icon>
"   'description': <description>
"   'pattern': <pattern>
"   'handler': <handler-function-reference>
"   'trigger': [<trigger>]
"   'choice': [<choice>]
" }


" Load plugins
let s:standalone_plugin_list = []
let s:embedded_plugin_list = []
let s:ime_english_enable = s:true
let s:ime_mode = {}
let s:ime_mode_2nd = {}


function! s:EscapeKey (key) " {{{
    if a:key == '|'
        return '<bar>'
    elseif a:key == ' '
        return '<space>'
    elseif a:key == '\'
        return '<bslash>'
    elseif a:key == '<'
        return '<lt>'
    endif
    return a:key
endfunction " }}}


function! s:SelectMode (new_mode) " {{{
    if has_key(s:ime_mode, 'trigger')
        for l:key in s:ime_mode['trigger']
            if l:key == ''
                continue
            endif
            try
                execute 'iunmap '. s:EscapeKey(l:key)
            catch
            endtry
        endfor
    endif

    if s:ime_english_enable == s:false && has_key(s:ime_mode, 'menu_cb')
        call s:ime_mode['menu_cb']('')
    endif

    if type(a:new_mode) == type('ENGLISH') && a:new_mode == 'ENGLISH'
        let s:ime_english_enable = s:true
    elseif type(a:new_mode) == type({}) && a:new_mode == {}
        let s:ime_english_enable = s:true
    elseif type(a:new_mode) == type({})
        if s:ime_mode_2nd == {} && s:ime_mode != a:new_mode
            let s:ime_mode_2nd = s:ime_mode
        elseif s:ime_mode_2nd == a:new_mode
            let s:ime_mode_2nd = s:ime_mode
        endif

        let s:ime_mode = a:new_mode
        let s:ime_english_enable = s:false
    endif

    if s:ime_english_enable == s:false
        for l:key in s:ime_mode['trigger']
            try
                " Compose this command (so complex):
                " inoremap trigger (SendKey('trigger'))
                let l:escaped_key = s:EscapeKey(l:key)
                let l:cmd = 'inoremap '
                let l:cmd .= l:escaped_key .' '
                let l:cmd .= '<C-R>=<SID>SendKey('''
                let l:cmd .= (l:escaped_key == "'" ? "''" : l:escaped_key)
                let l:cmd .= ''')<CR>'
                execute l:cmd
            catch
                call ime#log('core', '>> '. v:exception)
            endtry
        endfor
    endif

    redrawstatus!
    redraw!
endfunction " }}}


function! s:CompSelectMode () " {{{
    augroup ime
        autocmd! ime CompleteDone
        for l:plugin in s:standalone_plugin_list
            if v:completed_item['menu'] == l:plugin['menu']
                call s:SelectMode(l:plugin)
            endif
        endfor
    augroup end
endfunction " }}}


function! s:ExecutePlugin (line, plugin, trigger) " {{{
    if index(a:plugin['trigger'], a:trigger) == -1
        return s:false
    endif

    let l:matchobj = matchlist(a:line, a:plugin['pattern'])
    if len(l:matchobj) == 0
        return s:false
    endif

    try
        let l:len = strlen(l:matchobj[0])
        let l:options = []
        let l:ret = a:plugin['handler'](l:matchobj, a:trigger)
        if type(l:ret) == type({})
            try
                let l:len = l:ret['len']
                let l:options = l:ret['options']
            catch
                call ime#log('core', '['. a:plugin['name'] .']', '// invalid return value:', string(l:ret))
                call ime#log('core', '['. a:plugin['name'] .']', '\\ return value should contain ''len'' and ''options''')
                return s:false
            endtry
        elseif type(l:ret) == type([])
            let l:options = l:ret
        else
            call ime#log('core', '['. a:plugin['name'] .']', '// invalid return value:', string(l:ret))
            call ime#log('core', '['. a:plugin['name'] .']', '\\ return type should be {} or []')
            return s:false
        endif

        if l:options == []
            return s:false
        endif

        " choice {{{
        if has_key(a:plugin, 'choice') && exists('##CompleteDone') && exists('v:completed_item')
            let s:option_cache = {'options': {}}
            let l:i = 0
            let l:choices = copy(a:plugin['choice'])
            while l:i < len(l:options) && len(l:choices)
                if type(l:options[(l:i)]) == type('')
                    let l:options[(l:i)] = {'word': l:options[(l:i)]}
                endif

                let l:opt = l:options[(l:i)]

                if !has_key(s:option_cache['options'], l:opt['word'])
                    let l:opt['menu'] = l:choices[0]
                    let s:option_cache['options'][(l:opt['word'])] = l:options[(l:i)]
                    try
                        " Compose this command (so complex):
                        " inoremap choice (choose_option(choice))
                        let l:escaped_key = s:EscapeKey(l:choices[0])
                        let l:cmd = 'inoremap '
                        let l:cmd .= l:escaped_key .' '
                        let l:cmd .= '<C-R>=<SID>choose_option('''
                        let l:cmd .= (l:escaped_key == "'" ? "''" : l:escaped_key)
                        let l:cmd .= ''')<CR>'
                        execute l:cmd
                    catch
                        call ime#log('core', '>> '. v:exception)
                    endtry
                    call remove(l:choices, 0)
                endif

                let l:i = l:i + 1
            endwhile

            augroup ime
                autocmd! ime CompleteDone
                autocmd ime CompleteDone * call s:clear_option_cache()
            augroup end

            let s:option_cache['col'] = col('.') - l:len
        endif " }}}

        call complete(col('.') - l:len, l:options)
        return s:true
    catch
        call ime#log('core', '['. a:plugin['name'] .']', '// '. v:throwpoint)
        call ime#log('core', '['. a:plugin['name'] .']', '\\ '. v:exception)
    endtry
    return s:false
endfunction " }}}


function! s:choose_option (key) " {{{
    for l:key in keys(get(s:option_cache, 'options', {}))
        let l:option = s:option_cache['options'][(l:key)]
        if has_key(l:option, 'menu') && l:option['menu'] == a:key
            call ime#log('core', l:option)
            unlet l:option['menu']
            call complete(s:option_cache['col'], [(l:option)])
        endif
    endfor

    let s:option_cache = {}
    call s:clear_option_cache()
    return ''
endfunction " }}}


function! s:clear_option_cache () " {{{
    " User use 'choose' key: s:choose_option() -> s:clear_option_cache()
    " User cancel completion: CompleteDone -> s:clear_option_cache()

    if len(s:option_cache)
        return
    endif

    for l:key in get(s:ime_mode, 'choice', [])
        if l:key == ''
            continue
        endif
        try
            execute 'iunmap '. s:EscapeKey(l:key)
        catch
        endtry
    endfor

    augroup ime
        autocmd! ime CompleteDone
    augroup end
endfunction " }}}


function! s:SendKey (trigger) " {{{
    if s:ime_english_enable
        if !empty(maparg(s:EscapeKey(a:trigger), 'i'))
            execute "iunmap ". s:EscapeKey(a:trigger)
        endif
        return a:trigger
    endif

    let l:line = strpart(getline('.'), 0, (col('.') - 1))

    " search for embedded plugins first
    for l:plugin in s:embedded_plugin_list
        let l:result = s:ExecutePlugin(l:line, l:plugin, a:trigger)
        if l:result == s:true
            return ''
        endif
    endfor

    let l:result = s:ExecutePlugin(l:line, s:ime_mode, a:trigger)
    return l:result == s:true ? '' : (a:trigger == '<space>' ? ' ' : a:trigger)
endfunction " }}}


function! s:interactive_menu (prompt, menu_render, cursor, menu_handler) " {{{
    try
        let l:more = &more
        let l:showmode = &showmode
        set nomore
        set noshowmode

        let l:menu = a:menu_render()
        let l:cursor = a:cursor
        while s:true
            if type(l:menu) != type([])
                break
            endif

            redraw!
            echo a:prompt
            for l:index in range(len(l:menu))
                echo ((l:index == l:cursor) ? '> ' : '  '). l:menu[(l:index)]['menu']
            endfor

            let l:key = getchar()
            if type(l:key) == type(0)
                let l:key = nr2char(l:key)
            endif
            if l:key == 'j' || l:key == "\<Down>" || l:key == "\<C-n>"
                let l:cursor = (l:cursor + 1) % len(l:menu)
            elseif l:key == 'k' || l:key == "\<Up>" || l:key == "\<C-p>"
                let l:cursor = (l:cursor + len(l:menu) - 1) % len(l:menu)
            elseif l:key == 'q'
                break
            elseif l:key == "\<Esc>"
                call feedkeys("\<Esc>")
                break
            else
                let l:action = a:menu_handler(l:menu, l:cursor, l:key)
                if l:action == 'return'
                    break
                elseif l:action == 'menu'
                    let l:menu = a:menu_render()
                    let l:cursor = l:cursor % len(l:menu)
                endif
            endif
        endwhile
    catch /^Vim:Interrupt$/
    catch
        call ime#log('core', '// '. v:throwpoint)
        call ime#log('core', '\\ '. v:exception)
    finally
        let &more = l:more
        let &showmode = l:showmode
        redraw!
    endtry
endfunction " }}}


function! s:per_mode_menu_render () " {{{
    let l:menu = s:ime_mode['menu_cb']()

    if type(l:menu) != type([])
        return l:menu
    endif

    let l:ret = []
    for l:index in range(len(l:menu))
        let l:menu[(l:index)]['menu'] = '('. l:menu[(l:index)]['key'] .') '. l:menu[(l:index)]['menu']
    endfor
    return l:menu
endfunction " }}}


function! s:per_mode_menu_handler (menu, cursor, key) " {{{
    if a:key == "\<CR>" || a:key == ' '
        call s:ime_mode['menu_cb'](a:menu[(a:cursor)]['key'])
        if a:key == "\<CR>"
            return 'return'
        endif

        if a:key == ' '
            return 'menu'
        endif
    endif

    for l:index in range(len(a:menu))
        if a:key == a:menu[(l:index)]['key']
            call s:ime_mode['menu_cb'](a:key)
            return 'menu'
        endif
    endfor

    return 'return'
endfunction " }}}


function! s:interactive_mode_select_menu_render () " {{{
    return s:standalone_plugin_list
endfunction " }}}


function! s:interactive_mode_select_menu_handler (menu, cursor, key) " {{{
    call s:SelectMode(s:standalone_plugin_list[(a:cursor)])
endfunction " }}}


function! s:mode_menu_window_confirm () " {{{
    let l:line = getline('.')

    for l:plugin in s:standalone_plugin_list
        if (' '. l:plugin['icon'] .' - '. l:plugin['description'] == l:line)
            call s:SelectMode(l:plugin)
        endif
    endfor

    return ''
endfunction " }}}


" =============================================================================
" Internal API
" =============================================================================
function! ime#load_plugins () " {{{
    for l:pname in g:ime_plugins
        if match(l:pname, '\v^\w+$') == -1
            call ime#log('core', 'invalid plugin name "'. l:pname . '"')
            continue
        endif

        try
            let l:plugin_info = function('ime#'. l:pname .'#info')()
        catch
            try
                let l:plugin_info = function('ime_'. l:pname .'#info')()
            catch
                call ime#log('core', '// '. v:throwpoint)
                call ime#log('core', '\\ '. v:exception)
                continue
            endtry
        endtry

        let l:invalid = s:false

        " sanity check
        if !has_key(l:plugin_info, 'type')
            call ime#log('core', 'plugin "'. l:pname . '" lacks "type" information')
            let l:invalid = s:true
        endif

        if l:plugin_info['type'] == 'standalone' &&
                \ (!has_key(l:plugin_info, 'icon') ||
                \ !has_key(l:plugin_info, 'description'))
            call ime#log('core', 'plugin "'. l:pname . '" lacks "icon" or "description" information')
            let l:invalid = s:true
        endif

        if !has_key(l:plugin_info, 'pattern')
            call ime#log('core', 'plugin "'. l:pname . '" lacks "pattern" information')
            let l:invalid = s:true
        endif

        if !has_key(l:plugin_info, 'handler')
            call ime#log('core', 'plugin "'. l:pname . '" lacks "handler" information')
            let l:invalid = s:true
        endif

        if !has_key(l:plugin_info, 'trigger')
            call ime#log('core', 'plugin "'. l:pname . '" lacks "trigger" information')
            let l:invalid = s:true
        endif

        if has_key(l:plugin_info, 'switch')
            call ime#log('core', 'plugin "'. l:pname . '" has deprecated information "switch"')
            let l:invalid = s:true
        endif

        if has_key(l:plugin_info, 'submode')
            call ime#log('core', 'plugin "'. l:pname . '" has deprecated information "submode"')
            let l:invalid = s:true
        endif

        if l:invalid != s:false
            continue
        endif

        let l:plugin_info['name'] = l:pname

        if l:plugin_info['type'] == 'standalone'
            call add(s:standalone_plugin_list, l:plugin_info)
        elseif l:plugin_info['type'] == 'embedded'
            call add(s:embedded_plugin_list, l:plugin_info)
        endif

        if has_key(l:plugin_info, 'menu')
            " have to rename 'menu' or it will be overridden
            " cb stands for callback
            let l:plugin_info['menu_cb'] = l:plugin_info['menu']
        endif
    endfor

    for l:plugin in s:standalone_plugin_list
        let l:plugin['menu'] = l:plugin['icon'] .' - '. l:plugin['description']
        let l:plugin['word'] = ''
        let l:plugin['dup'] = s:true
        let l:plugin['empty'] = s:true
    endfor

    if len(s:standalone_plugin_list) == 0
        let s:ime_mode = {}
    else
        let s:ime_mode = s:standalone_plugin_list[0]
    endif
endfunction " }}}


function! ime#toggle_english () " {{{
    if s:standalone_plugin_list == []
        call ime#load_plugins()
    endif

    if s:ime_english_enable == s:true
        call s:SelectMode(s:ime_mode)
    else
        call s:SelectMode('ENGLISH')
    endif
    return ''
endfunction " }}}


function! ime#switch_2nd () " {{{
    if s:ime_mode_2nd == {}
        return ''
    endif

    call s:SelectMode(s:ime_mode_2nd)
    return ''
endfunction " }}}


function! ime#plugin_menu (...) " {{{
    if a:0 == 0
        if s:ime_english_enable || !has_key(s:ime_mode, 'menu_cb')
            call feedkeys(g:ime_menu, 'n')
            return
        endif

        call s:interactive_menu(
                \ 'Select menu: (j/Down/<C-n>) (k/Up/<C-p>) (enter/space) (q/esc)',
                \ function('s:per_mode_menu_render'),
                \ 0,
                \ function('s:per_mode_menu_handler'),
                \ )
        return
    endif

    if a:0 == 2
        let l:pname = substitute(a:1, '-', '_', 'g')
        if l:pname != ime#mode()
            call ime#log('core', '// ime#plugin_menu('. l:pname .'): forbidden')
            call ime#log('core', '\\ current activated plugin: "'. ime#mode() .'"')
            return
        endif

        if !has_key(s:ime_mode, 'menu_cb')
            call ime#log('core', '// ime#plugin_menu(): plugin "'. s:ime_mode['name'] .'" have no menu')
            return
        endif

        call s:ime_mode['menu_cb'](a:2)
        return
    endif

    call ime#log('core', 'ime#plugin_menu(): wrong argument')
endfunction " }}}


function! ime#_mode_menu_popup () " {{{
    if s:standalone_plugin_list == []
        call ime#load_plugins()
    endif

    if s:ime_mode == {}
        call ime#log('core', 'No input mode installed.')
        return ''
    endif

    augroup ime
        autocmd! ime CompleteDone
        autocmd ime CompleteDone * call s:CompSelectMode()
    augroup end
    call complete(col('.'), s:standalone_plugin_list)
    return ''
endfunction " }}}


function! ime#_mode_menu_interactive () " {{{
    if s:standalone_plugin_list == []
        call ime#load_plugins()
    endif

    let l:cursor = index(s:standalone_plugin_list, s:ime_mode)
    call s:interactive_menu(
            \ 'Select input mode: (j/Down/<C-n>) (k/Up/<C-p>) (enter) (q/esc)',
            \ function('s:interactive_mode_select_menu_render'),
            \ l:cursor,
            \ function('s:interactive_mode_select_menu_handler'),
            \ )
    return
endfunction " }}}


function! ime#_mode_menu_window () " {{{
    if s:standalone_plugin_list == []
        call ime#load_plugins()
    endif

    exec len(s:standalone_plugin_list) .'new'
    setlocal buftype=nofile
    setlocal nonu
    setlocal nowrap
    setlocal colorcolumn=
    setlocal cursorline

    inoremap <buffer> k <Up>
    inoremap <buffer> j <Down>
    inoremap <buffer> q <C-o>i
    inoremap <buffer> <C-c> <Esc>
    inoremap <buffer> <CR> <C-r>=<SID>mode_menu_window_confirm()<CR><C-o>i
    nnoremap <buffer> <CR> :call <SID>mode_menu_window_confirm()<CR>

    let &l:statusline = 'Select input mode: (j/Down) (k/Up) (enter) (q//esc/C-c)'

    for l:idx in range(len(s:standalone_plugin_list))
        let l:plugin = s:standalone_plugin_list[(l:idx)]
        call setline(l:idx + 1, ' '. l:plugin['icon'] .' - '. l:plugin['description'])
    endfor

    let l:idx = index(s:standalone_plugin_list, s:ime_mode)
    call cursor(l:idx + 1, 1)

    setlocal nomodifiable
    autocmd BufLeave <buffer> quit
    autocmd InsertLeave <buffer> quit
endfunction " }}}


function! ime#boshiamy_export_cin_file () " {{{
    let l:boshiamy_table = ime#boshiamy_table#table()
    let l:chewing_table = ime#chewing_table#table()

    tabedit
    call setline('$', '%gen_inp')
    call append('$', '%ename liu57')
    call append('$', '%cname 嘸蝦米')
    call append('$', '%encoding UTF-8')
    call append('$', '%selkey !@#$%^&*(')
    call append('$', '%keyname begin')
    let l:keyname = split("abcdefghijklmnopqrstuvwxyz,.'[];1234567890-=/", '\zs')
    let l:keylook = split("ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ，．'〔〔；１２３４５６７８９０-＝／", '\zs')
    for l:idx in range(len(l:keyname))
        call append('$', l:keyname[(l:idx)] .' '. l:keylook[(l:idx)])
    endfor
    call append('$', '%keyname end')
    call append('$', '%chardef begin')

    let l:kana_tables = ime#kana_table#table()
    let l:small_kana = split('ぁぇぃゕゖぉっぅゎゃょゅァェィヵヶォッゥヮャョュ', '\zs')
    for l:tuple in [[l:kana_tables[0], ','], [l:kana_tables[1], '.']]
        let l:kana_table = l:tuple[0]
        let l:postfix = l:tuple[1]
        for l:key in sort(keys(l:kana_table))
            if l:key == '''' || l:key == '.'
                continue
            endif
            for l:char in l:kana_table[(l:key)]
                let l:is_small = (index(l:small_kana, l:char) >= 0)
                if l:key == 'nn'
                    call append('$', 'n'. l:postfix .' '. l:char)
                endif
                if l:is_small
                    call append('$', l:key . l:postfix .'v '. l:char)
                endif
                call append('$', l:key . l:postfix .' '. l:char)
            endfor
        endfor
    endfor

    for l:key in sort(keys(l:boshiamy_table))
        for l:char in l:boshiamy_table[l:key]
            call append('$', l:key .' '. l:char)
        endfor
    endfor

    for l:key in sort(keys(l:chewing_table))
        for l:char in l:chewing_table[l:key]
            call append('$', l:key .' '. l:char)
        endfor
    endfor

    call append('$', '%chardef end')
endfunction " }}}


" =============================================================================
" Public API
" =============================================================================
function! ime#mode () " {{{
    if s:ime_english_enable == s:true
        return 'english'
    endif

    return get(s:ime_mode, 'name', '')
endfunction " }}}


function! ime#log (tag, ...) " {{{
    redraw
    let l:arguments = copy(a:000)
    call map(l:arguments, 'type(v:val) == type("") ? (v:val) : string(v:val)')
    let l:log_msg = join(l:arguments, ' ')
    echom substitute('[ime]['. a:tag .'] '. l:log_msg, '] [', '][', '')
endfunction " }}}


function! ime#icon (...) " {{{
    if a:0 == 0
        if s:ime_english_enable == s:true
            return '[En]'
        endif

        let l:ret = get(s:ime_mode, 'icon', '[？]')
        if g:ime_show_2nd_mode
            let l:ret .= get(s:ime_mode_2nd, 'icon', '')
        endif
        return l:ret
    endif

    if a:0 == 2
        " ime#icon(pname, icon)
        let l:pname = substitute(a:1, '-', '_', 'g')
        if l:pname != ime#mode()
            call ime#log('core', '// ime#icon('. l:pname .'): forbidden')
            call ime#log('core', '\\ current activated plugin: "'. ime#mode() .'"')
            return
        endif

        let s:ime_mode['icon'] = a:2
        let s:ime_mode['menu'] = s:ime_mode['icon'] .' - '. s:ime_mode['description']

        redrawstatus!
        return
    endif

    call ime#log('core', 'ime#icon(): wrong argument')
endfunction " }}}


function! ime#plugins () " {{{
    return {
    \ 'standalone': map(copy(s:standalone_plugin_list), 'v:val[''name'']'),
    \ 'embedded': map(copy(s:embedded_plugin_list), 'v:val[''name'']'),
    \ }
endfunction " }}}
