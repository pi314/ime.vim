let s:true = exists('v:true') ? v:true : 1
let s:false = exists('v:false') ? v:false : 1

let s:table = []
let s:keys = []
let s:submode = 0
let s:large_small_kana = 'あえいかけおつうわやよゆアエイカケオツウワヤヨユぁぃぅぇぉっゃゅょゎゕゖァィゥェォッャュョヮヵヶ'


function! s:log (...)
    call call(function('ime#log'), ['builtin-kana'] + a:000)
endfunction


function! ime#builtin_kana#handler (matchobj, trigger)
    if s:table == []
        let s:table = ime#kana_table#table()
        let s:keys = s:table[3]
    endif

    let l:buffer = a:matchobj[1]
    let l:key = a:matchobj[1] . a:trigger

    if a:trigger == 'v'
        if a:matchobj[2] != ''
            return [s:table[2][(a:matchobj[2])]]
        endif
        return ['']
    endif

    let l:matched_keys = filter(copy(s:keys), 'strpart(v:val, 0, strlen(l:key)) == l:key')
    if len(l:matched_keys) == 1
        return {
        \ 'len': strlen(l:buffer),
        \ 'options': s:table[(s:submode)][a:matchobj[1] . a:trigger]
        \ }
    elseif len(l:matched_keys) > 1
        let l:ret = []
        for l:k in l:matched_keys
            for l:char in s:table[(s:submode)][(l:k)]
                call add(l:ret, {
                \ 'word': l:char,
                \ 'menu': l:k,
                \ 'dup': s:true,
                \ })
            endfor
        endfor
        return {
        \ 'len': strlen(l:buffer),
        \ 'options': [(l:key)] + l:ret,
        \ }
    endif
    return []
endfunction


function! ime#builtin_kana#menu (...)
    if a:0 == 0
        let s:submode = 1 - s:submode
    elseif a:1 == ''
        let s:submode = 0
    endif

    if s:submode == 0
        call ime#icon('builtin-kana', '[あ]')
    else
        call ime#icon('builtin-kana', '[ア]')
    endif
endfunction


" built-in plugin: builtin-kana
function! ime#builtin_kana#info ()
    return {
    \ 'type': 'standalone',
    \ 'icon': '[あ]',
    \ 'description': 'Kana input mode',
    \ 'pattern': '\v%(([.a-z]*)|(['. s:large_small_kana .'])|([んン]))$',
    \ 'handler': function('ime#builtin_kana#handler'),
    \ 'trigger': split('-.''abcdefghijkmnoprstuvwyz', '\zs'),
    \ 'menu': function('ime#builtin_kana#menu'),
    \ }
endfunction
