-- disable netrw early
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- import wrapper for plugin manager
P = require('internal/pseudopack')

P.push { 'tomtom/tcomment_vim' } -- enhance comment toggle
P.sync()
