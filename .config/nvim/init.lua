-- disable netrw early
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- add playground plugin directory to runtimepath
vim.opt.runtimepath:append(vim.env.PLAYGROUND_DIR .. '/neovim')

