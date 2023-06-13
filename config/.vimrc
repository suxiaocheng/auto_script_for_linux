set nu
set hlsearch
set mouse=
syntax on
set nu
if has("cscope")
    set csprg=CSCOPE_PROGRAM_WHICH
    set csto=0
    set cst 
    set nocsverb
    if filereadable("cscope.out")
        cs add cscope.out
    else
        let cscope_file=findfile("cscope.out",".;")
        let cscope_pre=matchstr(cscope_file,".*/")
        if !empty(cscope_file)&&filereadable(cscope_file)
            exe "cs add" cscope_file  cscope_pre
        endif
    endif
endif
 
map <C-\>1 :set mouse=<CR>
map <C-\>2 :set mouse=a<CR>
nmap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>g :cs find g <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>e :cs find e <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>f :cs find f <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>i :cs find i <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>d :cs find d <C-R>=expand("<cword>")<CR><CR>

filetype plugin indent on
let Tlist_Ctags_Cmd = 'CTAGS_PROGRAM_WHICH'
let Tlist_Show_One_File = 1
let Tlist_Exit_OnlyWindow = 1
map <silent> <F8> :TlistToggle<cr>

if exists('$ITERM_PROFILE')
	if exists('$TMUX')
		let &t_SI = "<Esc>[3 q"
		let &t_EI = "<Esc>[0 q"
	else
		let &t_SI = "<Esc>]50;CursorShape=1x7"
		let &t_EI = "<Esc>]50;CursorShape=0x7"
	endif
end
