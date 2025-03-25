-- Initialize global variables to store framework, player table and identifier column
Framework = nil
PlayerTable = nil
IdentifierColumn = nil

-- Initialize framework based on the resources running
local function InitializeFramework()
    if GetResourceState('es_extended') == 'started' then
        ESX = exports['es_extended']:getSharedObject()
        Framework = 'esx'
        PlayerTable = 'users'
        IdentifierColumn = 'identifier'
    elseif GetResourceState('qbx_core') == 'started' then
        QBCore = exports['qb-core']:GetCoreObject()
        Framework = 'qbx'
        PlayerTable = 'players'
        IdentifierColumn = 'citizenid'
    elseif GetResourceState('qb-core') == 'started' then
        QBCore = exports['qb-core']:GetCoreObject()
        Framework = 'qb'
        PlayerTable = 'players'
        IdentifierColumn = 'citizenid'
    end
end

-- Get online players
function getPlayers()
    if Framework == 'esx' then
        return ESX.GetPlayers()
    elseif Framework == 'qb' or Framework == 'qbx' then
        return QBCore.Functions.GetPlayers()
    end
end

-- Get player from source
--- @param source number Player ID
function getPlayer(source)
    if not source then return end
    if Framework == 'esx' then
        return ESX.GetPlayerFromId(source)
    elseif Framework == 'qb' then
        return QBCore.Functions.GetPlayer(source)
    elseif Framework == 'qbx' then
        return exports.qbx_core:GetPlayer(source)
    else
        return nil
    end
end

-- Get player by identifier
function getPlayerByIdentifier(identifier)
    local player = nil
    if Framework == 'esx' then
        player = ESX.GetPlayerFromIdentifier(identifier)
    elseif Framework == 'qb' then
        player = QBCore.Functions.GetPlayerByCitizenId(identifier)
    elseif Framework == 'qbx' then
        player = exports.qbx_core:GetPlayerByCitizenId(identifier)
    end
    if not player then return false end
    return player
end

-- Get player name by identifier
function getPlayerName(identifier)
    local player = getPlayerByIdentifier(identifier)
    if not player then return end
    if Framework == 'esx' then
        return player.variables.firstName, player.variables.lastName
    elseif Framework == 'qb' or Framework == 'qbx' then
        local playerData = player.PlayerData
        return playerData.charinfo.firstname, playerData.charinfo.lastname
    end
end

-- Function to get a player identifier by source
--- @param source number Player ID
function getIdentifier(source)
    local player = getPlayer(source)
    if not player then return end
    if Framework == 'esx' then
        return player.identifier or player.getIdentifier()
    elseif Framework == 'qb' or Framework == 'qbx' then
        return player.PlayerData and player.PlayerData.citizenid or nil
    end
end

-- Register callback
function registerCallback(name, cb)
    if Framework == 'esx' then
        ESX.RegisterServerCallback(name, cb)
    elseif Framework == 'qb' or Framework == 'qbx' then
        QBCore.Functions.CreateCallback(name, cb)
    end
end

function debugPrint(msg, ...)
    if Config.debug then
        print(msg, ...)
    end
end

function InitializeDatabase()
    if Framework == 'esx' then
        local columnExists = MySQL.query.await('SHOW COLUMNS FROM users LIKE "zombiekills"')
        if not columnExists or #columnExists == 0 then
            MySQL.query.await('ALTER TABLE users ADD COLUMN zombiekills INT NOT NULL DEFAULT 0')
        end
    elseif Framework == 'qb' or Framework == 'qbx' then
        local columnExists = MySQL.query.await('SHOW COLUMNS FROM players LIKE "zombiekills"')
        if not columnExists or #columnExists == 0 then
            MySQL.query.await('ALTER TABLE players ADD COLUMN zombiekills INT NOT NULL DEFAULT 0')
        end
    end
    local tableExists = MySQL.query.await('SHOW TABLES LIKE "zombiekills_messages"')
    if not tableExists or #tableExists == 0 then
        MySQL.execute([[
        CREATE TABLE IF NOT EXISTS zombiekills_messages (
            id INT AUTO_INCREMENT PRIMARY KEY,
            message_id VARCHAR(50) NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        );
    ]], {})

        debugPrint("^2[INFO]^0 Table 'zombiekills_messages' created or already exists.")
    else
        debugPrint("^2[INFO]^0 Table 'zombiekills_messages' already exists.")
    end
end

-- Initialize defaults
InitializeFramework()
InitializeDatabase()
