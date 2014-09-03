" gtfo.vim - Go to Terminal or File manager
" Author:       Justin M. Keyes
" Version:      1.1.4

if exists('g:loaded_gtfo') || &compatible
  finish
endif
let g:loaded_gtfo = 1

" Turn on support for line continuations when creating the script
let s:cpo_save = &cpo
set cpo&vim

let s:iswin = has('win32') || has('win64')
"vim is running in 'vanilla' (non-msysgit) cygwin
let s:iscygwin = has('win32unix') || has('win64unix')
let s:ismac = has('gui_macvim') || has('mac')
let s:isunix = !s:iswin && !s:ismac
let s:istmux = !(empty($TMUX))
"GUI Vim
let s:isgui = has('gui_running') || &term ==? 'builtin_gui'
"non-GUI Vim running within a GUI environment
let s:is_gui_available = s:ismac || s:iswin || (!empty($DISPLAY) && $TERM !=# 'linux')

func! s:beep(s)
  echoerr 'gtfo: failed to open '.a:s
endf

func! s:init_win()
  "try 'Program Files', else fall back to 'Program Files (x86)'.
  for programfiles_path in ['$ProgramW6432', '$ProgramFiles', '$ProgramFiles (x86)']
    let path = expand(programfiles_path, 1).'/Git/bin/bash.exe'
    if executable(path)
      let g:gtfo_cygwin_bash = path
      break
    endif
  endfor
  if !exists('g:gtfo_cygwin_bash') "didn't find msysgit cygwin; try vanilla cygwin.
    let g:gtfo_cygwin_bash = $SystemDrive.'/cygwin/bin/bash'
  endif
endf

if s:iswin && !exists('g:gtfo_cygwin_bash')
  call s:init_win()
endif

func! gtfo#openfileman(path) "{{{
  if exists('+shellslash') && &shellslash
    "Windows: force expand() to return `\` paths so explorer.exe won't choke. #11
    let l:shslash=1 | set noshellslash
  endif

  let l:path = expand(a:path, 1)
  let l:dir = isdirectory(l:path) ? l:path : fnamemodify(l:path, ":h")
  let l:validfile = filereadable(l:path)

  if exists("l:shslash")
    set shellslash
  endif

  if !isdirectory(l:dir) "this happens if the directory was moved/deleted.
    echom 'gtfo: invalid/missing directory: '.l:dir
    return
  endif

  if s:iscygwin && executable('cygstart')
    if l:validfile
      silent exec "!cygstart explorer /select,`cygpath -w '".l:path."'`"
    else
      silent exec "!cygstart explorer `cygpath -w '".l:dir."'`"
    endif
    redraw!
  elseif !s:is_gui_available && !executable('xdg-open')
    if s:istmux "fallback to 'got'
      call gtfo#openterm(l:dir, "")
    else
      call s:beep("file manager")
    endif
  elseif s:iswin
    silent exec '!start explorer '.(l:validfile ? '/select,"'.l:path.'"' : l:dir)
  elseif s:ismac
    if l:validfile
      silent exec "!open --reveal '".l:path."'"
    else
      silent exec "!open '".l:dir."'"
    endif
    if !s:isgui | redraw! | endif
  elseif executable('xdg-open')
    silent exec "!xdg-open '".l:dir."' &"
    if !s:isgui | redraw! | endif
  else
    "instead of complaining every time vim starts up, wait for invocation.
    echoerr 'gtfo: xdg-open is not in your $PATH. Try "sudo apt-get install xdg-utils"'
  endif
endf "}}}

func! gtfo#openterm(dir, cmd) "{{{
  let l:dir = expand(a:dir, 1)
  if !isdirectory(l:dir) "this happens if a directory was deleted outside of vim.
    echom 'gtfo: invalid/missing directory: '.l:dir
    return
  endif

  if s:istmux
    silent exec '!tmux split-window -h \; send-keys "cd ''' . l:dir . ''' && clear" C-m'
  elseif s:iscygwin && executable('cygstart') && executable('mintty')
    " https://code.google.com/p/mintty/wiki/Tips
    silent exec '!cd ''' . l:dir . ''' && cygstart mintty /bin/env CHERE_INVOKING=1 /bin/bash'
    redraw!    
  elseif s:iswin
    if executable(g:gtfo_cygwin_bash)
      " HACK: start redundant shell immediately after -c to prevent exit.
      "   http://stackoverflow.com/questions/14441855/run-bash-c-without-exit
      " NOTE: Yes, these are nested quotes (""foo" "bar""), and yes, that is what cmd.exe expects.
      silent exe '!start '.$COMSPEC.' /c "cd "'.l:dir.'" & "' . g:gtfo_cygwin_bash . '" --login -i "'
    else "fall back to cmd.exe
      silent exe '!start '.$COMSPEC.' /k "cd "'.l:dir.'""'
    endif
  elseif s:ismac
    if $TERM_PROGRAM ==? 'iTerm.app' || exists('g:gtfo_force_iterm')
      silent call <sid>mac_open_iTerm(l:dir)
    else
      silent exec "!open -a Terminal '".l:dir."'"
      if !s:isgui | redraw! | endif
    endif
  elseif s:is_gui_available
    "Termite also uses the -e flag to pass in commands to run when the session starts
    if executable('termite')
      silent exec "silent ! termite -d '".l:dir."'"
    elseif executable('rxvt-unicode')
      silent exec "silent ! rxvt-unicode -cd '".l:dir."' &"
    elseif executable('gnome-terminal')
      silent exec 'silent ! gnome-terminal --window -e "$SHELL -c \"cd '''.l:dir.''' ; $SHELL\"" &'
    else
      call s:beep("terminal")
    endif
    if !s:isgui | redraw! | endif
  else
    call s:beep("terminal")
  endif
endf "}}}

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
  call s:mac_do_ascript_voodoo(l:cmd, a:expanded_dir)
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
  call s:mac_do_ascript_voodoo(l:cmd, a:expanded_dir)
endf
endif "}}}

if maparg('gof', 'n') ==# ''
  nnoremap <silent> gof :<c-u>call gtfo#openfileman("%:p")<cr>
endif
if maparg('got', 'n') ==# ''
  nnoremap <silent> got :<c-u>call gtfo#openterm("%:p:h", "")<cr>
endif
if maparg('goF', 'n') ==# ''
  nnoremap <silent> goF :<c-u>call gtfo#openfileman(getcwd())<cr>
endif
if maparg('goT', 'n') ==# ''
  nnoremap <silent> goT :<c-u>call gtfo#openterm(getcwd(), "")<cr>
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

