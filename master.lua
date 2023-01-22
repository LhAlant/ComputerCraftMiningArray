--Code pour la tortue maitre, qui commande les autres
--Inventaire :
--Slot 1 :  Enderchest avec les esclaves
--Slot 2 :  Enderchest avec les enderchest de carburant
--Slot 3 :  Enderchest avec les sceaux vides
--Slot 4 :  Enderchest avec les enderchest de retour de minage

utils = require("utils")
protocol = require("protocol")
constants = require("constants")

local modem = wrapModem()
modem.open(MISO_CHANNEL)

local enderchest_containing_turtles_slot = 1
local enderchest_containing_fuel_enderchests_slot = 2
local enderchest_containing_buckets_slot = 3
local enderchest_containing_return_enderchests_slot = 4

--Place toutes les enderchests
function placeEnderchests()
    turtle.select(enderchest_containing_turtles_slot)
    safeDigDown()
    turtle.placeDown()

    for i = enderchest_containing_fuel_enderchests_slot, enderchest_containing_return_enderchests_slot, 1 do
        turtle.forward()
        turtle.select(i)
        safeDigDown()
        turtle.placeDown()
    end

    --Retourne au dessus du premier enderchest
    unsafeMoveBack(enderchest_containing_return_enderchests_slot - enderchest_containing_turtles_slot)
end

function placeTurtles()
    for i = 1, 56, 1 do
        turtle.suckDown(1)
        turtle.place()
        sleep(0.3)
        local slave = peripheral.wrap("front")
        slave.turnOn()
        sleep(0.3) --Let the turtle startup
        giveSlaveId(modem, i)
        makeSlaveDoSetup(modem, i)

        listenSlaveSetupDone(i) --waits for the turtle to be done picking up items
        if i % 16 == 1 then
            sleep(5) --Give the turtle enough time to clear the stone to go to it's post
        end
    end
end

function startMining()
    tellSlavesToStartMining(modem)
end

placeEnderchests()
placeTurtles()
startMining()