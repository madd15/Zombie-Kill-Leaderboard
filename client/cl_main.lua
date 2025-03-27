local client = awaitServerCallback('zombie_killboard:server:getConfig')

local isScoreboardVisible = false
local isTextVisible = client.visibleByDefault
local zombiekills = 0

-- Function to set display
function SetDisplay(state)
    SendNUIMessage({
        action = state and "show" or "hide"
    })
    SetNuiFocus(state, state)
end

function ToggleZombieKills(state)
    SendNUIMessage({
        action = state and "killshow" or "killhide",
    })
end

function SetZombieKills(kills)
    SendNUIMessage({
        action = "updatePlayerKills",
        kills = kills
    })
end

function incrementZombieKills()
    zombiekills = zombiekills + 1
    TriggerServerEvent("zombie_killboard:playerZombieKill")
    SetZombieKills(zombiekills)
end

RegisterCommand('toggleScoreboard', function()
    isScoreboardVisible = not isScoreboardVisible
    SetDisplay(isScoreboardVisible)
end, false)

RegisterCommand('toggleKillText', function()
    isTextVisible = not isTextVisible
    ToggleZombieKills(isTextVisible)
end, false)

local function toggleKillText(state)
    isTextVisible = state
    ToggleZombieKills(state)
end

exports('toggleKillText', toggleKillText)

RegisterNUICallback('close', function()
    isScoreboardVisible = false
    SetDisplay(false)
end)

-- NUI Callback for fetching player data
RegisterNUICallback('fetchPlayersData', function(data, cb)
    local playerData = awaitServerCallback('zombie_killboard:scoreboard:requestPlayerData')
    cb(playerData)
end)

RegisterNUICallback('fetchTop50PlayersData', function(data, cb)
    local playerData = awaitServerCallback('zombie_killboard:scoreboard:request50PlayersData')
    cb(playerData)
end)

RegisterNUICallback('fetchStatsData', function(data, cb)
    local stats = awaitServerCallback('zombie_killboard:scoreboard:requestStatsData')
    cb(stats)
end)

-- Bind the F10 key to toggle the scoreboard
RegisterKeyMapping('toggleScoreboard', 'Toggle Scoreboard', 'keyboard', 'F10')

AddEventHandler('onZombieDied', function(entity)
    if GetPedSourceOfDeath(entity) == PlayerPedId() then
        incrementZombieKills()
    end
end)

AddEventHandler('zombie_killboard:onPlayerLoaded', function()
    zombiekills = awaitServerCallback('zombie_killboard:getPlayerKills')
    SetZombieKills(zombiekills)
    ToggleZombieKills(isTextVisible)
end)

Citizen.CreateThread(function()
    while true do
        Wait(500)
        if IsPauseMenuActive() then
            ToggleZombieKills(false)
        else
            ToggleZombieKills(isTextVisible)
        end
    end
end)