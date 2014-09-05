let s:iswin = has('win32') || has('win64')
"vim is running in 'vanilla' (non-msysgit) cygwin
let s:iscygwin = has('win32unix') || has('win64unix')
let s:ismac = has('gui_macvim') || has('mac')
let s:istmux = !(empty($TMUX))
"GUI Vim
let s:isgui = has('gui_running') || &term ==? 'builtin_gui'
"non-GUI Vim running within a GUI environment
let s:is_gui_available = s:ismac || s:iswin || (!empty($DISPLAY) && $TERM !=# 'linux')

let s:termpath = ''

func! s:beep(s)
  echohl ErrorMsg | echom 'gtfo: '.a:s | echohl None
endf
func! s:trimws(s)
  return substitute(a:s, '^\s*\(.\{-}\)\s*$', '\1', '')
endf
" Returns true if the value is non-empty.
func! s:empty(s)
  return strlen(s:trimws(a:s)) == 0
endf

func! s:init()
  " initialize missing keys with empty strings.
  let g:gtfo#terminals = extend(get(g:, "gtfo#terminals", {}),
        \ { 'win' : '', 'mac' : '', 'unix': '' }, 'keep')

  if s:iswin
    let s:termpath = s:empty(g:gtfo#terminals.win) ? s:find_cygwin_bash() : g:gtfo#terminals.win
  elseif s:ismac
    let s:termpath = s:empty(g:gtfo#terminals.mac) ? '' : g:gtfo#terminals.mac
  else
    let s:termpath = s:empty(g:gtfo#terminals.unix) ? '' : g:gtfo#terminals.unix
  endif

  let s:termpath = s:trimws(s:termpath)
endf

func! s:find_cygwin_bash()
  "try 'Program Files', else fall back to 'Program Files (x86)'.
  for programfiles_path in ['$ProgramW6432', '$ProgramFiles', '$ProgramFiles (x86)']
    let path = expand(programfiles_path, 1).'/Git/bin/bash.exe'
    if executable(path)
      return path
    endif
  endfor
  "didn't find msysgit cygwin; try vanilla cygwin.
  return executable($SystemDrive.'/cygwin/bin/bash') ? $SystemDrive.'/cygwin/bin/bash' : ''
endf

func! gtfo#open#file(path) "{{{
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

  if executable('cygstart')
    if l:validfile
      silent exec "!cygstart explorer /select,`cygpath -w '".l:path."'`"
    else
      silent exec "!cygstart explorer `cygpath -w '".l:dir."'`"
    endif
    redraw!
  elseif !s:is_gui_available && !executable('xdg-open')
    if s:istmux "fallback to 'got'
      call gtfo#open#term(l:dir, "")
    else
      call s:beep('failed to open file manager')
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
    call s:beep('xdg-open is not in your $PATH. Try "sudo apt-get install xdg-utils"')
  endif
endf "}}}

func! gtfo#open#term(dir, cmd) "{{{
  let l:dir = expand(a:dir, 1)
  if !isdirectory(l:dir) "this happens if a directory was deleted outside of vim.
    call s:beep('invalid/missing directory: '.l:dir)
    return
  endif

  if s:istmux
    silent exec '!tmux split-window -h \; send-keys "cd ''' . l:dir . ''' && clear" C-m'
  elseif executable('cygstart') && executable('mintty')
    " https://code.google.com/p/mintty/wiki/Tips
    silent exec '!cd ''' . l:dir . ''' && cygstart mintty /bin/env CHERE_INVOKING=1 /bin/bash'
    redraw!
  elseif s:iswin
    if s:termpath =~? "bash" && executable(s:termpath)
      " NOTE: Yes, these are nested quotes (""foo" "bar""), and yes, that is what cmd.exe expects.
      silent exe '!start '.$COMSPEC.' /c "cd "'.l:dir.'" & "' . s:termpath . '" --login -i "'
    else "Assume it's a path with the required arguments (considered 'not executable' by Vim).
      if s:empty(s:termpath) | let s:termpath = 'cmd.exe /k'  | endif
      silent exe '!start '.s:termpath.' "cd "'.l:dir.'""'
    endif
  elseif s:ismac
    if (s:empty(s:termpath) && $TERM_PROGRAM ==? 'iTerm.app') || s:termpath ==? "iterm"
      silent call <sid>mac_open_iTerm(l:dir)
    else
      if s:empty(s:termpath) | let s:termpath = 'Terminal' | endif
      silent exec "!open -a ".s:termpath." '".l:dir."'"
      if !s:isgui | redraw! | endif
    endif
  elseif s:is_gui_available
    if !s:empty(s:termpath)
      silent exec "silent ! ".s:termpath." '".l:dir."' &"
    elseif executable('gnome-terminal')
      silent exec 'silent ! gnome-terminal --window -e "$SHELL -c \"cd '''.l:dir.''' ; $SHELL\"" &'
    else
      call s:beep('failed to open terminal')
    endif
    if !s:isgui | redraw! | endif
  else
    call s:beep('failed to open terminal')
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

call s:init()
