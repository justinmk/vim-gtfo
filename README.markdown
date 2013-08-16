# gtfo.vim

Opens the directory of the *current buffer* in the [file manager](http://en.wikipedia.org/wiki/File_manager#Examples) 
or a [terminal](http://en.wikipedia.org/wiki/Terminal_emulator). Also provides 
a variant for opening the *current directory* (see `:help :cd` to understand the 
difference).

This simple feature is missing or half-baked in many IDEs and editors:
* missing in Eclipse [since 2005](https://bugs.eclipse.org/bugs/show_bug.cgi?id=107436)
* clunky in Visual Studio
* Intellij requires a plugin (oh the irony!)

We can make it painless in Vim, I hope.
* *Just works™* on Windows, OS X, Linux, and [tmux](http://tmux.sourceforge.net/)
* Supports vim and gvim, GUI or no GUI
* Sane defaults: **no configuration**
* Does not override existing bindings (try `:verbose map gof | map got`)

This plugin doesn't care what your `&shell` is. And `ctrl-z` doesn't care 
about Vim's current directory or buffer.

## Features

**Normal-mode key bindings:**
* `gof`: **Go** to the current buffer's directory in the **F**ile manager 
    * *Windows:* opens Windows Explorer
    * *Mac OS X:* opens Finder
    * *Linux:* defers to [`xdg-open`](http://portland.freedesktop.org/xdg-utils-1.0/xdg-open.html)
    * falls back to `got` if you're not in a GUI (eg, ssh)
* `got`: **Go** to the current buffer's directory in the **T**erminal
    * *Windows:* opens cygwin (tries to find Git bash (msysgit), otherwise falls back to "vanilla" cygwin)
    * *Mac OS X:* opens Terminal
    * *Linux:* opens `gnome-terminal`
        * Send an issue or pull request if you want support for a different terminal
    * *tmux:* opens a new pane
* `goo`: (todo) **Go** to the current buffer's directory in some **O**ther terminal
* `goF`: (todo) like `gof`, but opens the *current directory* instead of the *buffer directory*
* `goT`: (todo) like `got`, but opens the *current directory*
* `goO`: (todo) like `goo`, but opens the *current directory*

## Installation

Same installation as most Vim plugins, or use a package manager:

* [vundle](https://github.com/gmarik/vundle)
* [neobundle](https://github.com/Shougo/neobundle.vim)
* [pathogen.vim](https://github.com/tpope/vim-pathogen):
  `cd ~/.vim/bundle && git clone git://github.com/justinmk/vim-gtfo.git`

## Credits

* Sangmin Ryu, [open-terminal-filemanager](http://www.vim.org/scripts/script.php?script_id=2896)
* @tpope, for impeccable Vim plugin reference implementations

## TODO

* Powershell
* goT, goF, goO
* linux GUI detection probably sends a false positive when ssh-ing from a GUI
* provide vim commands (GtfoTerminal, GtfoFileman, GtfoOther)
* if [vimux](https://github.com/benmills/vimux) is available, use that instead
* iTerm?

## License

Copyright © Justin M. Keyes. Distributed under the same terms as Vim itself.
See `:help license`.

