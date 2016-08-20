echom "Loading runes table..."
let boshiamy#runes#table = {}
let boshiamy#runes#table[','] = ['ᛮ', 'ᛯ', 'ᛰ']
let boshiamy#runes#table['.'] = ['᛫', '᛬', '᛭']
let boshiamy#runes#table['a'] = ['ᚨ', 'ᚪ', 'ᛅ', 'ᛆ']
let boshiamy#runes#table['ae'] = ['ᚫ']
let boshiamy#runes#table['b'] = ['ᛒ', 'ᛓ']
let boshiamy#runes#table['c'] = ['ᚳ', 'ᛍ', 'ᛢ', 'ᛣ', 'ᛤ']
let boshiamy#runes#table['d'] = ['ᛞ', 'ᛑ']
let boshiamy#runes#table['e'] = ['ᛖ', 'ᛂ']
let boshiamy#runes#table['ea'] = ['ᛠ']
let boshiamy#runes#table['eng'] = ['ᛜ', 'ᛝ']
let boshiamy#runes#table['f'] = ['ᚠ']
let boshiamy#runes#table['g'] = ['ᚴ', 'ᚷ', 'ᚸ', 'ᚵ', 'ᚶ']
let boshiamy#runes#table['h'] = ['ᚺ', 'ᚻ', 'ᚼ', 'ᚽ']
let boshiamy#runes#table['i'] = ['ᛁ', 'ᛇ']
let boshiamy#runes#table['io'] = ['ᛡ']
let boshiamy#runes#table['j'] = ['ᛃ', 'ᛄ']
let boshiamy#runes#table['k'] = ['ᚲ', 'ᚴ']
let boshiamy#runes#table['l'] = ['ᛚ', 'ᛛ']
let boshiamy#runes#table['m'] = ['ᛗ', 'ᛘ', 'ᛙ']
let boshiamy#runes#table['n'] = ['ᚾ', 'ᚿ', 'ᛀ']
let boshiamy#runes#table['o'] = ['ᚩ', 'ᚬ', 'ᚭ', 'ᚮ', 'ᚯ', 'ᛟ']
let boshiamy#runes#table['on'] = ['ᚰ']
let boshiamy#runes#table['p'] = ['ᛈ', 'ᛔ', 'ᛕ']
let boshiamy#runes#table['q'] = ['ᛩ']
let boshiamy#runes#table['r'] = ['ᚱ', 'ᛦ', 'ᛧ', 'ᛨ']
let boshiamy#runes#table['s'] = ['ᛊ', 'ᛋ', 'ᛌ', 'ᛥ']
let boshiamy#runes#table['t'] = ['ᛏ', 'ᛐ']
let boshiamy#runes#table['th'] = ['ᚦ', 'ᚧ']
let boshiamy#runes#table['u'] = ['ᚢ']
let boshiamy#runes#table['v'] = ['ᚡ']
let boshiamy#runes#table['w'] = ['ᚥ', 'ᚹ']
let boshiamy#runes#table['x'] = ['ᛉ', 'ᛪ']
let boshiamy#runes#table['y'] = ['ᚣ', 'ᚤ']
let boshiamy#runes#table['z'] = ['ᛉ', 'ᛎ']
echom "Done"

function! boshiamy#runes#handler (line, runes_str)
    if strlen(a:runes_str) == 0
        return ' '
    endif

    let l:idx = strlen(a:line) - strlen(a:runes_str)
    let l:col  = l:idx + 1

    if has_key(g:boshiamy#runes#table, a:runes_str)
        call complete(l:col, g:boshiamy#runes#table[ (a:runes_str) ])
        return ''
    endif

    let ret_runes = ''
    let i = 0
    let j = 2
    while l:i <= l:j
        let t = a:runes_str[ (l:i) : (l:j) ]
        echom l:t

        if has_key(g:boshiamy#runes#table, l:t)
            let ret_runes = l:ret_runes . g:boshiamy#runes#table[(l:t)][0]
            let i = l:j + 1
            let j = l:i + 2
        else
            let j = l:j - 1
        endif

    endwhile
    let remain = a:runes_str[(l:j + 1) : ]

    call complete(l:col, [l:ret_runes . l:remain] )
    return ''
endfunction
