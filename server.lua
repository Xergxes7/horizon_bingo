
local QBCore = exports['qb-core']:GetCoreObject() 
local calledNumbers = {}
local alreadyGenerated = false
RegisterServerEvent("bingo:getCard", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
        if Player.Functions.AddItem(Config.BingoCardItem, 1) then
            TriggerClientEvent("ox_lib:notify", src, {
            title = "Bingo",
            description = "Card Received",
            type = "success"})
        else
            TriggerClientEvent("ox_lib:notify", src, {
            title = "Bingo",
            description = "Could not give card",
            type = "error"
        })
    end
end)

QBCore.Functions.CreateUseableItem(Config.BingoCardItem, function(source)
    TriggerClientEvent('ox_lib:notify', source,{ title = "Bingo", description = "Generating Numbers", type = "success" })
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local citizenId = Player.PlayerData.citizenid
    if alreadyGenerated then
        exports.oxmysql:execute('SELECT numbers FROM bingo_cards WHERE player_id = ?', { citizenId }, function(result)
            if result[1] then
                local cardNumbers = json.decode(result[1].numbers)
                TriggerClientEvent("bingo:openCard", src, cardNumbers)
            else
                        alreadyGenerated = true
                        generateCardForPlayer(source)  
            end
        end)
    else
        alreadyGenerated = true
        generateCardForPlayer(source)   
    end
end)

RegisterServerEvent("bingo:generateCard", function()
    local src = source
    generateCardForPlayer(src)
end)

function generateCardForPlayer(source)
    local cardNumbers = generateBingoCardNumbers()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local citizenId = Player.PlayerData.citizenid
    exports.oxmysql:insert('INSERT INTO bingo_cards (player_id, numbers) VALUES (?, ?) ON DUPLICATE KEY UPDATE numbers = ?', {
        citizenId, json.encode(cardNumbers), json.encode(cardNumbers)
    })
    Citizen.Wait(3000)
    TriggerClientEvent('ox_lib:notify', src,{ title = "Bingo", description = "Numbers Generated", type = "success" })
    TriggerClientEvent("bingo:openCard", src, cardNumbers)
end

RegisterServerEvent("bingo:pickNumber", function()
    local newNumber = math.random(1, 75)
    while tableContains(calledNumbers, newNumber) do
        newNumber = math.random(1, 75)
    end
    table.insert(calledNumbers, newNumber)
    --print("New number: " .. newNumber)
    TriggerClientEvent("bingo:client:newNumber", -1, newNumber)
    TriggerClientEvent("bingo:client:controllernewNumber", source, newNumber)
end)

RegisterServerEvent("bingo:resetGame", function()
    calledNumbers = {}
    local src = source
    TriggerClientEvent("bingo:client:resetGame", -1)
    TriggerClientEvent("ox_lib:notify", src, {
        title = "Bingo",
        description = "Game has been reset!",
        type = "info"
    })
end)


RegisterServerEvent("bingo:checkBingo", function(selected)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local citizenId = Player.PlayerData.citizenid
    exports.oxmysql:execute('SELECT numbers FROM bingo_cards WHERE player_id = ?', { citizenId }, function(result)
        if result[1] then
            local stored = json.decode(result[1].numbers)
            if checkForBingo(stored, selected) then
                TriggerClientEvent("ox_lib:notify", src, {
                    title = "Bingo",
                    description = "You got BINGO!",
                    type = "success"
                })
            end
        end
    end)
end)

function generateBingoCardNumbers()
    local nums = {}
    while #nums < 25 do
        local num = math.random(1, 75)
        if not tableContains(nums, num) then
            table.insert(nums, num)
        end
    end
    return nums
end

function checkForBingo(original, selected)
    return #selected >= 5 and allIn(selected, original)
end

function allIn(a, b)
    for _, v in ipairs(a) do
        if not tableContains(b, v) then return false end
    end
    return true
end

function tableContains(tbl, val)
    for _, v in ipairs(tbl) do
        if v == val then return true end
    end
    return false
end
