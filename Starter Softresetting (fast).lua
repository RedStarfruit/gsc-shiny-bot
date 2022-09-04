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
  local atkDef = emu:read8(targetAddress + 0x15)
  local speSpc = emu:read8(targetAddress + 0x16)
  if speSpc == 0xAA then
    if  atkDef == 0x2A or  atkDef == 0x3A or  atkDef == 0x6A or  atkDef == 0x7A or  atkDef == 0xAA or  atkDef == 0xBA or  atkDef == 0xEA or  atkDef == 0xFA then
      return true
    end
  end
  return false
end


statsBuffer = console:createBuffer("IVs")
function statViewer(targetAddress)
  local atkDef = emu:read8(targetAddress + 21)
  local speSpc = emu:read8(targetAddress + 22)
  if attempts % 8 == 0 then
    statsBuffer:clear()
  end
  statsBuffer:moveCursor(0,attempts % 8)
  statsBuffer:print("Attack: "..math.floor(atkDef/16).." Defense: "..(atkDef%16).." Speed: "..math.floor(speSpc/16).." Special: "..(speSpc%16))
end



--- This code is more specifically tailored for this script
originalPartySize = emu:read8(partySizeAddress)
console:log("Original Partysize: "..originalPartySize)
partySize = originalPartySize
if originalPartySize >= 6 then
  console:log("No Party Slot Available!")
end

targetAddress = partySizeAddress + (originalPartySize * 0x30) + 8 -- Sets the address of the target pokemon based on party size when activating the script
console:log(targetAddress.."")

attemptString = "Number of attempts: %d"
attemptBuffer = console:createBuffer("Attempts")
attempts = 0

function attemptCounter() -- Tracks your attempts and prints them to a text buffer
  attempts = attempts + 1
  attemptText = string.format(attemptString, attempts)
  attemptBuffer:moveCursor(0,0)
  attemptBuffer:print(attemptText)
end

frameDelay = 0

function activeHunt()
  if frameDelay == 0 then
    partySize = emu:read8(partySizeAddress)
    if partySize ~= (originalPartySize + 1) then
      lastFrame = emu:currentFrame()
      if emu:currentFrame() % 8 == 0 then
        emu:addKey(0)
      elseif emu:currentFrame() % 8 == 4 then
        emu:clearKey(0)
      end
    else
      if emu:currentFrame() >= lastFrame + 4 then
        if checkShiny(targetAddress) then
          emu:clearKey(0)
          console:log("Shiny Found! Terminating Script.")
          callbacks:remove(huntCBID)
        else
          frameDelay = 8
          emu:clearKey(0)
          statViewer(targetAddress)
          attemptCounter()
          emu:loadStateSlot(3,15)
        end
      end
    end
  else
    frameDelay = frameDelay - 1
    emu:saveStateSlot(3,15)
  end
end

emu:saveStateSlot(3,15)
huntCBID = callbacks:add("frame",activeHunt)
