--- This snippet checks game region and version and sets the partySizeAddress accordingly

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


-- Prints out the stats of all the pokemon seen. Useful to diagnose whether the script is working or not.
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

-- Necessary variables for the attemptcounter
attemptString = "Number of attempts: %d"
attemptBuffer = console:createBuffer("Attempts")
attempts = 0

-- Simply prints the attempts to a buffer
function attemptCounter() -- Tracks your attempts and prints them to a text buffer
  attempts = attempts + 1
  attemptText = string.format(attemptString, attempts)
  attemptBuffer:moveCursor(0,0)
  attemptBuffer:print(attemptText)
end

frameDelay = 0

function activeHunt()
  if frameDelay == 0 then -- Makes the RNG advance between SRs
    partySize = emu:read8(partySizeAddress) -- Updates Partysize every frame
    if partySize ~= (originalPartySize + 1) then -- Detects a change in partysize
      lastFrame = emu:currentFrame() -- This just marks the last frame of the partysize being constant, giving a measure of time further down
      if emu:currentFrame() % 8 == 0 then -- This block just mashes the A button in bursts of 4 frames on and off.
        emu:addKey(0)
      elseif emu:currentFrame() % 8 == 4 then
        emu:clearKey(0)
      end
    else
      if emu:currentFrame() >= lastFrame + 4 then -- This line is here to give a delay between the partysize updating and reading the stats, it was giving me blank stats w/o it.
        if checkShiny(targetAddress) then -- This block just terminates everything when a shiny is found
          emu:clearKey(0)
          console:log("Shiny Found! Terminating Script.")
          callbacks:remove(huntCBID)
        else -- Resets everything and updates stats for the next reset.
          frameDelay = 8 -- Framedelay to not reset multiple times on the same rng frame
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

emu:saveStateSlot(3,15) -- Savestate created beforehand to get the loop up and running
huntCBID = callbacks:add("frame",activeHunt) -- Runs activeHunt() every frame
