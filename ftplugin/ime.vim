if exists('g:ime_enable_ime_buffer') && g:ime_enable_ime_buffer
    setlocal buftype=nofile
    setlocal noswapfile

    function! s:set_title ()
        let l:postfix = ''
        let l:idx = 1
        while 1
            try
                exec 'file ime'. l:postfix
                break
            catch /^Vim\%((\a\+)\)\=:E95/
            endtry
            let l:idx += 1
            let l:postfix = string(l:idx)
        endwhile
    endfunction

    call s:set_title()

    inoremap <expr> <buffer> <CR> (pumvisible() ? "<C-Y>" : "") . (getline('.') == '' ? "<C-R>*" : "<ESC>0\"*C")
    vnoremap <buffer> <CR> "*x
endif
