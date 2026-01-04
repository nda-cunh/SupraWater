vim9script noclear

if exists('g:SupraTreeLoaded')
	finish
endif

g:SupraTreeLoaded = 1

################################
## Import Modules
################################

import autoload 'SupraWater/SupraWater.vim' as SupraWater
import autoload 'SupraWater/Colors.vim' as Colors
import autoload 'SupraWater/FileManager.vim' as FileManager
import autoload 'SupraWater/DarkenColor.vim' as Darken

g:suprawater_icons_glyph_func = 'g:WebDevIconsGetFileTypeSymbol'
g:suprawater_icons_glyph_palette_func = 'SupraIcons#Palette#Apply'
g:suprawater_filter_files = []
g:suprawater_show_hidden = true 

nnoremap - <scriptcmd>call SupraWater.Water()<CR>

hi SupraWaterPath cterm=bold guifg=#f1c058 guibg=NONE
hi SupraWaterSort guifg=#00CAFF guibg=NONE
hi link SupraWaterSign Error
hi link SupraWaterErrorSign Error

augroup SupraWaterAutoCmd
	autocmd! 
	autocmd VimEnter,BufEnter * if isdirectory(@%) | SupraWater.Water() | endif
	autocmd ColorScheme * Darken.Create_HiColor()
augroup END

###############################
## Define Signs
###############################

if exists('g:SupraTreeSymbolSigns')
	execute 'sign define SupraWaterSign text=' .. g:SupraTreeSymbolSigns .. ' texthl=SupraWaterErrorSign'
else
	execute 'sign define SupraWaterSign text=✖ texthl=SupraWaterErrorSign'
endif


######################################
## Utility FileManager Function  
######################################

def g:SupraCopyFile(src: string, dest: string)
	FileManager.SupraCopyFile(src, dest)
enddef

def g:SupraMakeTempDir(): string
	return FileManager.SupraMakeTempDir()
enddef

def g:SupraCopyDir(src: string, dest: string)
	FileManager.SupraCopyDir(src, dest)
enddef

### Initialize the Darken (NormalDark) Colors
Darken.Create_HiColor()
