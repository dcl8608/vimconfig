set nocompatible
set nu
colorscheme desert 
set guifont=courier_new:h16
let &termencoding=&encoding
set fileencodings=utf-8,gbk,ucs-bom,cp936
source $VIMRUNTIME/vimrc_example.vim
source $VIMRUNTIME/mswin.vim
behave mswin
set tabstop=4
set softtabstop=4
set shiftwidth=4
set autoindent
set cindent
set cinoptions={0,1s,t0,n-2,p2s,(03s,=.5s,>1s,=1s,:1s
set expandtab

map ,r ggO#!/bin/ruby<CR><Esc>
map ,b ggO#!/bin/bash<CR><Esc>
map ,, A,<Esc>
map ,; A;<Esc>
inoremap ( ()<Esc>i 
inoremap [ []<Esc>i
inoremap { {}<Esc>i
inoremap " ""<Esc>i
inoremap ,, <Esc>la

" -------- ruby 版本 -------- "
" 映射版权输入"
map ,vr ggo## Copyright(c) Awifi .<CR>## Authored by HONGLIANG ZOU on:<Esc>:read !date <CR>kJ$a<CR>## @desc:<CR>## @history<CR><Esc>
" 映射函数或对象声明"
map ,fr O## Authored by HONGLIANG ZOU on:<Esc>:read !date <CR>kJ$a<CR>## Funcion goal:<CR>## Input arguments:<CR>## OutPut arguments:<CR><Esc>
map ,mr O## Modified by HONGLIANG ZOU on:<Esc>:read !date <CR>kJ$a<CR><Esc>
" 映射插入分割线 "
map ,-r O## ------------------------- 此处为分割线 ------------------------<CR><Esc>


set diffexpr=MyDiff()
function MyDiff()
  let opt = '-a --binary '
  if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
  if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
  let arg1 = v:fname_in
  if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
  let arg2 = v:fname_new
  if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
  let arg3 = v:fname_out
  if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
  let eq = ''
  if $VIMRUNTIME =~ ' '
    if &sh =~ '\<cmd'
      let cmd = '""' . $VIMRUNTIME . '\diff"'
      let eq = '"'
    else
      let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '\diff"'
    endif
  else
    let cmd = $VIMRUNTIME . '\diff'
  endif
  silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3 . eq
endfunction
