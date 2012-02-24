" THIS IS AN UNHOLY MIX OF STUFF, THINGS AND WOTSITS. USE AT THINE PROPER PERIL.

" Use Vim defaults instead of 100% vi compatibility
set nocompatible

" Disable mode lines to prevent unwanted code execution (CVE-2007-2438)
set modelines=0

" Searching
set ignorecase
set smartcase
set incsearch
map <F7> :set hlsearch!<CR>

" Interface
set ruler
set laststatus=2
set showmode
set showmatch
set showcmd
set nowrap
set list
set listchars=tab:→\ ,extends:»,precedes:«,trail:▒,nbsp:·
set mouse=a

" Buffers, tabs and windows
nnoremap <Leader>b :buffers<CR>:buffer<Space>

" Splitview options
set splitright
set splitbelow

set tabpagemax=1024

" History
set history=1024
set undolevels=1024

" When editing a file, always jump to the last known cursor position.
autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal g`\"" | endif

" Delete trailing whitespaces on saving a file
autocmd BufWritePre * :%s/\s\+$//e

" Less finger wrecking window navigation.
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l

" Hop from method to method.
nmap <c-n> ]]
nmap <c-p> [[

" Syntax highlighting
color zenburn
syntax on
syntax sync fromstart
set synmaxcol=16384

" Indentation settings
set autoindent

" Do not extend the visual selection beyond the last character.
vnoremap $ $h

" Whitespace settings
set shiftwidth=4
set softtabstop=4
set tabstop=4
set noexpandtab

" Auto-completion
set wildmode=longest,list,full

" Show a menu at the bottom of the vim window.
set wildmenu

" Folding
set foldmethod=marker

" Show line numbers and make them 5 characters wide
map <F6> :set number!<CR>
set numberwidth=5

" Show information concerning the current position in the document.
set ruler
