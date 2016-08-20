function! boshiamy#unicode#handler_encode (line, unicode_pattern)
    let l:idx = strlen(a:line) - strlen(a:unicode_pattern)
    let l:col  = l:idx + 1

    let unicode_codepoint = str2nr(a:unicode_pattern[2:], 16)
    call complete(l:col, [nr2char(l:unicode_codepoint)])

    return 0
endfunction

function! boshiamy#unicode#handler_decode (line, unicode_pattern)
    let l:idx = strlen(a:line) - strlen(a:unicode_pattern)
    let l:col  = l:idx + 1

    let utf8_str = a:unicode_pattern[3:-2]
    let unicode_codepoint = char2nr(l:utf8_str)
    let unicode_codepoint_str = printf('\u%x', unicode_codepoint)
    let html_code_str = printf('&#%d;', unicode_codepoint)
    call complete(l:col, [unicode_codepoint_str, html_code_str])

    return 0
endfunction
