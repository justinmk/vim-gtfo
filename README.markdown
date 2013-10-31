# gtfo.vim :point_right:

This Vim plugin provides two simple features:
* `gof` opens the [file manager](http://en.wikipedia.org/wiki/File_manager#Examples) 
  at the directory of the file you are currently editing in Vim.
* `got` opens the [terminal](http://en.wikipedia.org/wiki/Terminal_emulator)
  at the directory of the file you are currently editing in Vim.

<!-- * Enter `:Gtfo <arbitrary shell command>` to run any command in a new terminal relative to the current file. -->

gtfo.vim just works™ in [tmux](http://tmux.sourceforge.net/), [Cygwin](http://www.cygwin.com/), 
[Git bash](http://msysgit.github.io/), Windows, OS X, and Linux.

### Features

**Normal-mode key bindings**
* `gof`: **Go** to the current file's directory in the **F**ile manager 
* `got`: **Go** to the current file's directory in the **T**erminal
  * See the *Platform Support* section (below) for details on which terminal is chosen
* `goF`: like `gof` for the current "session" directory, that is, the directory
  returned by `:pwd`
* `goT`: like `got` for the current "session" directory

Existing bindings will not be overridden. Try `:verbose map gof | map got` to 
see if some other plugin is using those mappings.

### Platform Support

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
* Terminal defaults to Terminal.app *unless* Vim is running in iTerm.

**Linux**
* File manager is determined by [`xdg-open`](http://portland.freedesktop.org/xdg-utils-1.0/xdg-open.html), 
  the Linux desktop standard utility.
* Terminal defaults to `gnome-terminal`, unless one of these alternatives is found:
  * Termite

### Settings

* `g:gtfo_cygwin_bash` : absolute path to bash executable 
  (example: `'C:\cygwin\bin\bash'`)

### Installation

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

### FAQ

> Why not just use `ctrl-z` or `:shell` to drop to a shell?

* `ctrl-z` and `:shell` do not go to the directory of the current file
* Vim's `&shell` may not be your preferred shell (for example, if you use [fish](http://fishshell.com/)).
  And it is [not advisable](https://github.com/tpope/vim-sensible/issues/50#issuecomment-19875409) 
  to set `&shell` to fish. So, opening a new terminal gives you your preferred 
  shell (assuming you've configured your terminal to do so).

> On Linux without a gui, 'gof' does nothing, or launches w3m

* `xdg-open` defaults to w3m if no GUI is available (eg, in ssh or tty console).
  To change the default: `xdg-mime default application/x-directory foo`

### Credits

* Sangmin Ryu, [open-terminal-filemanager](http://www.vim.org/scripts/script.php?script_id=2896)
* @tpope, for impeccable Vim plugin reference implementations
* [EasyShell](http://marketplace.eclipse.org/node/974#.Ui1kc2R273E)
* [junegunn](https://github.com/junegunn) for some readme copy

### Todo

* look for [posh](https://github.com/dahlbyk/posh-git) instead of vanilla Powershell
* look for mintty instead of cmd.exe
* provide Vim command `Gtfo`
* if [vimux](https://github.com/benmills/vimux) is available, defer to it for tmux behavior

### License

Copyright © Justin M. Keyes. Distributed under the same terms as Vim itself.
See `:help license`.


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/justinmk/vim-gtfo/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

