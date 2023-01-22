constants = require("constants")

--Gives the slaves an id
--Master ->
function giveSlaveId(modem, id)
    modem.transmit(MOSI_CHANNEL, MOSI_CHANNEL, ""..MOSI_PREFIX..MOSI_SET_ID.." "..tostring(id))
end

--Tells the slave to do the setup sequence()
--Master ->
function makeSlaveDoSetup(modem, id)
    modem.transmit(MOSI_CHANNEL, MOSI_CHANNEL, ""..MOSI_PREFIX..MOSI_DO_SETUP.." "..id)
end

--Receives a slave id from the master
--Slave <-
function receiveSlaveId()
    while true do
        local e, side, recv, rply, message, distance = os.pullEvent("modem_message")

        if distance == 1 then
            local data = splitStringBySpace(message)
            if data[1] == ""..MOSI_PREFIX..MOSI_SET_ID then
                return tonumber(data[2])
            end
        end
    end
end

--Receives a command from the master
--Slave <-

function receiveSlaveCommand()
    while true do
        local e, side, recv, rply, message = os.pullEvent("modem_message")
        if string.sub(message, 1, 5)  == "MOSI." then
           return string.sub(message, 6, -1) --keeps the right half of the string
        end
    end
end

--Tell the master the turtle is done getting the setup items
--Slave ->
function tellMasterSetupDone(modem, id)
    modem.transmit(MISO_CHANNEL, MISO_CHANNEL, ""..MISO_PREFIX..MISO_DONE_SETUPING)
end

--Listen for when the slave is done placing and verifies it's id
--Master <-
function listenSlaveSetupDone(id)
    local e, side, recv, rply, message, distance = os.pullEvent("modem_message")
    if string.sub(message, 1, 5)  == "MISO." then
        local data = splitStringBySpace(string.sub(message, 6, -1))
        if data[1] == MISO_DONE_SETUPING and tonumber(data[2]) == id then
            return
        end
    end
end

--Master tells the slave to start their mining sequence
--Master ->
function tellSlavesToStartMining(modem)
    modem.transmit(MOSI_CHANNEL, MOSI_CHANNEL, ""..MOSI_PREFIX..MOSI_START_MINING)
end

function tellSlavesToStopMining(modem)
    modem.transmit(MOSI_CHANNEL, MOSI_CHANNEL, ""..MOSI_PREFIX..MOSI_STOP_MINING)
end

--Slave receives a signal to stop mining
--Slave <-
function receiveStopSignal()
    local stopSignal = ""..MOSI_PREFIX..MOSI_STOP_MINING
    while true do
        local e, side, recv, rply, message, distance = os.pullEvent("modem_message")
        if message == stopSignal then
            return
        end
    end
end

--Master tells a specific slave to transmit it's coordinates
--Master ->
function requestCoordinatesFromSlave(modem, id)
    modem.transmit(MOSI_CHANNEL, MOSI_CHANNEL, ""..MOSI_PREFIX..MOSI_REQUEST_COORDS.." "..id)

    local expectedMessage = ""..MISO_PREFIX..MISO_RETURN_COORDS
    local e, side, recv, rply, message, distance = os.pullEvent("modem_message")
    if string.sub(message, 1, #expectedMessage) ~= expectedMessage then
        error("Got '"..message.."' expected '"..expectedMessage.."', shutting down")
    end

    return unformatVector3D(string.sub(message, #expectedMessage + 1, -1))
end

function tellCoordinatesToMaster(modem, currentPos)
    print("tostring(currentPos) : "..tostring(currentPos).." currentPos : "..currentPos)
    modem.transmit(MOSI_CHANNEL, MOSI_CHANNEL, ""..MISO_PREFIX..MISO_RETURN_COORDS.." "..tostring(currentPos))
end

--Master tells the slave to go to a specific coordinate relative to where they started
--Master ->
function tellSlaveToGotoX(modem, x)
    modem.transmit(MOSI_CHANNEL, MOSI_CHANNEL, ""..MOSI_PREFIX..MOSI_GOTO_X.." "..x)
end

--Master ->
function tellSlaveToGotoY(modem, y)
    modem.transmit(MOSI_CHANNEL, MOSI_CHANNEL, ""..MOSI_PREFIX..MOSI_GOTO_Y.." "..y)
end

--Master ->
function tellSlaveToGotoZ(modem, z)
    modem.transmit(MOSI_CHANNEL, MOSI_CHANNEL, ""..MOSI_PREFIX..MOSI_GOTO_Z.." "..z)
end

function startDisassemblingSequence()
    modem.transmit(MOSI_CHANNEL, MOSI_CHANNEL, ""..MOSI_PREFIX..MOSI_DISASSEMBLE_ARRAY)
end