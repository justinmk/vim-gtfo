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

let s:is_windows = has('win32') || has('win64')
let s:is_mac = has('gui_macvim') || has('mac')
let s:is_unix = has('unix')
let s:is_msysgit = (has('win32') || has('win64')) && $TERM ==? 'cygwin'
let s:is_tmux = !(empty($TMUX))
let s:is_gui = has('gui_running') || &term ==? 'builtin_gui'
"TODO
let s:is_linux_gui = 0
"vim may be running in terminal mode, but there may still be a gui available to show the file manager
let s:is_gui_available = s:is_mac || s:is_windows || s:is_linux_gui

func! s:mac_open_terminal()
  let l:cmd = "
        \ set cmd to 'cd \"".expand("%:p:h")."\"'     \n
        \ tell application 'Terminal'                 \n
        \   do script with command cmd                \n
        \   activate                                  \n
        \ end tell                                    \n
        \ "
  let l:cmd = substitute(l:cmd,  "'", '\\"', 'g') 
  call system('osascript -e " ' . l:cmd . '"')
endf

" navigate to the directory of the current file
if maparg('gof', 'n') ==# ''
  if !(s:is_gui_available)
    "fallback
    nnoremap <silent> gof :normal got<cr>
  elseif s:is_windows
    nnoremap <silent> gof :silent !start explorer /select,%:p<cr>
  elseif s:is_mac
    nnoremap <silent> gof :silent execute '!open ' . substitute(expand("%:p:h")," ","\\\\ ","g")<cr>
  endif
endif

" C:\opt\cygwin\bin\bash
let g:cygwin_bash = 'C:\Program Files (x86)\Git\bin\sh.exe'
if maparg('got', 'n') ==# ''
  if s:is_tmux
    nnoremap <silent> got :silent execute '!tmux split-window -h \; ' .  'send-keys "cd "' . substitute(expand("%:p:h")," ","\\\\ ","g") . ' C-m'<cr>
  elseif s:is_windows
    " HACK: Execute bash (again) immediately after -c to prevent exit.
    "   http://stackoverflow.com/questions/14441855/run-bash-c-without-exit
    " NOTE: Yes, these are nested quotes (""foo" "bar""), and yes, that is what cmd.exe expects.
    nnoremap <silent> got :silent exe '!start '.$COMSPEC.' /c ""' . g:cygwin_bash . '" "--login" "-i" "-c" "cd '''.expand("%:h").''' ; bash" "'<cr>
  elseif s:is_mac
    nnoremap <silent> got :silent call <sid>mac_open_terminal()<cr>
  endif
endif

