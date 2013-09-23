" gtfo.vim - Go to Terminal, File manager, or Other
" Author:       Justin M. Keyes
" Version:      1.1

" TODO: https://github.com/vim-scripts/open-terminal-filemanager
" TODO: directory traversal: https://github.com/tpope/vim-sleuth/
" also :h findfile()

if exists('g:loaded_gtfo') || &compatible
  finish
endif
let g:loaded_gtfo = 1

" Turn on support for line continuations when creating the script
let s:cpo_save = &cpo
set cpo&vim

let s:iswin = has('win32') || has('win64')
"vim is running in 'vanilla' (non-msysgit) cygwin
let s:is_cygwin = has('win32unix') || has('win64unix')
let s:ismac = has('gui_macvim') || has('mac')
let s:isunix = !s:iswin && !s:ismac
let s:is_tmux = !(empty($TMUX))
"non-GUI Vim running within a GUI
let s:is_gui_available = s:ismac || s:iswin || (!empty($DISPLAY) && $TERM !=# 'linux')

func! s:is_gui()
  return has('gui_running') || &term ==? 'builtin_gui'
endf

"AppleScript backflips {{{
if s:ismac
func! s:mac_do_ascript_voodoo(cmd)
  "This is somewhat complicated because we must pass a correctly-escaped,
  "newline-delimitd applescript literal from vim => shell => osascript.

  "Applescript does not allow apostrophes; we use them only for readability.
  "replace ' with \"'
  let l:cmd = substitute(a:cmd,  "'", '\\"', 'g')
  "replace ___ with the shell command to be passed from applescript to Terminal.app.
  let l:cmd = substitute(l:cmd, '___', "cd '".<sid>getdir()."'", 'g')
  call system('osascript -e " ' . l:cmd . '"')
endf

func! s:mac_open_terminal()
  let l:cmd = "
        \ tell application 'Terminal'     \n
        \   do script with command '___'  \n
        \   activate                      \n
        \ end tell                        \n
        \ "
  call <sid>mac_do_ascript_voodoo(l:cmd)
endf

func! s:mac_open_iTerm()
  let l:cmd = "
        \ tell application 'iTerm'                             \n
        \   set term to (make new terminal)                    \n
        \   tell term                                          \n
        \     set sess to (launch session 'Default Session')   \n
        \     tell sess                                        \n
        \       write text '___'                               \n
        \     end tell                                         \n
        \   end tell                                           \n
        \   activate                                           \n
        \ end tell                                             \n
        \ "
  call <sid>mac_do_ascript_voodoo(l:cmd)
endf
endif "}}}

func! s:getdir()
  let l:dir = expand("%:p:h")
  if !isdirectory(l:dir)
    "this happens if a directory was deleted outside of vim.
    echoerr 'gtfo: invalid/missing directory: '.l:dir
  endif
  return l:dir
endf

func! s:getfile()
  let l:file = expand("%:p")
  if !filereadable(l:file)
    "this happens if a file was deleted outside of vim.
    echoerr 'gtfo: invalid/missing file: '.l:file
  endif
  return l:file
endf

if maparg('gof', 'n') ==# ''
  if s:is_cygwin && executable('cygstart')
    nnoremap <silent> gof :silent execute '!cygstart explorer /select,`cygpath -w '''.<sid>getfile().'''`' <bar> redraw!<cr>
  elseif !s:is_gui_available && !executable('xdg-open')
    if s:is_tmux "fallback to 'got'
      nnoremap <silent> gof :normal got<cr>
    else "what environment are you using?
      nnoremap <silent> gof :shell<cr>
    endif
  elseif s:iswin
    nnoremap <silent> gof :silent !start explorer /select,<sid>getfile()<cr>
  elseif s:ismac
    nnoremap <silent> gof :silent execute "!open --reveal '".<sid>getfile()."'" <bar> if !<sid>is_gui()<bar>redraw!<bar>endif<cr>
  elseif executable('xdg-open')
    nnoremap <silent> gof :silent execute "!xdg-open '".<sid>getdir()."'" <bar> if !<sid>is_gui()<bar>redraw!<bar>endif<cr>
  else
    "instead of complaining every time vim starts up, wait for the user to call 'gof'.
    nnoremap <silent> gof :echoerr 'gtfo.vim: xdg-open is not in your $PATH. Try "sudo apt-get install xdg-utils".'<cr>
  endif
endif

" TODO: \opt\cygwin\bin\mintty.exe /bin/env CHERE_INVOKING=1 /bin/bash [args?]
if s:iswin && !exists('g:gtfo_cygwin_bash')
  "try 'Program Files', else fall back to 'Program Files (x86)'.
  let g:gtfo_cygwin_bash = (exists('$ProgramW6432') ? $ProgramW6432 : $ProgramFiles) . '/Git/bin/bash.exe'
  if !executable(g:gtfo_cygwin_bash)
    let g:gtfo_cygwin_bash = $ProgramFiles.'/Git/bin/bash.exe'
    if !executable(g:gtfo_cygwin_bash)
      "cannot find msysgit cygwin; look for vanilla cygwin
      let g:gtfo_cygwin_bash = $SystemDrive.'/cygwin/bin/bash'
    endif
  endif
endif

if maparg('got', 'n') ==# ''
  if s:is_cygwin && executable('cygstart') && executable('mintty')
    " https://code.google.com/p/mintty/wiki/Tips
    " TODO: cygstart mintty /bin/env CHERE_INVOKING=1 SHELL=/bin/zsh zsh [args?]
    nnoremap <silent> got :silent execute '!cd ''' . <sid>getdir() . ''' && cygstart mintty /bin/env CHERE_INVOKING=1 /bin/bash' <bar> redraw!<cr>
  elseif s:is_tmux
    nnoremap <silent> got :silent execute '!tmux split-window -h \; send-keys "cd ''' . <sid>getdir() . '''" C-m'<cr>
  elseif s:iswin
    if executable(g:gtfo_cygwin_bash)
      " HACK: Execute bash (again) immediately after -c to prevent exit.
      "   http://stackoverflow.com/questions/14441855/run-bash-c-without-exit
      " NOTE: Yes, these are nested quotes (""foo" "bar""), and yes, that is what cmd.exe expects.
      nnoremap <silent> got :silent exe '!start '.$COMSPEC.' /c ""' . g:gtfo_cygwin_bash . '" "--login" "-i" "-c" "cd '''.<sid>getdir().''' ; bash" "'<cr>
    else "fall back to cmd.exe
      nnoremap <silent> got :silent exe '!start '.$COMSPEC.' /k "cd "'.<sid>getdir().'""'<cr>
    endif
  elseif s:ismac
    if $TERM_PROGRAM ==? 'iTerm.app'
      nnoremap <silent> got :silent call <sid>mac_open_iTerm()<cr>
    else
      nnoremap <silent> got :silent execute "!open -a Terminal '".<sid>getdir()."'" <bar> if !<sid>is_gui()<bar>redraw!<bar>endif<cr>
    endif
  elseif s:is_gui_available && executable('gnome-terminal')
    nnoremap <silent> got :silent execute 'silent ! gnome-terminal --window -e "bash -c \"cd '''.<sid>getdir().''' ; bash\"" &'<cr>
  else
    nnoremap <silent> got :shell<cr>
  endif
endif

if maparg('goo', 'n') ==# ''
  if s:iswin
    nnoremap <silent> goo :silent exe '!start powershell -NoLogo -NoExit -Command "cd '''.<sid>getdir().'''"'<cr>
  elseif s:ismac
    nnoremap <silent> goo :silent call <sid>mac_open_iTerm()<cr>
  endif
endif

let &cpo = s:cpo_save
unlet s:cpo_save

" vim: foldmethod=indent foldlevel=99
