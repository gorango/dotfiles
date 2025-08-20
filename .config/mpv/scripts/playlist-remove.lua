mp.register_script_message("playlist-remove", function(index)
	local playlist = mp.get_property_native("playlist")
	local current = mp.get_property_number("playlist-pos", 0)

	if index == "current" then
		table.remove(playlist, current + 1)
		mp.commandv("playlist-remove", current)
	else
		local i = tonumber(index)
		if i and i >= 0 and i < #playlist then
			mp.commandv("playlist-remove", i)
		end
	end
end)
