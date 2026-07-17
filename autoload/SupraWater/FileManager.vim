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

# Native recursive directory copy (no shell, injection-safe and cross-platform).
# Preserves file permissions to keep the `cp -p` semantics.
export def SupraCopyDir(src: string, dest: string)
	if !isdirectory(dest)
		mkdir(dest, 'p')
	endif
	for entry in readdirex(src)
		var from = src .. '/' .. entry.name
		var to = dest .. '/' .. entry.name
		if entry.type == 'dir' || entry.type == 'linkd'
			SupraCopyDir(from, to)
		else
			SupraCopyFile(from, to)
		endif
	endfor
	var perm = getfperm(src)
	if perm != ''
		call setfperm(dest, perm)
	endif
enddef
