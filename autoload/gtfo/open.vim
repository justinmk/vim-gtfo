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
func! s:scrub(s)
  "replace \\ with \ (greedy) #21
  return substitute(a:s, '\\\\\+', '\', 'g')
endf
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

func! s:force_cmdexe()
  if &shell !~? "cmd"
    let s:shell=&shell | let s:shslash=&shellslash | let s:shcmdflag=&shellcmdflag
    set shell=$COMSPEC noshellslash shellcmdflag=/c
  endif
endf

func! s:restore_shell()
  if exists("s:shell")
    let &shell=s:shell | let &shellslash=s:shslash | let &shellcmdflag=s:shcmdflag
  endif
endf

func! gtfo#open#file(path) "{{{
  if exists('+shellslash') && &shellslash
    "Windows: force expand() to return `\` paths so explorer.exe won't choke. #11
    let l:shslash=1 | set noshellslash
  endif

  let l:path = s:scrub(expand(a:path, 1))
  let l:dir = isdirectory(l:path) ? l:path : fnamemodify(l:path, ":h")
  let l:validfile = filereadable(l:path)

  if exists("l:shslash")
    set shellslash
  endif

  if !isdirectory(l:dir) "this happens if the directory was moved/deleted.
    echom 'gtfo: invalid/missing directory: '.l:dir
    return
  endif

  if s:iswin
    call s:force_cmdexe()
    silent exec '!start explorer '.(l:validfile ? '/select,"'.l:path.'"' : l:dir)
    call s:restore_shell()
  elseif executable('cygstart')
    if l:validfile
      silent exec "!cygstart explorer /select,`cygpath -w '".l:path."'`"
    else
      silent exec "!cygstart explorer `cygpath -w '".l:dir."'`"
    endif
    if !s:isgui | redraw! | endif
  elseif !s:is_gui_available && !executable('xdg-open')
    if s:istmux "fallback to 'got'
      call gtfo#open#term(l:dir, "")
    else
      call s:beep('failed to open file manager')
    endif
  elseif s:ismac
    if l:validfile
      silent call system("open --reveal '".l:path."'")
    else
      silent call system("open '".l:dir."'")
    endif
  elseif executable('xdg-open')
    silent call system("xdg-open '".l:dir."' &")
  else
    call s:beep('xdg-open is not in your $PATH. Try "sudo apt-get install xdg-utils"')
  endif
endf "}}}

func! gtfo#open#term(dir, cmd) "{{{
  let l:dir = s:scrub(expand(a:dir, 1))
  if !isdirectory(l:dir) "this happens if a directory was deleted outside of vim.
    call s:beep('invalid/missing directory: '.l:dir)
    return
  endif

  if s:istmux
    silent call system('tmux split-window -h \; send-keys "cd ''' . l:dir . ''' && clear" C-m')
  elseif &shell !~? "cmd" && executable('cygstart') && executable('mintty')
    " https://code.google.com/p/mintty/wiki/Tips
    silent exec '!cd ''' . l:dir . ''' && cygstart mintty /bin/env CHERE_INVOKING=1 /bin/bash'
    if !s:isgui | redraw! | endif
  elseif s:iswin
    call s:force_cmdexe()
    if s:termpath =~? "bash" && executable(s:termpath)
      silent exe '!start '.$COMSPEC.' /c "cd "'.l:dir.'" & "' . s:termpath . '" --login -i "'
    else "Assume it's a path with the required arguments (considered 'not executable' by Vim).
      if s:empty(s:termpath) | let s:termpath = 'cmd.exe /k'  | endif
      " Yes, these are nested quotes (""foo" "bar""), and yes, that is what cmd.exe expects.
      silent exe '!start '.s:termpath.' "cd "'.l:dir.'""'
    endif
    call s:restore_shell()
  elseif s:ismac
    if (s:empty(s:termpath) && $TERM_PROGRAM ==? 'iTerm.app') || s:termpath ==? "iterm"
      silent call system("open -a iTerm '".l:dir."'")
    else
      if s:empty(s:termpath) | let s:termpath = 'Terminal' | endif
      silent call system("open -a ".s:termpath." '".l:dir."'")
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

call s:init()
