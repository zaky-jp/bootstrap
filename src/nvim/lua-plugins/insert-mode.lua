-- skip config when inside vscode
if vim.g.vscode then
	return
end

P.push { 'windwp/nvim-autopairs', -- auto-close pairs, require nvim v0.7+
	config = function()
		require('nvim-autopairs').setup()
	end,
}
P.push { 'kylechui/nvim-surround', -- enhance surrounding chars, require nvim v0.8+
	config = function()
		require('nvim-surround').setup()
	end,
}
