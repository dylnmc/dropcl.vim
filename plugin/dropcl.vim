
" drop-down command-line

command -nargs=0 -bar -bang DropCL if <bang>0 | call <sid>new() | endif | call <sid>initDropCL()
nnoremap <silent> <plug>(dropCL) :call <sid>initDropCL()<cr>
nnoremap <silent> <plug>(dropCLNew) :DropCL!<cr>

function! s:source()
	silent execute 'write! '.s:tempname
	execute 'source '.s:tempname
	execute 'file dropcl \#'.s:tempid
endfunction

function! s:new()
	silent execute 'write! '.s:tempname
	call add(s:tempnames, s:tempname)
	let s:tempname = tempname()
	silent call deletebufline(s:bufnr, 1, '$')
	let s:tempid = len(s:tempnames) - 1
	execute 'file dropCL \#'.s:tempid
endfunction

function! s:next()
	if s:tempid >= len(s:tempnames) - 1
		echohl ErrorMsg
		echon 'Alreaady at newest dropCL'
		echohl NONE
		return
	endif
	silent execute 'write! '.s:tempname
	let s:tempid += 1
	let s:tempname = s:tempnames[s:tempid]
	silent call deletebufline(s:bufnr, 1, '$')
	call setbufline(s:bufnr, 1, readfile(s:tempname))
	execute 'file dropCL \#'.s:tempid
endfunction

function! s:prev()
	if s:tempid <= 0
		echohl ErrorMsg
		echon 'Alreaady at oldest dropCL'
		echohl NONE
		return
	endif
	silent execute 'write! '.s:tempname
	let s:tempid -= 1
	let s:tempname = s:tempnames[s:tempid]
	silent call deletebufline(s:bufnr, 1, '$')
	call setbufline(s:bufnr, 1, readfile(s:tempname))
	execute 'file dropCL \#'.s:tempid
endfunction

function! s:initDropCL()
	if ! exists('s:bufnr')
		botright new
		let s:bufnr = bufnr('')
		let s:tempname = tempname()
		let s:tempnames = [s:tempname]
		let s:tempid = 0
		file dropCL\ \#0
		autocmd User dropCLInit let &ro = &ro
		10 wincmd _
	else
		if ! (&filetype ==# 'vim' && expand('%') ==# 'dropcl')
			let l:winid = bufwinid(s:bufnr)
			if l:winid ==# -1
				execute 'botright sbuffer '.s:bufnr
				10 wincmd _
			else
				call win_gotoid(l:winid)
			endif
		endif
	endif
	command! -buffer Done call <sid>source() | close
	command! -buffer D call <sid>source() | close
	command! -buffer Run call <sid>source()
	command! -buffer R call <sid>source()
	command! -buffer NextDropCL call <sid>next()
	command! -buffer NN call <sid>next()
	command! -buffer PrevDropCL call <sid>prev()
	command! -buffer PP call <sid>prev()
	command! -buffer NewDropCL call <sid>new()
	command! -buffer New call <sid>new()
	if ! get(g:, 'dropCL_noreturn', 0)
		nnoremap <buffer> <cr> :Done " press enter to run and close<c-b><s-right>
		nnoremap <buffer> <leader>D :Done " press enter to run and close<c-b><s-right>
		nnoremap <buffer> <leader>R :Run " press enter to run<c-b><s-right>
		nnoremap <silent> <buffer> <leader>N :NewDropCL<cr>
		nnoremap <silent> <buffer> <leader>n :NextDropCL<cr>
		nnoremap <silent> <buffer> <leader>p :PrevDropCL<cr>
	endif
	setlocal filetype=vim buftype=nofile nobuflisted colorcolumn= nolist nonumber norelativenumber
	doautocmd User dropCLInit
endfunction

if ! (get(g:, 'dropCL_nomap', 0) || mapcheck('<leader>:', 'n') || hasmapto('<plug>(dropCL)', 'n'))
	nmap <leader>: <plug>(dropCL)
endif

