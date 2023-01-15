--Constantes partagées entre master et slave

local MISO_CHANNEL = 42069
local MOSI_CHANNEL = 42070

local MOSI_PREFIX = "MOSI."
local MOSI_SET_ID = "SET_ID"
local MOSI_DO_SETUP = "DO_SETUP"
local MOSI_START_MINING = "START_MINING"
local MOSI_STOP_MINING = "STOP_MINING"
local MOSI_GOTO_X = "GOTO_X"
local MOSI_GOTO_X = "GOTO_Y"
local MOSI_GOTO_X = "GOTO_Z"
local MOSI_REQUEST_COORDS = "REQUEST_COORDS"
local MOSI_DISASSEMBLE_ARRAY = "DISASSEMBLE_ARRAY"

local MISO_PREFIX = "MISO."
local MISO_DONE_SETUPING = "DONE_SETUPING"
local MISO_RETURN_COORDS = "RETURN_COORDS"