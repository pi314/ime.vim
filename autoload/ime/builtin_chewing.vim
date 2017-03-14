let s:table = {}


function! ime#builtin_chewing#handler (matchobj, trigger)
    if s:table == {}
        let s:table = ime#chewing_table#table()
    endif
    return get(s:table, a:matchobj[0], [])
endfunction


" built-in plugin: builtin_chewing
function! ime#builtin_chewing#info ()
    return {
    \ 'type': 'embedded',
    \ 'pattern': '\v(;[^;]+|;[^;]*;[346]?)$',
    \ 'handler': function('ime#builtin_chewing#handler'),
    \ 'trigger': ['<space>'],
    \ }
endfunction
