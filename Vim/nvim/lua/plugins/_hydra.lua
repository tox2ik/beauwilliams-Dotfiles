
local Hydra = require('hydra')
local cmd = require('hydra.keymap-util').cmd

-- NOTE: For key mappings we use this
Hydra.spawn = function(head)
   if head == 'Hydra_Telescope' then
	  Hydra_Telescope:activate()
   end
   if head == 'Hydra_Options' then
	  Hydra_Options:activate()
   end
   if head == 'Hydra_Window' then
	  Hydra_Window:activate()
   end
end

local hint_telescope = [[

		  _f_: files       _m_: marks
	  ▄▀  _o_: old files   _g_: live grep
 █▀▀▀█▀█  _p_: projects    _/_: search in file
  ▀▄░▄▀   _r_: resume      _u_: undotree
	█     _h_: vim help    _c_: execute command
  ▄▄█▄▄   _k_: keymaps     _;_: commands history
		  _O_: options     _?_: search history

		  _<Enter>_: Telescope           _<Esc>_
]]

Hydra_Telescope = Hydra({
   name = 'Telescope',
   hint = hint_telescope,
   config = {
	  color = 'teal',
	  invoke_on_body = true,
	  hint = {
		 position = 'middle',
		 border = 'rounded',
	  },
   },
   mode = 'n',
   -- body = '<Leader>f',
   heads = {
	  { 'f', cmd 'Telescope find_files' },
	  { 'g', cmd 'Telescope live_grep' },
	  { 'o', cmd 'Telescope oldfiles', { desc = 'recently opened files' } },
	  { 'h', cmd 'Telescope help_tags', { desc = 'vim help' } },
	  { 'm', cmd 'MarksListBuf', { desc = 'marks' } },
	  { 'k', cmd 'Telescope keymaps' },
	  { 'O', cmd 'Telescope vim_options' },
	  { 'r', cmd 'Telescope resume' },
	  { 'p', cmd 'Telescope projects', { desc = 'projects' } },
	  { '/', cmd 'Telescope current_buffer_fuzzy_find', { desc = 'search in file' } },
	  { '?', cmd 'Telescope search_history',  { desc = 'search history' } },
	  { ';', cmd 'Telescope command_history', { desc = 'command-line history' } },
	  { 'c', cmd 'Telescope commands', { desc = 'execute command' } },
	  { 'u', cmd 'silent! %foldopen! | UndotreeToggle', { desc = 'undotree' }},
	  { '<Enter>', cmd 'Telescope', { exit = true, desc = 'list all pickers' } },
	  { '<Esc>', nil, { exit = true, nowait = true } },
   }
})

local hint_options = [[
^                  ^  ^ ^ ^^^^Options                    ^
^⠀⠀⠀⢀⣴⣷⡀⠀⠀⠀⠀⠀⢸⣦⡀⠀⠀⠀^  ^ ^ ^^^^^                          ^
^⠀⠀⡐⣿⣿⣿⣿⣄⠀⠀⠀⠀⢸⣿⣿⣦⡀⠀^  _v_ %{ve}^^^ virtual edit          ^
^⠀⢸⠈⢎⢿⣿⣿⣿⣦⠀⠀⠀⢸⣿⣿⣿⡇⠀^  _i_ %{list}^ invisible characters  ^
^⠀⢸⠀⠀⠢⡻⣿⣿⣿⣷⡀⠀⢸⣿⣿⣿⡇⠀^  _s_ %{spell} spell                 ^
^⠀⢸⠀⠀⠀⡇⠙⣿⣿⣿⣿⣄⢸⣿⣿⣿⡇⠀^  _w_ %{wrap}^ wrap                  ^
^⠀⢸⠀⠀⠀⡇⠀⠈⢿⣿⣿⣿⣮⢻⣿⣿⡇⠀^  _c_ %{cul}^^ cursor line           ^
^⠀⢸⠀⠀⠀⡇⠀⠀⠀⠻⣿⣿⣿⣷⡹⣿⡇⠀^  _n_ %{nu}^^^ number                ^
^⠀⠈⠢⡀⠀⡇⠀⠀⠀⠀⠙⣿⣿⣿⣿⠜⠁⠀^  _r_ %{rnu}^^ relative number       ^
^⠀⠀⠀⠈⠢⡇⠀⠀⠀⠀⠀⠈⢿⠟⠁⠀⠀⠀^  ^ ^ ^^^^^                          ^
^                  ^      ^^^^^               _q_: exit  ^
]]

Hydra_Options = Hydra({
   name = 'Options',
   hint = hint_options,
   config = {
	  color = 'amaranth',
	  invoke_on_body = true,
	  hint = {
		 border = 'rounded',
		 position = 'middle'
	  }
   },
   mode = {'n','x'},
   body = '<leader>o',
   heads = {
	  { 'n', function()
		 if vim.o.number == true then
			vim.o.number = false
		 else
			vim.o.number = true
		 end
	  end, { desc = 'number' } },
	  { 'r', function()
		 if vim.o.relativenumber == true then
			vim.o.relativenumber = false
		 else
			vim.o.number = true
			vim.o.relativenumber = true
		 end
	  end, { desc = 'relativenumber' } },
	  { 'v', function()
		 if vim.o.virtualedit == 'all' then
			vim.o.virtualedit = 'block'
		 else
			vim.o.virtualedit = 'all'
		 end
	  end, { desc = 'virtualedit' } },
	  { 'i', function()
		 if vim.o.list == true then
			vim.o.list = false
		 else
			vim.o.list = true
		 end
	  end, { desc = 'show invisible' } },
	  { 's', function()
		 if vim.o.spell == true then
			vim.o.spell = false
		 else
			vim.o.spell = true
		 end
		 -- NOTE: exit on submit
		 -- end, { exit = true, desc = 'spell' } },
	  end, { desc = 'spell' } },
	  { 'w', function()
		 if vim.o.wrap ~= true then
			vim.o.wrap = true
			-- Dealing with word wrap:
			-- If cursor is inside very long line in the file than wraps
			-- around several rows on the screen, then 'j' key moves you to
			-- the next line in the file, but not to the next row on the
			-- screen under your previous position as in other editors. These
			-- bindings fixes this.
			vim.keymap.set('n', 'k', function() return vim.v.count > 0 and 'k' or 'gk' end,
			   { expr = true, desc = 'k or gk' })
			vim.keymap.set('n', 'j', function() return vim.v.count > 0 and 'j' or 'gj' end,
			   { expr = true, desc = 'j or gj' })
		 else
			vim.o.wrap = false
vim.keymap.del('n', 'k')
			vim.keymap.del('n', 'j')
		 end
	  end, { desc = 'wrap' } },
{ 'c', function()
   if vim.o.cursorline == true then
			vim.o.cursorline = false
		 else
vim.o.cursorline = true
		 end
	  end, { desc = 'cursor line' } },
	  { "<Esc>", nil, { exit = true, desc = false } },
{ "<CR>",  nil, { exit = true, desc = false } },
	  { "q",     nil, { exit = true, desc = false } },
}
})


Hydra_Window = Hydra({
   name = "Change / Resize Window",
mode = { "n" },
body = "<leader>8",
config = {
-- color = "pink",
},
heads = {
   -- move between windows
{ "<C-h>", "<C-w>h" },
{ "<C-j>", "<C-w>j" },
	  { "<C-k>", "<C-w>k" },
{ "<C-l>", "<C-w>l" },

	  -- resizing window
	  { "H", "<C-w>3<" },
	  { "L", "<C-w>3>" },
	  { "K", "<C-w>2+" },
	  { "J", "<C-w>2-" },

	  -- equalize window sizes
{ "e", "<C-w>=" },

-- close active window
	  { "Q", ":q<cr>" },
{ "<C-q>", ":q<cr>" },

	  -- exit this Hydra
{ "q", nil, { exit = true, nowait = true } },
{ ";", nil, { exit = true, nowait = true } },
	  { "<Esc>", nil, { exit = true, nowait = true } },
   },
})

local hint_actions = [[

					     Actions
 ⠀⠀⠀⢀⣴⣷⡀⠀⠀⠀⠀⠀⢸⣦⡀⠀⠀⠀
 ⠀⠀⡐⣿⣿⣿⣿⣄⠀⠀⠀⠀⢸⣿⣿⣦⡀⠀   _t_: Telescope   _m_: marks
 ⠀⢸⠈⢎⢿⣿⣿⣿⣦⠀⠀⠀⢸⣿⣿⣿⡇⠀   _o_: Options     _g_: live grep
 ⠀⢸⠀⠀⠢⡻⣿⣿⣿⣷⡀⠀⢸⣿⣿⣿⡇⠀   _p_: projects    _/_: search in file
 ⠀⢸⠀⠀⠀⡇⠙⣿⣿⣿⣿⣄⢸⣿⣿⣿⡇⠀   _r_: resume      _u_: undotree
 ⠀⢸⠀⠀⠀⡇⠀⠈⢿⣿⣿⣿⣮⢻⣿⣿⡇⠀   _h_: vim help    _c_: execute command
 ⠀⢸⠀⠀⠀⡇⠀⠀⠀⠻⣿⣿⣿⣷⡹⣿⡇⠀   _k_: keymaps     _;_: commands history
 ⠀⠈⠢⡀⠀⡇⠀⠀⠀⠀⠙⣿⣿⣿⣿⠜⠁⠀   _O_: options     _?_: search history
 ⠀⠀⠀⠈⠢⡇⠀⠀⠀⠀⠀⠈⢿⠟⠁⠀⠀⠀
                      _<Enter>_: Telescope      _<Esc>_: Quit\
]]

Hydra_Actions = Hydra({
	name = 'Action',
	hint = hint_actions,
	config = {
		color = 'teal',
		invoke_on_body = true,
		hint = {
			position = 'middle',
			border = 'rounded',
		},
	},
	mode = 'n',
	body = '<Leader>a',
	heads = {
		{ 't', cmd 'lua require"hydra".spawn("Hydra_Telescope")', { desc = 'Fuzzy search and pickers' } },
		{ 'o', cmd 'lua require"hydra".spawn("Hydra_Options")', { desc = 'Neovim options' } },
		{ 'g', cmd 'Telescope live_grep' },
		{ 'h', cmd 'Telescope help_tags', { desc = 'vim help' } },
		{ 'm', cmd 'MarksListBuf', { desc = 'marks' } },
		{ 'k', cmd 'Telescope keymaps' },
		{ 'O', cmd 'Telescope vim_options' },
		{ 'r', cmd 'Telescope resume' },
		{ 'p', cmd 'Telescope projects', { desc = 'projects' } },
		{ '/', cmd 'Telescope current_buffer_fuzzy_find', { desc = 'search in file' } },
		{ '?', cmd 'Telescope search_history',  { desc = 'search history' } },
		{ ';', cmd 'Telescope command_history', { desc = 'command-line history' } },
		{ 'c', cmd 'Telescope commands', { desc = 'execute command' } },
		{ 'u', cmd 'silent! %foldopen! | UndotreeToggle', { desc = 'undotree' }},
		{ '<Enter>', cmd 'Telescope', { exit = true, desc = 'list all pickers' } },
		{ '<Esc>', nil, { exit = true, nowait = true } },
	}
})





--[[ Hydra({
   config = {
	  invoke_on_body = true,
	  hint = {
		 position = 'middle',
		 border = 'rounded',
	  },
},
name = 'Side scroll',
   mode = 'n',
   body = '<Leader>7',
   heads = {
	  { 'h', '5zh' },
	  { 'l', '5zl', { desc = '←/→' } },
	  { 'H', 'zH' },
	  { 'L', 'zL', { desc = 'half screen ←/→' } },
   }
}) ]]
