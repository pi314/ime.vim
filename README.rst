==================
pi314.boshiamy.vim
==================

安裝
----

pi314.boshiamy.vim 可以使用 Vundle_ 安裝，請參考 Vundle_ 的安裝教學，在你的 ``~/.vim/vimrc`` 中加上 ::

  Bundle 'pi314/pi314.boshiamy.vim'

並在 Vim 裡面執行 ``:PluginInstall``

..  _Vundle: https://github.com/gmarik/Vundle.vim

這些是我習慣的設定，放在 ``~/.vim/vimrc`` 中 ::

  set statusline=%<%{boshiamy#status()}%{VimTableModeStatusString()}%f\ %h%m%r%=%y\ %-14.(%l,%c%V%)\ %P
  inoremap <expr>  boshiamy#toggle()
  inoremap <space> <C-R>=boshiamy#send_key()<CR>
  nnoremap <expr> <ESC><ESC> boshiamy#leave()

介紹
----

在 Vim 裡面輸入中文一直都是件麻煩事。

有在使用中文輸入法的人都會知道，每個中文輸入法都有兩種狀態:

* 英文
* 中文

Vim 也有兩種狀態:

* Insert Mode (以及 Replace 和類似的狀態)
* 非 Insert Mode (例如 Normal Mode 和 Command Mode 等等)

這些狀態在使用時會疊在一起，如下表:

+----------------+------+------+
| Vim \ 輸入法   | 英文 | 中文 |
+----------------+------+------+
| Insert Mode    |      |      |
+----------------+------+------+
| 非 Insert Mode |      |      |
+----------------+------+------+

這四種狀況中，中文 + 非 Insert Mode 非常討厭，按下的按鍵是中文的字根，會被輸入法攔截下來，不會直接進入 Vim。

如果能把這個狀況去除，就可以避免 "需要不斷的按下 Shift 或是 Control+Space" 的狀況。要達到這個目標，最好的方式就是在 Vim 中嵌入一個中文輸入法。

相關前作
--------

個人是嘸蝦米的使用者，但目前能力不足，不便購買行易公司的嘸蝦米輸入法，所以先尋找前人的作品。

* VimIM

  - 據說很強大的中文輸入法
  - 支援相當多的中文輸入法 (包含數種雲端輸入法)

* boshiamy-cue

  - 感覺很輕量，但很老舊的 Plugin

VimIM 的功能非常強大，但個人覺得強大的軟體就會很肥大，所以沒有嘗試。我希望找到一個剛好符合需求，不要有太多彩蛋或不必要功能的軟體。

boshiamy-cue 則是年代久遠，在 2013 年初發佈第一個版本後就沒有再更新，也因此這個 Plugin 並沒有考慮 Pathogen/Vundle。此外嘸蝦米還是需要選字的，而 boshiamy-cue 沒有提供這個功能。

使用
----

本 Plugin 提供一些介面可供使用。

* ``boshiamy#status()`` 函式回傳輸入法當前的狀態，你可以在自己的 statusline 中顯示這個資訊 ::

    set statusline=%<%{boshiamy#status()}%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P

  - 這行 statusline 看起來會像 ``[嘸]README.rst [+]      75,67-59  53%``

* ``boshiamy#toggle()`` 切換輸入法/英文 ::

    inoremap <expr> ,, boshiamy#toggle()

  - 我正計畫加入其他種類的輸入法， ``boshiamy#toggle()`` 會在英文和這些輸入法之間做切換
  - 離開 Vim 的 Insert Mode 會將輸入法的狀態保留，下次進入 Insert Mode 後不會被還原回預設的模式

* ``boshiamy#send_key()`` 送字 ::

    inoremap <space> <C-R>=boshiamy#send_key()<CR>

* ``boshiamy#leave()`` 離開輸入法 ::

    nnoremap <expr> <ESC><ESC> boshiamy#leave()

* ``g:boshiamy_cancel_key`` 指定 "取消輸入" 的按鍵 ::

    let g:boshiamy_cancel_key = '<C-h>'
    let g:boshiamy_cancel_key = ['<C-h>', '<F1>']

  - 有些英文單字如 ``user`` 是某些字的字根，如果開著中文模式輸入英文，會讓這些英文單字變成中文，此時按下 ``<C-h>`` 就可以把字打回英文，並在後方加上一個空白字元

* 目前這個 Plugin 提供一些輸入模式

  - 中文

    + 可直接輸入嘸蝦米
    + 輸入 ``;`` 後可直接以注音輸入
    + 輸入 ``\u`` 後可使用 Unicode Code Point 輸入 Unicode 字元
    + ``\u[字]`` 可把 ``字`` 解碼為 ``\u5b57`` 或是 ``&#23383;``
    + 輸入 ``&#28204;`` 或 ``&#x6e2c;`` 可轉換為 ``測``

  - 日文假名
  - 全型字
  - 盧恩字母

* 在不同輸入模式之間切換

  - 在中文模式下，輸入一特定字串後按下空白鍵送字，可以在不同輸入模式之間切換

    + 切換為嘸蝦米的預設值為 ::

        let g:boshiamy_switch_boshiamy = ',t,'
        let g:boshiamy_switch_boshiamy = [',t,']

    + 切換為日文假名的預設值為 ::

        let g:boshiamy_switch_kana = [',j,']

      * 平假名可以直接用羅馬拼音輸入
      * 片假名需在字根後加上一個 ``.``
      * 下標字需在字根後加上一個 ``v``
      * 範例

        - ``a`` -> ``あ``
        - ``a.`` -> ``ア``
        - ``a.v`` -> ``ァ``
        - ``av.`` -> ``ァ``
        - ``buiaiemu`` -> ``ぶいあいえむ``
        - ``buiaiemu`` -> ``ぶいあいえむ``

    + 切換為全型字的預設值為 ::

        let g:boshiamy_switch_wide = ',w,'

      * 之後按下空白鍵送字，會把前面連續的半型字元都換成全型字元
      * 全型空白請在嘸蝦米模式下用 ``,space`` 輸入

    + 切換為盧恩字母的預設值為 ::

        let g:boshiamy_switch_rune = ',r,'

    + 若需要自行設定，請注意不要包含 ``boshiamy#toggle()`` 的按鍵序列，因為 ``imap`` 的效果比較優先

空白鍵是送字，如同嘸蝦米輸入法的行為

這個輸入法是以嘸蝦米為主體，但我也加入了注音輸入的功能（有些字真的臨時忘了怎麼寫）：
在輸入時前面加上 ``;`` ，就可以輸入注音，例如 ``;hk4`` ，按下空白鍵送字以後會跳出 ``測`` 的同音字選單。

對嘸蝦米字表的改動
------------------

為了方便，我自己更改了嘸蝦米的字表，新增/刪除了一些項目，此處不細述，只大概列出一些比較重要的改動

* 全型格線的輸入都使用 ``,g`` 開頭，接上形狀： ``t`` / ``l`` / ``i`` / ``c``

  - ``,gt`` -> ``┬`` （其他方向的符號在選單中會列出）
  - ``,gl`` -> ``┌``
  - ``,gi`` -> ``─``
  - ``,gc`` -> ``╭``
  - 雙線的格線符號就把形狀重覆，最多三次

    + ``,gttt`` -> ``╦``

* 嘸蝦米模式中的日文片假名、平假名被我刪除，否則 ``u，`` 會無法正常輸入
* 新增 Mac OS X 相關的特殊符號

  - ``,cmd`` / ``,command`` -> ``⌘``
  - ``,shift`` -> ``⇧``
  - ``,option`` / ``,alt`` -> ``⌥``

其他
----

這個軟體是為 Console Vim 設計的，沒有考慮 gVim，已知在 Windows 上的 gVim 會有嘸蝦米字表編碼的問題。

我在 Windows 上只用 Cygwin 裡的 Vim，所以不會去處理 gVim 的問題。

授權
----

本軟體使用 WTFPL Version 2 發佈，請參考 LICENSE.txt

----

2015/05/19 pi314 (cychih) @ nctu

