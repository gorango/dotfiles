local mp = require("mp")
local utils = require("mp.utils")

mp.add_key_binding(nil, "open-dir", function()
	local path = mp.get_property_native("path")
	if not path then
		return
	end
	local dir = utils.split_path(path)
	mp.commandv("run", "mpv", dir)
end)
