vim9script

export class UndoStack
	var edit: list<dict<any>>
	var contents: list<list<string>>
	var position: list<list<number>>

	var redo_edit: list<dict<any>>
	var redo_contents: list<list<string>>
	var redo_position: list<list<number>>

	def new()
		this.Clear()
	enddef

	def Get(): dict<any>
		return this.edit[-1]
	enddef

	def InitPosition()
		this.position[-1] = deepcopy(getpos('.'))
	enddef

	def Len(): number
		return len(this.edit)
	enddef
	
	def GetContents(): list<string>
		return this.contents[-1]
	enddef

	def Redo(buf: number)
        if empty(this.redo_contents) | return | endif

        var r_item = remove(this.redo_edit, -1)
        var r_lines = remove(this.redo_contents, -1)
		var r_pos = remove(this.redo_position, -1)
        
        this.edit->add(r_item)
        this.contents->add(r_lines)
		this.position->add(r_pos)

        noautocmd this.ApplyToBuffer(buf, r_lines)
    enddef

    # Helper interne pour éviter de répéter le code de mise à jour
    def ApplyToBuffer(buf: number, lines: list<string>)
        noautocmd setbufline(buf, 1, lines)
        noautocmd deletebufline(buf, len(lines) + 1, '$')
		const pos = this.position[-1]
		noautocmd setpos('.', pos)
    enddef

	def Undo(buf: number)
        if len(this.edit) < 2
			echom "No more undo states available."
			this.ApplyToBuffer(buf, this.contents[0])
			return
		endif

        # On déplace le dernier état vers la pile Redo
        this.redo_edit->add(remove(this.edit, -1))
        this.redo_contents->add(remove(this.contents, -1))
		this.redo_position->add(remove(this.position, -1))

        var previous_lines = this.contents[-1]
        this.ApplyToBuffer(buf, previous_lines)
		echom "Undo performed. " .. this.Len() .. " states remaining."
    enddef


	def Save(buffer: number)
		if empty(this.edit)
			return
		endif

		var item = deepcopy(this.Get())
		var new_lines = deepcopy(getbufline(buffer, 1, '$'))
		this.Add(item, new_lines)
	enddef

	def Add(item: dict<any>, new_lines: list<string>)
		this.edit->add(deepcopy(item))
        this.contents->add(deepcopy(new_lines))
		this.position->add(deepcopy(getpos('.')))
		this.redo_edit = []
		this.redo_contents = []
		this.redo_position = []
	enddef

	def Clear()
		this.edit = []
        this.contents = []
        this.redo_edit = []
        this.redo_contents = []
		this.position = []
		this.redo_position = []
	enddef

endclass
