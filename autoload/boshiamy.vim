" vim:fdm=marker
" ============================================================================
" File:        boshiamy.vim
" Description: A Boshiamy Chinese input method plugin for vim
" Maintainer:  Pi314 <michael66230@gmail.com>
" License:     This program is free software. It comes without any warranty,
"              to the extent permitted by applicable law. You can redistribute
"              it and/or modify it under the terms of the Do What The Fuck You
"              Want To Public License, Version 2, as published by Sam Hocevar.
"              See http://sam.zoy.org/wtfpl/COPYING for more details.
" ============================================================================
let s:true = exists('v:true') ? v:true : 1
let s:false = exists('v:false') ? v:false : 0

function! boshiamy#log (tag, msg)
    redraw
    echom substitute('[boshiamy]['. a:tag .'] '. a:msg, '] [', '][', '')
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
    for l:plugin in g:boshiamy_plugins
        try
            let l:plugin_info = function('boshiamy_'. l:plugin .'#info')()
        catch
            try
                let l:plugin_info = function('boshiamy#'. l:plugin .'#info')()
            catch
                call boshiamy#log('core', v:exception)
                continue
            endtry
        endtry

        " sanity check
        if !has_key(l:plugin_info, 'type')
            call boshiamy#log('core', 'plugin "'. l:plugin . '" lacks "type" information')
            continue
        endif

        if l:plugin_info['type'] == 'standalone' &&
                \ (!has_key(l:plugin_info, 'icon') ||
                \ !has_key(l:plugin_info, 'description'))
            call boshiamy#log('core', 'plugin "'. l:plugin . '" lacks "icon" or "description" information')
            continue
        endif

        if !has_key(l:plugin_info, 'pattern')
            call boshiamy#log('core', 'plugin "'. l:plugin . '" lacks "pattern" information')
            continue
        endif

        if !has_key(l:plugin_info, 'handler')
            call boshiamy#log('core', 'plugin "'. l:plugin . '" lacks "handler" information')
            continue
        endif

        if !has_key(l:plugin_info, 'trigger')
            call boshiamy#log('core', 'plugin "'. l:plugin . '" lacks "trigger" information')
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


let s:boshiamy_english_enable = s:true
if len(s:standalone_plugin_list) == 0
    let s:boshiamy_mode = {}
else
    let s:boshiamy_mode = s:standalone_plugin_list[0]
endif


function! s:SelectMode (new_mode) " {{{
    for l:trigger in s:boshiamy_mode['trigger']
        execute 'iunmap '. l:trigger .' <C-R>=<SID>SendKey()<CR>'
    endfor

    if type(a:new_mode) == type('ENGLISH') && a:new_mode == 'ENGLISH'
        let s:boshiamy_english_enable = s:true
    elseif type(a:new_mode) == type({}) && a:new_mode == {}
        let s:boshiamy_english_enable = s:true
    elseif type(a:new_mode) == type({})
        let s:boshiamy_mode = a:new_mode
        let s:boshiamy_english_enable = s:false
    endif

    if s:boshiamy_english_enable == s:false
        for l:trigger in s:boshiamy_mode['trigger']
            execute 'inoremap '. l:trigger .' <C-R>=<SID>SendKey()<CR>'
        endfor
    endif

    redrawstatus!
    redraw!
endfunction " }}}


function! s:ShowModeMenuComp () " {{{
    augroup boshiamy
        autocmd! boshiamy CompleteDone
        autocmd boshiamy CompleteDone * call s:CompSelectMode()
    augroup end
    call complete(col('.'), s:standalone_plugin_list)
endfunction " }}}


function! s:CompSelectMode () " {{{
    augroup boshiamy
        autocmd! boshiamy CompleteDone
        for l:plugin in s:standalone_plugin_list
            if v:completed_item['menu'] == l:plugin['menu']
                call s:SelectMode(l:plugin)
            endif
        endfor
    augroup end
endfunction " }}}


function! s:ShowModeMenuInput () " {{{
    let l:prompt = ['Select input mode:'] + map(copy(s:standalone_plugin_list), '(v:key + 1) ." - ". v:val["menu"]')
    let l:user_input = inputlist(l:prompt)
    if l:user_input
        call s:SelectMode(s:standalone_plugin_list[l:user_input - 1])
    endif
endfunction " }}}


function! s:ShowModeMenuDialog () " {{{
    let l:prompt = ['Select input mode:'] + map(copy(s:standalone_plugin_list), '(v:key + 1) ." - ". v:val["menu"]')
    let l:user_input = str2nr(inputdialog(join(l:prompt, "\n") ."\n> "))
    if 0 < l:user_input && l:user_input < len(l:prompt)
        call s:SelectMode(s:standalone_plugin_list[l:user_input - 1])
    endif
endfunction " }}}


function! s:ExecutePlugin (line, plugin) " {{{
    let l:matchobj = matchlist(a:line, a:plugin['pattern'])
    if len(l:matchobj) == 0
        return s:false
    endif

    try
        let l:len = strlen(l:matchobj[0])
        let l:options = []
        let l:ret = a:plugin['handler'](l:matchobj)
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
        call boshiamy#log(a:plugin['name'], v:exception)
    endtry
    return s:false
endfunction " }}}


function! s:SendKey (trigger) " {{{
    if s:boshiamy_english_enable
        if !empty(maparg('<space>', 'i'))
            iunmap <space>
        endif
        return ' '
    endif

    let l:line = strpart(getline('.'), 0, (col('.') - 1))

    " search for embedded plugins first
    for l:plugin in s:embedded_plugin_list
        let l:result = s:ExecutePlugin(l:line, l:plugin)
        if l:result == s:true
            return ''
        endif
    endfor

    let l:result = s:ExecutePlugin(l:line, s:boshiamy_mode)
    return l:result == s:true ? '' : ' '
endfunction " }}}


" ================
" Public Functions
" ================
function! boshiamy#mode () " {{{
    if s:boshiamy_english_enable == s:true
        return '[En]'
    endif
    return get(s:boshiamy_mode, 'icon', '[？]')
endfunction " }}}


function! boshiamy#toggle () " {{{
    if s:boshiamy_english_enable == s:true
        call s:SelectMode(s:boshiamy_mode)
    else
        call s:SelectMode('ENGLISH')
    endif
    return ''
endfunction " }}}


function! boshiamy#_show_mode_menu () " {{{
    if s:boshiamy_mode == {}
        call boshiamy#log('core', 'No input mode installed.')
        return ''
    endif

    let l:fallback_style = g:boshiamy_select_mode_style

    if index(['menu', 'input', 'dialog'], l:fallback_style) == -1
        let l:fallback_style = 'menu'
    endif

    if l:fallback_style == 'menu' && !exists('##CompleteDone')
        let l:fallback_style = 'input'
    endif

    if l:fallback_style == 'menu'
        call s:ShowModeMenuComp()
    elseif l:fallback_style == 'input'
        call s:ShowModeMenuInput()
    elseif l:fallback_style == 'dialog'
        call s:ShowModeMenuDialog()
    endif
    return ''
endfunction " }}}


function! boshiamy#plugins () " {{{
    return {
    \ 'standalone': map(copy(s:standalone_plugin_list), 'v:val[''name'']'),
    \ 'embedded': map(copy(s:embedded_plugin_list), 'v:val[''name'']'),
    \ }
endfunction " }}}
