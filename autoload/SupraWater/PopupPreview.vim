vim9script

import autoload './Popup.vim' as APopup

type Popup = APopup.Popup

export class PopupPreview extends Popup
	var filename: string

	def new(filename: string)
		this.filename = filename
		var width = min([&columns - 4, 100])
		var options = {
			maxheight: &lines - 4,
			minwidth: width,
			maxwidth: width,
			scrollbar: 1,
			moved: 'any'
		}
		super.Init(options)
		this.Open()
	enddef

	def Open()
		try 
		if !filereadable(this.filename)
			throw 'File not readable: ' .. this.filename
		endif
		var contents = readfile(this.filename)
		this.SetText(contents)
		catch
		endtry
		# Set syntax and filetype
		win_execute(super.wid, 'syntax clear')
		setwinvar(super.wid, '&syntax', '')
		setwinvar(super.wid, '&filetype', '')
		setwinvar(super.wid, '&number', 1)
		setwinvar(super.wid, '&cursorline', 0)
		win_execute(super.wid, 'filetype detect')
		win_execute(super.wid, 'silent! doautocmd filetypedetect BufNewFile ' .. this.filename)
		win_execute(super.wid, 'silent! setlocal nospell nolist')

	enddef
endclass
