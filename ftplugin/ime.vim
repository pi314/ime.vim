if exists('g:ime_enable_ime_buffer') && g:ime_enable_ime_buffer
    setlocal buftype=nofile
    setlocal noswapfile
    file ime

    inoremap <expr> <buffer> <CR> (pumvisible() ? "<C-Y>" : "") . (getline('.') == '' ? "<C-R>*" : "<ESC>0\"*C")
    vnoremap <buffer> <CR> "*x
endif
