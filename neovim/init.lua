-- disable netrw early
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- package manager
--- bootstrap
vim.cmd.packadd('vim-jetpack') -- need to manually call packadd as jetpack is vimscript plugin
local packer = require('jetpack.packer')
packer.add {
  {'tani/vim-jetpack', opt = 1}, -- self-manage
  -- editor
  {'lewis6991/gitsigns.nvim'}, -- git integration
  {'tani/vim-typo'}, -- auto-fix typo
  {'cohama/lexima.vim'}, -- auto-close parentheses
  {'tpope/vim-surround'}, -- surround feature
  {'tomtom/tcomment_vim'}, -- comment feature
  {'dense-analysis/ale'}, -- linting
  -- appearance
  {'overcache/NeoSolarized'}, -- colorscheme
  {'lambdalisue/fern.vim'}, -- file tree
  {'zefei/vim-wintabs'}, -- tabbar
  {'mvllow/modes.nvim'}, -- line decoration
  {'luochen1990/rainbow'}, -- rainbow parentheses
  -- syntax
  {'isobit/vim-caddyfile', ft = 'caddyfile'},
  {'ekalinin/Dockerfile.vim', ft = 'dockerfile'},
}
local jetpack = require('jetpack')
for _, name in ipairs(jetpack.names()) do
  if jetpack.tap(name) ~= true then
    jetpack.sync() -- sync when any of the plugins uninstalled
    break
  end
end

-- config
--- misc
vim.opt.mouse = 'a'
vim.opt.clipboard = 'unnamedplus'
--- filesystem interaction
vim.opt.autochdir = true

-- editor
--- tabstop
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
--- indent style
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true
--- parentheses
vim.opt.showmatch = true
vim.opt.matchpairs:append '<:>' -- match xml-alike
vim.g.rainbow_active = true

-- appearance / window
--- true color
if string.match(vim.env.TERM, '256-col') or vim.env.TERM == 'alacritty' then
  vim.opt.termguicolors = true
end
--- colorscheme
vim.cmd.colorscheme 'NeoSolarized'
vim.opt.background = 'light'
--- font
if vim.fn.has('gui') == 1 then
  vim.opt.guifont = 'SF Mono Square:h20'
end
-- appearance / editor
--- line decoration
require('modes').setup()
--- line numbers
vim.opt.number = true
vim.opt.relativenumber = true
--- invisible chars
vim.opt.list = true
vim.opt.listchars = { 
  tab = '>-',
  eol = '$',
  trail = '_',
  extends ='❯',
  precedes = '❮',
  nbsp = '%'
}

-- file-specific
vim.opt.modelines = 3

-- syntax
vim.cmd.syntax 'on'