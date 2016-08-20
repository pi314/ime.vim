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

" 0: English
" 1: Boshiamy
" 2: Kana (Japanese alphabet)
" 3: Wide characters
" 4: Runes
" 5: Braille
let s:IM_ENGLISH = 0
let s:IM_BOSHIAMY = 1
let s:IM_KANA = 2
let s:IM_WIDE = 3
let s:IM_RUNES = 4
let s:IM_BRAILLE = 5

let s:boshiamy_sub_status = s:IM_BOSHIAMY
let s:boshiamy_status = s:IM_ENGLISH

function! s:UpdateIMStatus (new_status) " {{{
    let s:boshiamy_status = a:new_status
    if a:new_status != s:IM_ENGLISH
        let s:boshiamy_sub_status = a:new_status
    endif
    redrawstatus!
    redraw!
endfunction " }}}

" ==============
" Apply Settings
" ==============

let s:switch_table = {}
let s:switch_table[g:boshiamy_switch_boshiamy .'$'] = s:IM_BOSHIAMY
let s:switch_table[g:boshiamy_switch_kana .'$'] = s:IM_KANA
let s:switch_table[g:boshiamy_switch_wide .'$'] = s:IM_WIDE
let s:switch_table[g:boshiamy_switch_runes .'$'] = s:IM_RUNES
let s:switch_table[g:boshiamy_switch_braille .'$'] = s:IM_BRAILLE

" ================
" Public Functions
" ================

function! boshiamy#send_key () " {{{
    if s:boshiamy_status == s:IM_ENGLISH
        return ' '
    endif

    let l:line = strpart(getline('.'), 0, (col('.')-1) )

    " Switch input mode
    for [switch, switch_type] in items(s:switch_table)
        if l:line =~# switch
            let c = col('.')
            call setline('.', l:line[:(0-strlen(switch))] . getline('.')[ (l:c-1) : ] )
            call cursor(line('.'), l:c-( strlen(switch)-1 ) )
            call s:UpdateIMStatus(switch_type)
            return ''
        endif
    endfor

    if s:boshiamy_status == s:IM_WIDE
        let l:wide_str = matchstr(l:line, '\([ a-zA-Z0-9]\|[-=,./;:<>?_+\\|!@#$%^&*(){}"]\|\[\|\]\|'."'".'\)\+$')
        return boshiamy#wide#handler(l:line, l:wide_str)
    endif

    if s:boshiamy_status == s:IM_KANA
        let l:kana_str = matchstr(l:line, '[.a-z]\+$')
        return boshiamy#kana#handler(l:line, l:kana_str)
    endif

    if s:boshiamy_status == s:IM_RUNES
        let l:runes_str = matchstr(l:line, '[.a-z,]\+$')
        return boshiamy#runes#handler(l:line, l:runes_str)
    endif

    if s:boshiamy_status == s:IM_BRAILLE
        let l:braille_str = matchstr(l:line, '\v['. g:boshiamy_braille_keys .']*$')
        return boshiamy#braille#handler(l:line, l:braille_str)
    endif

    " Try chewing
    let chewing_str = matchstr(l:line, ';[^;]*;[346]\?$')
    if l:chewing_str == ''
        let chewing_str = matchstr(l:line, ';[^;]\+$')
    endif

    if l:chewing_str != ''
        " Found chewing pattern
        if boshiamy#chewing#handler(l:line, l:chewing_str) == 0
            return ''
        endif
    endif

    let unicode_pattern = matchstr(l:line, '\\[Uu][0-9a-fA-F]\+$')
    if l:unicode_pattern != ''
        if boshiamy#unicode#handler_encode(l:line, l:unicode_pattern) == 0
            return ''
        endif
    endif

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

    return boshiamy#boshiamy#handler(l:line)
endfunction " }}}

function! boshiamy#status () " {{{
    if s:boshiamy_status == s:IM_ENGLISH
        return '[英]'
    elseif s:boshiamy_status == s:IM_BOSHIAMY
        return '[嘸]'
    elseif s:boshiamy_status == s:IM_KANA
        return '[あ]'
    elseif s:boshiamy_status == s:IM_WIDE
        return '[Ａ]'
    elseif s:boshiamy_status == s:IM_RUNES
        return '[ᚱ]'
    elseif s:boshiamy_status == s:IM_BRAILLE
        return '[⢝]'
    endif
    return '[？]'
endfunction " }}}

function! boshiamy#toggle () " {{{
    if s:boshiamy_status
        call s:UpdateIMStatus(s:IM_ENGLISH)

    else
        call s:UpdateIMStatus(s:boshiamy_sub_status)

    endif
    return ''
endfunction " }}}
