if !1 | finish | endif

"------------------------------------
" OSの判定
"------------------------------------
let OSTYPE = system('uname')

"------------------------------------
" dein
"------------------------------------
"{{{
"dein Scripts-----------------------------
if &compatible
    set nocompatible               " Be iMproved
endif
set runtimepath+=~/.cache/dein/repos/github.com/Shougo/dein.vim
if dein#load_state('~/.cache/dein/')
    call dein#begin('~/.cache/dein/')
    call dein#add('~/.cache/dein/repos/github.com/Shougo/dein.vim')
    let g:rc_dir    = expand('~/.vim/rc')
    let s:toml      = g:rc_dir . '/dein.toml'
    let s:lazy      = g:rc_dir . '/lazy.toml'
    call dein#load_toml(s:toml,      {'lazy': 0})
    call dein#load_toml(s:lazy,      {'lazy': 1})
    call dein#end()
    call dein#save_state()
endif
filetype plugin indent on
syntax enable
if dein#check_install()
    call dein#install()
endif
"End dein Scripts-------------------------
" }}}

"------------------------------------
" デフォルトの人たち
"------------------------------------
"{{{
set modelines=0
set backspace=2
au BufWrite /private/tmp/crontab.* set nowritebackup nobackup
au BufWrite /private/etc/pw.* set nowritebackup nobackup
"}}}

"------------------------------------
" 補完の設定
"------------------------------------
"{{{
let g:deoplete#enable_at_startup = 1
set completeopt=menuone
"}}}

"------------------------------------
" ペーストができるように
"------------------------------------
"{{{
if &term =~ "xterm"
    let &t_ti .= "\e[?2004h"
    let &t_te .= "\e[?2004l"
    let &pastetoggle = "\e[201~"
    function! XTermPasteBegin(ret)
        set p;ste
        return a:ret
    endfunction
    noremap <special> <expr> <Esc>[200~ XTermPasteBegin("0i")
    inoremap <special> <expr> <Esc>[200~ XTermPasteBegin("")
    cnoremap <special> <Esc>[200~ <nop>
    cnoremap <special> <Esc>[201~ <nop>
endif
"}}}

"------------------------------------
" 基本的なキーマッピング
"------------------------------------
"{{{
map <Space> <Plug>(operator-replace)

nnoremap == gg=G''

nnoremap n nzz
nnoremap N Nzz
nnoremap * *zz
nnoremap # #zz
nnoremap g* g*zz
nnoremap g# g#zz

nnoremap x "_x

nnoremap j gj
vnoremap j gj
nnoremap gj j
vnoremap gj j
nnoremap k gk
vnoremap k gk
nnoremap gk k
vnoremap gk k
nnoremap <Up> gk
nnoremap <Down> j
vnoremap <Up> gk
vnoremap <Down> j

nnoremap ZZ <Nop>
nnoremap ZQ <Nop>
nnoremap Q gq
"}}}

"------------------------------------
" 画面分割(キーマッピング)
"------------------------------------
"{{{
noremap vs :vs<CR>
nnoremap s <Nop>
nnoremap sj <C-w>j
nnoremap sk <C-w>k
nnoremap sl <C-w>l
nnoremap sh <C-w>h
nnoremap sJ <C-w>J
nnoremap sK <C-w>K
nnoremap sL <C-w>L
nnoremap sH <C-w>H
nnoremap sn gt
nnoremap sp gT
nnoremap sr <C-w>r
nnoremap s= <C-w>=
nnoremap sw <C-w>w
nnoremap so <C-w>_<C-w>|
nnoremap sO <C-w>=
nnoremap sN :<C-u>bn<CR>
nnoremap sP :<C-u>bp<CR>
nnoremap st :<C-u>tabnew<CR>
nnoremap sT :<C-u>Unite tab<CR>
nnoremap ss :<C-u>sp<CR>
nnoremap sv :<C-u>vs<CR>
nnoremap sq :<C-u>q<CR>
nnoremap sQ :<C-u>bd<CR>
nnoremap sb :<C-u>Unite buffer_tab -buffer-name=file<CR>
nnoremap sB :<C-u>Unite buffer -buffer-name=file<CR>
call submode#enter_with('bufmove', 'n', '', 's>', '<C-w>>')
call submode#enter_with('bufmove', 'n', '', 's<', '<C-w><')
call submode#enter_with('bufmove', 'n', '', 's+', '<C-w>+')
call submode#enter_with('bufmove', 'n', '', 's-', '<C-w>-')
call submode#map('bufmove', 'n', '', '>', '<C-w>>')
call submode#map('bufmove', 'n', '', '<', '<C-w><')
call submode#map('bufmove', 'n', '', '+', '<C-w>+')
call submode#map('bufmove', 'n', '', '-', '<C-w>-')
"}}}

"------------------------------------
" ノーマルモード移行時に自動で英数IMEに切り替え→Macのみ
"------------------------------------
"{{{
"if OSTYPE == "Darwin\n"
"    set ttimeoutlen=1
"    let g:imeoff = 'osascript -e "tell application \"System Events\" to key code 102"'
"    augroup MyIMEGroup
"        autocmd!
"        autocmd InsertLeave * :call system(g:imeoff)
"    augroup END
"    inoremap <silent> <ESC> <ESC>:call system(g:imeoff)<CR>
"endif
"}}}

"------------------------------------
" その他の設定
"------------------------------------
"{{{
if has("syntax")
    syntax on
endif

" VimFilerで自動cd
let g:vimfiler_enable_auto_cd = 1

" Rainbow Parentheses Improved
let g:rainbow_active = 1

" 改行時の自動コメント化を無効に
augroup auto_comment_off
    au!
    au BufEnter * setlocal formatoptions-=r
    au BufEnter * setlocal formatoptions-=o
augroup END

set number
set ambiwidth=double
set expandtab
set tabstop=4
set shiftwidth=4
set autoindent
set smartindent
set wrap
set list
set listchars=tab:»-,trail:-,eol:↲,extends:»,precedes:«,nbsp:%
set nrformats-=octal
set hidden
set history=50
set virtualedit=block
set whichwrap=b,s,[,],<,>
set backspace=indent,eol,start
set wildmenu

set foldmethod=marker
set ignorecase
set mouse=a
colorscheme molokai
set t_Co=256

hi Comment ctermfg=cyan
vnoremap * "zy:let @/ = @z<CR>

if OSTYPE == "Linux\n"
    set clipboard+=unnamedplus
else
    set clipboard+=unnamed
endif


"w!!でsudo 保存
cabbr w!! w !sudo tee > /dev/null %
" swp 生成先を変更
"set directory=~/.vim/tmp
set noswapfile

hi Normal ctermbg=NONE guibg=NONE
hi NonText ctermbg=NONE guibg=NONE
"}}}

"------------------------------------
" JAVA-SCRIPT系の設定
"------------------------------------
" {{{
function! EnableJavascript()
    let g:used_javascript_libs = 'jquery,underscore,react,flux,jasmine,d3'
    let b:javascript_lib_use_jquery = 1
    let b:javascript_lib_use_underscore = 1
    let b:javascript_lib_use_react = 1
    let b:javascript_lib_use_flux = 0
    let b:javascript_lib_use_jasmine = 0
    let b:javascript_lib_use_d3 = 0
endfunction

au BufNewFile,BufRead *.js setlocal tabstop=2 softtabstop=2 shiftwidth=2
au BufNewFile,BufRead *.sol set filetype=javascript
au BufNewFile,BufRead *.jsx set filetype=typescript tabstop=2 softtabstop=2 shiftwidth=2
au BufNewFile,BufRead *.ts set filetype=typescript tabstop=2 softtabstop=2 shiftwidth=2
au BufNewFile,BufRead *.tsx set filetype=typescript tabstop=2 softtabstop=2 shiftwidth=2

au BufNewFile,BufRead FileType javascript,javascript.jsx,javascript.tsx call EnableJavascript()
au FileType html setlocal tabstop=2 softtabstop=2 shiftwidth=2
"}}}

"------------------------------------
" MD記法
"------------------------------------
" {{{
let g:previm_open_cmd='open -a firefox'
au BufRead,BufNewFile *.{mkd,md} set filetype=markdown
au! FileType markdown hi! def link markdownItalic Normal
au FileType markdown set commentstring=<\!--\ %s\ -->
nnoremap md :PrevimOpen<CR>
" }}}

"------------------------------------
" Tex記法
"------------------------------------
" {{{
au BufRead,BufNewFile *.{tex} setlocal filetype=tex tabstop=2 softtabstop=2 shiftwidth=2
" }}}

"------------------------------------
" Plugins Settings
"------------------------------------
"{{{
" VimFiler
let g:vimfiler_as_default_explorer = 1

" VimShell
let g:vimshell_prompt = "> "
let g:vimshell_secondary_prompt = "> "
let g:vimshell_user_prompt = 'getcwd()'

"}}}

"------------------------------------
" Highlights
"------------------------------------
" {{{
hi Pmenu ctermbg=4
hi PmenuSel ctermbg=1
hi PMenuSbar ctermbg=4
hi MatchParen cterm=bold ctermbg=none ctermfg=white
" }}}

au BufRead,BufNewFile *.tera  set filetype=jinja
au BufNewFile,BufRead *.pug setlocal tabstop=2 softtabstop=2 shiftwidth=2
au FileType dart set tabstop=2 softtabstop=2 shiftwidth=2


noremap vf :VimFiler -auto-cd<CR>
nnoremap VS :VimShellInteractive zsh<CR>
noremap DU :call dein#update()<CR>
