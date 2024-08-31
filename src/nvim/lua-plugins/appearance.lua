-- skip config when inside vscode
if vim.g.vscode then
	return
end

local H = require('internal/helper')

-- set colorscheme
vim.opt.background = 'light'

-- tell nvim when true color is available
if string.match(vim.env.TERM, '256-col') or vim.env.TERM == 'alacritty' then
	vim.opt.termguicolors = true
end

-- specify fonts for gui
if H.is_true(vim.fn.has('gui')) then
	vim.opt.guifont = 'SF Mono Square:h20'
end

-- show line numbers
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = 'yes'

-- show invisible chars
vim.opt.list = true
vim.opt.listchars = {
	tab = '>-',
	eol = '↴',
	trail = '_',
	extends = '>',
	precedes = '<',
	nbsp = '%'
}

-- show matching parentheses
vim.opt.showmatch = true
vim.opt.matchpairs:append '<:>' -- match xml-alike

P.push({ 'tpope/vim-fugitive' })
