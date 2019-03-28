
" drop-down command-line

nnoremap <silent> <plug>(dropCL) :call <sid>initDropCL()<cr>

function! s:source()
	setlocal buftype=
	silent execute 'write! '.s:tempname
	execute 'source '.s:tempname
	setlocal buftype=nofile
	file dropcl
endfunction

function! s:initDropCL()
	if ! exists('s:bufnr')
		botright new
		let s:bufnr = bufnr('')
		let s:tempname = tempname()
		file dropcl
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
	command! -buffer Run call<sid>source()
	if ! get(g:, 'dropCL_noreturn', 0)
		inoremap <buffer> <cr> <c-bslash><c-o>:Done " press enter to run<c-b><s-right>
		nnoremap <buffer> <cr> <c-bslash><c-o>:Done " press enter to run<c-b><s-right>
	endif
	setlocal filetype=vim buftype=nofile nobuflisted colorcolumn= nolist nonumber norelativenumber
	doautocmd User dropCLInit
	" echon '-- INSERT --'
	" startinsert
endfunction

if ! (get(g:, 'dropCL_nomap', 0) || hasmapto('<leader>:', 'n'))
	nmap <leader>: <plug>(dropCL)
endif

