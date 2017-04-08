let s:table = []
let s:submode = 0
let s:large_small_kana = 'あえいかけおつうわやよゆアエイカケオツウワヤヨユぁぃぅぇぉっゃゅょゎゕゖァィゥェォッャュョヮヵヶ'


function! s:log (...)
    call call(function('ime#log'), ['builtin-kana'] + a:000)
endfunction


function! ime#builtin_kana#handler (matchobj, trigger)
    if s:table == []
        let s:table = ime#kana_table#table()
    endif

    call s:log(a:matchobj, a:trigger)

    if a:trigger == 'v'
        if a:matchobj[2] != ''
            return [s:table[2][(a:matchobj[2])]]
        endif
        return ['']
    endif

    if has_key(s:table[(s:submode)], a:matchobj[1] . a:trigger)
        return {
        \ 'len': strlen(a:matchobj[1]),
        \ 'options': s:table[(s:submode)][a:matchobj[1] . a:trigger]
        \ }
    endif
    return []
endfunction


function! ime#builtin_kana#submode (switch)
endfunction


" built-in plugin: builtin-kana
function! ime#builtin_kana#info ()
    return {
    \ 'type': 'standalone',
    \ 'icon': '[あ]',
    \ 'description': 'Kana input mode',
    \ 'pattern': '\v%(([.a-z]*)|(['. s:large_small_kana .']))$',
    \ 'handler': function('ime#builtin_kana#handler'),
    \ 'trigger': split('.''abcdefghijkmnoprstuvwyz', '\zs'),
    \ 'submode': function('ime#builtin_kana#submode'),
    \ }
endfunction
