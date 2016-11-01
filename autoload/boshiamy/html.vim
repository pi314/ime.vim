function! boshiamy#html#handler (line, htmlcode_pattern)
    let l:idx = strlen(a:line) - strlen(a:htmlcode_pattern)
    let l:col  = l:idx + 1

    if a:htmlcode_pattern[2] == 'x'
        let utf8_str = a:htmlcode_pattern[3:-2]
        let unicode_codepoint = str2nr(l:utf8_str, 16)
    else
        let utf8_str = a:htmlcode_pattern[2:-2]
        let unicode_codepoint = str2nr(l:utf8_str, 10)
    endif
    call complete(l:col, [nr2char(l:unicode_codepoint)])

    return 0
endfunction
