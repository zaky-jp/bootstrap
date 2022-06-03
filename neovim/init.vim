" jetpack
" install if not already
for name in jetpack#names()
  if !jetpack#tap(name)
    call jetpack#sync()
    break
  endif
endfor

call jetpack#begin()
call jetpack#add('cohama/lexima.vim')
call jetpack#add('luochen1990/rainbow')
call jetpack#add('ekalinin/Dockerfile.vim')
call jetpack#add('tpope/vim-surround')
call jetpack#add('tomtom/tcomment_vim')
call jetpack#add('isobit/vim-caddyfile')
call jetpack#add('overcache/NeoSolarized')
call jetpack#end()

" ruler
set number
set relativenumber

" tabstop
set expandtab
set tabstop=2
set softtabstop=2
set shiftwidth=2
set autoindent
set smartindent

"show invisibles
set list
set listchars=tab:>-,eol:$,trail:_,extends:❯,precedes:❮,nbsp:%

" parentheses
let g:rainbow_active=1
set showmatch
set matchpairs+=<:>

" misc
set mouse=a
set clipboard+=unnamedplus 
set modelines=3
set autochdir

" colorscheme
set termguicolors
colorscheme NeoSolarized

syntax on

set background=light

