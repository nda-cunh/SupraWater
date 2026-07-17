vim9script

if has('patch-9.1.0850') == 0
	finish
endif

if !exists('*supraconfig#RegisterMany')
	finish
endif

import autoload '../autoload/SupraWater/DarkenColor.vim' as Darken

supraconfig#RegisterGroup('suprawater', 'SupraWater file explorer settings')

supraconfig#RegisterMany([
	# --- SUPRAWATER ---
	{
		id: 'suprawater/show_hidden',
		type: 'bool',
		default: true,
		lore: 'Show hidden files in the explorer',
		handler: (v) => {
			g:suprawater_show_hidden = v
		}
	},
	{
		id: 'suprawater/sort_ascending',
		type: 'bool',
		default: true,
		lore: 'Sort explorer files in ascending order',
		handler: (v) => {
			g:suprawater_sortascending = v
		}
	},
	{
		id: 'suprawater/show_metadata',
		type: 'bool',
		default: true,
		lore: 'Show file size and date in a right column',
		handler: (v) => {
			g:suprawater_show_metadata = v
		}
	},
	{
		id: 'suprawater/theme_darken_percent',
		type: 'number',
		default: 25,
		lore: 'Percentage to darken the explorer background',
		spawn: (v: number) => {
			g:suprawater_darken_amount = v
		},
		handler: (v: number) => {
			g:suprawater_darken_amount = v
			Darken.Create_HiColor()
		}
	},
	{
		id: 'suprawater/theme_forcecolor',
		type: 'string',
		default: "",
		lore: 'Force a specific hex color for the explorer (e.g. #adedb8)',
		spawn: (v) => {
			g:suprawater_force_color = v
		},
		handler: (v) => {
			g:suprawater_force_color = v
			Darken.Create_HiColor()
		}
	}
])
