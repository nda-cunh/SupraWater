vim9script

import autoload './Popup.vim' as APopup

type Popup = APopup.Popup

export class PopupClipboard extends Popup
	var col: number
	var line: number

	def new(col: number, line: number)
		this.col = col
		this.line = line
		this.Construct()
	enddef

	def Construct()
		var options = {
			col: this.col,
			line: this.line,
			pos: 'topright',
			maxwidth: 50,
			title: '📋 Clipboard ',
			hidden: 1,
			filter: (_, _) => {
				return 0
			},
			mapping: 1,
		}
		super.Init(options)
	enddef

	def Clear()
		super.Close()
	enddef

	def SetText(lst: list<string>)
		if super.wid == 0
			this.Construct()
		endif
		super.SetText(lst)
		popup_show(this.wid)
	enddef
endclass
