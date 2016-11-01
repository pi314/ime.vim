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
let s:true = 1
let s:false = 0

let s:mode_list = [
            \['BOSHIAMY',   '[嘸]'],
            \['KANA',       '[あ]'],
            \['WIDE',       '[Ａ]'],
            \['RUNES',      '[ᚱ]'],
            \['BRAILLE',    '[⢝]'],
            \]

let s:boshiamy_english_enable = s:true
let s:boshiamy_mode = s:mode_list[0][0]

let s:__mode2icon = {}
let s:__icon2mode = {}
let s:__mode_order = []
for [s:mode, s:icon] in s:mode_list
    let s:__mode2icon[s:mode] = {}
    let s:__mode2icon[s:mode]['menu'] = s:icon
    let s:__mode2icon[s:mode]['word'] = ''
    let s:__mode2icon[s:mode]['dup'] = s:true
    let s:__mode2icon[s:mode]['empty'] = s:true
    let s:__icon2mode[s:icon] = s:mode
    call add(s:__mode_order, s:mode)
endfor


function! s:SelectMode (new_mode) " {{{
    if a:new_mode == 'ENGLISH'
        let s:boshiamy_english_enable = 1
    else
        let s:boshiamy_mode = a:new_mode
        let s:boshiamy_english_enable = 0
    endif

    if s:boshiamy_english_enable == s:false
        inoremap <space> <C-R>=boshiamy#send_key()<CR>
    elseif !empty(maparg('<space>', 'i'))
        iunmap <space>
    endif

    redrawstatus!
    redraw!
endfunction " }}}


" ================
" Public Functions
" ================

function! boshiamy#send_key () " {{{
    if s:boshiamy_english_enable
        if !empty(maparg('<space>', 'i'))
            iunmap <space>
        endif
        return ' '
    endif

    let l:line = strpart(getline('.'), 0, (col('.')-1) )

    if s:boshiamy_mode == 'WIDE'
        let l:wide_str = matchstr(l:line, '\([ a-zA-Z0-9]\|[-=,./;:<>?_+\\|!@#$%^&*(){}"]\|\[\|\]\|'."'".'\)\+$')
        return boshiamy#wide#handler(l:line, l:wide_str)
    endif

    if s:boshiamy_mode == 'KANA'
        let l:kana_str = matchstr(l:line, '[.a-z]\+$')
        return boshiamy#kana#handler(l:line, l:kana_str)
    endif

    if s:boshiamy_mode == 'RUNES'
        let l:runes_str = matchstr(l:line, '[.a-z,]\+$')
        return boshiamy#runes#handler(l:line, l:runes_str)
    endif

    if s:boshiamy_mode == 'BRAILLE'
        let l:braille_str = matchstr(l:line, '\v['. g:boshiamy_braille_keys .']*$')
        return boshiamy#braille#handler(l:line, l:braille_str)
    endif

    " Try chewing
    let chewing_str = matchstr(l:line, ';[^;]*;[346]\?$')
    if l:chewing_str == ''
        let chewing_str = matchstr(l:line, ';[^;]\+$')
    endif
    if l:chewing_str != ''
        if boshiamy#chewing#handler(l:line, l:chewing_str) == 0
            return ''
        endif
    endif

    " Translating code point to unicode character
    let unicode_pattern = matchstr(l:line, '\\[Uu][0-9a-fA-F]\+$')
    if l:unicode_pattern != ''
        if boshiamy#unicode#handler_encode(l:line, l:unicode_pattern) == 0
            return ''
        endif
    endif

    " Reverse lookup for code point
    let unicode_pattern = matchstr(l:line, '\\[Uu]\[[^]]*\]$')
    if l:unicode_pattern == ''
        let unicode_pattern = matchstr(l:line, '\\[Uu]\[\]\]$')
    endif
    if l:unicode_pattern != ''
        if boshiamy#unicode#handler_decode(l:line, l:unicode_pattern) == 0
            return ''
        endif
    endif

    let htmlcode_pattern = matchstr(l:line, '&#x\?[0-9a-fA-F]\+;$')
    if l:htmlcode_pattern != ''
        if boshiamy#html#handler(l:line, l:htmlcode_pattern) == 0
            return ''
        endif
    endif

    let emoji_pattern = matchstr(l:line, ':[0-9a-z_+-]\+:\?$')
    " +-0123456789:_abcdefghijklmnopqrstuvwxyz
    if emoji_pattern != ''
        if boshiamy#emoji#handler(l:line, l:emoji_pattern) == 0
            return ''
        endif
    endif

    return boshiamy#boshiamy#handler(l:line)
endfunction " }}}


function! boshiamy#mode () " {{{
    if s:boshiamy_english_enable
        return '[英]'
    elseif has_key(s:__mode2icon, s:boshiamy_mode)
        return s:__mode2icon[s:boshiamy_mode]['menu']
    endif
    return '[？]'
endfunction " }}}


function! boshiamy#toggle () " {{{
    if s:boshiamy_english_enable
        call s:SelectMode(s:boshiamy_mode)
    else
        call s:SelectMode('ENGLISH')
    endif

    return ''
endfunction " }}}


function! boshiamy#show_mode_menu () " {{{
    augroup boshiamy
        autocmd! boshiamy CompleteDone
        autocmd boshiamy CompleteDone * call boshiamy#select_mode()
    augroup end
    let l:tmp = []
    for l:mode in s:__mode_order
        call add(l:tmp, s:__mode2icon[(l:mode)])
    endfor
    call complete(col('.'), l:tmp)
    return ''
endfunction " }}}


function! boshiamy#select_mode () " {{{
    augroup boshiamy
        autocmd! boshiamy CompleteDone
        if has_key(s:__icon2mode, v:completed_item['menu'])
            call s:SelectMode(s:__icon2mode[v:completed_item['menu']])
        endif
    augroup end
endfunction " }}}
