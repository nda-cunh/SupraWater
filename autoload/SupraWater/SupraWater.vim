vim9script

import autoload './PopupSave.vim' as NPopupSave
import autoload './Utils.vim' as Utils
import autoload './Colors.vim' as Colors
import autoload './Read.vim' as Read 
import autoload './ClipBoard.vim' as NClipBoard
import autoload './UndoStack.vim' as NUndoStack

type PopupSave = NPopupSave.PopupSave
type ClipBoard = NClipBoard.ClipBoard
type UndoStack = NUndoStack.UndoStack

export def Water()
	var view = WaterView.new()
enddef

const SIMPLE = 0
const TABNEW = 1
const VSPLIT = 2
const HSPLIT = 3
type TypeOpen = number

type ModifiedFiles = dict<list<string>> 

class WaterView
	var buf: number
	var previous_buf: number
	var first_path: string
	var first_filename: string
	var path: string
	var cursor_pos: dict<list<number>>
	var open_from_directory: bool = false
	var clipboard: ClipBoard
	static var index: number = 0
	# var undostack: list<dict<any>>
	var undostack: UndoStack

	def new()
		this.undostack = UndoStack.new()
		this.clipboard = ClipBoard.new()
		this.previous_buf = bufnr('%')
		this.first_path = expand('%:p:h')
		this.first_filename = expand('%:t')
		if isdirectory(expand('%')) == 1
			this.open_from_directory = true
		endif

		const buf = bufadd('suprawater_' .. WaterView.index .. '.water')
		WaterView.index += 1

		this.buf = buf
		execute 'b ' .. buf
		setbufvar(buf, '&buflisted', 0)
		setbufvar(buf, '&buftype', 'acwrite')
		setbufvar(buf, '&bufhidden', 'hide')
		setbufvar(buf, '&modeline', 0)
		setbufvar(buf, '&swapfile', 0)
		setbufvar(buf, '&undolevels', -1)
		setbufvar(buf, '&nu', 0)
		setbufvar(buf, '&relativenumber', 0)
		setbufvar(buf, "&updatetime", 2500)
		setbufvar(buf, '&signcolumn', 'yes')
		setbufvar(buf, '&fillchars', 'vert:│,eob: ')
		setbufvar(buf, '&wrap', 0)
		setbufvar(buf, '&relativenumber', 0)
		setbufvar(buf, '&cursorline', 1)
		setbufvar(buf, '&wincolor', 'NormalDark')
		setbufvar(buf, '&filetype', 'suprawater')

		b:SupraWaterInstance = this

		#####################
		# Keymaps
		#####################
		noremap <buffer><cr>			<scriptcmd>b:SupraWaterInstance.Open()<cr>
		nnoremap <buffer><2-LeftMouse>	<scriptcmd>b:SupraWaterInstance.Open()<cr>
		noremap <buffer><c-t>			<scriptcmd>b:SupraWaterInstance.Open(TABNEW)<cr>
		noremap <buffer><c-h>			<scriptcmd>b:SupraWaterInstance.Open(HSPLIT)<cr>
		noremap <buffer><c-v>			<scriptcmd>b:SupraWaterInstance.Open(VSPLIT)<cr>


		inoremap <buffer><c-q>		<scriptcmd>b:SupraWaterInstance.Quit()<cr>
		noremap <buffer><c-q>		<scriptcmd>b:SupraWaterInstance.Quit()<cr>
		noremap <buffer>q			<scriptcmd>b:SupraWaterInstance.Quit()<cr>
		noremap <buffer><bs>		<scriptcmd>b:SupraWaterInstance.BackFolder()<cr>
		noremap <buffer>-			<scriptcmd>b:SupraWaterInstance.BackFolder()<cr>
		inoremap <buffer><Cr>		<scriptcmd>b:SupraWaterInstance.SupraOverLoadCr()<cr>
		inoremap <buffer><del>		<scriptcmd>b:SupraWaterInstance.SupraOverLoadDel()<cr>
		inoremap <buffer><bs>		<scriptcmd>b:SupraWaterInstance.SupraOverLoadBs()<cr>
		nnoremap <buffer>p			<scriptcmd>b:SupraWaterInstance.Paste()<cr>
		nnoremap <buffer><del>		<esc>i<del>
		nnoremap <buffer><c-s>		<scriptcmd>b:SupraWaterInstance.SaveBuffer()<cr>
		inoremap <buffer><c-s>		<scriptcmd>b:SupraWaterInstance.SaveBuffer()<cr>
		nnoremap <buffer>~			<scriptcmd>b:SupraWaterInstance.GoToHome()<cr>
		nnoremap <buffer>_			<scriptcmd>b:SupraWaterInstance.GoToFirstPath()<cr>

		nnoremap <buffer>=			<scriptcmd>b:SupraWaterInstance.ToggleAscendingSort()<cr>
		nnoremap <buffer>g.		<scriptcmd>b:SupraWaterInstance.ToggleShowHiddenFiles()<cr>
		nnoremap <buffer>u			<scriptcmd>b:SupraWaterInstance.Undo()<cr>
		nnoremap <buffer><c-r>		<scriptcmd>b:SupraWaterInstance.Redo()<cr>


		nnoremap <buffer>dw			<scriptcmd>noautocmd normal! dw<cr>
		nnoremap <buffer>db			<scriptcmd>noautocmd normal! db<cr>
		nnoremap <buffer>yw			<scriptcmd>noautocmd normal! yw<cr>
		nnoremap <buffer>yb			<scriptcmd>noautocmd normal! yb<cr>nnoremap <buffer><c-s>		<esc>:w<cr>
		nnoremap <buffer><a-Up>		<scriptcmd>b:SupraWaterInstance.SwitchUp()<cr>
		nnoremap <buffer><a-Down>	<scriptcmd>b:SupraWaterInstance.SwitchDown()<cr>
		vnoremap <buffer><a-Up>		<Nop> # TODO Not supported yet
		vnoremap <buffer><a-Down>	<Nop> # TODO Not supported yet


		#####################
		# Autocmds (Events)
		#####################
		autocmd WinScrolled <buffer> if exists('b:SupraWaterInstance') | b:SupraWaterInstance.Actualize() | endif
		autocmd TextChangedI,TextChanged <buffer> if exists('b:SupraWaterInstance') | b:SupraWaterInstance.Changed() | endif
		autocmd TextYankPost <buffer> if exists('b:SupraWaterInstance') && v:event.operator ==# 'd' && v:event.regname ==# '' | b:SupraWaterInstance.Cut() | endif
		autocmd TextYankPost <buffer> if exists('b:SupraWaterInstance') && v:event.operator ==# 'y' && v:event.regname ==# '' | b:SupraWaterInstance.Yank() | endif
		autocmd BufWriteCmd <buffer> if exists('b:SupraWaterInstance') | b:SupraWaterInstance.SaveBuffer() | endif
		autocmd CursorMoved,CursorMovedI <buffer> if exists('b:SupraWaterInstance') | b:SupraWaterInstance.CancelOneLine() | endif
		autocmd BufHidden <buffer> if exists('b:SupraWaterInstance') | b:SupraWaterInstance.Hide() | endif

		this.DrawPath(this.first_path)
		this.JumpToFile(this.first_filename)
		this.undostack.InitPosition()
		this.undostack.Save(this.buf)

	enddef

	### It's for fix the bug when the buffer is not saved when closing
	def Hide()
		setbufvar(this.buf, '&modified', 0)
	enddef

	def GoToHome()
		this.path = $HOME
		this.DrawPath(this.path)
	enddef

	def GoToFirstPath()
		this.path = this.first_path
		this.DrawPath(this.path)
		this.JumpToFile(this.first_filename)
	enddef

	# When you press <bs> or - is triggered
	def BackFolder()
		# WARNING test if the buffer is modified

		if this.path == '/'
			return
		endif

		# jump is the folder name we need to jump after going back
		const jump = fnamemodify(this.path, ':t')
	
		this.cursor_pos[this.path] = getcurpos()
		this.path = Utils.LeftPath(this.path)

		this.DrawPath(this.path)
		this.JumpToFile(jump)
	enddef

	def JumpToFile(filename: string)
		search('^' .. escape(filename, '\^$.*[]'), 'w')
		normal! zz
	enddef

	def Quit()

		# Check if the buffer is modified
		# WARNING Do not use it anymore
		# if getbufvar(this.buf, '&modified') == true
			# return
		# endif

		# Quit if suprawater is open from a directory
		if this.open_from_directory == true
			quit!
		endif

        if bufexists(this.previous_buf)
            execute 'buffer! ' .. this.previous_buf
        else
            execute 'enew!'
        endif
    enddef

	def DrawPath(path: string)
		this.path = substitute(path, '\/\+', '/', 'g')
		const lst = Read.GetCustomFileList(path)
		noautocmd setbufline(this.buf, 1, [' ', '../'] + lst)
		noautocmd deletebufline(this.buf, len(lst) + 3, '$')  # delete all lines in the buffer
		setbufvar(this.buf, '&modified', 0)
		this.undostack.Clear()
		var edit: dict<any> = {}
		var nb = 3
		for i in lst
			var tmp = {
				name: i, # the name of the file or folder
				is_deleted: false, # if the file is deleted
				new_file: false, # if the file is a new file
				copy_of: '', # link to the original file if it is a copy
			}
			edit[nb] = tmp
			nb += 1
		endfor
		# add(this.undostack, edit)
		this.undostack.Add(edit, getbufline(this.buf, 1, '$'))
		this.Actualize()
	enddef

	# It print all icons and text_props
	def Actualize()
		const winid = win_findbuf(this.buf)[0]
		const buf = this.buf 

		# Simple text printing
		var sort_text: string
		if get(g:, 'suprawater_sortascending', true) == true
			sort_text = 'Sort by name ▲ '
		else
			sort_text = 'Sort by name ▼ '
		endif

		if get(g:, 'suprawater_showhidden', false) == true
			sort_text ..= '  | hidden files: 🗸 '
		else
			sort_text ..= '  | hidden files: ✕'
		endif

		const help_text = 'Press ("?" or "h") for Help !'
		sort_text ..= repeat(' ', (winwidth(winid) - len(sort_text) - len(help_text))) ..  help_text
		prop_clear(1, line('$w', winid), {bufnr: buf})

		var draw_path = substitute(this.path, '^' .. $HOME, '~', 'g')
		var lines = []
		var width_line = winwidth(winid) - 2
		{
			var i = 0
			while true
				if draw_path == ''
					break
				endif
				lines[i] = draw_path[0 : width_line]
				draw_path = draw_path[width_line : ]
				i = i + 1
			endwhile
		}
		for line in lines
			prop_add(1, 0, {bufnr: buf, text: line, type: 'suprawaterpath', text_align: 'above'})
		endfor
		prop_add(1, 0, {bufnr: buf, text: sort_text, type: 'suprawatersort', text_align: 'above'})

		var edit = this.undostack.Get()
		###############################
		# Icons printing
		###############################
		const result = getbufline(buf, 1, '$')
		const p_begin = line('w0', winid) - 1
		var p_end = len(result) - 1
		if p_end >= line('w$', winid)
			p_end = line('w$', winid)
		endif

		for i in range(p_begin, p_end)
			if result[i] == '' || i == 0
				continue
			endif
			var sym: string
			var ext: string
			const complete_path = this.path .. '/' .. result[i]

			if has_key(edit, i + 1) != 0 && edit[i + 1].is_deleted == true
				ext = 'DELETED'
				sym = ''
			elseif complete_path[-1] == '/'
				sym = Utils.GetIcon(complete_path, 1)
				ext = 'FOLDER'
			else
				sym = Utils.GetIcon(complete_path)
				ext = fnamemodify(result[i], ':e')
				if ext == ''
					ext = result[i]
				endif
			endif
			if has_key(Colors.colors, sym)
				const color = Colors.colors[sym]
				silent! call prop_add(i + 1, 1, {bufnr: buf, text: sym .. '  ', type: color})
			else
				silent! call prop_add(i + 1, 1, {bufnr: buf, text: sym .. '  ', type: 'suprawater'})
			endif
		endfor
		setbufvar(buf, '&modified', 0)
	enddef

	def Undo()
		# If an edit is in progress, Add it to the undostack
		# Compare getbufline with the undostack last edit
		# const current_lines = getbufline(this.buf, 1, '$')
		# const last_edit = this.undostack.GetContents()
# 
		# if current_lines != last_edit
			# var edit = this.undostack.Get()
			# this.undostack.Add(edit, current_lines)
		# endif

		this.undostack.Undo(this.buf)
		this.Actualize()
	enddef

	def Redo()
		this.undostack.Redo(this.buf)
		this.Actualize()
	enddef

	###############################################
	## Save/Writing the buffer
	###############################################

	def SaveBuffer()
		var modified_file = this.GetModifiedFile()

		if len(modified_file.rename) == 0 && len(modified_file.deleted) == 0 && len(modified_file.new_file) == 0 && len(modified_file.all_copy) == 0
			echohl WarningMsg
			echo "[SupraWater] No changes to save."
			echohl None
			return
		endif

		this.OpenPopupModifiedfile(modified_file)
	enddef

	def GetModifiedFile(): ModifiedFiles 
		const id = this.buf
		var all_deleted: list<string> = []
		var all_new_file: list<string> = []
		var all_rename: list<string> = []
		var all_copy: list<string> = []
		var bufs = getbufline(id, 1, '$')

		var edit = this.undostack.Get()

		for i in keys(edit)
			if edit[i].is_deleted == true
				add(all_deleted, edit[i].name)
			elseif edit[i].copy_of != ''
				const nb = str2nr(i)
				const nm = getbufline(id, nb)[0]
				const copy_of = edit[i].copy_of
				add(all_copy, copy_of .. ' -> ' .. nm)
			elseif edit[i].new_file == false
				const nb = str2nr(i)
				const nm = getbufline(id, nb)[0]
				if nm != edit[i].name && nm != ''
					add(all_rename, edit[i].name .. " -> " .. nm)
				endif
			elseif edit[i].new_file == true
				const nb = str2nr(i)
				const nm = getbufline(id, nb)[0]
				if nm =~# '^\s*$'
					continue
				endif
				add(all_new_file, nm)
			endif
		endfor

		var result: ModifiedFiles = {
			rename: all_rename,
			deleted: all_deleted,
			new_file: all_new_file,
			all_copy: all_copy
		}

		return result
	enddef

	def OpenPopupModifiedfile(modified_file: ModifiedFiles)
		var popup = PopupSave.new()

		# When The user confirm the operation
		popup.OnYes(() => {
			var current = getline('.')
			popup.ProcessModification(modified_file, this.clipboard, this.path)
			this.DrawPath(this.path)
			search(current, 'c')
			this.Actualize()
		})

		# When The user cancel the operation
		popup.OnCancel(() => {
			var pos = getpos('.')
			this.DrawPath(this.path)
			setpos('.', pos)
			this.Actualize()
		})

		const width = float2nr(&columns * 0.6)
		const nb_minus: number = (width / 2)
		const nb_space = repeat(' ', (nb_minus))
		var lines = []
		extend(lines, Utils.GetStrPopup(modified_file))
		add(lines, nb_space .. ' [(Y)es] [(N)o] [(C)ancel] ' .. nb_space)
		popup.SetText(lines)
	enddef


	############################################
	## Events
	############################################

	def Open(type: TypeOpen = SIMPLE)
		var line = getline('.')
		if line[-1] == '/'
			const path: string = this.path .. '/' .. line
			if type == SIMPLE
				this.DrawPath(path[0 : -2])
				# Jump to the cursor_pos of the new folder path if exists
				if has_key(this.cursor_pos, this.path)
					call setpos('.', this.cursor_pos[this.path])
					normal! zz
				endif
			elseif type == VSPLIT
				execute 'vsplit! ' .. path
			elseif type == HSPLIT
				execute 'split! ' .. path
			elseif type == TABNEW
				execute 'tabnew! ' .. path
			endif
		else
			if type == TABNEW
				# Close the current buffer
				this.Quit()
				execute 'tabnew! ' .. this.path .. '/' .. line
			elseif type == VSPLIT
				execute 'vsplit! ' .. this.path .. '/' .. line
			elseif type == HSPLIT
				execute 'split! ' .. this.path .. '/' .. line
			else
				execute 'edit! ' .. this.path .. '/' .. line
			endif
		endif
	enddef

	def ToggleAscendingSort()
		if !exists('g:suprawater_sortascending')
			g:suprawater_sortascending = true
		endif
		var value: bool = g:suprawater_sortascending
		g:suprawater_sortascending = !value
		this.DrawPath(this.path)
	enddef

	def ToggleShowHiddenFiles()
		if !exists('g:suprawater_showhidden')
			g:suprawater_showhidden = false
		endif
		var value: bool = g:suprawater_showhidden
		g:suprawater_showhidden = !value
		this.DrawPath(this.path)
	enddef


	############################################
	## Typing Events
	############################################

	# Like Alt+Up/Down switch the edit line with the line above/below
	def SwitchUp()
		const current_line = line('.')
		if current_line <= 3
			return
		endif
		this.undostack.Save(this.buf)
		var edit = this.undostack.Get()

		var temp = edit[current_line]
		edit[current_line] = edit[current_line - 1]
		edit[current_line - 1] = temp

		var line_content = getbufline(this.buf, current_line)[0]
		var line_above = getbufline(this.buf, current_line - 1)[0]
		noautocmd setbufline(this.buf, current_line, line_above)
		noautocmd setbufline(this.buf, current_line - 1, line_content)

		this.Actualize()
		normal! k
	enddef

	def SwitchDown()
		const current_line = line('.')
		if current_line >= line('$')
			return
		endif
		this.undostack.Save(this.buf)
		var edit = this.undostack.Get()

		var temp = edit[current_line]
		edit[current_line] = edit[current_line + 1]
		edit[current_line + 1] = temp

		var line_content = getbufline(this.buf, current_line)[0]
		var line_below = getbufline(this.buf, current_line + 1)[0]
		noautocmd setbufline(this.buf, current_line, line_below)
		noautocmd setbufline(this.buf, current_line + 1, line_content)

		this.Actualize()
		normal! j
	enddef

	def CancelOneLine()
		if (line('.') == 1)
			normal! j
		endif
	enddef

	def SupraOverLoadCr()
		const col = col('.')
		const line = line('.')
		const end = strlen(getline('.'))
		if line == 2
			return
		endif
		if col == 1
			silent! normal O
		elseif col == end + 1
			silent! normal o
		endif
		this.Actualize()
	enddef

	def SupraOverLoadDel()
		const col = col('.')
		const line = line('.')
		const end = strlen(getline('.'))

		var edit = this.undostack.Get()
		if col == 1 && end == 1
			setline(line, edit[line].name)
			edit[line].is_deleted = true
		elseif col == end + 1 || end == 0
			return
		else
			feedkeys("\<del>", 'n')
		endif
	enddef

	def SupraOverLoadBs()
		const col = col('.')
		const line = line('.')
		const end = strlen(getline('.'))
		var edit = this.undostack.Get()
		if end == 1
			setline(line, edit[line].name)
			edit[line].is_deleted = true
		elseif end == 0 || col == 1
			return
		else
			feedkeys("\<bs>", 'n')
		endif
	enddef


	###########################
	## Clipboard Operations
	###########################
	def Paste()
		const id = this.buf
		var pos = getpos('.')

		if this.clipboard.IsEmpty()
			return
		endif
		# var edit = this.undostack.Get()
		# noautocmd this.undostack.Add(edit, getbufline(this.buf, 1, '$'))
		this.undostack.Save(id)
		var edit = this.undostack.Get()
		var nb_len = this.clipboard.Len()

		for i in range(len(edit) + 1, pos[1] + 1, -1)
			edit[i + nb_len] = edit[i]
		endfor

		# Add Edit[New_id] with the clipboard content
		for i in range(0, nb_len - 1)
			var new_id = pos[1] + i
			var name = this.clipboard.Get(i)

			edit[new_id + 1] = {
				name: fnamemodify(name, ':t'),
				new_name: '',
				is_deleted: false,
				new_file: true,
				copy_of: name
			}
		endfor

		noautocmd var lines = getbufline(id, 1, '$')
		var new_lines: list<string> = []
		var i: number = 1
		var len_lines = len(lines)
		while i <= len_lines
			add(new_lines, lines[i - 1])
			if i == pos[1]
				var lst = this.clipboard.Copy()
				for y in range(0, len(lst) - 1)
					if lst[y][-1] == '/'
						lst[y] = fnamemodify(lst[y], ':h:t') .. '/'
					else
						lst[y] = fnamemodify(lst[y], ':t')
					endif
				endfor
				extend(new_lines, lst)
			endif
			i = i + 1
		endwhile
		noautocmd setbufline(id, 1, new_lines)
	enddef



	def Yank()
		const pos = getpos('.')

		var [ln, count] = Utils.GetBeginEndYank()
		if ln == -1 || count == -1
			return
		endif
		# Make sure we don't yank ../
		if ln == 1
			ln = 2 
			count -= 1
		endif
		
		this.clipboard.SetYank()

		var edit = this.undostack.Get()

		for i in range(ln, ln + count - 1)
			# Special case for ../
			if edit[i].name == '../'
				continue
			endif
			const complete_path = this.path .. '/' .. edit[i].name
			if complete_path == this.path
				continue
			endif
			this.clipboard.Add(complete_path)
		endfor
		# Actualize_popupclipboard(dict)
	enddef

	def Cut()
		var modified = getbufvar(this.buf, '&modified')
		const pos = getpos('.')
		# this.undostack.Add(this.undostack.Get(), getbufline(this.buf, 1, '$'))
		this.undostack.Save(this.buf)
		# TODO
		# Popup.SetTitle(dict.popup_clipboard, '📋 Clipboard (Delete)')

		var [ln, count] = Utils.GetBeginEndYank()
		if ln == -1 || count == -1
			return
		endif
		# Make sure we don't cut ../
		if ln == 1
			ln = 2 
			count -= 1
		endif

		this.clipboard.SetCut()
		var edit = this.undostack.Get()
		var remove_line: list<number> = []
		for i in range(ln, ln + count - 1)
			# Special case for ../
			if edit[i].name == '../'
				continue
			endif
			const complete_path = this.path .. '/' .. edit[i].name
			if edit[i].is_deleted == false
				if edit[i].copy_of != '' || edit[i].name == ''
					remove_line = add(remove_line, i)
					continue
				endif
				edit[i].is_deleted = true
				if complete_path == this.path
					continue
				endif
				this.clipboard.Add(complete_path)
			else
				edit[i].is_deleted = false
			endif
		endfor

		remove_line = reverse(remove_line)
		#delete the lines and move all lines after it
		var old_buffer = getbufline(this.buf, 1, '$')
		var new_buffer: list<string> = []

		for i in range(len(old_buffer))
			if index(remove_line, i + 1) != -1
				add(new_buffer, '')
				continue
			endif
			var line_content = old_buffer[i]
			add(new_buffer, line_content)
		endfor

		timer_start(10, (_) => {
			noautocmd setbufline(this.buf, 1, new_buffer)
			setpos('.', pos)
			this.Actualize()
			setbufvar(this.buf, '&modified', modified)
			this.Changed()
		})
	enddef


	#######################################################################
	# When the buffer is changed by the user
	# This function is called by the autocmd TextChangedI and TextChanged
	#######################################################################
	def Changed()
		const buf = this.buf
		const nb_lines = line('$') - 1
		var edit = this.undostack.Get()

		# ../ is a special case
		noautocmd setline(2, '../')
		edit[2] = {
			name: '../', # the name of the file or folder
			is_deleted: false, # if the file is deleted
			new_file: false, # if the file is a new file
			copy_of: '', # link to the original file if it is a copy
		}

		if nb_lines == 0
			noautocmd setbufline(buf, 1, '   ')
			noautocmd setbufline(buf, 2, ' ')
			edit[2] = {
				name: '',
				is_deleted: false,
				new_file: true,
				copy_of: '',
			}
			timer_start(10, (_) => {
				normal k
			})
		endif


		# NEW FILE (When a new line is added)
		if len(edit) < nb_lines
			var current = line('.')
			var new_file = {
				name: '',
				is_deleted: false,
				new_file: true,
				copy_of: '',
			}
			for i in range(nb_lines, current, -1)
				edit[i + 1] = edit[i]
			endfor
			edit[current] = new_file
			# add(this.undostack, edit)
			this.undostack.Add(edit, getbufline(buf, 1, '$'))
			this.Actualize()
			return
		endif

		const cursor = getpos('.')

		var p_begin = line('w0') - 1
		var p_end = len(edit) - 1
		if p_end >= line('w$')
			p_end = line('w$')
		endif

		# If the line is deleted, force the firstname of the file
		for i in range(p_begin, p_end + 1)
			if i == 0
				continue
			endif
			if edit[i + 1].is_deleted == true
				if getline(i + 1) != edit[i + 1].name
					noautocmd setline(i + 1, edit[i + 1].name)
				endif
			endif
		endfor

		for i in range(line('$'), 1, -1)
			if getline(i) == ''
				noautocmd execute ':' .. i .. 'd'
				for j in range(i, len(edit))
					if has_key(edit, j)
						edit[j] = edit[j + 1]
					endif
				endfor
				unlet edit[len(edit) + 1]
				continue
			endif
		endfor

		setpos('.', cursor)
		if line('.') == 1
			normal! j
		endif
		this.Actualize()
	enddef
endclass
