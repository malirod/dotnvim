set encoding=utf-8
scriptencoding utf-8
" use comma key as <leader>
let mapleader=','
let $MYNVIMRC=$HOME.'/.config/nvim/init.vim'

" Auto-install vim-plug
if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall
endif

call plug#begin('~/.config/nvim/plugged')

" Color schemes
Plug 'freeo/vim-kalisi'
Plug 'jonathanfilip/vim-lucius'
Plug 'tomasr/molokai'

" Set of default configuratios
Plug 'tpope/vim-sensible'

" CtrlP pluging: fuzzy file search
Plug 'kien/ctrlp.vim'

" vim-airline/vim-airline
Plug 'vim-airline/vim-airline'

" vim-airline/vim-airline-themes
Plug 'vim-airline/vim-airline-themes'

" NerdTree
Plug 'scrooloose/nerdtree'

" Syntastic
Plug 'scrooloose/syntastic'

" Fugitive
Plug 'tpope/vim-fugitive'

" TagBar
Plug 'majutsushi/tagbar'

" FSwitch
Plug 'derekwyatt/vim-fswitch'

" YouCompleteMe
Plug 'Valloric/YouCompleteMe', { 'do': './install.py --clang-completer' }

" Initialize plugin system
call plug#end()

" Basic configuration

" setup colorscheme
colorscheme molokai

" automatically reread Vim's configuration after writing it
autocmd! BufWritePost $MYNVIMRC source $MYNVIMRC

" show at most 20 suggestions on z=
set spellsuggest+=10

" smart indentation
filetype plugin indent on

" extends directory for tags file search (from current to root)
set tags=tags;/

" save indentation when going to next line
set autoindent

" save indentation when going to next line
" save indentation when going to next line
" increase history size
set history=10000

" automatically reread file changed by external application
set autoread

" show tab line always
set showtabline=2
" enable line numbers
set number
" number of columns for line number
set numberwidth=5

" some shortcuts
map <leader>1 :tab drop $MYNVIMRC<cr>

" highlight current line
set cursorline

" use Ctrl-n/Ctrl-p to switch between tabs
nnoremap <c-n> gt
nnoremap <c-p> gT

" show/hide folds on space
nnoremap <space> za

" toggle line wrapping on <leader>w
nmap <leader>w :set wrap!<cr>

" copy&paste to system's clipboard
nmap <leader>y "+y
nmap <leader>Y "+Y
nmap <leader>p "+p

" don't loose selection in visual mode on < and >
vnoremap < <gv
vnoremap > >gv

" smart case policy on search
set ignorecase
set smartcase


" Show vertical bar
autocmd BufEnter,BufWinEnter,WinEnter * :call <SID>SetParams()
function! <SID>SetParams()
    if search('^[^a-z]*vim: .*colorcolumn=', 'nw') != 0
        return
    endif
    let l:nocc = ['', 'gitrebase', 'gitcommit', 'qf', 'help', 'git']
    if index(l:nocc, &filetype) == -1
        " vertical border after 80 column
        set colorcolumn=81
    else
        " no vertical border
        set colorcolumn=0
    endif
endfunction

function! GenerateTags()
    " Setup excludes
    if exists("g:ctag_options")
        let l:ctag_options = g:ctag_options
    else
        let l:ctag_options = ''
    endif

    if has('win32')
        execute ":silent !start /b ctags -R -a --c++-kinds=+p ".l:ctag_options
                \." --fields=+iaS --extra=+q ."
    else
        execute ":silent !ctags -R -a --c++-kinds=+p ".l:ctag_options
                \." --fields=+iaS --extra=+q ."
    endif

endfunction

" create tags on Shift-F12 key
nmap <silent> <s-f12> :call GenerateTags()<cr>

noremap <leader>p :set paste<CR>:put *<CR>:set nopaste<CR>

" ------------------------------------------------------------------------------
" modification for Enter key in normal mode

" break current line into two on Enter key (except some windows)
autocmd BufReadPost,BufEnter,BufWinEnter,WinEnter  *
            \ if &filetype == 'qf' |
            \ elseif &filetype == 'vifm-cmdedit' |
            \ elseif &filetype == 'vifm-edit' |
            \ elseif bufname("%") == '__TagBar__' |
            \ elseif !&modifiable |
            \ elseif &readonly |
            \ else |
            \     nmap <buffer> <expr> <cr> MyEnter() |
            \ endif
function! MyEnter()
    if &filetype == 'qf'
        return "\<cr>"
    elseif bufname("%") == '__TagBar__'
        return "\<cr>"
    elseif !&modifiable
        return "\<cr>"
    elseif &readonly
        return "\<cr>"
    else
        return "i\<cr>\<esc>"
    endif
endfunction

" Plugins setup

" ------------------------------------------------------------------------------
" CtrlP

" setup ignore
let g:ctrlp_custom_ignore = { 'file': '\v\.(pyc|so)$'}
" Find buffers (find buffer)
nnoremap <leader>fb :CtrlPBuffer<CR>
" Find files (find files)
nnoremap <leader>ff :CtrlP<CR>
" Change the default mapping (find mixed)
let g:ctrlp_map = '<leader>fm'
let g:ctrlp_cmd = 'CtrlP'

" ------------------------------------------------------------------------------
" NERDTree

" map NERDTree toggle
nmap <leader>n :NERDTreeToggle<cr>

" open a NERDTree automatically when vim starts up if no files were specified
"autocmd vimenter * if !argc() | NERDTree | endif

" select current file in NERDTree
map <leader>r :NERDTreeFind<cr>

" close tree on file open
let NERDTreeQuitOnOpen = 1

" Filter out files
let NERDTreeIgnore = ['\.pyc$']

" ------------------------------------------------------------------------------
" Vim Airline

let g:airline#extensions#tabline#enabled = 1
let g:airline_theme='simple'

" ------------------------------------------------------------------------------
" Syntastic
let g:syntastic_python_checkers = ['pylint']

function! FindConfig(prefix, what, where)
    let cfg = findfile(a:what, escape(a:where, ' ') . ';')
    return cfg !=# '' ? '' . a:prefix . '' . shellescape(cfg) : ''
endfunction

autocmd FileType python let b:syntastic_python_pylint_args =
    \ get(g:, 'syntastic_python_pylint_args', '') .
    \ FindConfig('--rcfile=', '.pylintrc', expand('<afile>:p:h', 1))

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 1

autocmd FileType python map <buffer> <leader>8 :SyntasticCheck<CR>

" ------------------------------------------------------------------------------
" Fugitive

" Map Gstatus
nnoremap <leader>gs :Gstatus<CR>

" Map Gdiff
nnoremap <leader>gd :Gdiff<CR>

" Map Gcommit
nnoremap <leader>gci :Gcommit<CR>

" ------------------------------------------------------------------------------
" TagBar

" expand window when it's needed
let g:tagbar_expand = 1

" omit odd empty lines
let g:tagbar_compact = 1

" capture cursor on popup
let g:tagbar_autofocus = 1

" close TagBar after tag was selected
"let g:tagbar_autoclose = 1

" map tagbar toggle on ,t
nmap <leader>t :TagbarToggle<cr>

" ------------------------------------------------------------------------------
" YouCompleteMe

" populate locations list (:lopen \ :lclose)
let g:ycm_always_populate_location_list = 1
" usage of the tag file cause the huge memory usage
" by the plugin(python process)
" Related issue: https://github.com/Valloric/YouCompleteMe/issues/595
let g:ycm_collect_identifiers_from_tags_files = 0

" map build action
nnoremap <leader>Q :YcmForceCompileAndDiagnostics<CR>

let g:ycm_confirm_extra_conf = 0

" ------------------------------------------------------------------------------
" FSwitch

" autocommands to setup settings for different file types
augroup fswitch
    autocmd!
    autocmd! BufEnter,BufRead *.h let b:fswitchdst = 'cc,cpp,c'
                              \ | let b:fswitchlocs = '.'
    autocmd! BufEnter,BufRead *.c let b:fswitchdst = 'h'
                              \ | let b:fswitchlocs = '.'
    autocmd! BufEnter,BufRead *.hpp let b:fswitchdst = 'cpp,cc'
                              \ | let b:fswitchlocs = '.'
    autocmd! BufEnter,BufRead *.cpp let b:fswitchdst = 'hpp,h'
                                \ | let b:fswitchlocs = '.'
    autocmd! BufEnter,BufRead *.cc let b:fswitchdst = 'h,hpp'
                                \ | let b:fswitchlocs = '.'
    autocmd! BufEnter,BufRead *.xaml let b:fswitchdst = 'xaml.cs'
                              \ | let b:fswitchlocs = '.'
    autocmd! BufEnter,BufRead *.xaml.cs let b:fswitchdst = 'xaml'
                              \ | let b:fswitchfnames = '/\.xaml//'
                              \ | let b:fswitchlocs = '.'
augroup end

" switch to the file and load it into the current window
nmap <silent> <Leader>of :FSHere<cr>

" in current window
nmap <silent> <Leader>oo :FSHere<cr>
" in a new tab
nmap <silent> <Leader>ot :call FSwitch('%', 'tabedit')<cr>

" switch to the file and load it into the window on the right
nmap <silent> <Leader>ol :FSRight<cr>

" switch to the file and load it into a new window split on the right
nmap <silent> <Leader>oL :FSSplitRight<cr>

" switch to the file and load it into the window on the left
nmap <silent> <Leader>oh :FSLeft<cr>

" switch to the file and load it into a new window split on the left
nmap <silent> <Leader>oH :FSSplitLeft<cr>

" switch to the file and load it into the window above
nmap <silent> <Leader>ok :FSAbove<cr>

" switch to the file and load it into a new window split above
nmap <silent> <Leader>oK :FSSplitAbove<cr>

" switch to the file and load it into the window below
nmap <silent> <Leader>oj :FSBelow<cr>

" switch to the file and load it into a new window split below
nmap <silent> <Leader>oJ :FSSplitBelow<cr>
