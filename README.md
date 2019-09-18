gtfo.vim :point_right:
======================

Opens the
[file manager](http://en.wikipedia.org/wiki/File_manager#Examples)
or [terminal](http://en.wikipedia.org/wiki/Terminal_emulator) at the
directory of the current file in Vim.

Features
--------

### Mappings

* `gof`: **Go** to the directory of the current file in the **File manager** 
    * `goF`: Go to the *working directory* (`:pwd`)
* `got`: **Go** to the directory of the current file in the **Terminal**
    * `goT`: Go to the *working directory* (`:pwd`)

### Options

* `g:gtfo#terminals` Optional dictionary with one or more of the following keys: `win`, `mac`, `unix`

    The `g:gtfo#terminals.<key>` *value* is the name (or absolute path) of
    a terminal program followed by the necessary flags (`-e`, `/k`, etc.) for
    executing a command on startup.

    **Special case (OS X):** To use iTerm instead of Terminal.app, use the special value "iterm":
    ```
    let g:gtfo#terminals = { 'mac': 'iterm' }
    ```

Platform Support
----------------

* **tmux:** `got` opens a new tmux pane.
* **mintty ([Git-for-Windows](https://gitforwindows.org/),
[Cygwin](http://www.cygwin.com/), etc.):** `got` opens a new mintty console.
* **Windows**
    * `gof` opens Windows Explorer.
    * `got` opens `g:gtfo#terminals['win']` *or* the first terminal it can find:
      "Git bash", mintty, or cmd.exe.
    * To use powershell:
      ```
      let g:gtfo#terminals = { 'win': 'powershell -NoLogo -NoExit -Command' }
      ```
    * To use ye olde cmd.exe:
      ```
      let g:gtfo#terminals = { 'win': 'cmd.exe /k' }
      ```
* **Mac OS X**
    * `gof` opens Finder.
    * `got` opens Terminal.app *unless* Vim is running in iTerm or `g:gtfo#terminals['mac']` is set.<br/>
      To force iTerm (special case, see [above][#settings]):
      ```
      let g:gtfo#terminals = { 'mac': 'iterm' }
      ```
* **Unix**
    * `gof` opens the file manager dictated by
      [`xdg-open`](https://portland.freedesktop.org/doc/xdg-open.html).
    * `got` opens `$SHELL` inside `gnome-terminal` unless `g:gtfo#terminals['unix']` is set.
        * To use termite:
          ```
          let g:gtfo#terminals = { 'unix': 'termite -d' }
          ```
        * To use rxvt-unicode:
          ```
          let g:gtfo#terminals = { 'unix': 'urxvt -cd' }
          ```

Installation
------------

- [Pathogen](https://github.com/tpope/vim-pathogen)
  - `cd ~/.vim/bundle && git clone git://github.com/justinmk/vim-gtfo.git`
- [vim-plug](https://github.com/junegunn/vim-plug)
  1. Add `Plug 'justinmk/vim-gtfo'` to .vimrc
  2. Run `:PlugInstall`

FAQ
---

> `got` (or `gof`) doesn't work

Try `:verbose map gof` to see if some other plugin is using that mapping.

> On Linux without a gui, `gof` does nothing, or launches w3m

`xdg-open` defaults to w3m if no GUI is available (eg, in ssh or tty console).
To change the default: `xdg-mime default application/x-directory foo`

Credits
-------

* Sangmin Ryu, [open-terminal-filemanager](http://www.vim.org/scripts/script.php?script_id=2896)
* @tpope, for impeccable Vim plugin reference implementations
* [EasyShell](http://marketplace.eclipse.org/node/974#.Ui1kc2R273E)
* [junegunn](https://github.com/junegunn) for some readme copy

License
-------

Copyright © Justin M. Keyes. MIT license.
