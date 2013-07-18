
let s:save_cpo = &cpo
set cpo&vim

if exists( "g:loaded_pycmake" )
  finish
elseif !has( 'python' )
  echohl WarningMsg |
        \ echomsg "pycmake unavailable: requires python 2.x support" |
        \ echohl None
  finish
endif

let s:script_folder_path = escape( expand( '<sfile>:p:h' ), '\' )


function! s:UpdateIncludePath()
  py import vim
  py import sys
  py import os
  exe 'python sys.path.insert( 0, "' . s:script_folder_path . '/../python" )'
  py from cmake_helper import find_includes
  python << EOF
fname = vim.eval("expand('%:t')")
cdir = vim.eval("expand('%:p:h')")
incs = []
for p in find_includes(base_dir=cdir):
  vim.command("set path+={}".format(p))
  incs.append(p)
vim.command("let g:syntastic_c_include_dirs = {}".format(incs))
vim.command("let g:syntastic_cpp_include_dirs = {}".format(incs))
EOF
endfunction

augroup pycmake
  autocmd FileType c,cpp call s:UpdateIncludePath()
augroup END

let g:loaded_pycmake = 1

" This is basic vim plugin boilerplate
let &cpo = s:save_cpo
unlet s:save_cpo
