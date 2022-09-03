--- This snippet checks region and sets the partySizeAddress accordingly

gameVer = emu:read8(0x141)
gameReg = emu:read8(0x142)


if gameVer == 0x54 then
  if gameReg == 0x44 or gameReg == 0x46 or gameReg == 0x49 or gameReg == 0x53 then
    console:log("EUR Crystal Detected!")
    partySizeAddress = 0xDCD7
  elseif gameReg == 0x45 then
    console:log("USA Crystal Detected!")
    partySizeAddress = 0xDCD7
  elseif gameReg == 0x4A then
    console:log("JPN Crystal Detected!")
    partySizeAddress = 0xDC9D
  end
elseif gameVer == 0x55 or gameVer == 0x58 then
  if gameReg == 0x44 or gameReg == 0x46 or gameReg == 0x49 or gameReg == 0x53 then
    console:log("EUR Gold/Silver Detected!")
    partySizeAddress = 0xDA22
  elseif gameReg == 0x45 then
    console:log("USA Gold/Silver Detected!")
    partySizeAddress = 0xDA22
  elseif gameReg == 0x4A then
    console:log("JPN Gold/Silver Detected!")
    partySizeAddress = 0xD9E8
  elseif gameReg == 0x4B then
    console:log("KOR Gold/Silver Detected!")
    partySizeAddress = 0xDB1F
  end
else
console:log("Unknown Game; Ceasing Script")
  return
end
----



function checkShiny(targetAddress) -- Checks if the Pokémon is shiny
  atkDef = emu:read8(targetAddress + 0x15)
  speSpc = emu:read8(targetAddress + 0x16)
  if speSpc == 0xAA then
    if  atkDef == 0x2A or  atkDef == 0x3A or  atkDef == 0x6A or  atkDef == 0x7A or  atkDef == 0xAA or  atkDef == 0xBA or  atkDef == 0xEA or  atkDef == 0xFA then
      return true
    end
  end
  return false
end

--- This code is more specifically tailored for this script
originalPartySize = emu:read8(partySizeAddress)
partySize = originalPartySize
if originalPartySize >= 6 then
  console:log("No Party Slot Available!")
end

targetAddress = partySizeAddress + (partySize * 0x30) + 1 -- Sets the address of the target pokemon based on party size when activating the script

attemptString = "Number of attempts: %d"
attemptBuffer = console:createBuffer("Attempts")
attempts = 0

function attemptCounter() -- Tracks your attempts and prints them to a text buffer
  attempts = attempts + 1
  attemptText = string.format(attemptString, attempts)
  attemptBuffer:moveCursor(0,0)
  attemptBuffer:print(attemptText)
end



function activeHunt()
  partySize = emu:read8(partySizeAddress)
  if partySize ~= (originalPartySize + 1) then
    if emu:currentFrame() % 8 == 0 then
      emu:addKey(0)
    elseif emu:currentFrame() % 8 == 4 then
      emu:clearKey(0)
    end
  else
    if checkShiny(targetAddress) then
      console:log("Shiny Found! Terminating Script.")
      callbacks:remove(attemptCBID)
    else
      attemptCounter()
      emu:reset()
    end
  end
end

--attemptCBID = callbacks:add("reset",attemptCounter)
huntCBID = callbacks:add("frame",activeHunt)
