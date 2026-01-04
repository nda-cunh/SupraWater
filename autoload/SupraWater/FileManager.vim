vim9script

export def SupraCopyFile(src: string, dest: string)
	var stat = getfperm(src)
	call mkdir(fnamemodify(dest, ':h'), 'p')

	var content = readfile(src, 'b')
	writefile(content, dest, 'b')
	call setfperm(dest, stat)
enddef

export def SupraMakeTempDir(): string
	var tmpdir = tempname()
	call mkdir(tmpdir, 'p')
	return tmpdir
enddef

export def SupraCopyDir(src: string, dest: string)
	mkdir(dest, 'p')
	delete(dest, 'rf')
	echom 'cp -r ' .. shellescape(src) .. ' ' .. shellescape(dest)
	system('cp -r ' .. shellescape(src) .. ' ' .. shellescape(dest))
enddef
