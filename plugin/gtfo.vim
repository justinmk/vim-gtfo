" gtfo.vim - Go to Terminal, File manager, or Other
" Maintainer:   Justin M. Keyes
" Version:      0.1

" TODO: https://github.com/vim-scripts/open-terminal-filemanager
" TODO: directory traversal: https://github.com/tpope/vim-sleuth/
" also :h findfile()

if exists('g:loaded_gtfo') || &compatible
  finish
else
  let g:loaded_gtfo = 1
endif

" Turn on support for line continuations when creating the script
let s:cpo_save = &cpo
set cpo&vim

let s:is_windows = has('win32') || has('win64')
let s:is_mac = has('gui_macvim') || has('mac')
let s:is_unix = has('unix')
let s:is_tmux = !(empty($TMUX))
let s:is_unix_gui = !empty($DISPLAY) && $TERM !=# 'linux'
"even if vim is in a terminal, there may still be a gui file manager available
let s:is_gui_available = s:is_mac || s:is_windows || s:is_unix_gui

func! s:is_gui()
  return has('gui_running') || &term ==? 'builtin_gui'
endf

func! s:mac_do_ascript_voodoo(cmd)
  "This is somewhat complicated because we must pass a correctly-escaped,
  "newline-delimitd applescript literal from vim => shell => osascript.

  "Applescript does not allow apostrophes; we use them only for readability.
  "replace ' with \"'
  let l:cmd = substitute(a:cmd,  "'", '\\"', 'g')
  "replace ___ with the shell command to be passed from applescript to Terminal.app.
  let l:cmd = substitute(l:cmd, '___', "cd '".expand("%:p:h")."'", 'g')
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

func! s:mac_open_other_terminal()
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

if maparg('gof', 'n') ==# ''
  if !s:is_gui_available && !executable('xdg-open')
    if s:is_tmux "fallback to 'got'
      nnoremap <silent> gof :normal got<cr>
    else "what environment are you using?
      nnoremap <silent> gof :shell<cr>
    endif
  elseif s:is_windows
    nnoremap <silent> gof :silent !start explorer /select,%:p<cr>
  elseif s:is_mac
    nnoremap <silent> gof :silent execute "!open '".expand("%:p:h")."'" <bar> if !<sid>is_gui()<bar>redraw!<bar>endif<cr>
  elseif executable('xdg-open')
    nnoremap <silent> gof :silent execute "!xdg-open '".expand("%:p:h")."'" <bar> if !<sid>is_gui()<bar>redraw!<bar>endif<cr>
  else
    "instead of complaining every time vim starts up, wait for the user to call 'gof'.
    nnoremap <silent> gof :echoerr 'gtfo.vim: xdg-open is not in your $PATH. Try "sudo apt-get install xdg-utils".'<cr>
  endif
endif

if s:is_windows && !exists('g:gtfo_cygwin_bash')
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
  if s:is_tmux
    nnoremap <silent> got :silent execute '!tmux split-window -h \; send-keys "cd ''' . expand("%:p:h") . '''" C-m'<cr>
  elseif s:is_windows
    if executable(g:gtfo_cygwin_bash)
      " HACK: Execute bash (again) immediately after -c to prevent exit.
      "   http://stackoverflow.com/questions/14441855/run-bash-c-without-exit
      " NOTE: Yes, these are nested quotes (""foo" "bar""), and yes, that is what cmd.exe expects.
      nnoremap <silent> got :silent exe '!start '.$COMSPEC.' /c ""' . g:gtfo_cygwin_bash . '" "--login" "-i" "-c" "cd '''.expand("%:p:h").''' ; bash" "'<cr>
    else "fall back to cmd.exe
      nnoremap <silent> got :silent exe '!start '.$COMSPEC.' /k "cd "'.expand("%:p:h").'""'<cr>
    endif
  elseif s:is_mac
    nnoremap <silent> got :silent call <sid>mac_open_terminal()<cr>
  elseif s:is_gui_available && executable('gnome-terminal')
    nnoremap <silent> got :silent execute 'silent ! gnome-terminal --window -e "bash -c \"cd '''.expand("%:p:h").''' ; bash\"" &'<cr>
  else
    nnoremap <silent> got :shell<cr>
  endif
endif

if maparg('goo', 'n') ==# ''
  if s:is_windows
    nnoremap <silent> goo :silent exe '!start powershell -NoLogo -NoExit -Command "cd '''.expand("%:p:h").'''"'<cr>
  elseif s:is_mac
    nnoremap <silent> goo :silent call <sid>mac_open_other_terminal()<cr>
  endif
endif

let &cpo = s:cpo_save
unlet s:cpo_save
