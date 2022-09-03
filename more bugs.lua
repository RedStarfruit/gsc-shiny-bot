function tester()
  console:log((emu:currentFrame() % 500).."")
  if emu:currentFrame() % 500 == 0 then
    emu:reset()
  end
end

testingCBID = callbacks:add("frame",tester)
