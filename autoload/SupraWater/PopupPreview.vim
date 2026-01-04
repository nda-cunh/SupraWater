vim9script

import autoload './Popup.vim' as APopup
import autoload './ClipBoard.vim' as NClipBoard

type Popup = APopup.Popup
type ClipBoard = NClipBoard.ClipBoard

export class PopupPreview extends Popup
	var filename: string

	def new(filename: string)
		this.filename = filename
		var options = {
			filter: this.FilterPreview,
			maxheight: &lines - 4,
			scrollbar: 1,
		}
		super.Init(options)
		this.Open()
	enddef

	def Open()
		try 
		var contents = readfile(this.filename)
		this.SetText(contents)
		catch
		endtry
		# enable FileTypeMode with auto ftdetect
		win_execute(super.wid, 'syntax clear')
		setwinvar(super.wid, '&syntax', '')
		setwinvar(super.wid, '&filetype', '')
		setwinvar(super.wid, '&number', 1)
		setwinvar(super.wid, '&cursorline', 0)
		win_execute(super.wid, 'filetype detect')
		win_execute(super.wid, 'silent! doautocmd filetypedetect BufNewFile ' .. this.filename)
		win_execute(super.wid, 'silent! setlocal nospell nolist')

	enddef

	def FilterPreview(wid: number, key: string): number
		if key ==? 'q' || key == "\<Esc>"
			this.Close()
		endif
		return 0
	enddef
endclass
