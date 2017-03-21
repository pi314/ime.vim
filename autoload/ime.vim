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

function! ime#log (tag, msg)
    redraw
    if type(a:msg) == type('')
        let l:log_msg = a:msg
    else
        let l:log_msg = string(a:msg)
    endif
    echom substitute('[ime]['. a:tag .'] '. l:log_msg, '] [', '][', '')
endfunction


" Plugin struct
" {
"   'name': <name>
"   'type': 'standalone' / 'embedded'
"   'icon': <icon>
"   'description': <description>
"   'pattern': <pattern>
"   'handler': <handler-function-reference>
" }


" Load plugins
let s:standalone_plugin_list = []
let s:embedded_plugin_list = []
function! s:LoadPlugins () " {{{
    for l:plugin in g:ime_plugins
        let l:plugin = substitute(l:plugin, '-', '_', 'g')
        try
            let l:plugin_info = function('ime_'. l:plugin .'#info')()
        catch
            try
                let l:plugin_info = function('ime#'. l:plugin .'#info')()
            catch
                call ime#log('core', v:exception)
                continue
            endtry
        endtry

        " sanity check
        if !has_key(l:plugin_info, 'type')
            call ime#log('core', 'plugin "'. l:plugin . '" lacks "type" information')
            continue
        endif

        if l:plugin_info['type'] == 'standalone' &&
                \ (!has_key(l:plugin_info, 'icon') ||
                \ !has_key(l:plugin_info, 'description'))
            call ime#log('core', 'plugin "'. l:plugin . '" lacks "icon" or "description" information')
            continue
        endif

        if !has_key(l:plugin_info, 'pattern')
            call ime#log('core', 'plugin "'. l:plugin . '" lacks "pattern" information')
            continue
        endif

        if !has_key(l:plugin_info, 'handler')
            call ime#log('core', 'plugin "'. l:plugin . '" lacks "handler" information')
            continue
        endif

        if !has_key(l:plugin_info, 'trigger')
            call ime#log('core', 'plugin "'. l:plugin . '" lacks "trigger" information')
            continue
        endif

        let l:plugin_info['name'] = l:plugin

        if l:plugin_info['type'] == 'standalone'
            call add(s:standalone_plugin_list, l:plugin_info)
        elseif l:plugin_info['type'] == 'embedded'
            call add(s:embedded_plugin_list, l:plugin_info)
        endif
    endfor

    for s:plugin in s:standalone_plugin_list
        let s:plugin['menu'] = s:plugin['icon'] .' - '. s:plugin['description']
        let s:plugin['word'] = ''
        let s:plugin['dup'] = s:true
        let s:plugin['empty'] = s:true
    endfor
endfunction " }}}
call s:LoadPlugins()


let s:ime_english_enable = s:true
if len(s:standalone_plugin_list) == 0
    let s:ime_mode = {}
else
    let s:ime_mode = s:standalone_plugin_list[0]
endif


function! s:SelectMode (new_mode) " {{{
    for l:trigger in s:ime_mode['trigger']
        try
            execute 'iunmap '. l:trigger
        catch
        endtry
    endfor

    if type(a:new_mode) == type('ENGLISH') && a:new_mode == 'ENGLISH'
        let s:ime_english_enable = s:true
    elseif type(a:new_mode) == type({}) && a:new_mode == {}
        let s:ime_english_enable = s:true
    elseif type(a:new_mode) == type({})
        let s:ime_mode = a:new_mode
        let s:ime_english_enable = s:false
    endif

    if s:ime_english_enable == s:false
        for l:trigger in s:ime_mode['trigger']
            execute 'inoremap '. l:trigger .' <C-R>=<SID>SendKey("'.
                        \ substitute(l:trigger, '<', '<lt>', 'g') .'")<CR>'
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
            let l:len = l:ret['len']
            let l:options = l:ret['options']
        elseif type(l:ret) == type([])
            let l:options = l:ret
        else
            return s:false
        endif

        if l:options == []
            return s:false
        endif

        call complete(col('.') - l:len, l:options)
        return s:true
    catch
        call ime#log(a:plugin['name'], v:exception)
    endtry
    return s:false
endfunction " }}}


function! s:SendKey (trigger) " {{{
    if s:ime_english_enable
        if !empty(maparg(a:trigger, 'i'))
            execute "iunmap ". a:trigger
        endif
        return ' '
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


" ================
" Public Functions
" ================
function! ime#mode () " {{{
    if s:ime_english_enable == s:true
        return '[En]'
    endif
    return get(s:ime_mode, 'icon', '[？]')
endfunction " }}}


function! ime#toggle () " {{{
    if s:ime_english_enable == s:true
        call s:SelectMode(s:ime_mode)
    else
        call s:SelectMode('ENGLISH')
    endif
    return ''
endfunction " }}}


function! ime#_comp_mode_menu () " {{{
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


function! ime#_fallback_mode_menu () " {{{
    let l:cursor = index(s:standalone_plugin_list, s:ime_mode)
    try
        let l:more = &more
        set nomore
        while s:true
            redraw!
            echo 'Select input mode: (j/Down/<C-n>) (k/Up/<C-p>) (enter) (c/Esc)'
            for l:index in range(len(s:standalone_plugin_list))
                if l:index == l:cursor
                    echo '> '. s:standalone_plugin_list[(l:index)]['menu']
                else
                    echo '  '. s:standalone_plugin_list[(l:index)]['menu']
                endif
            endfor

            let l:key = getchar()
            if l:key == char2nr('j') || l:key == "\<Down>" || l:key == char2nr("\<C-n>")
                let l:cursor = (l:cursor + 1) % len(s:standalone_plugin_list)
            elseif l:key == char2nr('k') || l:key == "\<Up>" || l:key == char2nr("\<C-p>")
                let l:cursor = (l:cursor + len(s:standalone_plugin_list) - 1) % len(s:standalone_plugin_list)
            elseif l:key == char2nr("\<CR>")
                break
            elseif l:key == char2nr('c')
                redraw!
                return
            endif
        endwhile
    finally
        let &more = l:more
        redraw!
    endtry

    call s:SelectMode(s:standalone_plugin_list[(l:cursor)])
endfunction " }}}


function! ime#plugins () " {{{
    return {
    \ 'standalone': map(copy(s:standalone_plugin_list), 'v:val[''name'']'),
    \ 'embedded': map(copy(s:embedded_plugin_list), 'v:val[''name'']'),
    \ }
endfunction " }}}
