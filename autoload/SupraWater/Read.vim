vim9script

export def GetCustomFileList(path: string): list<string>
	var patterns = []

	# Filter hidden files
	if get(g:, 'suprawater_show_hidden', false) == false
		add(patterns, '^\.')
	endif

	# Add custom filter files
	if exists('g:suprawater_filter_files') && !empty(g:suprawater_filter_files)
		var custom_filters = g:suprawater_filter_files
			->mapnew((_, val) => glob2regpat(val))
		extend(patterns, custom_filters)
	endif

	var filter_pattern: string
	if !empty(patterns)
		filter_pattern = '\%(' .. join(patterns, '\|') .. '\)'
	else
		filter_pattern = ''
	endif

	const entries = readdirex(path, (n) => (filter_pattern == '' || n.name !~ filter_pattern), {sort: 'none'})

	var folder: list<string> = []
	var files: list<string> = []
	for entry in entries
		if entry.type == 'dir'
			folder->add(entry.name .. '/')
		else
			files->add(entry.name)
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

