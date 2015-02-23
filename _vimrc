set nocompatible
source $VIMRUNTIME/vimrc_example.vim
source $VIMRUNTIME/mswin.vim
behave mswin

"set diffexpr=MyDiff()
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
   if $VIMRUNTIME =~ ' '
     if &sh =~ '\<cmd'
       if empty(&shellxquote)
         let l:shxq_sav = ''
         set shellxquote&
       endif
       let cmd = '"' . $VIMRUNTIME . '\diff"'
     else
       let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '\diff"'
     endif
   else
     let cmd = $VIMRUNTIME . '\diff'
   endif
   silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3
   if exists('l:shxq_sav')
     let &shellxquote=l:shxq_sav
   endif
endfunction

if has('gui_running')
    set guifont=Consolas:h10:cEASTEUROPE
endif
set encoding=utf-8

let mapleader=","
let maplocalleader=","
set nocompatible
set autowrite
set viminfo='50,\"500
set history=50

noremap <C-Q>       <C-V>

" Vzhled
" Zapnuti barevne syntaxe v gui a terminalech ktere maji barvy
"if &t_Co > 2 || has("gui_running")
"set background=dark "defaultne se pouziji barvy pro tmave pozadi
"if has("gui_running")
"  "set background=light   " v gui se ale pouziji barvy pro svetle pozadi
"                         " zakomentovano, colorscheme nastavuje vsechno
"  if(filereadable($VIMRUNTIME . "/colors/desert.vim"))
"    colorscheme desert " existuje-li barevne schema darkblue, pouzij ho
"  else
"    echo 'nexistuje DARKBLUE'
"    colorscheme default  " jinak pouzij defaultni, ktere by melo
"                         " existovat vzdy, kdyz ne, mate poskozenou
"    endif                  " instalaci Vimu
"  endif
"endif
"set t_Co=256
if has('gui_running')
    colorscheme  darkblue
endif

let g:airline#extensions#tabline#enabled = 1

"syntax on
set nojoinspaces    " pri spojovani radku nezdvojuj mezery za znaky: .?!
set hlsearch	"zvtrazňuje hledání
set showmatch	"zobrazeni parových znaků
set showcmd	"hlida zavorky

set laststatus=2
"set statusline=%1*%n:%*\ %<%f\ %l/%L,%c%V
"set statusline=%1*%n:%*\ %<%f\ %y%m%2*%r%*%=[%b,0x%B]\ \ %l/%L,%c%V
"highlight User1 guibg=white guifg=blue
"highlight User2 guibg=white guifg=red


set scrolloff=3


" Chovani
set nowrap
filetype plugin on

set smartindent
set cmdheight=2     " prikazovy radek o velikosti dva radky
set showcmd         " ukazuje se zadavani prikazu v prik. radku
set wildmenu
" nastaveni tabelatoru
set tabstop=4
set shiftwidth=4
set expandtab
autocmd BufRead [Mm][Aa][Kk][Ee][Ff][Ii][Ll][Ee]* set noexpandtab
set ignorecase
set smartcase

"*************************************** funkce DEFAULT_KEYS()
"Tato funkce nastavuje defaultni horke klavesy, ktere budeme
"chtit pouzivat vzdy.
let $NTABMODE = -1 "pro prvni nastaveni
function DEFAULT_KEYS()
"
"
" - multifunkcni klavesa TAB
  "v NORMALNIM REZIMU prepina 1) mezi dvemi okny,
  "                           2) mezi vsemi okny
  "funkce se prepina klavesovou zkratkou SPACE
    if $NTABMODE == -1
      "nastavuje se jen jednou, aby pri chozeni mezi soubory
      "nedochazelo k def. nastaveni
      let $NTABMODE = 0
    endif
    nmap <TAB>   :call NTAB_NEXTWINDOW()<CR>
    nmap <Space> :call ChangeNTABMODE()<CR>
"
  "v INSERT REZIMU klavesa TAB vklada na zacatku radku tabelator
  "jinak doplnuje slovo
    imap <Tab> <C-R>=ITAB_SMART()<CR>
    imap <S-Tab> <C-R>=ITAB_SMART1()<CR>
"
" - kurzorovych klavesy oznamuji Ascii kod znaku pod kurzorem
  map <Left>  <Left>ga
  map <Right> <Right>ga
  map <Up>    <Up>ga
  map <Down>  <Down>ga
"
endfunction

" pomocne funkce pro DEFAULT_KEYS()
  function FillChar(shift, char)
    let nLi1=line('.')
    let nCo1=col('.')
    "
    if(nLi1+a:shift<1)
      return
    endif
    if(nLi1+a:shift>line('$'))
      return
    endif
    "
    let nLi2=nLi1+a:shift
    let sLi2=getline(nLi2)
    let lLi2=strlen(sLi2)
    "
    let iCo2=nCo1
    let tSp=0
    "
    while(iCo2<lLi2)
      if(tSp==1)
        if(sLi2[iCo2]!=a:char)
          break
        endif
      else
        if(sLi2[iCo2]==a:char)
          let tSp=1
        endif
      endif
      let iCo2=iCo2+1
    endwhile
    let nFill=iCo2-nCo1
    "
    let i=0
    let sFill=''
    while(i<nFill)
      let sFill=sFill.a:char
      let i=i+1
    endwhile
    "
    let x=@x
    let @x=sFill
    normal "xp
    let @x=x
    "
  endfunction
  "
  function FillCharPrevious(shift)
    let  s=getline('.')
    let  c=col('.')
    let  char=s[c-1]
    normal x
    call FillChar(a:shift, char)
  endfunction
  "

"
  function ChangeNTABMODE()
    if $NTABMODE==0
      let  $NTABMODE= 1
      echo 'TAB PREPINA MEZI VSEMI OKNY'
    else
      let  $NTABMODE= 0
      echo 'TAB PREPINA MEZI DVEMI OKNY'
    endif
  endfunction
"
  function NTAB_NEXTWINDOW()
    if winbufnr(2) != -1
      if $NTABMODE == 1 "mezi vsemi okny
        exe "normal \<C-W>w"
      else "mezi dvema okny
        exe "normal \<C-W>p"
      endif
    endif
  endfunction
"
  function NTAB_NEXTFILE()
    if bufnr("$") > 1
      if bufnr("#") != -1 && $NTABMODE == 2
        exe "normal :e #\<CR>v\<Esc>"
        echo "Zobrazen predchozi soubor."
      else
        exe "normal :bn\<CR>v\<Esc>"
        echo "Zobrazen dalsi soubor."
      endif
    else
      echo "Je jen jeden soubor."
    endif
  endfunction
  function ITAB_SMART()
    if strpart(getline('.'), 0, col('.')-1) =~ '^\s*$'
       return "\<Tab>"
    else
       return "\<C-P>"
    endif
  endfunction
  function ITAB_SMART1()
       return "\<Tab>"
  endfunction
" ---------------------------------------------------------------------------------------


"function
function! s:DiffWithSaved()
  let filetype=&ft
  diffthis
  vnew | r # | normal! 1Gdd
  diffthis
  exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
endfunction
com! DiffSaved call s:DiffWithSaved()

function! s:XMLLINTFormat()
  %!xmllint % --format
endfunction
com! XMLFormat call s:XMLLINTFormat()

function! s:ShowLongLine()
  highlight OverLength ctermbg=DarkGrey guibg=DarkGrey
  match OverLength /\%>80v.\+/
endfunction
com! ShowLongLine call s:ShowLongLine()


call DEFAULT_KEYS()

"spell
if has('gui_running')
"    set spell spelllang=cs
endif


" change to powershell 
" set shell=powershell.exe\ -ExecutionPolicy\ Unrestricted 
" set shellcmdflag=-Command 
" set shellpipe=> 
" set shellredir=> 


function! DeleteInactiveBufs()
    "From tabpagebuflist() help, get a list of all buffers in all tabs
    let tablist = []
    for i in range(tabpagenr('$'))
        call extend(tablist, tabpagebuflist(i + 1))
    endfor

    "Below originally inspired by Hara Krishna Dara and Keith Roberts
    "http://tech.groups.yahoo.com/group/vim/message/56425
    let nWipeouts = 0
    for i in range(1, bufnr('$'))
        if bufexists(i) && !getbufvar(i,"&mod") && index(tablist, i) == -1
        "bufno exists AND isn't modified AND isn't in the list of buffers open in windows and tabs
            silent exec 'bwipeout' i
            let nWipeouts = nWipeouts + 1
        endif
    endfor
    echomsg nWipeouts . ' buffer(s) wiped out'

endfunction
command! Bdi :call DeleteInactiveBufs()


let $TMP="c:/temp"

:hi CursorLine   cterm=NONE ctermbg=darkblue ctermfg=white guibg=darkblue guifg=white
:hi CursorColumn cterm=NONE ctermbg=darkblue ctermfg=white guibg=darkblue guifg=white
:nnoremap <Leader>cu :set cursorline! cursorcolumn!<CR>
map <F12> :NERDTreeToggle<CR>
:nnoremap <Leader>nu :set nu!<CR>

:set foldcolumn=3
:hi foldcolumn ctermbg=0
hi LineNr ctermfg=8 guifg=DarkGray

" nogui
:set guioptions-=m  "remove menu bar
:set guioptions-=T  "remove toolbar
:set guioptions-=r  "remove right-hand scroll bar
:set guioptions-=L  "remove left-hand scroll bar


