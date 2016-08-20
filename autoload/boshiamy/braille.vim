function! boshiamy#braille#handler (line, braille_pattern)
    if strlen(a:braille_pattern) == 0
        return ' '
    endif

    let l:idx = strlen(a:line) - strlen(a:braille_pattern)
    let l:col  = l:idx + 1
    let l:braille_input_set = [0, 0, 0, 0, 0, 0, 0, 0]
    let l:boshiamy_braille_keys_list = split(g:boshiamy_braille_keys, '\zs')
    for i in range(strlen(a:braille_pattern))
        let l:braille_input_set[index(l:boshiamy_braille_keys_list, a:braille_pattern[i])] = 1
    endfor

    let l:braille_value = 0
    let l:probe = 1
    for i in l:braille_input_set
        if i == 1
            let l:braille_value += l:probe
        endif
        let l:probe = l:probe * 2
    endfor
    call complete(l:col, [nr2char(l:braille_value + 0x2800)])
    return ''
endfunction
