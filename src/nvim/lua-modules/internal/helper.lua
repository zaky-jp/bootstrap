local is_true = function(v)
	-- vimscript variables and functions may not always return boolean, so wrapping up function can be useful
	return v == true or v == 1 or v == '1' or v == 'yes'
end

return {
	is_true = is_true,
}
