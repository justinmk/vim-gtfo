# gtfo.vim

Opens the directory of the *current buffer* in the [file manager](http://en.wikipedia.org/wiki/File_manager#Examples) 
or the [terminal](http://en.wikipedia.org/wiki/Terminal_emulator). **No configuration.**
Just works™ on [tmux](http://tmux.sourceforge.net/), Windows, OS X, Linux. 
Supports vim and gvim, GUI or no GUI (tty console, ssh). 

Does not override existing bindings (try `:verbose map gof | map got`)

This simple feature is missing or cumbersome in many IDEs and editors:
* [missing in Eclipse](https://bugs.eclipse.org/bugs/show_bug.cgi?id=107436)
* clunky in Visual Studio
* Intellij requires a plugin (oh the irony!)
* Vim `ctrl-z` and `:shell` do not open to the buffer's directory

## Features

**Normal-mode key bindings: got, gof, goo**
* `gof`: **Go** to the current buffer's directory in the **F**ile manager 
    * *Windows:* opens Windows Explorer
    * *Mac OS X:* opens Finder
    * *Linux:* defers to [`xdg-open`](http://portland.freedesktop.org/xdg-utils-1.0/xdg-open.html)
        * `xdg-open` also works without a GUI (ssh or tty console)
* `got`: **Go** to the current buffer's directory in the **T**erminal
    * *Windows:* opens "Git bash" ([msysgit](http://msysgit.github.io/))
        * else, falls back to ["vanilla" Cygwin](http://www.cygwin.org)
        * else, falls back to `%COMSPEC%` (cmd.exe)
    * *Mac OS X:* opens Terminal
    * *Linux:* opens `gnome-terminal`
    * *tmux:* opens a new pane
* `goo`: **Go** to the current buffer's directory in some **O**ther terminal
    * *Mac OS X:* opens iTerm
* `goF`: (todo) like `gof`, but opens the *current directory* instead of the *buffer directory*
* `goT`: (todo) like `got`, but opens the *current directory*
* `goO`: (todo) like `goo`, but opens the *current directory*

**Settings**

* `g:gtfo_cygwin_bash` : absolute path to cygwin bash executable (example: "C:\cygwin\bin\bash")

## Installation

Same installation as most Vim plugins, or use a package manager:

* [vundle](https://github.com/gmarik/vundle)
* [neobundle](https://github.com/Shougo/neobundle.vim)
* [pathogen.vim](https://github.com/tpope/vim-pathogen):
  `cd ~/.vim/bundle && git clone git://github.com/justinmk/vim-gtfo.git`

## Credits

* Sangmin Ryu, [open-terminal-filemanager](http://www.vim.org/scripts/script.php?script_id=2896)
* @tpope, for impeccable Vim plugin reference implementations

## Todo

* Powershell
* try to find mintty and use it instead of cmd.exe
* support shells other than bash (zsh, fish) if `&shell` and friends are configured correctly 
* goT, goF, goO
* provide vim commands (GtfoTerminal, GtfoFileman, GtfoOther)
* if [vimux](https://github.com/benmills/vimux) is available, defer to it for tmux behavior
* conemu?

## License

Copyright © Justin M. Keyes. Distributed under the same terms as Vim itself.
See `:help license`.

