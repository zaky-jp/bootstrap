local H = require('internal/helper')

-- import jetpack
vim.cmd.packadd('vim-jetpack') -- need to manually call packadd as jetpack is vimscript plugin

local packs = {}

local add_pack = function(pack)
	table.insert(packs, pack)
end

local load_packs = function()
	require('jetpack.packer').add(packs)
end

local sync_packs = function()
	load_packs()
	local jetpack = require('jetpack')
	for _, name in ipairs(jetpack.names()) do
		if not H.is_true(jetpack.tap(name)) then
			jetpack.sync() -- sync when any of the plugins uninstalled
			break
		end
	end
end

add_pack { 'tani/vim-jetpack', opt = 1 } -- cspell: disable-line

return {
	push = add_pack,
	load = load_packs,
	sync = sync_packs,
}
