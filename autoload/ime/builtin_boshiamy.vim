let s:true = exists('v:true') ? v:true : 1
let s:false = exists('v:false') ? v:false : 0

let s:table = {}
let s:eager = s:false


function! s:log (...)
    call call(function('ime#log'), ['builtin_boshiamy'] + a:000)
endfunction


function! s:fallback_str (arg)
    if a:arg =~ '\v^\w'
        return matchlist(a:arg, '\v^\w+(\W+.*)?$')[1]
    elseif a:arg =~ '\v^,'
        return matchlist(a:arg, '\v^,+([^,]+.*)?$')[1]
    elseif a:arg =~ '\v^\.'
        return matchlist(a:arg, '\v^\.+([^.]+.*)?$')[1]
    elseif a:arg =~ '\v^[\[\]]'
        return matchlist(a:arg, '\v^[\[\]]+([^\[\]]+.*)?$')[1]
    elseif a:arg =~ '\v^'''
        return matchlist(a:arg, '\v^''+([^'']+.*)?$')[1]
    endif
    return a:arg
endfunction


function! ime#builtin_boshiamy#handler (matchobj, trigger)
    if s:table == {}
        let s:table = ime#boshiamy_table#table()
    endif

    let l:boshiamy_str = a:matchobj[0]

    if s:eager
        let l:boshiamy_str = substitute(l:boshiamy_str, '\C^.*[A-Z0-9_]', '', '')
    endif

    while l:boshiamy_str != ''
        if has_key(s:table, l:boshiamy_str)
            return {
            \ 'len': strlen(l:boshiamy_str),
            \ 'options': s:table[l:boshiamy_str],
            \ }
        endif

        let l:boshiamy_str = s:fallback_str(l:boshiamy_str)
    endwhile
    return []
endfunction


function! ime#builtin_boshiamy#menu (...)
    if a:0 == 0
        return [
                \ {
                    \ 'key': 'e',
                    \ 'menu': '積極模式：去除大寫字母、數字以及底線，儘可能送字 ('. (s:eager ? 'on' : 'off') .')'
                \ },
            \ ]
    endif

    if a:1 == 'e'
        let s:eager = !s:eager
    endif
endfunction


function! ime#builtin_boshiamy#info ()
    return {
    \ 'type': 'standalone',
    \ 'icon': '[嘸]',
    \ 'description': 'Boshiamy input mode',
    \ 'pattern': '\v%(\w|[,.''\[\]])+$',
    \ 'handler': function('ime#builtin_boshiamy#handler'),
    \ 'trigger': [' '],
    \ 'menu': function('ime#builtin_boshiamy#menu'),
    \ }

    " Note: This plugin use ``\w`` in regex.
    " ``\w`` includes ``_``, but ``_`` does not appear in any key.
    " The reason ``_`` used instead of ``\a|\d`` is that
    " ``apple_id`` should not output any word.
endfunction
