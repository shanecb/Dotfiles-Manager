" Mouse Support
set mouse=a

" Make line numbers visible by default
set number

" Change tab to be 4 spaces
set shiftwidth=4
set tabstop=4
set softtabstop=0
set expandtab
set smarttab
set autoindent

" Make wrapped lines start on the same column as the line they're wrapped from
set breakindent
set breakindentopt=shift:3 " wrapped lines tabbed over 3 columns from column they wrapped from

" Turn on syntax highlighting
syntax on

" Set Encoding
set encoding=utf-8

" Key Mappings
nnoremap <CR> G
inoremap nn <Esc>
inoremap jj <Esc>
cnoremap <Up> <Up>

set timeoutlen=300

