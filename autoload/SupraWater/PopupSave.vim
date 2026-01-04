vim9script

import autoload './Popup.vim' as APopup
import autoload './ClipBoard.vim' as NClipBoard

type Popup = APopup.Popup
type ClipBoard = NClipBoard.ClipBoard

export class PopupSave extends Popup
	var Cb_cancel: func()
	var Cb_yes: func()

	def new()
		var options = {
			filter: this.FilterSave,
		}
		super.Init(options)
	enddef

	def OnCancel(Cb: func())
		this.Cb_cancel = Cb
	enddef

	def OnYes(Cb: func())
		this.Cb_yes = Cb
	enddef

	def FilterSave(wid: number, key: string): number
		if key ==? 'q' || key ==? 'n' || key == "\<Esc>"
			this.Close()
		elseif key ==? 'c'
			if this.Cb_cancel != null
				this.Cb_cancel()
			endif
			this.Close()
		elseif key ==? 'y'
			if this.Cb_yes != null
				this.Cb_yes()
			endif
			this.Close()
		endif
		return 1
	enddef

	def ProcessModification(modified_file: dict<list<string>>, clipboard: ClipBoard, path: string)
		const actual_path = path .. '/'

		var commands = []
		var copy_history = []
		var delete_history = []

		for i in modified_file.all_copy
			var copy_of = i
			if copy_of[-1] == '/'
				var sp = split(copy_of, ' -> ')
				var full_path = substitute(sp[0], '/\+$', '', 'g')
				sp[1] = substitute(sp[1], '/\+$', '', 'g')
				var tmp_copy_file = g:SupraMakeTempDir()
				add(commands, 'g:SupraCopyDir(' .. shellescape(full_path) .. ', "' .. tmp_copy_file .. '")')
				var cmd = '"mv ' .. shellescape(tmp_copy_file) .. ' ' .. shellescape(actual_path .. sp[1]) .. '"'
				add(copy_history, "system(" .. cmd .. ")")
				if fnamemodify(sp[0], ':h') .. '/' != actual_path
					if clipboard.IsCut()
						add(delete_history, "delete(" .. shellescape(sp[0]) .. ", 'rf')")
					endif
				endif
			else
				var sp = split(copy_of, ' -> ')
				var tmp_copy_file = tempname()
				add(commands, 'g:SupraCopyFile(' .. shellescape(sp[0]) .. ', "' .. tmp_copy_file .. '")')
				add(copy_history, 'rename("' .. tmp_copy_file .. '", ' .. shellescape(actual_path .. fnamemodify(sp[1], ':t')) .. ')')
				if fnamemodify(sp[0], ':h') .. '/' != actual_path
					if clipboard.IsCut()
						add(delete_history, "delete(" .. shellescape(sp[0]) .. ")")
					endif
				endif
			endif
		endfor

		for i in modified_file.deleted
			var new_name = i
			if new_name[-1] == '/'
				new_name = fnamemodify(new_name, ':h:t')
				add(commands, 'delete(' .. shellescape(actual_path .. new_name) .. ', "rf")')
			else
				add(commands, 'delete(' .. shellescape(actual_path .. new_name) .. ')')
			endif
		endfor

		for i in modified_file.new_file
			var new_name = i
			if new_name[-1] == '/'
				add(commands, 'mkdir(' .. shellescape(actual_path .. new_name) .. ')')
			else
				add(commands, 'writefile([], ' .. shellescape(actual_path .. new_name) .. ')')
			endif
		endfor

		for i in modified_file.rename
			var [old_name, new_name] = split(i, ' -> ')
			if old_name[-1] == '/'
				old_name = fnamemodify(old_name, ':h:t')
				new_name = fnamemodify(new_name, ':h:t')
				add(commands, 'rename(' .. shellescape(actual_path .. old_name) .. ', ' .. shellescape(actual_path .. new_name) .. ')')
			else
				add(commands, 'rename(' .. shellescape(actual_path .. old_name) .. ', ' .. shellescape(actual_path .. new_name) .. ')')
			endif
		endfor

		extend(commands, copy_history)
		extend(commands, delete_history)

		for c in commands
			execute(c)
			echom 'Executed: ' .. c
		endfor

		clipboard.Clear()
	enddef
endclass
