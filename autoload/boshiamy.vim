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

let s:IM_MODE_TABLE = {}
let s:IM_MODE_TABLE['BOSHIAMY'] = {'menu': '[嘸]'}
let s:IM_MODE_TABLE['KANA'] =     {'menu': '[あ]'}
let s:IM_MODE_TABLE['WIDE'] =     {'menu': '[Ａ]'}
let s:IM_MODE_TABLE['RUNES'] =    {'menu': '[ᚱ]'}
let s:IM_MODE_TABLE['BRAILLE'] =  {'menu': '[⢝]'}

let s:boshiamy_english_enable = s:true
let s:boshiamy_mode = 'BOSHIAMY'


for [s:mode, s:mode_item] in items(s:IM_MODE_TABLE)
    let s:mode_item['word'] = ''
    let s:mode_item['dup'] = s:true
    let s:mode_item['empty'] = s:true
endfor


function! s:SwitchMode (new_mode) " {{{
    let s:boshiamy_mode = a:new_mode
    let s:boshiamy_english_enable = 0
    redrawstatus!
    redraw!
endfunction " }}}

" ==============
" Apply Settings
" ==============

let s:switch_table = {}
" let s:switch_table[g:boshiamy_switch_boshiamy .'$'] = s:IM_BOSHIAMY
" let s:switch_table[g:boshiamy_switch_kana .'$'] = s:IM_KANA
" let s:switch_table[g:boshiamy_switch_wide .'$'] = s:IM_WIDE
" let s:switch_table[g:boshiamy_switch_runes .'$'] = s:IM_RUNES
" let s:switch_table[g:boshiamy_switch_braille .'$'] = s:IM_BRAILLE

" ================
" Public Functions
" ================

function! boshiamy#send_key () " {{{
    if s:boshiamy_english_enable
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

function! boshiamy#mode () " {{{
    if s:boshiamy_english_enable
        return '[英]'
    elseif has_key(s:IM_MODE_TABLE, s:boshiamy_mode)
        return s:IM_MODE_TABLE[s:boshiamy_mode]['menu']
    endif
    return '[？]'
endfunction " }}}

function! boshiamy#toggle () " {{{
    let s:boshiamy_english_enable = 1 - s:boshiamy_english_enable
    redrawstatus!
    redraw!
    return ''
endfunction " }}}

function! boshiamy#show_mode_menu () " {{{
    augroup boshiamy
        autocmd! boshiamy CompleteDone
        autocmd boshiamy CompleteDone * call boshiamy#select_mode()
    augroup end
    call complete(col('.'), values(s:IM_MODE_TABLE))
    return ''
endfunction " }}}

function! boshiamy#select_mode () " {{{
    augroup boshiamy
        autocmd! boshiamy CompleteDone
        let l:new_mode = ''
        for [s:mode, s:mode_item] in items(s:IM_MODE_TABLE)
            if s:mode_item['menu'] ==# v:completed_item['menu']
                let l:new_mode = s:mode
                break
            endif
        endfor
        echom string(l:new_mode)
        call s:SwitchMode(l:new_mode)
    augroup end
endfunction " }}}
