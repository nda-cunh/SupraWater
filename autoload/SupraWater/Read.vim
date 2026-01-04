vim9script

export def GetCustomFileList(path: string): list<string>
	var filter_pattern: string 

	# Create the combined filter pattern for the best performance
	if get(g:, 'suprawater_showhidden', false) == false
		filter_pattern = '\%(^\.'
	else
		filter_pattern = '\%('
	endif
	if exists('g:suprawater_filter_files') && len(g:suprawater_filter_files) > 0
		if filter_pattern == '\%(^\.'
			filter_pattern ..= '\|'
		endif
		filter_pattern = filter_pattern .. g:suprawater_filter_files
			->mapnew((_, val) => glob2regpat(val))
			->join('\|')
	endif
	filter_pattern ..= '\)'

	const entries = readdirex(path, (n) => (filter_pattern == '' || n.name !~ filter_pattern), {sort: 'none'})


	var folder: list<string> = []
	var files: list<string> = []
	for entrie in entries
		if entrie.type == 'dir'
			folder->add(entrie.name .. '/')
		else
			files->add(entrie.name)
		endif
	endfor
	
	# sort folders and files
	# separately
	folder = sort(folder, 'i')
	files = sort(files, 'i')
	if get(g:, 'suprawater_sortascending', true) == false 
		reverse(folder)
		reverse(files)
	endif

	return folder + files
enddef

