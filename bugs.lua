local partySizeAddress = 0xDCD7
local i = 1
function loopTester ()
  while i < 10000 do
    emu:addKey(0)
    emu:runFrame()
    emu:clearKey(0)
    emu:runFrame()
    i = i + 1
  end
end

loopTester()
