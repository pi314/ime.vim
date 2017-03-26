===============================================================================
ime.vim
===============================================================================

`這份文件的中文版。 <README.rst>`_

Introduction
-------------------------------------------------------------------------------
It's always a trouble to input Chinese characters in Vim.

Everyone who uses Chinese Input Method knows that they have two states:

- English mode
- Chinese mode

Vim has two states, too:

- Insert mode (and similar modes)
- Non-insert mode (like normal mode or command mode)

So we have four combinations:

+--------------------+---------+---------+
| Vim \ Input method | English | Chinese |
+--------------------+---------+---------+
| Insert mode        | :)      | :)      |
+--------------------+---------+---------+
| Non-insert mode    | :)      | :(      |
+--------------------+---------+---------+

The "Chinese / Non-insert mode" is very troublesome,
your keyboard input will be intercepted
by the input method and will not go into Vim.

If we can get rid of this situation, we can avoid keep hitting
``shift`` or ``ctrl`` + ``space`` to close input method
(``⌘`` + ``space`` on macOS).
And the best way to do this is to embedded an input method in Vim.

ime.vim implements a Input Method Engine in pure VimScript.
Not depends on external programs, not depends on network.
After installing it, you can use it right the way.


Installation
-------------------------------------------------------------------------------
ime.vim can be installed with
`Vundle <https://github.com/gmarik/Vundle.vim>`_
or `vim-plug <https://github.com/junegunn/vim-plug>`_.
Please refer to their installation tutorial

Under some environment, plugin managers may not operate normally
(e.g. Windows 7 without any of ``git``, ``curl``, ``fetch``, ``wget`` installed).
You can still `install it manually <README-install-manually.en.rst>`_.

ime.vim is tested under these environments:

* Vim 7.4 / Mac OS X
* Vim 8.0 / macOS Sierra
* Vim 7.4 / FreeBSD
* Vim 8.0 / FreeBSD
* gVim 7.3 / Windows 7


Related works
-------------------------------------------------------------------------------
I'm a 嘸蝦米 input method user, but currently I'm unable to buy one,
so I do a little survey first:

* `VimIM <http://www.vim.org/scripts/script.php?script_id=2506>`_

  - It's said that it is very powerful
  - It supports many kind of Chinese input methods (including cloud input methods)

* `boshiamy-cue <http://www.vim.org/scripts/script.php?script_id=4392>`_

  - Light weight, but old

* `vim-boshiamy <https://github.com/dm4/vim-boshiamy>`_

  - Fork from VimIM 0.9.9.9.6 and adjusted for 嘸蝦米

VimIM is powerful, but I have a biased view that "powerful software is fat",
so I haven't try it.
I want a software that just fit my need.

boshiamy-cue is very old, and it doesn't update since first version in early 2013.
This plugin doesn't consider Pathogen and Vundle.
Besides, 嘸蝦米 still needs word-choosing,
which is a feature that boshiamy-cue unable to provide.

vim-boshiamy is a temporary workaround, it doesn't update since middle 2012.


Usage
-------------------------------------------------------------------------------
* ``ime#mode()`` returns the current status of ime.vim, you can show this
  information in your ``statusline`` ::

    set statusline=%<%{ime#mode()}%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P

  - This statusline looks like ``[嘸]README.rst [+]      75,67-59  53%``

* Toggle English ::

    let g:ime_toggle_english = ',,'

  - 在英文與目前選定的輸入模式之間切換
  - 如果目前的模式是日文，用 ``,,`` 切換回英文再切換回來仍會是日文

* 在不同輸入模式之間切換： ::

    let g:ime_select_mode = ',m'

* 取消輸入，回復為輸入前的字串： ::

    let g:ime_cancel_input = '<C-h>'

  - 有些英文單字如 ``are`` 是某些字的字根，如果開著中文模式輸入英文，會讓這些英文單字變成中文，此時按下 ``<C-h>`` 就可以把字打回英文，並在後方加上一個空白字元

* 按下空白鍵送字
* 內建輸入模式

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

    let g:ime_plugins = ['emoji', 'runes']

詳細的文件請參考 ``:help ime.vim`` ，或是 ``doc/ime.txt``


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
ime.vim 能夠載入第三方套件，以擴充自己的輸入能力。

目前已經有的套件有：

* `ime-emoji.vim <https://github.com/pi314/ime-emoji.vim>`_ - 輸入 emoji 符號
* `ime-runes.vim <https://github.com/pi314/ime-runes.vim>`_ - 輸入盧恩字母
* `ime-wide.vim <https://github.com/pi314/ime-wide.vim>`_ - 輸入全型字
* `ime-braille.vim <https://github.com/pi314/ime-braille.vim>`_ - 輸入點字

這些套件原本都是 ime.vim 的一部份，現在拔出核心，更加彈性。

要注意 ime.vim 本身並不管理套件，請手動安裝，或是透過
`Vundle <https://github.com/gmarik/Vundle.vim>`_ 、
`vim-plug <https://github.com/junegunn/vim-plug>`_ 等套件管理系統安裝。

第三方套件的開發請參考 ``:help ime-plugins``
或是 ``doc/ime-plugins.txt``


可以配合 vim 使用的技巧
-------------------------------------------------------------------------------
在取代模式中，一個字元只會覆蓋一個字元，無論寬度。

在繪製 ASCII 圖片時，如果用中文字去覆蓋空白字元，會讓那行變得越來越長，
因為一個兩格寬的中文字卻只覆蓋了一個空白字元。

此時 vim 內建的 ``gR`` 變得很有用，它可以根據字元的寬度覆蓋字元。


授權
-------------------------------------------------------------------------------
本軟體使用 WTFPL version 2 發佈，請參考 LICENSE.txt

--------

2017/03/22 pi314 @ HsinChu
