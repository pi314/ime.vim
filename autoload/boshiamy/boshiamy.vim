let s:table = {}


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


function! boshiamy#boshiamy#handler (matchobj, trigger)
    if s:table == {}
        let s:table = boshiamy#boshiamy_table#table()
    endif

    let l:boshiamy_str = a:matchobj[0]
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


function! boshiamy#boshiamy#info ()
    return {
    \ 'type': 'standalone',
    \ 'icon': '[嘸]',
    \ 'description': 'Chinese mode',
    \ 'pattern': '\v%(\w|[,.''\[\]])+$',
    \ 'handler': function('boshiamy#boshiamy#handler'),
    \ 'trigger': ['<space>'],
    \ }

    " Note: This plugin use ``\w`` in regex.
    " ``\w`` includes ``_``, but ``_`` does not appear in any key.
    " The reason ``_`` used instead of ``\a|\d`` is that
    " ``apple_id`` should not output any word.
endfunction
