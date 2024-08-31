-- skip config when inside vscode
if vim.g.vscode then
	return
end

-- define indent
vim.opt.autoindent = true
vim.opt.smartindent = true

-- define folding level
vim.opt.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true

-- use mouse
vim.opt.mouse = 'a'

-- use system clipboard
vim.opt.clipboard = 'unnamedplus'

-- change current directory automatically by current file
vim.opt.autochdir = true

-- tell nvim how many lines to expect to read modelines
vim.opt.modelines = 3
