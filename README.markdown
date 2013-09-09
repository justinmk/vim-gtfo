# gtfo.vim

Opens the directory of the *current buffer* in the [file manager](http://en.wikipedia.org/wiki/File_manager#Examples) 
or the [terminal](http://en.wikipedia.org/wiki/Terminal_emulator). **No configuration.**
Just works™ in [tmux](http://tmux.sourceforge.net/), cygwin/mintty, msysgit, 
Windows, OS X, and Linux. Supports vim and gvim, GUI or no GUI (tty console, ssh).

## Features

**Normal-mode key bindings: got, gof, goo**
* Existing bindings will not be overridden (try `:verbose map gof | map got`)
* `gof`: **Go** to the current buffer's directory in the **F**ile manager 
    * *Windows:* opens Windows Explorer
    * *Mac OS X:* opens Finder
    * *Linux:* defers to [`xdg-open`](http://portland.freedesktop.org/xdg-utils-1.0/xdg-open.html)
* `got`: **Go** to the current buffer's directory in the **T**erminal
    * *Windows:* opens "Git bash" ([msysgit](http://msysgit.github.io/))
        * else, falls back to ["vanilla" Cygwin](http://www.cygwin.org)
        * else, falls back to `%COMSPEC%` (cmd.exe)
    * *Cygwin (mintty):* opens a new mintty console
    * *Mac OS X:* opens Terminal *unless* Vim is running in iTerm
    * *Linux:* opens `gnome-terminal`
    * *tmux:* opens a new pane
* `goo`: **Go** to the current buffer's directory in some **O**ther terminal
    * *Windows:* opens Powershell
    * *Mac OS X:* opens iTerm
    * *Linux:* [todo]
* `goF`: [todo] like `gof`, but opens the *current directory* instead of the *buffer directory*
* `goT`: [todo] like `got`, but opens the *current directory*
* `goO`: [todo] like `goo`, but opens the *current directory*

**Settings**

* `g:gtfo_cygwin_bash` : absolute path to bash executable 
  (example: `'C:\cygwin\bin\bash'`)

## Installation

Same installation as most Vim plugins, or use a package manager:

* [vundle](https://github.com/gmarik/vundle)
* [neobundle](https://github.com/Shougo/neobundle.vim)
* [pathogen.vim](https://github.com/tpope/vim-pathogen):
  `cd ~/.vim/bundle && git clone git://github.com/justinmk/vim-gtfo.git`

## FAQ

> On Linux without a gui, 'gof' does nothing, or launches w3m. Why?
* `xdg-open` works without a GUI (ssh or tty console), but its default might 
  not be what you want. Try: `xdg-mime default application/x-directory foo`

## Credits

* Sangmin Ryu, [open-terminal-filemanager](http://www.vim.org/scripts/script.php?script_id=2896)
* @tpope, for impeccable Vim plugin reference implementations
* [EasyShell](http://marketplace.eclipse.org/node/974#.Ui1kc2R273E)

## Todo

* look for [posh](https://github.com/dahlbyk/posh-git) instead of vanilla Powershell
* look for mintty instead of cmd.exe
* support shells other than bash (zsh, fish)?
* provide vim commands (GtfoTerminal, GtfoFileman, GtfoOther)
* if [vimux](https://github.com/benmills/vimux) is available, defer to it for tmux behavior

## License

Copyright © Justin M. Keyes. Distributed under the same terms as Vim itself.
See `:help license`.

