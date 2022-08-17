let s:iswin = has('win32') || has('win64') || has('win32unix') || has('win64unix')
let s:ismac = has('gui_macvim') || has('mac')
let s:istmux = !(empty($TMUX))
let s:iswezterm = $WEZTERM_PANE !=? ''
let s:iskitty = $KITTY_LISTEN_ON !=? ''
"GUI Vim
let s:isgui = has('gui_running') || &term ==? 'builtin_gui'
"non-GUI Vim running within a GUI environment
let s:is_gui_available = s:ismac || s:iswin || (!empty($DISPLAY) && $TERM !=# 'linux')

let s:termpath = ''
let s:tmux_1_6 = 0

func! s:beep(s) abort
  echohl ErrorMsg | echom 'gtfo: '.a:s | echohl None
endf
func! s:trimws(s) abort
  return substitute(a:s, '^\s*\(.\{-}\)\s*$', '\1', '')
endf
func! s:scrub(s) abort
  "replace \\ with \ (greedy) #21
  return substitute(a:s, '\\\\\+', '\', 'g')
endf
func! s:empty(s) abort
  return strlen(s:trimws(a:s)) == 0
endf

func! s:init() abort
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

  if s:istmux
    call system('tmux -V')
    let s:tmux_1_6 = v:shell_error
  endif
endf

func! s:try_find_git_bin(binname) abort
  "try 'Program Files', else fall back to 'Program Files (x86)'.
  for programfiles_path in [$ProgramW6432, $ProgramFiles, $ProgramFiles.' (x86)', $SCOOP.'/apps']
    let path = substitute(programfiles_path, '\', '/', 'g').'/'.a:binname
    if executable(path)
      return path
    endif
  endfor
  return ''
endf

func! s:find_cygwin_bash() abort
  let path = s:try_find_git_bin('Git/usr/bin/mintty.exe')
  let path = '' !=# path ? path : s:try_find_git_bin('Git/bin/bash.exe')
  let path = '' !=# path ? path : s:try_find_git_bin('git/current/usr/bin/mintty.exe')
  "return path or fallback to vanilla cygwin.
  return '' !=# path ? path :
        \ (executable($SystemDrive.'/cygwin/bin/bash') ? $SystemDrive.'/cygwin/bin/bash' : '')
endf

func! s:force_cmdexe() abort
  if &shell !~? "cmd" || &shellslash
    let s:shell=&shell | let s:shslash=&shellslash | let s:shcmdflag=&shellcmdflag
    let &shell=$COMSPEC
    set noshellslash shellcmdflag=/c
  endif
endf
func! s:restore_shell() abort
  if exists("s:shell")
    let &shell=s:shell | let &shellslash=s:shslash | let &shellcmdflag=s:shcmdflag
  endif
endf

func! s:cygwin_cmd(path, dir, validfile) abort
  let startcmd = executable('cygstart') ? 'cygstart' : 'start'
  return a:validfile
        \ ? startcmd.' explorer /select,$(cygpath -w '.shellescape(a:path).')'
        \ : startcmd.' explorer $(cygpath -w '.shellescape(a:dir).')'
endf

func! gtfo#open#file(path) abort "{{{
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

  if has('win32unix')
    silent call system(s:cygwin_cmd(l:path, l:dir, l:validfile))
  elseif s:iswin
    call s:force_cmdexe()
    silent exec '!start explorer '.(l:validfile ? '/select,'.shellescape(l:path, 1) : shellescape(l:dir, 1))
    call s:restore_shell()
  elseif !s:is_gui_available && !executable('xdg-open')
    if s:istmux "fallback to 'got'
      call gtfo#open#term(l:dir, "")
    else
      call s:beep('failed to open file manager')
    endif
  elseif s:ismac
    if l:validfile
      silent call system('open --reveal '.shellescape(l:path))
    else
      silent call system('open '.shellescape(l:dir))
    endif
  elseif executable('xdg-open')
    silent call system("xdg-open ".shellescape(l:dir)." &")
  else
    call s:beep('xdg-open is not in your $PATH. Try "sudo apt-get install xdg-utils"')
  endif
endf "}}}

func! gtfo#open#term(dir, cmd) abort "{{{
  let l:dir = s:scrub(expand(a:dir, 1))
  if !isdirectory(l:dir) "this happens if a directory was deleted outside of vim.
    call s:beep('invalid/missing directory: '.l:dir)
    return
  endif

  if s:istmux
    if s:tmux_1_6
      silent call system('tmux split-window -h \; send-keys "cd ''' . l:dir . ''' && clear" C-m')
    else
      silent call system("tmux split-window -h -c '" . l:dir . "'")
    endif
  elseif s:iskitty
    let l:cwd = s:iswin ? shellescape(l:dir, 1) : "'" . l:dir .  "'"
    silent call system("kitty @ --to=$KITTY_LISTEN_ON new-window --cwd=" . l:cwd)
  elseif s:iswezterm
    let l:cwd = s:iswin ? shellescape(l:dir, 1) : "'" . l:dir .  "'"
    silent call system("wezterm cli split-pane --cwd=" . l:cwd)
  elseif &shell !~? "cmd" && executable('cygstart') && executable('mintty')
    " https://github.com/mintty/mintty/wiki/Tips
    silent exec '!cd '.shellescape(l:dir, 1).' && cygstart mintty /bin/env CHERE_INVOKING=1 /bin/bash'
    if !s:isgui | redraw! | endif
  elseif s:iswin && &shell !~? "cmd" && executable('mintty')
    silent call system('cd '.shellescape(l:dir).' && mintty - &')
  elseif s:iswin
    call s:force_cmdexe()
    if s:isgui
      " Prevent cygwin/msys from inheriting broken $VIMRUNTIME.
      " WEIRD BUT TRUE: This correctly unsets $VIMRUNTIME in the child shell,
      "                 without modifying $VIMRUNTIME in the running gvim.
      let $VIMRUNTIME=''
    endif
    let drive = matchstr(l:dir, '^\s*\S:')
    let cmdsep = (s:termpath =~? 'powershell') ? ' ; ' : ' & '
    let cdcmd = ( '' ==# drive ? '' : drive.cmdsep ).'cd '.shellescape(l:dir, 1)

    if s:termpath =~? 'bash' && executable('bash')
      silent exe '!start '.$COMSPEC.' /c "'.cdcmd.' & "'.s:termpath.'" --login -i "'
    elseif s:termpath =~? 'mintty' && executable('mintty')
      silent exe '!start /min '.$COMSPEC.' /c "'.cdcmd.' & "'.s:termpath.'" - " & exit'
    elseif s:termpath =~? 'powershell' && executable('powershell')
      silent exe '!start '.s:termpath.' \"'.cdcmd.'\"'
    else "Assume it is a path-plus-arguments.
      if s:empty(s:termpath) | let s:termpath = 'cmd.exe /k'  | endif
      " This will nest quotes (""foo" "bar""), and yes, that is what cmd.exe expects.
      silent exe '!start '.s:termpath.' "'.cdcmd.'"'
    endif
    call s:restore_shell()
  elseif s:ismac
    if (s:empty(s:termpath) && $TERM_PROGRAM ==? 'iTerm.app') || s:termpath ==? "iterm"
      silent call system("open -a iTerm ".shellescape(l:dir))
    else
      if s:empty(s:termpath) | let s:termpath = 'Terminal' | endif
      silent call system("open -a ".shellescape(s:termpath)." ".shellescape(l:dir))
    endif
  elseif s:is_gui_available
    if !s:empty(s:termpath)
      silent call system(s:termpath." ".shellescape(l:dir))
    elseif executable('gnome-terminal')
      silent call system('gnome-terminal --app-id=org.gnome.Terminal --window --working-directory '''. l:dir . '''')
    else
      call s:beep('failed to open terminal')
    endif
    if !s:isgui | redraw! | endif
  else
    call s:beep('failed to open terminal')
  endif
endf "}}}

call s:init()
