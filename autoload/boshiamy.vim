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

function! s:CharType (c) " {{{
    if a:c =~# "[a-zA-Z0-9]"
        return 1

    elseif a:c == "[" || a:c == "]"
        return 2

    elseif a:c == "," || a:c == "."
        return 3

    elseif a:c == "'"
        return 4

    endif

    return 0
endfunction " }}}

function! s:ProcessChewing (line, chewing_str) " {{{
    let l:start = strlen(a:line) - strlen(a:chewing_str)
    let l:col  = l:start + 1

    if has_key(g:boshiamy#chewing#table, a:chewing_str)
        call complete(l:col, g:boshiamy#chewing#table[a:chewing_str])
        return 0
    endif

    return 1
endfunction " }}}

function! s:ProcessKana (line, kana_str) " {{{
    let l:start = strlen(a:line) - strlen(a:kana_str)
    let l:col  = l:start + 1

    let kana_str_length = strlen(a:kana_str)
    if l:kana_str_length == 0
        return ' '
    endif

    if has_key(g:boshiamy#kana#table, a:kana_str)
        call complete(l:col, g:boshiamy#kana#table[ (a:kana_str) ])
        return ''
    endif

    let ret_hiragana = ''
    let ret_katakana = ''
    let i = 0
    let j = 4
    while l:i <= l:j
        let t = a:kana_str[ (l:i) : (l:j) ]
        echom l:t

        if has_key(g:boshiamy#kana#table, l:t)
            let ret_hiragana = l:ret_hiragana . g:boshiamy#kana#table[(l:t)][0]
            if has_key(g:boshiamy#kana#table, l:t .'.')
                let ret_katakana = l:ret_katakana . g:boshiamy#kana#table[(l:t .'.')][0]
            else
                let ret_katakana = l:ret_katakana . g:boshiamy#kana#table[(l:t)][0]
            endif
            let i = l:j + 1
            let j = l:i + 4
        else
            let j = l:j - 1
        endif

    endwhile
    let remain = a:kana_str[(l:j + 1) : ]

    call complete(l:col, [l:ret_hiragana . l:remain, l:ret_katakana . l:remain] )
    return ''
endfunction " }}}

function! s:ProcessWide (line, wide_str) " {{{
    let l:start = strlen(a:line) - strlen(a:wide_str)
    let l:col  = l:start + 1

    let wide_str_length = strlen(a:wide_str)
    if l:wide_str_length == 0
        return ' '
    endif

    let p = 0
    let ret = ''
    echom a:wide_str
    echom strlen(a:wide_str)
    while l:p < strlen(a:wide_str)
        echom l:p
        echom a:wide_str[(l:p)]
        let l:ret = l:ret . g:boshiamy#wide#table[a:wide_str[(l:p)]]
        let l:p = l:p + 1
    endwhile

    call complete(l:col, [l:ret] )
    return ''
endfunction " }}}

function! s:ProcessUnicodeEncode (line, unicode_pattern) " {{{
    let l:start = strlen(a:line) - strlen(a:unicode_pattern)
    let l:col  = l:start + 1

    let unicode_codepoint = str2nr(a:unicode_pattern[2:], 16)
    call complete(l:col, [nr2char(l:unicode_codepoint)])

    return 0
endfunction " }}}

function! s:ProcessUnicodeDecode (line, unicode_pattern) " {{{
    let l:start = strlen(a:line) - strlen(a:unicode_pattern)
    let l:col  = l:start + 1

    let utf8_str = a:unicode_pattern[3:-2]
    let unicode_codepoint = char2nr(l:utf8_str)
    let unicode_codepoint_str = printf('\u%x', unicode_codepoint)
    let html_code_str = printf('&#%d;', unicode_codepoint)
    call complete(l:col, [unicode_codepoint_str, html_code_str])

    return 0
endfunction " }}}

function! s:ProcessHTMLCode (line, htmlcode_pattern) " {{{
    let l:start = strlen(a:line) - strlen(a:htmlcode_pattern)
    let l:col  = l:start + 1

    if a:htmlcode_pattern[2] == 'x'
        let utf8_str = a:htmlcode_pattern[3:-2]
        let unicode_codepoint = str2nr(l:utf8_str, 16)
    else
        let utf8_str = a:htmlcode_pattern[2:-2]
        let unicode_codepoint = str2nr(l:utf8_str, 10)
    endif
    echom l:unicode_codepoint
    call complete(l:col, [nr2char(l:unicode_codepoint)])

    return 0
endfunction " }}}

function! s:ProcessRune (line, rune_str) " {{{
    let l:start = strlen(a:line) - strlen(a:rune_str)
    let l:col  = l:start + 1

    let rune_str_length = strlen(a:rune_str)
    if l:rune_str_length == 0
        return ' '
    endif

    if has_key(g:boshiamy#rune#table, a:rune_str)
        call complete(l:col, g:boshiamy#rune#table[ (a:rune_str) ])
        return ''
    endif

    let ret_rune = ''
    let i = 0
    let j = 2
    while l:i <= l:j
        let t = a:rune_str[ (l:i) : (l:j) ]
        echom l:t

        if has_key(g:boshiamy#rune#table, l:t)
            let ret_rune = l:ret_rune . g:boshiamy#rune#table[(l:t)][0]
            let i = l:j + 1
            let j = l:i + 2
        else
            let j = l:j - 1
        endif

    endwhile
    let remain = a:rune_str[(l:j + 1) : ]

    call complete(l:col, [l:ret_rune . l:remain] )
    return ''
endfunction " }}}

function! s:ProcessBraille (line, braille_pattern) " {{{
    let l:start = strlen(a:line) - strlen(a:braille_pattern)
    let l:col  = l:start + 1
    let l:braille_input_set = [0, 0, 0, 0, 0, 0, 0, 0]
    let l:boshiamy_braille_keys_list = split(g:boshiamy_braille_keys, '\zs')
    for i in range(strlen(a:braille_pattern))
        let l:braille_input_set[index(l:boshiamy_braille_keys_list, a:braille_pattern[i])] = 1
    endfor
    " call reverse(l:braille_input_set)

    let l:braille_value = 0
    let l:probe = 1
    for i in l:braille_input_set
        if i == 1
            let l:braille_value += l:probe
        endif
        let l:probe = l:probe * 2
    endfor
    call complete(l:col, [nr2char(l:braille_value + 0x2800)])
    return ''
endfunction " }}}

" 0: English
" 1: Boshiamy
" 2: Kana (Japanese alphabet)
" 3: Wide characters
" 4: Runed
" 5: Braille
let s:IM_ENGLISH = 0
let s:IM_BOSHIAMY = 1
let s:IM_KANA = 2
let s:IM_WIDE = 3
let s:IM_RUNE = 4
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
let s:switch_table[g:boshiamy_switch_rune .'$'] = s:IM_RUNE
let s:switch_table[g:boshiamy_switch_braille .'$'] = s:IM_BRAILLE

" ================
" Public Functions
" ================

function! boshiamy#send_key () " {{{
    if s:boshiamy_status == s:IM_ENGLISH
        " IM is not ON, just return a space
        return ' '
    endif

    " I need to substract 2 here, because
    " 1.
    "   col  : 1 2 3 4 5 6
    "   index: 0 1 2 3 4 5
    "   line : a b c d e f
    " 2.
    "   string slice is head-tail-including
    "
    " if you want "bcde", and the cursor is on "f",
    " the col=6, the index=5, tail_index=4
    " so you have to use "line[1:col-2]", which is "line[1:4]"
    "
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
        let l:wide_str = matchstr(l:line, '\([a-zA-Z0-9]\|[-=,./;:<>?_+\\|!@#$%^&*(){}"]\|\[\|\]\|'."'".'\)\+$')
        return s:ProcessWide(l:line, l:wide_str)
    endif

    if s:boshiamy_status == s:IM_KANA
        let l:kana_str = matchstr(l:line, '[.a-z]\+$')
        return s:ProcessKana(l:line, l:kana_str)
    endif

    if s:boshiamy_status == s:IM_RUNE
        let l:rune_str = matchstr(l:line, '[.a-z,]\+$')
        return s:ProcessRune(l:line, l:rune_str)
    endif

    if s:boshiamy_status == s:IM_BRAILLE
        let l:braille_str = matchstr(l:line, '\v['. g:boshiamy_braille_keys .']*$')
        return s:ProcessBraille(l:line, l:braille_str)
    endif

    " Try chewing
    let chewing_str = matchstr(l:line, ';[^;]*;[346]\?$')
    if l:chewing_str == ''
        let chewing_str = matchstr(l:line, ';[^;]\+$')
    endif

    if l:chewing_str != ''
        " Found chewing pattern
        if s:ProcessChewing(l:line, l:chewing_str) == 0
            return ''
        endif
    endif

    let unicode_pattern = matchstr(l:line, '\\[Uu][0-9a-fA-F]\+$')
    if l:unicode_pattern != ''
        if s:ProcessUnicodeEncode(l:line, l:unicode_pattern) == 0
            return ''
        endif
    endif

    let unicode_pattern = matchstr(l:line, '\\[Uu]\[[^]]*\]$')
    if l:unicode_pattern == ''
        let unicode_pattern = matchstr(l:line, '\\[Uu]\[\]\]$')
    endif
    if l:unicode_pattern != ''
        if s:ProcessUnicodeDecode(l:line, l:unicode_pattern) == 0
            return ''
        endif
    endif

    let htmlcode_pattern = matchstr(l:line, '&#x\?[0-9a-fA-F]\+;$')
    if l:htmlcode_pattern != ''
        if s:ProcessHTMLCode(l:line, l:htmlcode_pattern) == 0
            return ''
        endif
    endif

    " Locate the start of the boshiamy key sequence
    let start = col('.') - 1
    while l:start > 0 && s:CharType(l:line[l:start-1])
        let start -= 1
    endwhile

    let l:base = l:line[(l:start): (col('.')-2)]
    let l:col  = l:start + 1

    " Input key start is l:start
    " Input key col is l:col
    " Input key sequence is l:base

    if has_key(g:boshiamy#boshiamy#table, l:base)
        call complete(l:col, g:boshiamy#boshiamy#table[l:base])
        return ''
    endif

    let char_type = s:CharType(l:base[0])

    while strlen(l:base) > 0
        let new_char_type = s:CharType(l:base[0])

        " Cut off the string
        if l:new_char_type != l:char_type

            if has_key( g:boshiamy#boshiamy#table, l:base )
                call complete(l:col, g:boshiamy#boshiamy#table[ (l:base) ])
                return ''

            endif

        endif

        " Boshiamy char not found, cut off one char and keep trying
        let l:col = l:col + 1
        let l:base = l:base[1:]

        let l:char_type = l:new_char_type

    endwhile

    " There is nothing I can do, just return a space
    return ' '

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
    elseif s:boshiamy_status == s:IM_RUNE
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

function! boshiamy#leave () " {{{
    call s:UpdateIMStatus(s:IM_ENGLISH)
    return ''
endfunction " }}}
