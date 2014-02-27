
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
  py import subprocess
  exe 'python sys.path.insert( 0, "' . s:script_folder_path . '/../python" )'
  py from cmake_helper import find_includes, find_git_ctags
  python << EOF
fname = vim.eval("expand('%:t')")
cdir = vim.eval("expand('%:p:h')")
incs = []
#if not os.path.exists('/tmp/tags'):
#  subprocess.call('mkdir /tmp/tags'.split())
for p in find_includes(fname, base_dir=cdir):
  vim.command("set path+={}".format(p))
  #  tagfile = '/tmp/tags/{}.tags'.format(p.replace('/', '_').replace('.', '_'))
  #  if not os.path.exists(tagfile):
  #    subprocess.call('touch {}'.format(tagfile).split())
  #    with open(os.devnull) as dn:
  #      subprocess.call('ctags -R --languages=c,c++ --c++-kinds=+p '
  #      '--fields=+iaS --extra=+q -f {} {}'.format(tagfile, p).split(),
  #      stdout=dn, stderr=dn)
  incs.append(p)
tagfile = find_git_ctags(base_dir=cdir)
if tagfile is not None:
  vim.command('set tags+={}'.format(tagfile))
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
