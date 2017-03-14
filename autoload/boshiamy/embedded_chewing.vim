let s:table = {}


function! boshiamy#embedded_chewing#handler (matchobj, trigger)
    if s:table == {}
        let s:table = boshiamy#embedded_chewing_table#table()
    endif
    return get(s:table, a:matchobj[0], [])
endfunction


" built-in plugin: embedded_chewing
function! boshiamy#embedded_chewing#info ()
    return {
    \ 'type': 'embedded',
    \ 'pattern': '\v(;[^;]+|;[^;]*;[346]?)$',
    \ 'handler': function('boshiamy#embedded_chewing#handler'),
    \ 'trigger': ['<space>'],
    \ }
endfunction
