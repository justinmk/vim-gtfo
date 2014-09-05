" gtfo.vim - Go to Terminal or File manager
" Author:       Justin M. Keyes
" Version:      2.0.0

if exists('g:loaded_gtfo') || &compatible
  finish
endif
let g:loaded_gtfo = 1

" Turn on support for line continuations when creating the script
let s:cpo_save = &cpo
set cpo&vim

if maparg('gof', 'n') ==# ''
  nnoremap <silent> gof :<c-u>call gtfo#open#file("%:p")<cr>
endif
if maparg('got', 'n') ==# ''
  nnoremap <silent> got :<c-u>call gtfo#open#term("%:p:h", "")<cr>
endif
if maparg('goF', 'n') ==# ''
  nnoremap <silent> goF :<c-u>call gtfo#open#file(getcwd())<cr>
endif
if maparg('goT', 'n') ==# ''
  nnoremap <silent> goT :<c-u>call gtfo#open#term(getcwd(), "")<cr>
endif

let &cpo = s:cpo_save
unlet s:cpo_save

