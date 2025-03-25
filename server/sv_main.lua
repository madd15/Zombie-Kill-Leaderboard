registerCallback('zombie_killboard:server:getConfig', function(src, cb)
    cb(Config.client)
end)

-- Function to get the player data for the scoreboard
local function GetScoreboardData()
    local players = {}
    local identifiers = {}

    for _, playerId in ipairs(getPlayers()) do
        local playerIdentifier = getIdentifier(playerId)
        if playerIdentifier then
            identifiers[#identifiers + 1] = playerIdentifier
        end
    end

    if #identifiers == 0 then
        return players
    end

    local query = ('SELECT %s AS ID, zombiekills FROM %s WHERE %s IN (?)'):format(IdentifierColumn, PlayerTable, IdentifierColumn)
    local results = MySQL.query.await(query, { identifiers })

    if results then
        for _, player in ipairs(results) do
            local firstname, lastname = getPlayerName(player.ID)
            players[#players + 1] = {
                name = (firstname or "Unknown") .. ' ' .. (lastname or "Player"),
                zombieKills = player.zombiekills or 0
            }
        end
    else
        print("^1[ERROR]^0 Failed to fetch player data from database.")
    end

    return players
end


-- Register the callback to get the player data
registerCallback('zombie_killboard:scoreboard:requestPlayerData', function(src, cb)
    local players = GetScoreboardData()
    cb(players)
end)

registerCallback('zombie_killboard:getPlayerKills', function(src, cb)
    local playerID = getIdentifier(src)
    if not playerID then return 0 end
    local query = ('SELECT zombiekills FROM %s WHERE %s = ?'):format(PlayerTable, IdentifierColumn)
    local result = MySQL.scalar.await(query, { playerID })
    cb(tonumber(result) or 0)
end)

RegisterServerEvent('zombie_killboard:playerZombieKill', function()
    local src = source
    local playerID = getIdentifier(src)
    if not playerID then return end
    local query = ('UPDATE %s SET zombiekills = zombiekills + 1 WHERE %s = ?'):format(PlayerTable, IdentifierColumn)
    MySQL.query.await(query, { playerID })
end)
