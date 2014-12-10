==========
BoshiamyIM
==========

Install
-------

BoshiamyIM 可以使用 Vundle 安裝，請參考 Vundle 的安裝教學，在 vimrc 中加上 ::

  Bundle 'pi314/BoshiamyIM'

這些是我習慣的 mappings ::

  set statusline=%<%{BoshiamyIM#Status()}%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P
  inoremap <expr> ,, BoshiamyIM#ToggleIM()
  inoremap <space> <C-R>=BoshiamyIM#SendKey()<CR>
  nnoremap <expr> <ESC><ESC> BoshiamyIM#LeaveIM()

Introduction
------------

在 vim 裡面輸入中文一直都是件麻煩事。

有需要輸入中文的人都會知道，每個中文輸入法都有兩種狀態:

* 英文
* 中文

不論你使用哪種輸入法。

vim 也有兩種狀態:

* Insert (以及 Replace 和類似的 State)
* 非 Insert (例如 Normal 和 Command 等等)

這些狀態在使用時會疊在一起，如下表:

+----------------+------+------+
| vim \ 輸入法   | 英文 | 中文 |
+----------------+------+------+
| Insert Mode    |      |      |
+----------------+------+------+
| 非 Insert Mode |      |      |
+----------------+------+------+

這四種狀況中，"中文 x 非 Insert Mode" 非常討厭，因為按下的按鍵會是中文的字根，所以會被 OS 攔截下來，不會直接進入 vim。

如果能把這個狀況去除，就可以避免 "需要不斷的按下 Shift 或是 Control+Space"。要達到這個，最好的方式就是在 Vim 中直接嵌入一個中文輸入法。

Related Work
------------

個人是嘸蝦米的使用者，但目前能力不足，不便購買行易公司的嘸蝦米輸入法，所以先尋找前人的作品。

* VimIM

  - 據說很強大的中文輸入法
  - 支援相當多的中文輸入法 (包含數種雲端輸入法)

* boshiamy-cue

  - 感覺很輕量，但很老舊的 Plugin

VimIM 的功能非常強大，但個人偏見，覺得強大的軟體就會很肥大，所以沒有嘗試。

boshiamy-cue 則是年代久遠，在 2013 年初發佈第一個版本後就沒有再更新，這個 Plugin 並不 Pathogen/Vundle Compatiable。
此外嘸蝦米還是需要選字的，boshiamy-cue 沒有提供這個功能。

Usage
-----

這個 Plugin 提供一些介面可供使用。

* BoshiamyIM#Status() 函式回傳輸入法當前的狀態，你可以在自己的 statusline 中顯示這個資訊

  - ``set statusline=%<%{BoshiamyIM#Status()}%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P``

* BoshiamyIM#ToggleIM() 用來切換輸入法/英文

  - ``inoremap <expr>  ToggleIM()``
  - 我正計畫加入其他種類的輸入法， ``Boshiamy#ToggleIM()`` 仍會在英文和這些輸入法之間做 Toggle
  - 離開 Vim 的 Insert Mode 並不會一併關閉輸入法

* BoshiamyIM#Sendkey() 用來送字

  - ``inoremap <space> <C-R>=BoshiamyIM#SendKey()<CR>``

* BoshiamyIM#LeaveIM() 用來離開輸入法

  - ``nnoremap <expr> <ESC><ESC> LeaveIM()``

空白鍵是送字，如同嘸蝦米輸入法的行為

這個輸入法是以嘸蝦米為主體，但我也加入了注音輸入的功能 (有些字真的臨時忘了怎麼寫)。
在輸入時前面加上 ``;`` ，就可以輸入注音，例如 ``;hk4`` ，按下空白鍵送字以後會跳出 ``測`` 的同音字選單。

以後會漸漸加上其他的輸入模式，例如專門輸入注音符號的模式、假名輸入，或是 Unicode 輸入等等。

2014/12/10 pi314 @ nctu
