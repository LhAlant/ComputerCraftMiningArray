--Pocket computer code to remotly control the slaves

local utils = require("utils")
local protocol = require("protocol")
local constants = require("constants")

local modem = peripheral.wrap("back") --Not a turtle, the utils command will not work since it's looking for a modem on the left
print("Stop mining ? Y/N")
local response = io.read()

if response == "y" or response == "Y" then
    tellSlavesToStopMining(modem)
    print("The slaves were told to stop mining")
    local slaveCoordinates = requestCoordinatesFromSlave(modem, 1) -- the id of the slave doesn't really matter, they should all approximately in the same area
    print("Coordinates were retrieved from slaves")
    tellSlaveToGotoX(modem, slaveCoordinates.x)
    print("Slaves are heawding to a specific X: "..slaveCoordinates.x)
    print("Giving them 20 seconds before the mining array disassembling sequence")
    sleep(20)
    startDisassemblingSequence()
end