# gtfo.vim

Open the directory of the *current buffer* in the [file manager](http://en.wikipedia.org/wiki/File_manager#Examples) 
or a [terminal](http://en.wikipedia.org/wiki/Terminal_emulator)

This plugin doesn't care what your `&shell` is. Sometimes (especially on Windows), 
you may want to leave `&shell` as the default (for `!` and `system()` commands), 
but do your actual interactive work in another shell.

## Features

* `gof`: **Go** to the current buffer's directory in the **F**ile manager
* `got`: **Go** to the current buffer's directory in the **T**erminal
* `goo`: (todo/not yet implemented) **Go** to the current buffer's directory in some **O**ther shell

## Installation

Same installation as most Vim plugins, or use a package manager:

* [vundle](https://github.com/Shougo/neobundle.vim)
* [neobundle](https://github.com/gmarik/vundle)
* [pathogen.vim](https://github.com/tpope/vim-pathogen):
    cd ~/.vim/bundle
    git clone git://github.com/justinmk/vim-gtfo.git

## Credits

* Sangmin Ryu, [open-terminal-filemanager](http://www.vim.org/scripts/script.php?script_id=2896)
* tpope

<!--
## FAQ

> Foo

bar
-->

## License

Copyright © Justin M. Keyes.  Distributed under the same terms as Vim itself.
See `:help license`.

