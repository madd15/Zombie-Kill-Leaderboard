local client = awaitServerCallback('zombie_killboard:server:getConfig')

local isScoreboardVisible = false
local isTextVisible = client.visibleByDefault
local zombiekills = 0

local function toggleKillText()
    isTextVisible = not isTextVisible
end

exports('toggleKillText', toggleKillText)

-- Function to set display
function SetDisplay(state)
    SendNUIMessage({
        action = state and "show" or "hide"
    })
    SetNuiFocus(state, state)
end

RegisterCommand('toggleScoreboard', function()
    isScoreboardVisible = not isScoreboardVisible
    SetDisplay(isScoreboardVisible)
end, false)

RegisterCommand('toggleKillText', function()
    toggleKillText()
end, false)

RegisterNUICallback('close', function()
    isScoreboardVisible = false
    SetDisplay(false)
end)

-- NUI Callback for fetching player data
RegisterNUICallback('fetchPlayersData', function(data, cb)
    local playerData = awaitServerCallback('zombie_killboard:scoreboard:requestPlayerData')
    cb(playerData)
end)

-- Bind the F10 key to toggle the scoreboard
RegisterKeyMapping('toggleScoreboard', 'Toggle Scoreboard', 'keyboard', 'F10')

AddEventHandler('onZombieDied', function(entity)
    if GetPedSourceOfDeath(entity) == PlayerPedId() then
        zombiekills = zombiekills + 1
        TriggerServerEvent("zombie_killboard:playerZombieKill")
    end
end)

AddEventHandler('zombie_killboard:onPlayerLoaded', function()
    zombiekills = awaitServerCallback('zombie_killboard:getPlayerKills')
end)

Citizen.CreateThread(function()
    while true do
        Wait(0)
        if isTextVisible then
            SetTextColour(client.rgb.r, client.rgb.g, client.rgb.b, client.alpha)
            SetTextFont(client.font)
            SetTextScale(client.size, client.size)
            SetTextWrap(0.0, 1.0)
            SetTextCentre(false)
            SetTextDropshadow(2, 2, 0, 0, 0)
            SetTextOutline()
            SetTextEntry("STRING")
            AddTextComponentString(client.label .."~w~: ".. zombiekills)
            DrawText(client.pos.x, client.pos.y)
        end
    end
end)