local vector3D_mt = {
    __add = 
    function(vec1, vec2)
        return {x = vec1.x + vec2.x, y = vec1.y + vec2.y, z = vec1.z + vec2.z}
    end,

    __sub =
    function(vec1, vec2)
        return {x = vec1.x - vec2.x, y = vec1.y - vec2.y, z = vec1.z - vec2.z}
    end,

    __tostring =
    function(vec)
        return ""..vec.x.." "..vec.y.." "..vec.z
    end,

    __call =
    function(vec, arg)
        if arg == "unformat" then
            numbers = splitStringBySpace(tostring(vec))
            return  vector3D({tonumber(numbers[1]), tonumber(numbers[2]), tonumber(numbers[3])})
        end
    end
}

function vector3D(table)
    table = {x = table[1], y = table[2]}
    return setmetatable(table, vector3D_mt)
end

function unformatVector3D(stringTable)
    numbers = splitStringBySpace(stringTable)
    return  vector3D({tonumber(numbers[1]), tonumber(numbers[2]), tonumber(numbers[3])})
end

--Utility to wrap the modem
function wrapModem()
    wrappedModem = peripheral.wrap("left")
    if wrappedModem then 
	return wrappedModem 
    end

    wrappedModem = peripheral.wrap("right")
    if wrappedModem then
	return wrappedModem
    end

    error("No modem found !")
end

--Will dig down until the block is not there
function safeDigDown()
    while turtle.detectDown() do
        turtle.digDown()
    end
end

--Will dig up until the block is not there
function safeDigUp()
    while turtle.detectUp() do 
        turtle.digUp()
    end
end

--Will dig up until the block is not there
function safeDig()
    while turtle.detect() do
        turtle.dig()
    end
end

--Will dig the block in front, bellow and under itself
function safeDigLoop()
    safeDigUp()
    safeDig()
    safeDigDown()
end

--Will dig left until the block is not there
function safeDigLeft()
    turtle.turnLeft()
    safeDig()
    turtle.turnRight()
end

--Ok t'as compris
function safeDigRight()
    turtle.turnRight()
    safeDig()
    turtle.turnLeft()
end

--Là aussi
function safeDigBack()
    turnAround()
    safeDig()
    turnAround()
end

--Ma arrêter de commenter tu comprends ce que ça fait làlà
function safePlaceDown()
    safeDigDown()
    turtle.placeDown()
end

function safePlaceUp()
    safeDigUp()
    turtle.placeUp()
end

function safePlace()
    safeDig()
    turtle.place()
end

function safePlaceLeft()
    turtle.left()
    safeDig()
    turtle.place()
    turtle.right()
end

function safePlaceRight()
    turtle.right()
    safeDig()
    turtle.place()
    turtle.left()
end

function safePlaceBack()
    turnAround()
    safeDig()
    turtle.place()
    turnAround()
end

--These functions will break blocks in their path
function safeMoveDown(amount)
    for _ = 1, amount, 1 do
        safeDigDown()
        turtle.down()
    end
end

function safeMoveUp(amount)
    for _ = 1, amount, 1 do
        safeDigUp()
        turtle.up()
    end
end

function safeMoveVertically(amount)
    if amount > 0 then
        safeMoveUp(amount)
    else
        safeMoveDown(math.abs(amount))
    end
end

function safeMove(amount)
    for _ = 1, amount, 1 do
        safeDig()
        turtle.forward()
    end
end

function safeMoveLeft(amount)
    turtle.left()
    safeMove(amount)
    turtle.right()
end

function safeMoveRight(amount)
    turtle.right()
    safeMove(amount)
    turtle.left()
end

function safeMoveBack(amount)
    turnAround()
    safeMove(amount)
    turnAround()
end

function unsafeMoveDown(amount)
    for _ = 1, amount, 1 do
        turtle.down()
    end
end

function unsafeMoveUp(amount)
    for _ = 1, amount, 1 do
        turtle.up()
    end
end

function unsafeMoveVertically(amount)
    if amount > 0 then
        unsafeMoveUp(amount)
    else
        unsafeMoveDown(math.abs(amount))
    end
end

function unsafeMove(amount)
    for _ = 1, amount, 1 do
        turtle.forward()
    end
end

function unsafeMoveLeft(amount)
    turtle.left()
    unsafeMove(amount)
    turtle.right()
end

function unsafeMoveRight(amount)
    turtle.right()
    unsafeMove(amount)
    turtle.left()
end

function unsafeMoveBack(amount)
    turnAround()
    unsafeMove(amount)
    turnAround()
end

--Tourne de 180 degrées
function turnAround()
    for _ = 1, 2, 1 do
        turtle.turnRight()
    end
end

--Returns a table containing the message splited by spaces
function splitStringBySpace(message)
    local data = {}
    for str in string.gmatch(message, "%S+") do
        table.insert(data, str)
    end
    
    return data
end

--Returns the relative position a turtle should have based on it's id
function calculateRelativePosFromId(id)
    id = id - 1

    local goalPos = {x = 0, y = 0, z = 0}

    goalPos.x = 0
    goalPos.y = math.floor(id / 16) * 3
    goalPos.z = 16 - (id % 16)

    return goalPos
end

function moveTo(currentPos, goalPos, currentRotation)
    local positionDiff = goalPos - currentPos

    currentRotation = rotateTo(currentRotation, getRotationFromXDiff(positionDiff.x))
    safeMove(math.abs(positionDiff.x))

    safeMoveVertically(positionDiff.y)

    currentRotation = rotateTo(currentRotation, getRotationFromZDiff(positionDiff.z))
    safeMove(math.abs(positionDiff.z))

    return currentRotation
end

function rotateTo(currentRotation, goalRotation)
    local diff = (goalRotation - currentRotation) % 4

    if diff == 1 then
        turtle.turnLeft()
    elseif diff == 2 then
        turnAround()
    elseif diff == 3 then
        turtle.turnRight()
    end

    return goalRotation
end

function getRotationFromXDiff(xOffset)
    if xOffset >= 0 then
        return 0
    end

    return 2
end

function getRotationFromZDiff(zOffset)
    if zOffset >= 0 then
        return 3
    end

    return 1
end
