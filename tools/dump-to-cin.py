from os.path import abspath, dirname, join
import os


TOOL_FOLDER = dirname(abspath(__file__))
TABLE_FOLDER = join(dirname(dirname(abspath(__file__))), 'autoload', 'boshiamy')


def readfile(filename, prefix):
    table = {}
    with open(join(TABLE_FOLDER, filename)) as f:
        for line in f:
            if not line.startswith(prefix):
                continue

            line = line.replace(prefix, 'table')
            c = compile(line, '<stdin>', 'single')
            exec(c)

    return table


def main():
    liu_table = readfile('boshiamy.vim', 'let g:boshiamy#boshiamy#table')
    chewing_table = readfile('chewing.vim', 'let g:boshiamy#chewing#table')
    assert '測' in liu_table['wmbr']
    assert '測' in chewing_table[';hk4']
    liu_table.update(chewing_table)

    for line in ["%gen_inp",
        "%ename liu57",
        "%cname 嘸蝦米",
        "%encoding UTF-8",
        "%selkey 0123456789",
        "%keyname begin",
        "a Ａ",
        "b Ｂ",
        "c Ｃ",
        "d Ｄ",
        "e Ｅ",
        "f Ｆ",
        "g Ｇ",
        "h Ｈ",
        "i Ｉ",
        "j Ｊ",
        "k Ｋ",
        "l Ｌ",
        "m Ｍ",
        "n Ｎ",
        "o Ｏ",
        "p Ｐ",
        "q Ｑ",
        "r Ｒ",
        "s Ｓ",
        "t Ｔ",
        "u Ｕ",
        "v Ｖ",
        "w Ｗ",
        "x Ｘ",
        "y Ｙ",
        "z Ｚ",
        ", ，",
        ". ．",
        "' ’",
        "[ 〔",
        "] 〔",
        "%keyname end",
        "%chardef begin",]:
        print(line)

    for key in sorted(liu_table.keys()):
        for char in liu_table[key]:
            if char not in ('　', '	'):
                print(key, char)

    print("%chardef end")

main()
