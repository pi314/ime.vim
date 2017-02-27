============
boshiamy.vim
============

安裝
-----
boshiamy.vim 可以使用 `Vundle <https://github.com/gmarik/Vundle.vim>`_ 或是 `vim-plug <https://github.com/junegunn/vim-plug>`_ 安裝，請參考它們的安裝教學。

在某些環境下，你可能沒有辦法使用 plugin manager，此時仍然可以手動安裝，以下以 Windows 7 gVim 作為範例。

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

**== 注意，手動安裝 plugin 時，請確定你知道自己在做什麼，避免把自己的設定檔覆蓋/刪除，必要時記得備份 ==**

本 Plugin 在以下環境測試過：

* Vim 7.4 / Mac OS X
* Vim 8.0 / macOS Sierra
* Vim 7.4 / FreeBSD
* Vim 8.0 / FreeBSD
* gVim 7.3 / Windows 7


介紹
-----
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

這四種狀況中，中文 + 非 insert mode 非常討厭，按下的按鍵是中文的字根，會被輸入法攔截下來，不會直接進入 Vim。

如果能把這個狀況去除，就可以避免 "需要不斷的按下 shift 或是 control + space" 的狀況。要達到這個目標，最好的方式就是在 Vim 中嵌入一個中文輸入法。


相關前作
---------
個人是嘸蝦米的使用者，但目前能力不足，不便購買行易公司的嘸蝦米輸入法，所以先尋找前人的作品。

* `VimIM <http://www.vim.org/scripts/script.php?script_id=2506>`_

  - 據說很強大的中文輸入法
  - 支援相當多的中文輸入法 (包含數種雲端輸入法)

* `boshiamy-cue <http://www.vim.org/scripts/script.php?script_id=4392>`_

  - 感覺很輕量，但很老舊的 Plugin

VimIM 的功能非常強大，但個人覺得強大的軟體就會很肥大，所以沒有嘗試。我希望找到一個剛好符合需求，不要有太多彩蛋或不必要功能的軟體。

boshiamy-cue 則是年代久遠，在 2013 年初發佈第一個版本後就沒有再更新，也因此這個 Plugin 並沒有考慮 Pathogen/Vundle。此外嘸蝦米還是需要選字的，而 boshiamy-cue 沒有提供這個功能。


使用
-----
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
    + 輸入 ``&#28204;`` 或 ``&#x6e2c;`` 可轉換為 ``測``
    + 輸入 ``:pudding:`` 可產生 ``🍮`` 字元

      * 輸入 ``:pu`` 可用選單選擇相同開頭的 emoji 字串

  - 日文假名 ``[あ]``

    + 平假名可以直接用羅馬拼音輸入
    + 片假名需在字根後加上一個 ``.``
    + 下標字需在字根後加上一個 ``v``
    + 範例

      * ``a`` -> ``あ``
      * ``a.`` -> ``ア``
      * ``a.v`` -> ``ァ``
      * ``av.`` -> ``ァ``
      * ``buiaiemu`` -> ``ぶいあいえむ``
      * ``bu.i.a.i.e.mu.`` -> ``ブイアイエム``

  - 全型字 ``[Ａ]``

    + 按下空白鍵送字會把前面連續的半型字元都換成全型字元
    + 全型空白請在嘸蝦米模式下用 ``,space`` 輸入

  - 盧恩字母 ``[ᚱ]``
  - 點字 ``[⢝]`` ::

      let g:boshiamy_braille_keys = '7uj8ikm,'

    + ``7uj8ikm,`` 分別為點字的 ``12345678`` ，請參考 https://en.wikipedia.org/wiki/Braille_Patterns

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


對嘸蝦米字表的改動
-------------------
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


授權
-----
本軟體使用 WTFPL version 2 發佈，請參考 LICENSE.txt

----

2017/02/27 pi314 @ HsinChu
