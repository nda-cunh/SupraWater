function! airline#extensions#suprawater#apply_active(...) abort
	if (&ft ==# 'suprawater') && a:2.active ==# '1'
		call airline#extensions#suprawater#configure_sections(a:1, a:2)
		return 1
	endif
endfunction

function! airline#extensions#suprawater#apply_inactive(...) abort
	if getbufvar(a:2.bufnr, '&filetype') ==# 'suprawater' && a:2.active ==# '0'
		call airline#extensions#suprawater#configure_sections(a:1, a:2)
		return 1
	endif
endfunction

function! airline#extensions#suprawater#configure_sections(win, context) abort
	let spc = g:airline_symbols.space

	call a:win.add_section('airline_a', spc.'SupraWater'.spc)
	call a:win.add_section('airline_b', '')

	call a:win.add_section('airline_c', '')

	call a:win.split()
endfunction
function! airline#extensions#suprawater#init(ext) abort
	call a:ext.add_statusline_func('airline#extensions#suprawater#apply_active')
	call a:ext.add_inactive_statusline_func('airline#extensions#suprawater#apply_inactive')
endfunction
