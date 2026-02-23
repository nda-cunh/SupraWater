vim9script

export abstract class Popup
	var wid: number

	def Init(options: dict<any>)
		var options_base = {
			border: [1],
			borderhighlight: ['Normal', 'Normal', 'Normal', 'Normal'],
			borderchars: ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
			highlight: 'Normal',
			padding: [0, 1, 0, 1],
			mapping: 0,
			filter: this.Filter,
		}

		extend(options_base, options, 'force')

		this.wid = popup_create([], options_base)
		const bufnr = winbufnr(this.wid)
		setbufvar(bufnr, '&filetype', 'suprawater_popup')
		this.AddColorPalette()
	enddef

	def AddColorPalette()
		if exists('g:suprawater_icons_glyph_palette_func')
			var func_name = g:suprawater_icons_glyph_palette_func
			
			if exists($'*{func_name}')
				win_execute(this.wid, $':call {func_name}()')
			else
				echo 'Warning: Function ' .. func_name .. ' does not exist. Color palette will not be added.'
			endif
		endif
	enddef

	def SetText(lines: list<string>)
		popup_settext(this.wid, lines)
	enddef

	def Close()
		popup_close(this.wid)
		this.wid = 0
	enddef

	def Filter(wid: number, key: string): number
		if key ==? 'q' || key == "\<Esc>"
			this.Close()
		endif
		return 0
	enddef
endclass
