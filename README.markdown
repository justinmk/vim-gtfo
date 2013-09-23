# gtfo.vim

Opens the directory of the *current buffer* in the [file manager](http://en.wikipedia.org/wiki/File_manager#Examples) 
or the [terminal](http://en.wikipedia.org/wiki/Terminal_emulator).
Just works™ in [tmux](http://tmux.sourceforge.net/), [Cygwin](http://www.cygwin.com/), 
[Git bash](http://msysgit.github.io/), Windows, OS X, and Linux.

## Features

**Normal-mode key bindings**
* `gof`: **Go** to the current buffer's directory in the **F**ile manager 
* `got`: **Go** to the current buffer's directory in the **T**erminal
  * See the *Platform Support* section (below) for details on which terminal is chosen
* `goF`: like `gof`, but opens the *current directory*, that is, the directory
  returned by `:pwd`. Think of this as your "project directory" for the current
  Vim session.
* `goT`: like `got`, but opens the *current directory*

Existing bindings will not be overridden (try `:verbose map gof | map got`).

## Platform Support

**tmux (all platforms)**
* If Vim is running in a tmux session, `got` opens a new tmux pane

**Cygwin**
* If Vim is running in Cygwin (mintty), `got` opens a new mintty console

**Windows**
* File manager is Windows Explorer
* Terminal defaults to the first terminal that can be found:
  * "Git bash" ([msysgit](http://msysgit.github.io/))
  * [Cygwin](http://www.cygwin.org) mintty
  * `%COMSPEC%` (cmd.exe)

**Mac OS X**
* File manager is Finder
* Terminal defaults to Terminal.app
  * If Vim is running in iTerm, `got` opens a new iTerm window

**Linux**
* File manager is determined by [`xdg-open`](http://portland.freedesktop.org/xdg-utils-1.0/xdg-open.html), 
  the Linux desktop standard utility.
* Terminal defaults to `gnome-terminal`, unless one of these alternatives is found:
  * Termite

## Settings

* `g:gtfo_cygwin_bash` : absolute path to bash executable 
  (example: `'C:\cygwin\bin\bash'`)

## Installation

Same installation as most Vim plugins, or use a plugin manager:

- [Pathogen](https://github.com/tpope/vim-pathogen)
  - `cd ~/.vim/bundle && git clone git://github.com/justinmk/vim-gtfo.git`
- [Vundle](https://github.com/gmarik/vundle)
  1. Add `Bundle 'justinmk/vim-gtfo'` to .vimrc
  2. Run `:BundleInstall`
- [NeoBundle](https://github.com/Shougo/neobundle.vim)
  1. Add `NeoBundle 'justinmk/vim-gtfo'` to .vimrc
  2. Run `:NeoBundleInstall`
- [vim-plug](https://github.com/junegunn/vim-plug)
  1. Add `Plug 'justinmk/vim-gtfo'` to .vimrc
  2. Run `:PlugInstall`

## FAQ

> On Linux without a gui, 'gof' does nothing, or launches w3m

* `xdg-open` defaults to w3m if no GUI is available (eg, in ssh or tty console).
  To change the default: `xdg-mime default application/x-directory foo`

## Credits

* Sangmin Ryu, [open-terminal-filemanager](http://www.vim.org/scripts/script.php?script_id=2896)
* @tpope, for impeccable Vim plugin reference implementations
* [EasyShell](http://marketplace.eclipse.org/node/974#.Ui1kc2R273E)
* [junegunn](https://github.com/junegunn) for some readme copy

## Todo

* look for [posh](https://github.com/dahlbyk/posh-git) instead of vanilla Powershell
* look for mintty instead of cmd.exe
* support shells other than bash (zsh, fish)?
* provide vim command: `GtfoTerm`
* if [vimux](https://github.com/benmills/vimux) is available, defer to it for tmux behavior

## License

Copyright © Justin M. Keyes. Distributed under the same terms as Vim itself.
See `:help license`.

