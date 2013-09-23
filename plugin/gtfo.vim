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
"GUI Vim
let s:isgui = has('gui_running') || &term ==? 'builtin_gui'
"non-GUI Vim running within a GUI environment
let s:is_gui_available = s:ismac || s:iswin || (!empty($DISPLAY) && $TERM !=# 'linux')

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

func! s:openfileman(path)
  let l:path = expand(a:path)
  let l:dir = isdirectory(l:path) ? l:path : fnamemodify(l:path, ":h")
  let l:validfile = filereadable(l:path)

  if !isdirectory(l:dir) "this happens if a directory was moved outside of vim.
    echom 'gtfo: invalid/missing directory: '.l:dir
    return
  endif

  if s:is_cygwin && executable('cygstart')
    if l:validfile
      silent exec "!cygstart explorer /select,`cygpath -w '".l:path."'`"
    else
      silent exec "!cygstart explorer `cygpath -w '".l:dir."'`"
    endif
    redraw!
  elseif !s:is_gui_available && !executable('xdg-open')
    if s:is_tmux "fallback to 'got'
      call openterm(l:dir)
    else "file a bug report!
      shell
    endif
  elseif s:iswin
    silent exec '!start explorer '.(l:validfile ? '/select,'.l:path : l:dir)
  elseif s:ismac
    if l:validfile
      silent exec "!open --reveal '".l:path."'"
    else
      silent exec "!open '".l:dir."'"
    endif
    if !s:isgui
      redraw!
    endif
  elseif executable('xdg-open')
    silent exec "!xdg-open '".l:dir."'" 
    if !s:isgui
      redraw!
    endif
  else
    "instead of complaining every time vim starts up, wait for invocation.
    echoerr 'gtfo: xdg-open is not in your $PATH. Try "sudo apt-get install xdg-utils"'
  endif
endf

func! s:openterm(dir, cmd)
  let l:dir = expand(a:dir)
  if !isdirectory(l:dir) "this happens if a directory was deleted outside of vim.
    echom 'gtfo: invalid/missing directory: '.l:dir
    return
  endif

  if s:is_cygwin && executable('cygstart') && executable('mintty')
    " https://code.google.com/p/mintty/wiki/Tips
    " TODO: cygstart mintty /bin/env CHERE_INVOKING=1 SHELL=/bin/zsh zsh [args?]
    silent exec '!cd ''' . l:dir . ''' && cygstart mintty /bin/env CHERE_INVOKING=1 /bin/bash'
    redraw!
  elseif s:is_tmux
    silent exec '!tmux split-window -h \; send-keys "cd ''' . l:dir . '''" C-m'
  elseif s:iswin
    if executable(g:gtfo_cygwin_bash)
      " HACK: Execute bash (again) immediately after -c to prevent exit.
      "   http://stackoverflow.com/questions/14441855/run-bash-c-without-exit
      " NOTE: Yes, these are nested quotes (""foo" "bar""), and yes, that is what cmd.exe expects.
      silent exe '!start '.$COMSPEC.' /c ""' . g:gtfo_cygwin_bash . '" "--login" "-i" "-c" "cd '''.l:dir.''' ; bash" "'
    else "fall back to cmd.exe
      silent exe '!start '.$COMSPEC.' /k "cd "'.l:dir.'""'
    endif
  elseif s:ismac
    if $TERM_PROGRAM ==? 'iTerm.app'
      silent call <sid>mac_open_iTerm(l:dir)
    else
      silent exec "!open -a Terminal '".l:dir."'"
      if !s:isgui
        redraw!
      endif
    endif
  elseif s:is_gui_available && executable('gnome-terminal')
    silent exec 'silent ! gnome-terminal --window -e "bash -c \"cd '''.l:dir.''' ; bash\"" &'
  else
    shell
  endif
endf

if s:ismac "{{{
func! s:mac_do_ascript_voodoo(cmd, expanded_dir)
  "This is somewhat complicated because we must pass a correctly-escaped,
  "newline-delimitd applescript literal from vim => shell => osascript.

  "Applescript does not allow apostrophes; we use them only for readability.
  "replace ' with \"'
  let l:cmd = substitute(a:cmd,  "'", '\\"', 'g')
  "replace ___ with the shell command to be passed from applescript to Terminal.app.
  let l:cmd = substitute(l:cmd, '___', "cd '".a:expanded_dir."'", 'g')
  call system('osascript -e " ' . l:cmd . '"')
endf

func! s:mac_open_terminal(expanded_dir)
  let l:cmd = "
        \ tell application 'Terminal'     \n
        \   do script with command '___'  \n
        \   activate                      \n
        \ end tell                        \n
        \ "
  call <sid>mac_do_ascript_voodoo(l:cmd)
endf

func! s:mac_open_iTerm(expanded_dir)
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

if maparg('gof', 'n') ==# ''
  nnoremap <silent> gof :<c-u>call <sid>openfileman("%:p")<cr>
endif
if maparg('got', 'n') ==# ''
  nnoremap <silent> got :<c-u>call <sid>openterm("%:p:h", "")<cr>
endif
if maparg('goF', 'n') ==# ''
  nnoremap <silent> goF :<c-u>call <sid>openfileman(getcwd())<cr>
endif
if maparg('goT', 'n') ==# ''
  nnoremap <silent> goT :<c-u>call <sid>openterm(getcwd(), "")<cr>
endif

if maparg('goo', 'n') ==# ''
  if s:iswin
    nnoremap <silent> goo :silent exe '!start powershell -NoLogo -NoExit -Command "cd '''.expand("%:p:h").'''"'<cr>
  elseif s:ismac
    nnoremap <silent> goo :silent call <sid>mac_open_iTerm(expand("%:p:h"))<cr>
  endif
endif

let &cpo = s:cpo_save
unlet s:cpo_save

