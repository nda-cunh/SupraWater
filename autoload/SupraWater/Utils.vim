vim9script

export def GetIcon(name: string, type: number = -1): string
	if name[-1] == '/'
		return g:WebDevIconsGetFileTypeSymbol(name, 1)
	endif
	return g:WebDevIconsGetFileTypeSymbol(name, type)
enddef

export def GetStrPopup(modified_file: dict<list<string>>): list<string>
	var lines: list<string> = []
	for i in modified_file.rename
		var sp = split(i, ' -> ')
		var str1 = sp[0]
		var str2 = sp[1]
		add(lines, '[Rename]       ' .. GetIcon(str1) .. ' ' .. str1 .. '  →  ' .. GetIcon(str2) .. ' ' .. str2)
	endfor
	for i in modified_file.deleted
		var str = i
		if str[-1] == '/'
			add(lines, '[Deleted Dir]  ' .. GetIcon(str, 1) .. ' ' .. str)
		else
			add(lines, '[Deleted File] ' .. GetIcon(str) .. ' ' .. str)
		endif
	endfor
	for i in modified_file.new_file
		var str = i
		if str[-1] == '/'
			add(lines, '[New Dir]      ' .. GetIcon(str, 1) .. ' ' .. str)
		else
			add(lines, '[New File]     ' .. GetIcon(str) .. ' ' .. str)
		endif
	endfor
	for i in modified_file.all_copy
		var sp = split(i, ' -> ')
		var str1 = sp[0]
		var str2 = sp[1]
		if str1[-1] == '/'
			add(lines, '[Copy Dir]     ' .. GetIcon(str1, 1) .. ' ' .. str1 .. '  →  ' .. GetIcon(str2, 1) .. ' ' .. str2)
		else
			add(lines, '[Copy File]    ' .. GetIcon(str1) .. ' ' .. str1 .. '  →  ' .. GetIcon(str2) .. ' ' .. str2)
		endif
	endfor
	return lines
enddef

export def LeftPath(str: string): string
	var path = str
	if len(path) > 1
		path = fnamemodify(path[0 : -2], ':h')
	endif
	return path
enddef

export def IsBinary(path: string): bool
	return match(readfile(path, '', 10), '\%x00') != -1
enddef

def Ft_strcmp(str1: string, str2: string): number
	var diff = 0
	for i in range(0, min([len(str1), len(str2)]) - 1)
		var char1 = char2nr(str1[i])
		var char2 = char2nr(str2[i])
		if char1 != char2
			diff = char1 - char2
			break
		endif
	endfor
	return diff
enddef

export def GetBeginEndYank(): list<number>
	var ln = line('.')
	var count: number
	if v:count > 0
		count = v:count1
	else
		count = 1
	endif
	if (count + ln) > line('$')
		count = line('$') - ln + 1
	endif

	var begin = getpos("'<")
	var end = getpos("'>")
	setpos("'<", [0, 0, 0, 0])
	setpos("'>", [0, 0, 0, 0])
	if begin[1] != 0 && end[1] != 0
		ln = begin[1]
		count = end[1] - begin[1] + 1
	endif

	if visualmode() == "\<c-v>" && (begin[2] != 1 || end[2] != 2147483647)
		return [-1, -1]
	endif
	return [ln, count]
enddef
