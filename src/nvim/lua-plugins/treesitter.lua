-- skip config when inside vscode
if vim.g.vscode then
	return
end

-- link highlight groups introduced by nvim-treesitter:
-- some groups are linked by default, but some are not, so manually linking

-- adapted from: https://github.com/nvim-treesitter/nvim-treesitter/commit/42ab95d5e11f247c6f0c8f5181b02e816caa4a4f#commitcomment-87014462
local hl = function(group, opts)
	opts.default = true
	vim.api.nvim_set_hl(0, group, opts)
end

-- how to select highlight groups to be added:
--   a) those used by treesitter (details at nvim-treesitter/CONTRIBUTING.md)
--   b) those linked by default (details at h: treesitter-highlight-groups)
--   union a*b minus b
-- below have full list, with b commented out, to help future update

-- Misc {{{
-- hl('@comment', {link = 'Comment'})
hl('@comment.documentation', { link = 'SpecialComment' })
hl('@error', { link = 'Error' })
hl('@none', { bg = 'NONE', fg = 'NONE' })
-- hl('@preproc', {link = 'PreProc'})
-- hl('@define', {link = 'Define'})
-- hl('@macro', {link = 'Macro'})
-- hl('@operator', {link = 'Operator'})
-- hl('@structure', {link = 'Structure'}) -- not in highlighter.scm
-- }}}
-- Punctuation {{{
-- hl('@punctuation', {link = 'Delimiter'}) -- not in high  .scm
hl('@punctuation.delimiter', { link = 'Delimiter' })
hl('@punctuation.bracket', { link = 'Delimiter' })
hl('@punctuation.special', { link = 'Delimiter' })
-- }}}
-- Literals {{{
-- hl('@string', {link = 'String'})
hl('@string.documentation', { link = 'SpecialComment' })
hl('@string.regex', { link = 'String' })
-- hl('@string.escape', {link = 'SpecialChar'})
-- hl('@string.special', {link = 'SpecialChar'})
-- hl('@character', {link = 'Character'})
-- hl('@character.special', {link = 'SpecialChar'})
-- hl('@boolean', {link = 'Boolean'})
-- hl('@number', {link = 'Number'})
-- hl('@float', {link = 'Float'})
-- }}}
-- Functions {{{
-- hl('@function', {link = 'Function'})
-- hl('@function.builtin', {link = 'Special'})
hl('@function.call', { link = 'Function' })
-- hl('@function.macro', {link = 'Macro'})
-- hl('@method', {link = 'Function'})
hl('@method.call', { link = 'Function' })
-- hl('@constructor', {link = 'Special'})
-- hl('@parameter', {link = 'Identifier'})
-- }}}
-- Keywords {{{
-- hl('@keyword', {link = 'Keyword'})
hl('@keyword.coroutine', { link = 'Keyword' })
hl('@keyword.function', { link = 'Keyword' })
hl('@keyword.operator', { link = 'Keyword' })
hl('@keyword.return', { link = 'Keyword' })
-- hl('@conditional', {link = 'Conditional'})
hl('@conditional.tenary', { link = 'Conditional' })
-- hl('@repeat', {link = 'Repeat'})
-- hl('@debug', {link = 'Debug'})
-- hl('@label', {link = 'Label'})
-- hl('@include', {link = 'Include'})
-- hl('@exception', {link = 'Exception'})
-- }}}
--
-- Types {{{
-- hl('@type', {link = 'Type'})
hl('@type.builtin', { link = 'Special' })
-- hl('@type.definition', {link = 'Typedef'})
hl('@type.qualifier', { link = 'Type' })
-- hl('@storageclass', {link = 'StorageClass'})
hl('@attribute', { link = 'PreProc' })
-- hl('@field', {link = 'Identifier'})
-- hl('@property', {link = 'Identifier'})
-- }}}
-- Identifiers {{{
-- hl('@variable', {link = 'Identifier'})
hl('@variable.builtin', { link = 'Special' })
-- hl('@constant', {link = 'Constant'})
-- hl('@constant.builtin', {link = 'Special'})
-- hl('@constant.macro', {link = 'Define'})
-- hl('@namespace', {link = 'Include'})
hl('@symbol', { link = 'Identifier' })
-- }}}
-- Text {{{
hl('@text', { link = 'Normal' })
hl('@text.strong', { bold = true })
hl('@text.emphasis', { italic = true })
-- hl('@text.underline', { link = 'Underlined' })
hl('@text.strike', { strikethrough = true })
-- hl('@text.title', {link = 'Title'})
hl('@text.quote', { link = 'Normal' })
-- hl('@text.uri', {link = 'Underlined'})
hl('@text.math', { link = 'Special' })
hl('@text.environment', { link = 'Macro' })
hl('@text.environment.name', { link = 'Type' })
-- hl('@text.reference', {link = 'Identifier'})
-- hl('@text.literal', {link = 'Comment'})
hl('@text.literal.block', { link = 'Comment' })
--  hl('@text.todo', {link = 'Todo'})
hl('@text.note', { link = 'SpecialComment' })
hl('@text.warning', { link = 'WarningMsg' })
hl('@text.warning', { link = 'WarningMsg' })
hl('@text.diff.add', { link = 'DiffAdd' })
hl('@text.diff.delete', { link = 'DiffDelete' })
-- }}}
-- Tags {{{
-- hl('@tag', {link = 'Tag'})
hl('@tag.attribute', { link = 'Identifier' })
hl('@tag.delimiter', { link = 'Delimiter' })
-- }}}
-- Conceal {{{
hl('@conceal', { link = 'Conceal' })
-- }}}
-- Spell {{{
hl('@spell', { link = 'Normal' })
hl('@nospell', { link = 'Normal' })
--- }}}
-- }
-- ### packages
P.push { 'nvim-treesitter/nvim-treesitter', -- intelligent syntax highlight, require nvim v0.9.1+
	run = function()
		local ok, _ = pcall(require, 'nvim-treesitter')
		if ok then
			vim.cmd.TSUpdate()
		end
	end,
}
