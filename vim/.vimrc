" Vim Configuration File
" Author: @edurso
" Modified by @Fr1tzBot

" CONFIGURATION VARS

let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

" <leader>
let mapleader=","

" indent based on filetype
"filetype plugin indent on
filetype indent on

" COLORSCHEME

syntax on
colorscheme gruvbox

" COLORSCHEME END

" SETTINGS

set termguicolors
set autoindent
set nostartofline
set confirm
set mouse=a
set tabstop=4
set softtabstop=0
set shiftwidth=4
set smartindent
set cindent
set expandtab
set number
set title
set showcmd
set cursorline
set wildmenu
set showmatch
set emoji
set noshowcmd
set noshowmode
set hls
set ic
set is
set nocursorline
set nocursorcolumn
set scrolljump=5
set lazyredraw
set redrawtime=10000
set synmaxcol=180
set re=1
set hidden
set nobackup
set nowritebackup
set cmdheight=1
set updatetime=300
set shortmess+=c
set signcolumn=yes

set whichwrap+=<,>,[,]
set backspace=indent,eol,start
set t_ut=

" SETTINGS END


" STATUSLINE

"set laststatus=2 " make statusline visible
"set stl= " initialize
"set stl+=%#CursorIM#
"set stl+=\ %(%{$USER}%)\  " print username
"set stl+=%#DiffAdd#%{(mode()=='n')?'\ \ NORMAL\ \ ':''} " editor mode
"set stl+=%#DiffChange#%{(mode()=='i')?'\ \ INSERT\ \ ':''} " editor mode
"set stl+=%#Cursor#%{(mode()=='r')?'\ \ REPLACE\ \ ':''} " editor mode
"set stl+=%#DiffDelete#%{(mode()=='v')?'\ \ VISUAL\ \ ':''} " editor mode
"set stl+=%#CursorLineNR# " visual mode background
"set stl+=%(\ %{gitbranch#name()}\ %) " print git branch
"set stl+=%#Visual# " visual mode background
"set stl+=%{&paste?'\ PASTE\ ':''}
"set stl+=%{&spell?'\ SPELL\ ':''}
"set stl+=%#DiffChange#%R " readonly flag
"set stl+=%#DiffDelete#%{&mod?'\ UNSAVED\ ':''} " add "UNSAVED" if file has changed
"set stl+=%#Cursor#
"set stl+=\ %t\  " filename
"set stl+=%#CursorLineNR#
"set stl+=%= " allign to right
"set stl+=%#CursorIM#
"set stl+=\ %p%% " percent through file
"set stl+=\ \|\ Line%3l\ \| " line number and formatting
"set stl+=\ %Y\ \| " file type
"set stl+=\ %{&fileencoding?&fileencoding:&encoding}\ -\  " file encoding
"set stl+=\[%{&fileformat}]\ \  " file formt
"set stl+=\|\ %3l:%-2c\  " linenum:columnum
"set stl+= " end

" STATUSLINE END


" FUNCTIONS

" check if last inserted char is a backspace (used by coc pmenu)
"function! s:check_back_space() abort
"    let col = col('.') - 1
"    return !col || getline('.')[col - 1]  =~# '\s'
"endfunction

" coc show documentation in window
"function! s:show_documentation()
"    if (index(['vim','help'], &filetype) >= 0)
"        execute 'h '.expand('<cword>')
"    elseif (coc#rpc#ready())
"        call CocActionAsync('doHover')
"    else
"        execute '!' . &keywordprg . " " . expand('<cword>')
"    endif
"endfunction

" FUNCTIONS END


" COMMANDS

" general
au BufEnter * set fo-=c fo-=r fo-=o " stop annoying auto commenting on new lines
"au FileType help wincmd L " open help in vertical split
au BufWritePre * :%s/\s\+$//e " remove trailing whitespaces before saving
" return to last edit position when opening files
autocmd BufReadPost *
            \ if line("'\"") > 0 && line("'\"") <= line("$") |
            \   exe "normal! g`\"" |
            \ endif

" nerdtree
"autocmd BufWinEnter * silent NERDTreeMirror " Open the existing NERDTree on each new tab.
"autocmd VimEnter * NERDTree | wincmd p " Open NERDTree when Vim is opened
" Exit Vim if NERDTree is the only window left.
"autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() |
"            \ quit | endif

" jsonc
"autocmd FileType json syntax match Comment +\/\/.\+$+

" coc
"autocmd CursorHold * silent call CocActionAsync('highlight') " highlight the symbol and its references when holding the cursor
"command! -nargs=0 OR :call CocAction('runCommand', 'editor.action.organizeImport')

" autoformat
"au BufWrite * :Autoformat " autoformat on write

" fzf
"command! -bang -nargs=? -complete=dir Files
"            \ call fzf#vim#files(<q-args>, fzf#vim#with_preview({'options': ['--layout=reverse', '--inline-info']}), <bang>0)

" COMMANDS END


" KEYMAPS

" general
noremap q :wq<CR>
noremap q! :q!<CR>
noremap qa :qa<CR>

" switch between splits using ctrl + {h,j,k,l}
inoremap <C-h> <C-\><C-N><C-w>h
inoremap <C-j> <C-\><C-N><C-w>j
inoremap <C-k> <C-\><C-N><C-w>k
inoremap <C-l> <C-\><C-N><C-w>l
nnoremap <C-h> <C-w>h
noremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" show mapping on all modes with F1
"nmap <F1> <plug>(fzf-maps-n)
"imap <F1> <plug>(fzf-maps-i)
"vmap <F1> <plug>(fzf-maps-x)

" new line in normal mode and back
"map <Enter> o<ESC>
"map <S-Enter> O<ESC>

" use a different register for delete and paste
nnoremap d "_d
vnoremap d "_d
vnoremap p "_dP
nnoremap x "_x

" list colorschemes
nmap <leader>c :Colors<CR>
nmap cs <leader>c

" list files
"nmap <leader>f :Files<CR>
"nmap f <leader>f

" list git commit history
"nmap <leader>gc :Commits<CR>
"nmap gc <leader>gc
"nmap <leader>g gc

" list open buffers
"nmap <leader>b :Buffers<CR>

" startify
"nmap <leader>s :Startify<CR>
"nmap s <leader>s

" comment toggle
"nmap cc <Plug>NERDCommenterToggle
"vmap cc <Plug>NERDCommenterToggle<CR>gv

" Refresh nvim (run init script again)
"nmap <leader>r :so ~/.config/nvim/init.vim<CR>

" show hackernews
"nmap hn <C-w>v<C-w>l:HackerNews best<CR>J
"nmap <leader>h hn

" gradle key maps
"nnoremap <F5> :!./gradlew deploy<CR>
"nnoremap gb :!./gradlew build<CR>

" formatter
"nnoremap <F3> :Autoformat<CR>

" nerdtree
"nnoremap <C-n> :NERDTreeMirror<CR>:NERDTreeFocus<CR>

" vundle
"noremap <leader>pi :PluginInstall<CR>
"noremap <leader>pu :PluginUpdate<CR>
"noremap <leader>pu :PluginUpgrade<CR>
"noremap <leader>ps :PluginStstus<CR>
"noremap <leader>pc :PluginClean<CR>

" coc
"inoremap <silent><expr> <TAB>
"            \ pumvisible() ? "\<C-n>" :
"            \ <SID>check_back_space() ? "\<TAB>" :
"            \ coc#refresh()
"inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
"inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<CR>"
"nmap <silent> <C-a> <Plug>(coc-cursors-word)
"xmap <silent> <C-a> <Plug>(coc-cursors-range)
"nmap <silent> [g <Plug>(coc-diagnostic-prev)
"nmap <silent> ]g <Plug>(coc-diagnostic-next)
"nmap <leader>rn <Plug>(coc-rename)
"nmap <leader>o :OR <CR>
"nmap <leader>jd <Plug>(coc-definition)
"nmap <leader>jy <Plug>(coc-type-definition)
"nmap <leader>ji <Plug>(coc-implementation)
"nmap <leader>jr <Plug>(coc-references)
"nnoremap <silent> K :call <SID>show_documentation()<CR>
"nmap <leader>a <Plug>(coc-codeaction-line)
"xmap <leader>a <Plug>(coc-codeaction-selected)
"nmap co :CocConfig<CR>
"nmap cl :CocList<CR>

" KEYMAPS END


set bg=dark
hi Normal guibg=NONE ctermbg=NONE

