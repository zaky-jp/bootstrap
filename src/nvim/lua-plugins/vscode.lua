if vim.g.vscode then
	local vscode = require('vscode')
	vim.notify = vscode.notify
end
