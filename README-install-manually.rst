===============================================================================
手動安裝 ime.vim
===============================================================================
在某些環境下，你可能沒有辦法正常使用 plugin manager，
以下以 Windows 7 gVim 7.3 作為範例，介紹手動安裝 ime.vim 的方式。

把這個 repository 裡的檔案按照以下目錄結構放好： ::

  ~/vimfiles
  ├── LICENSE.txt
  ├── README.rst
  ├── autoload
  │   ├── ime
  │   │   ├── boshiamy_table.vim
  │   │   ├── builtin_boshiamy.vim
  │   │   ├── builtin_chewing.vim
  │   │   ├── builtin_kana.vim
  │   │   ├── builtin_unicode.vim
  │   │   ├── chewing_table.vim
  │   │   └── kana_table.vim
  │   └── ime.vim
  ├── doc
  │   ├── ime-plugin.txt
  │   └── ime.txt
  └── plugin
      └── ime.vim

在 ``doc/`` 目錄下執行 ``:helptags .`` ，產生 ``tags`` 檔案。

重新開啟 gVim，就可以開始使用 ime.vim。

每個檔案請用 UTF-8 編碼儲存。

**== 注意，手動安裝 plugin 時，請確定你知道自己在做什麼。 ==**

**== 請別把自己的設定檔覆蓋/刪除，必要時記得備份。 ==**


使用 vim-plug 安裝
-------------------------------------------------------------------------------
即使沒有 ``git`` / ``curl`` / ``fetch`` / ``wget`` ，
你仍然可以讓 vim-plug 幫你處理 ``runtimepath``

手動安裝好 vim-plugin 以後，把 ime.vim 和第三方套件下載下來，
解壓縮後直接放在 ``~/vimfiles/plugged/`` 即可。
