vim9script

export const CUT = 1
export const YANK = 2
type CliboardMode = number

export class ClipBoard
	var mode: CliboardMode
	var contents: list<string>

	def new()
		this.mode = YANK
		this.contents = []
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
