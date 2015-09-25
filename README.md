# gtfo.vim :point_right:

This Vim plugin provides two simple features:

* `gof` opens the [file manager](http://en.wikipedia.org/wiki/File_manager#Examples) 
  at the directory of the file you are currently editing in Vim.
* `got` opens the [terminal](http://en.wikipedia.org/wiki/Terminal_emulator)
  at the directory of the file you are currently editing in Vim.

gtfo.vim just works™ in [tmux](http://tmux.sourceforge.net/), mintty ([Cygwin](http://www.cygwin.com/), [Babun](https://github.com/babun/babun)), 
[Git-for-Windows](https://git-for-windows.github.io/), Windows, OS X, and Unix.

### Features

**Normal-mode key bindings**

* `gof`: **Go** to the current file's directory in the **File manager** 
* `got`: **Go** to the current file's directory in the **Terminal**
* `goF`: like `gof` for the current *working* directory (`:pwd`)
* `goT`: like `got` for the current *working* directory (`:pwd`)

Existing bindings will not be overridden. Try `:verbose map gof` to 
see if some other plugin is using that mapping.

**Functions**

* `gtfo#open#file(path)`: opens file manager at `path` (may be a filename *or* folder)
* `gtfo#open#term(dir, cmd)`: opens terminal at `dir`
    * *Note:* Currently, the `cmd` parameter is ignored.

**Settings**

* `g:gtfo#terminals` Optional dictionary with one or more of the following keys: `win`, `mac`, `unix`

    The `g:gtfo#terminals.<key>` *value* is the name (or absolute path) of
    a terminal program followed by the necessary flags (`-e`, `/k`, etc.) for
    executing a command on startup.

    **Special case (OS X):** To use iTerm instead of Terminal.app, use the special value "iterm":<br/>
    `let g:gtfo#terminals = { 'mac' : 'iterm' }`

### Platform Support

**tmux (all platforms)**

* If Vim is running in a tmux session, `got` opens a new tmux pane.

**mintty ([Git-for-Windows](https://git-for-windows.github.io/), [Cygwin](http://www.cygwin.com/), [Babun](https://github.com/babun/babun), ...)**

* If Vim is running in mintty, `got` opens a new mintty console.

**Windows**

* `gof` opens Windows Explorer.
* `got` opens `g:gtfo#terminals['win']` *or* the first terminal that can be found:
  * "Git bash" ([Git-for-Windows](https://git-for-windows.github.io/))
  * [Cygwin](http://www.cygwin.org) mintty
  * `%COMSPEC%` (cmd.exe)
* To use powershell:<br/>
  `let g:gtfo#terminals = { 'win' : 'powershell -NoLogo -NoExit -Command' }`

**Mac OS X**

* `gof` opens Finder.
* `got` opens Terminal.app *unless* Vim is running in iTerm or `g:gtfo#terminals['mac']` is set.<br/>
  To force iTerm:<br/>
  `let g:gtfo#terminals = { 'mac' : 'iterm' }`

**Unix**

* `gof` opens the file manager determined by [`xdg-open`](http://portland.freedesktop.org/xdg-utils-1.0/xdg-open.html), 
  the Linux desktop standard utility.
* `got` opens `$SHELL` inside `gnome-terminal` unless `g:gtfo#terminals['unix']` is set.
    * To use termite:<br/>
      `let g:gtfo#terminals = { 'unix' : 'termite -d' }`
    * To use rxvt-unicode:<br/>
      `let g:gtfo#terminals = { 'unix' : 'urxvt -cd' }`

### Installation

Same installation as most Vim plugins, or use a plugin manager:

- [Pathogen](https://github.com/tpope/vim-pathogen)
  - `cd ~/.vim/bundle && git clone git://github.com/justinmk/vim-gtfo.git`
- [Vundle](https://github.com/gmarik/vundle)
  1. Add `Plugin 'justinmk/vim-gtfo'` to .vimrc
  2. Run `:PluginInstall`
- [NeoBundle](https://github.com/Shougo/neobundle.vim)
  1. Add `NeoBundle 'justinmk/vim-gtfo'` to .vimrc
  2. Run `:NeoBundleInstall`
- [vim-plug](https://github.com/junegunn/vim-plug)
  1. Add `Plug 'justinmk/vim-gtfo'` to .vimrc
  2. Run `:PlugInstall`

### FAQ

> On Linux without a gui, `gof` does nothing, or launches w3m

* `xdg-open` defaults to w3m if no GUI is available (eg, in ssh or tty console).
  To change the default: `xdg-mime default application/x-directory foo`

### Credits

* Sangmin Ryu, [open-terminal-filemanager](http://www.vim.org/scripts/script.php?script_id=2896)
* @tpope, for impeccable Vim plugin reference implementations
* [EasyShell](http://marketplace.eclipse.org/node/974#.Ui1kc2R273E)
* [junegunn](https://github.com/junegunn) for some readme copy

### License

Copyright © Justin M. Keyes. Distributed under the same terms as Vim itself.
See `:help license`.


