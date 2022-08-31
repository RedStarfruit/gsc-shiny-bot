formatString = "Current Frame: %d"
tb = console:createBuffer("Frame")
function poll()
	local frame = emu:currentFrame()
	local msg = string.format(formatString,frame)
	tb:moveCursor(0,0)
	tb:print(msg)
end
cbidPoll = callbacks:add("frame",poll)
