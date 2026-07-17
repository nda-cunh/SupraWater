vim9script

# Human-readable file size (e.g. 4.2K, 13M). Returns '' for negative sizes.
export def FormatSize(size: number): string
	if size < 0
		return ''
	endif
	const units = ['B', 'K', 'M', 'G', 'T']
	var value = size * 1.0
	var unit = 0
	while value >= 1024.0 && unit < len(units) - 1
		value = value / 1024.0
		unit += 1
	endwhile
	if unit == 0
		return printf('%d%s', size, units[0])
	endif
	return printf('%.1f%s', value, units[unit])
enddef

# Right-column metadata string for one readdirex() entry: size + date.
# Directories have no meaningful size, so a dash is shown instead.
export def FormatMeta(entry: dict<any>): string
	const date = strftime('%d %b %H:%M', entry.time)
	if entry.type == 'dir' || entry.type == 'linkd'
		return printf('%8s  %s', '-', date)
	endif
	return printf('%8s  %s', FormatSize(entry.size), date)
enddef

# When {meta} is given, it is filled with a `display name -> {size, time, perm,
# type}` entry per file, reusing the single readdirex() call below (no extra IO).
export def GetCustomFileList(path: string, meta: dict<dict<any>> = null_dict): list<string>
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
		var display_name: string
		if entry.type == 'dir'
			display_name = entry.name .. '/'
			folder->add(display_name)
		else
			display_name = entry.name
			files->add(display_name)
		endif
		if meta isnot null_dict
			meta[display_name] = {
				size: entry.size,
				time: entry.time,
				perm: entry.perm,
				type: entry.type,
			}
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

