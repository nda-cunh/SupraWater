vim9script

import autoload './Utils.vim' as Utils
import autoload './PopupClipboard.vim' as PopupClipboard

export const CUT = 1
export const YANK = 2
type CliboardMode = number

export class ClipBoard
	var mode: CliboardMode
	var contents: list<string>
	var popup: PopupClipboard.PopupClipboard

	def new()
		this.mode = YANK
		this.contents = []
		const winid: number = winnr()
		const win_width = winwidth(winid)
		const win_height = winheight(winid)
		var [row, col_start] = win_screenpos(winid)

		var popup_width = 20
		var popup_height = 5

		var col = col_start + win_width - 2
		var line = row + 3
		this.popup = PopupClipboard.PopupClipboard.new(col, line)
	enddef

	def SetYank()
		this.mode = YANK
		this.contents = []
	enddef

	def SetCut()
		this.mode = CUT
		this.contents = []
	enddef

	def Add(item: string)
		add(this.contents, item)
		var new_text = []
		# change the home path to ~
		for i in this.contents 
			var text = substitute(i, '^' .. $HOME .. '/', '~/', 'g')
			text = Utils.GetIcon(text) .. '  ' .. text
			add(new_text, text)
		endfor
		this.popup.SetText(new_text)
	enddef

	def IsEmpty(): bool
		return len(this.contents) == 0
	enddef

	def IsCut(): bool
		return this.mode == CUT
	enddef

	def IsYank(): bool
		return this.mode == YANK
	enddef

	def Clear()
		this.contents = []
		this.popup.Clear()
	enddef

	def Len(): number
		return len(this.contents)
	enddef

	def Get(index: number): string
		return this.contents[index]
	enddef

	def Copy(): list<string>
		return copy(this.contents)
	enddef
endclass
