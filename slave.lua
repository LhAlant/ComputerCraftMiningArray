utils = require("utils")
protocol = require("protocol")
constants = require("constants")

local modem = wrapModem()
modem.open(MOSI_CHANNEL)

local id = receiveSlaveId()

local currentPos = vector3D({0, 0, 0})
local rotation = 0

local fuel_enderchest_slot = 1
local bucket_slot = 2
local return_enderchest_slot = 3

--local maxFuelLevel = turtle.getFuelLimit() pas besoin de remplir les turtles
local maxFuelLevel = 1000
local absoluteMaxFuelLevel = 0 --Will be modified in the setup to be sure to catch the master's message since turtle operations are slow

function doSetup()
    absoluteMaxFuelLevel = turtle.getFuelLimit()

    --Place the fuel enderchest and refuel
    turtle.suckDown(fuel_enderchest_slot)
    safePlaceUp()

    while turtle.getFuelLevel() < maxFuelLevel do
        turtle.suckUp()
        turtle.refuel()
    end
    turtle.dropUp()
    turtle.transferTo(15)
    safeDigUp()

    --Get a bucket
    unsafeMove(1)
    turtle.select(bucket_slot)
    turtle.suckDown(1)

    --Get the return enderchest
    unsafeMove(1)
    turtle.select(return_enderchest_slot)
    turtle.suckDown(1)

    --Move one more and tell the master the turtle is done getting 
    safeMove(1)
    tellMasterSetupDone(modem, id)

    local goalPos = calculateRelativePosFromId(id)
    rotation = moveTo(currentPos, goalPos, rotation)
    currentPos = goalPos
    rotation = rotateTo(rotation, 0)
end

function startMiningLoop()
    while true do
        for i = turtle.getFuelLevel(), maxFuelLevel, -1 do
            safeDigLoop()
            currentPos.x = currentPos.x + 1
            if checkForLava(i) then
                i = turtle.getfuelLevel()
            end
            checkForFullInventory()
        end
    end
end

function checkForLava(currentFuelLevel)
    local status, block = turtle.inspect()
    if not status or block.name ~= "minecraft:lava" or block.state.level ~= 2 then
        return false
    end

    if absoluteMaxFuelLevel - 1000 <= turtle.getFuelLevel then
        return false
    end

    turtle.select(bucket_slot)
    turtle.refuel()

    return true
end

function refuelWhileMining()
    turtle.select(fuel_enderchest_slot)
    safePlaceDown()
    turtle.suckUp()
    turtle.refuel()
    turtle.digDown()
end

function checkForFullInventory()
    if not turtle.getItemCount(16) then
        return
    end

    dumpInventoryIntoReturnEnderchest(4)
end

function dumpInventoryIntoReturnEnderchest(startingSlot)
    turtle.select(return_enderchest_slot)
    safePlaceDown()
    for i = startingSlot, 16, 1 do
        turtle.select(i)
        turtle.dropDown()
    end
    turtle.select(3)
    turtle.digDown()
end

function disassembleArray()
    relativeXId = (id - 1) % 16 --The position of the turtle on it's row
    relativeYId = math.floor((id - 1) / 16) --The position of the turtle on it's column
    dumpInventoryIntoReturnEnderchest(1)
    rotation = rotateTo(rotation, 3)
    if relativeXId ~= 0 then
        safeMove(relativeXId - 1) --All the turtles will mine each others
        return
    end

    rotateTo(1)
    --Mine all the turtles on it's row
    while turtle.getItemCount(16) ~= 0 do
        turtle.dig()
    end 
    dumpInventoryIntoReturnEnderchest(1) --Returns all turtles in the storage

    if relativeYId ~= 0 then
        safeMoveDown((realtiveYid - 1) * 3 + 2)
        return
    end

    while true do
        turtle.digUp()
    end
end

while true do
    local message = receiveSlaveCommand()
    local data = splitStringBySpace(message)
    local command = data[1]

    if command == MOSI_DO_SETUP and tonumber(data[2]) == id then
        doSetup()
    elseif command == MOSI_START_MINING then
        parallel.waitForAny(startMiningLoop, receiveStopSignal)
    elseif command == MOSI_GOTO_X then
        rotation = moveTo(currentPos, {x = tonumber(data[2]), y = currentPos.y, z = currentPos.z}, rotation)
        currentPos.x = tonumber(data[2])
    elseif command == MOSI_GOTO_Y then
        rotation = moveTo(currentPos, {x = currentPos.x, y = tonumber(data[2]), z = currentPos.z}, rotation)
        currentPos.y = tonumber(data[2])
    elseif command == MOSI_GOTO_Z then
        rotation = moveTo(currentPos, {x = currentPos.x, y = currentPos.y, z = tonumber(data[2])}, rotation)
        currentPos.z = tonumber(data[2])
    elseif command == MOSI_DISASSEMBLE_ARRAY then
        disassembleArray()
    end
end