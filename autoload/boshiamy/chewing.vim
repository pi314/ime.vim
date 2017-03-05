let s:table = {}


function! s:Handler (matchobj)
    if s:table == {}
        let s:table = boshiamy#chewing_table#table()
    endif
    return get(s:table, a:matchobj[0], [])
endfunction


" built-in plugin: chewing
function! boshiamy#chewing#info ()
    return {
    \ 'type': 'embedded',
    \ 'pattern': '\v(;[^;]+|;[^;]*;[346]?)$',
    \ 'handler': function('s:Handler'),
    \ }
endfunction
