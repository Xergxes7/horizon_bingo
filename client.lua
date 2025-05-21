
local QBCore = exports['qb-core']:GetCoreObject() 
local isCardActive = false
local bingoNumbers = {}
local selectedNumbers = {}

RegisterNetEvent("bingo:openCard", function(numbers)
    isCardActive = true
    bingoNumbers = numbers
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "openBingoCard",
        numbers = bingoNumbers,
        selected = selectedNumbers
    })
end)

RegisterNetEvent("bingo:client:newNumber", function(number)
    --lib.notify({ title = 'Bingo', description = 'New number called: '..number, type = 'inform' })
    SendNUIMessage({ action = "newNumber", number = number })
end)



RegisterNetEvent("bingo:client:controllernewNumber", function(number)
    lib.notify({ title = 'Bingo', description = 'New number called: '..number, type = 'inform' })
end)

RegisterNetEvent("bingo:client:resetGame", function()
    SendNUIMessage({ action = "resetGame"})
end)

RegisterNUICallback("selectNumber", function(data, cb)
    table.insert(selectedNumbers, data.number)
    cb("ok")
end)

RegisterNUICallback("checkBingo", function(_, cb)
    TriggerServerEvent("bingo:checkBingo", selectedNumbers)
    cb("ok")
end)

RegisterNUICallback("resetCard", function(_, cb)
    selectedNumbers = {}
    TriggerServerEvent("bingo:generateCard")
    cb("ok")
end)


RegisterNUICallback("getPlayerName", function(_, cb)
    local playerName = QBCore.Functions.GetPlayerData().charinfo.firstname .. " " .. QBCore.Functions.GetPlayerData().charinfo.lastname
    cb(playerName)
end)



RegisterNUICallback("closeCard", function(_, cb)
    isCardActive = false
    SetNuiFocus(false, false)
    cb("ok")
end)

CreateThread(function()
    exports['qb-target']:AddBoxZone("bingo_table", Config.BingoTableCoords, 1.5, 1.5, {
        name = "bingo_table",
        heading = 0,
        debugPoly = false,
        minZ = Config.BingoTableCoords.z - 1,
        maxZ = Config.BingoTableCoords.z + 1,
    }, {
        options = {
            {
                label = "Get Bingo Card",
                icon = "fas fa-ticket",
                action = function()
                    TriggerServerEvent("bingo:getCard")
                end,
            },
        },
        distance = 2.0
    })

    exports['qb-target']:AddBoxZone("bingo_controller", Config.ControllerCoords, 1.5, 1.5, {
        name = "bingo_controller",
        heading = 0,
        debugPoly = false,
        minZ = Config.ControllerCoords.z - 1,
        maxZ = Config.ControllerCoords.z + 1,
    }, {
        options = {
            {
                label = "Pick a Ball",
                icon = "fas fa-dice",
                job = Config.RequiredJob,
                action = function()
                    TriggerServerEvent("bingo:pickNumber")
                end,
            },
            {
                label = "Reset Game",
                icon = "fas fa-dice",
                job = Config.RequiredJob,
                action = function()
                    TriggerServerEvent("bingo:resetGame")
                end,
            },
        },
        distance = 2.0
    })
end)
