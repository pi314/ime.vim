let s:table = {}

function! s:CharType (c) " {{{
    if a:c =~# "[a-zA-Z_]"
        return 1

    elseif a:c =~# "[0-9]"
        return 2

    elseif a:c == "[" || a:c == "]"
        return 3

    elseif a:c == "," || a:c == "."
        return 4

    elseif a:c == "'"
        return 5

    endif

    return 0
endfunction " }}}

function! boshiamy#boshiamy#handler (line)
    if s:table == {}
        let s:table = boshiamy#boshiamy_table#table()
    endif

    " Locate the starting idx of the boshiamy key sequence
    let idx = col('.') - 1
    while l:idx > 0 && s:CharType(a:line[l:idx-1])
        let idx -= 1
    endwhile

    let l:base = a:line[(l:idx): (col('.')-2)]    " the key seq
    let l:col  = l:idx + 1                        " the col of key seq

    if has_key(s:table, l:base)
        call complete(l:col, s:table[l:base])
        return ''
    endif

    let l:prev_char_type = s:CharType(l:base[0])
    while strlen(l:base) > 0
        let curr_char_type = s:CharType(l:base[0])
        if l:curr_char_type != l:prev_char_type
            if has_key(s:table, l:base)
                call complete(l:col, s:table[(l:base)])
                return ''
            endif
        endif

        " Boshiamy char not found, cut off one char and keep trying
        let l:col = l:col + 1
        let l:base = l:base[1:]
        let l:prev_char_type = l:curr_char_type
    endwhile

    " There is nothing I can do, just return a space
    return ' '
endfunction


function! boshiamy#boshiamy#info ()
    return {
    \ 'type': 'standalone',
    \ 'icon': '[嘸]',
    \ 'description': 'Chinese mode',
    \ 'pattern': '\v[\w,.''\[\]]*$',
    \ 'handler': function('boshiamy#boshiamy#handler'),
    \ }
endfunction
