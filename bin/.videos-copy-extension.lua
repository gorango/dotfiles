-- VLC Extension to copy current video file to destination directory
-- This extension is loaded by the videos command
-- Place this in ~/.local/share/vlc/lua/extensions/ or use --lua-config

function descriptor()
	return {
		title = "Video Copy Extension",
		version = "1.0",
		author = "videos command",
		shortdesc = "Copy current video to destination",
		description = "Copies the currently playing video to the folder where the videos command was executed. Triggered by the 'S' key.",
		capabilities = { "input-listener" },
	}
end

-- Global variables
local current_file = nil
local marker_file = os.getenv("VIDEOS_COPY_MARKER")

function activate()
	vlc.msg.info("Video Copy Extension activated")

	if not marker_file or marker_file == "" then
		vlc.msg.err("VIDEOS_COPY_MARKER not set")
	end
end

function deactivate()
	vlc.msg.dbg("Video Copy Extension deactivated")
end

function input_changed()
	local input = vlc.object.input()
	if input then
		local item = vlc.input.item()
		if item then
			current_file = item:uri()
			vlc.msg.dbg("Current file: " .. tostring(current_file))
		end
	end
end

-- Function to trigger copy via marker file
function trigger_copy()
	if not current_file then
		vlc.msg.warn("No video currently playing")
		return
	end

	if not marker_file or marker_file == "" then
		vlc.msg.err("VIDEOS_COPY_MARKER not set")
		return
	end

	-- Write current file URI to marker file
	local f = io.open(marker_file, "w")
	if f then
		f:write(current_file)
		f:close()
		vlc.msg.info("Copy triggered for: " .. current_file)

		-- Show OSD message
		local osd = vlc.osd and vlc.osd.channel and vlc.osd.channel(1)
		if osd then
			osd:message("Copying video...")
		end
	else
		vlc.msg.err("Could not write marker file: " .. marker_file)
	end
end

-- Menu entry
function menu()
	return {
		{ "Copy video to destination (S)", trigger_copy },
	}
end

-- Handle hotkeys
function trigger_hotkey(hotkey)
	if hotkey == "copy_video" then
		trigger_copy()
	end
end
