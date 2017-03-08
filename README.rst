===============================================================================
boshiamy.vim
===============================================================================

介紹
-------------------------------------------------------------------------------
在 Vim 裡面輸入中文一直都是件麻煩事。

有在使用中文輸入法的人都會知道，每個中文輸入法都有兩種狀態：

* 英文
* 中文

Vim 也有兩種狀態：

* Insert mode (以及 replace 和類似的狀態)
* 非 insert mode (例如 normal mode 和 command mode 等等)

這些狀態在使用時會疊在一起，如下表：

+----------------+------+------+
| Vim \ 輸入法   | 英文 | 中文 |
+----------------+------+------+
| Insert Mode    | :)   | :)   |
+----------------+------+------+
| 非 Insert Mode | :)   | :(   |
+----------------+------+------+

這四種狀況中，中文 + 非 insert mode 非常討厭，按下的按鍵是中文的字根，
會被輸入法攔截下來，不會直接進入 Vim。

如果能把這個狀況去除，就可以避免
「需要不斷的按下 ``shift`` 或是 ``ctrl`` + ``space`` 」
（在 macOS 上也許是 ``⌘`` + ``space`` ）的狀況。
要達到這個目標，最好的方式就是在 Vim 中嵌入一個中文輸入法。

boshiamy.vim 透過純 VimScript 實作了一個嘸蝦米輸入法引擎，
不需要外部程式，不需要網路，
安裝以後就能馬上開始使用。


安裝
-------------------------------------------------------------------------------
boshiamy.vim 可以使用
`Vundle <https://github.com/gmarik/Vundle.vim>`_
或是 `vim-plug <https://github.com/junegunn/vim-plug>`_
安裝，請參考它們的安裝教學。

在某些環境下，你可能沒有辦法使用 plugin manager，
此時仍然可以手動安裝，以下以 Windows 7 gVim 7.3 作為範例。

把這個 repository 裡的檔案按照以下目錄結構放好： ::

  ~/vimfiles
  ├── LICENSE.txt
  ├── README.rst
  ├── autoload/
  │   ├── boshiamy/
  │   │   ├── boshiamy.vim
  │   │   ├── braille.vim
  │   │   ├── chewing.vim
  │   │   ├── emoji.vim
  │   │   ├── html.vim
  │   │   ├── kana.vim
  │   │   ├── runes.vim
  │   │   ├── unicode.vim
  │   │   └── wide.vim
  │   └── boshiamy.vim
  └── plugin/
      └── boshiamy.vim

重新開啟 gVim，就可以開始使用 boshiamy.vim。

每個檔案請用 UTF-8 編碼儲存。

**== 注意，手動安裝 plugin 時，請確定你知道自己在做什麼。 ==**

**== 請別把自己的設定檔覆蓋/刪除，必要時記得備份。 ==**

boshiamy.vim 在以下環境測試過：

* Vim 7.4 / Mac OS X
* Vim 8.0 / macOS Sierra
* Vim 7.4 / FreeBSD
* Vim 8.0 / FreeBSD
* gVim 7.3 / Windows 7


相關前作
-------------------------------------------------------------------------------
個人是嘸蝦米的使用者，但目前能力不足，不便購買行易公司的嘸蝦米輸入法，
所以先尋找前人的作品。

* `VimIM <http://www.vim.org/scripts/script.php?script_id=2506>`_

  - 據說很強大的中文輸入法
  - 支援相當多的中文輸入法 (包含數種雲端輸入法)

* `boshiamy-cue <http://www.vim.org/scripts/script.php?script_id=4392>`_

  - 感覺很輕量，但很老舊的 Plugin

* `vim-boshiamy <https://github.com/dm4/vim-boshiamy>`_

  - 從 VimIM 0.9.9.9.6 fork 出來，並為嘸蝦米做了調整

VimIM 的功能非常強大，但個人覺得強大的軟體就會很肥大，所以沒有嘗試。
我希望找到一個剛好符合需求，不要有太多彩蛋或不必要功能的軟體。

boshiamy-cue 則是年代久遠，在 2013 年初發佈第一個版本後就沒有再更新，
也因此這個 Plugin 並沒有考慮 Pathogen/Vundle。
此外嘸蝦米還是需要選字的，而 boshiamy-cue 沒有提供這個功能。

vim-boshiamy 是暫時的 work around，2012 年中釋出後就沒有再更新。


使用
-------------------------------------------------------------------------------
* ``boshiamy#mode()`` 函式回傳輸入法當前的狀態，你可以在自己的 statusline 中顯示這個資訊： ::

    set statusline=%<%{boshiamy#mode()}%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P

  - 這行 statusline 看起來會像 ``[嘸]README.rst [+]      75,67-59  53%``

* 切換輸入法/英文： ::

    let g:boshiamy_toggle_english = ',,'

  - 在英文與目前選定的輸入模式之間切換
  - 如果目前的模式是日文，用 ``,,`` 切換回英文再切換回來仍會是日文

* 在不同輸入模式之間切換： ::

    let g:boshiamy_select_mode = ',m'

* 取消輸入，回復為輸入前的字串： ::

    let g:boshiamy_cancel_input = '<C-h>'

  - 有些英文單字如 ``are`` 是某些字的字根，如果開著中文模式輸入英文，會讓這些英文單字變成中文，此時按下 ``<C-h>`` 就可以把字打回英文，並在後方加上一個空白字元

* 按下空白鍵送字
* 各種輸入模式

  - 中文 ``[嘸]``

    + 可直接輸入嘸蝦米
    + 輸入 ``;`` 後可直接以注音輸入（有些字真的臨時忘了怎麼寫）

      * 輸入 ``;hk4`` ，按下空白鍵送字以後會跳出 ``測`` 的同音字選單

    + 輸入 ``\u`` 後可使用 Unicode Code Point 輸入 Unicode 字元
    + ``\u[字]`` 可把 ``字`` 解碼為 ``\u5b57`` 或是 ``&#23383;``

  - 日文假名 ``[あ]``

    + 平假名、片假名、促音（加上一個 ``v`` ）
    + 範例

      * ``a`` -> ``あ``
      * ``a.`` -> ``ア``
      * ``a.v`` -> ``ァ``
      * ``av.`` -> ``ァ``
      * ``buiaiemu`` -> ``ぶいあいえむ``
      * ``bu.i.a.i.e.mu.`` -> ``ブイアイエム``

* 自訂字根表

  - 使用者可以自訂字根表，這個字根表的優先度比內建的表格高，使用者可以用來新增甚至修改組字規則
  - 自訂字根表的檔名： ::

      let g:boshiamy_custom_table = '~/.boshiamy.table'

    + 此全城變數 *沒有* 預設值，請在需要使用時再設定

  - 自訂字根表格式為 ``字串 字根 字根 ...`` ，中間以空白字元分隔： ::

      (((°Д°;))  ,face
      (ಥ_ಥ)      ,face
      ಠ_ಠ        ,face ,stare
      ఠ_ఠ        ,face ,stare
      (ゝω・)    ,face
      (〃∀〃)    ,face
      (¦3[▓▓]    ,face ,sleep
      (눈‸눈)    ,face
      ㅍ_ㅍ      ,face

    + 先後順序和選字選單的順序相同

* 載入第三方套件（後述）::

    let g:boshiamy_plugins = ['emoji', 'runes']

詳細的文件請參考 ``:help boshiamy`` ，或是 ``doc/boshiamy.txt``


對嘸蝦米字表的改動
-------------------------------------------------------------------------------
為了方便，我自己更改了嘸蝦米的字表，新增/刪除了一些項目，此處不細述，只大概列出一些比較重要的改動。

* 全型格線的輸入都使用 ``,g`` 開頭，接上形狀： ``t`` / ``l`` / ``i`` / ``c``

  - ``,gt`` -> ``┬`` （其他方向的符號在選單中會列出）
  - ``,gl`` -> ``┌``
  - ``,gi`` -> ``─``
  - ``,gc`` -> ``╭``
  - 重覆形狀可以輸入雙線的格線符號，最多三次

    + ``,gttt`` -> ``╦``

* 嘸蝦米模式中的日文片假名、平假名被我刪除，否則 ``u，`` 會無法正常輸入
* 新增 Mac OS X 相關的特殊符號

  - ``,cmd`` / ``,command`` -> ``⌘``
  - ``,shift`` -> ``⇧``
  - ``,option`` / ``,alt`` -> ``⌥``


第三方套件
-------------------------------------------------------------------------------
boshiamy.vim 能夠載入第三方套件，以擴充自己的輸入能力。

目前已經有的套件有：

* `boshiamy-emoji <https://github.com/pi314/boshiamy-emoji>`_ - 輸入 emoji 符號
* `boshiamy-runes <https://github.com/pi314/boshiamy-runes>`_ - 輸入盧恩字母
* `boshiamy-wide <https://github.com/pi314/boshiamy-wide>`_ - 輸入全型字
* `boshiamy-braille <https://github.com/pi314/boshiamy-braille>`_ - 輸入點字

這些套件原本都是 boshiamy.vim 的一部份，現在拔出核心，更加彈性。

要注意 boshiamy.vim 本身並不管理套件，請手動安裝，或是透過
`Vundle <https://github.com/gmarik/Vundle.vim>`_ 、
`vim-plug <https://github.com/junegunn/vim-plug>`_ 等套件管理系統安裝。

第三方套件的開發請參考 ``:help boshiamy-plugins``
或是 ``doc/boshiamy-plugins.txt``


授權
-------------------------------------------------------------------------------
本軟體使用 WTFPL version 2 發佈，請參考 LICENSE.txt

--------

2017/03/08 pi314 @ HsinChu
