local AtkDef, SpeSpc

--- This snippet checks region and sets the partySizeAddress accordingly

local gameVer = emu:read8(0x141)
local gameReg = emu:read8(0x142)

local partySizeAddress

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



function checkShiny(atkDef, speSpc) -- Checks if the Pokémon is shiny
  if speSpc == 0xAA then
    if  atkDef == 0x2A or  atkDef == 0x3A or  atkDef == 0x6A or  atkDef == 0x7A or  atkDef == 0xAA or  atkDef == 0xBA or  atkDef == 0xEA or  atkDef == 0xFA then
      return true
    end
  end
  return false
end

--- This code is more specifically tailored for this script
originalPartySize = emu:read8(partySizeAddress)
local partySize = originalPartySize
if originalPartySize >= 6 then
  console:log("No Party Slot Available!")
end
local attempts = 0
targetAddress = partySizeAddress + (partySize * 0x30) + 1

console:log("originalPartySize: "..originalPartySize)

function activeHunt()
  while true do

    while partySize == originalPartySize do
      emu:addKey(0)
      emu:runFrame()
      emu:clearKey(0)
      emu:runFrame()
      partySize = emu:read8(partySizeAddress)
    end

    atkDef = emu:read8(targetAddress + 0x15)
    speSpc = emu:read8(targetAddress + 0x16)

    if checkShiny(AtkDef, SpeSpc) then
      console:log("Shiny Found! Terminating Script.")
      return true
    else
      attempts = attempts + 1
      console:log("Discarding. Attempts: "..attempts)
      emu:reset()
    end
  end
end

function activeHunt()
  while true do
    while partySize == originalPartySize do
      emu:addKey(0)
      emu:runFrame()
      emu:clearKey(0)
      emu:runFrame()
      partySize = emu:read8(partySizeAddress)
    end
    atkDef = emu:read8(targetAddress + 0x15)
    speSpc = emu:read8(targetAddress + 0x16)
    if checkShiny(AtkDef, SpeSpc) then
      console:error("Shiny Found! Terminating Script.")
      return
    else
      attempts = attempts + 1
      console:log("Discarding. Attempts: " + toString(attempts))
      emu:reset()
    end
  end
end

activeHunt()
