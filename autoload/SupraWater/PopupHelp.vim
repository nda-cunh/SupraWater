vim9script

import autoload './Popup.vim' as APopup

type Popup = APopup.Popup

export class PopupHelp extends Popup
	def new()
		var options = {
			scrollbar: 1,
			moved: 'any'
		}
		super.Init(options)
		this.Open()
	enddef

	def Open()
		const lines: list<string> = [
			'',
			' • <Ctrl-q> or q           * Quit',
			' • <Ctrl-s> or :w          * Save',
			' • <BackSpace> or <->      * Back',
			' • <Enter> or <Click>      * Enter the folder',
			' • <ctrl-h>                * Open with Split',
			' • <ctrl-v>                * Open with Vsplit',
			' • <Ctrl-t>                * Open with a new Tab',
			' • <Ctrl-p>                * Preview of the file',
			' • g.                      * Toggle hidden files',
			' • =                       * Toggle the Sort mode',
			' • ~                       * Go to the home directory',
			' • _                       * Enter the folder and jump'
		]
		setwinvar(super.wid, '&filetype', 'markdown')
		setbufvar(winbufnr(super.wid), '&filetype', 'markdown')
		setbufvar(winbufnr(super.wid), '&syntax', 'markdown')
		
		super.SetText(lines)
	enddef
endclass
