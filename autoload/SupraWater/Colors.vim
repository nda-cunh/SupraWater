vim9script

#####################################
# Highlighting and properties
#####################################

export var colors: dict<any> = {}

const suprawater_palette: dict<list<string>> = {
	# Red glyphs
	'GlyphPalette1': ['', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''],
	# Green glyphs
	'GlyphPalette2': ['', '', '', '', '', '', '󰡄', '', '', '', '', '', '', ''],
	# Yellow glyphs
	'GlyphPalette3': ['λ', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '󰜡', '', '', '', '', '', '', '', '', '', '', '󰗀'],
	# Blue glyphs
	'GlyphPalette4': ['', '', '', '', '', '', '󰌛', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '󱎒', '󱎒', '󱎏', '󱎏', '󱎐', '', '󰬈', '󰬉', '󰬊', '󰬋', '󰬌', '󰬍', '󰬟', '󰬠', '󰬡', ''],
	# Purple glyphs
	'GlyphPalette5': ['', '', '', '', '', '󱎎', ''],
	# Cyan glyphs
	'GlyphPalette6': ['', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''],
	# Orange glyphs
	'GlyphPalette7': ['', '', '', '', '', '', '', '', '', '', '', ''],
	# Gray glyphs
	'GlyphPalette8': [],
	'GlyphPalette9': ['', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''],
	'GlyphPaletteDirectory': ['', '', '', '', '', '', '', '', '', '', '󱂵', '󰉏', '󰉐', '󰉑', '󰉒', '󰉓', '󰉔', '󰉕', '󰉖', '󰉗', '󰉘', '󰉙', '󰉍', '󰚝', '󱧺', '󰉓', '', '', '󰉋', '󱍙'],
}

const GLYPH_PALETTE_COLORS = {
    light: [
        '#dcdfe7', '#cc517a', '#668e3d', '#c57339', '#2d539e', '#7759b4', '#3f83a6', '#33374c',
        '#8389a3', '#cc3768', '#598030', '#b6662d', '#22478e', '#6845ad', '#327698', '#262a3f'
    ],
    dark: [
        '#1e2132', '#e27878', '#b4be82', '#e2a478', '#84a0c6', '#a093c7', '#89b8c2', '#c6c8d1',
        '#6b7089', '#e98989', '#c0ca8e', '#e9b189', '#91acd1', '#ada0d3', '#95c4ce', '#d2d4de'
    ]
}

def Highlight(s_colors: list<string>)
    highlight default link SupraWaterGlyphPaletteDirectory Directory

    for i in range(len(s_colors))
        var color = s_colors[i]
        execute $'highlight default SupraWaterGlyphPalette{i} ctermfg={i} guifg={color}'
    endfor
enddef

def ApplyDefaults()
    var s_colors: list<string>

    if exists('g:terminal_ansi_colors')
        s_colors = g:terminal_ansi_colors
    elseif exists('g:terminal_color_0')
        s_colors = range(16)->mapnew((i, _) => get(g:, $'terminal_color_{i}'))
    else
        s_colors = GLYPH_PALETTE_COLORS[&background]
    endif

    Highlight(s_colors)

    augroup GlyphPaletteDefaultsHighlightInternal
        autocmd!
        autocmd ColorScheme * ++once ApplyDefaults()
    augroup END


	for key in suprawater_palette->keys()
		var lst = suprawater_palette[key]
		var name_prop = 'SupraWater' .. key
		call prop_type_delete(name_prop)
		call prop_type_add(name_prop, {highlight: name_prop})
		for i in lst
			colors[i] = name_prop
		endfor
	endfor

	execute 'hi SupraWaterGlyphPaletteTrash guifg=#ee2222 guibg=NONE'
	call prop_type_delete('SupraWaterGlyphPaletteTrash')
	call prop_type_add('SupraWaterGlyphPaletteTrash', {highlight: 'SupraWaterGlyphPaletteTrash'})
	colors[''] = 'SupraWaterGlyphPaletteTrash'
enddef

def InitColor(bg_color: string, name: string, color: string, lst: list<string>)
	const name_prop = 'suprawaterFile' .. name
	execute 'hi clear ' .. name_prop
	execute 'hi ' .. name_prop .. ' ' .. color .. ' guibg=' .. bg_color
	call prop_type_delete(name_prop)
	call prop_type_add(name_prop, {highlight: name_prop})
	for i in lst
		colors[i] = name_prop
	endfor
enddef

call ApplyDefaults()
