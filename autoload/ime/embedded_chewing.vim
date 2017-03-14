let s:table = {}


function! ime#embedded_chewing#handler (matchobj, trigger)
    if s:table == {}
        let s:table = ime#embedded_chewing_table#table()
    endif
    return get(s:table, a:matchobj[0], [])
endfunction


" built-in plugin: embedded_chewing
function! ime#embedded_chewing#info ()
    return {
    \ 'type': 'embedded',
    \ 'pattern': '\v(;[^;]+|;[^;]*;[346]?)$',
    \ 'handler': function('ime#embedded_chewing#handler'),
    \ 'trigger': ['<space>'],
    \ }
endfunction
