if Config.discord.enabled then

    local lastMessageID = nil

    -- Function to retrieve the last message ID from the database
    function getLastMessageID()
        MySQL.query("SELECT message_id FROM zombiekills_messages ORDER BY id DESC LIMIT 1", {}, function(result)
            if result[1] then
                lastMessageID = result[1].message_id
                debugPrint("^2[INFO]^0 Retrieved last message ID:", lastMessageID)
            else
                lastMessageID = nil
                debugPrint("^3[INFO]^0 No previous message ID found. Will create a new one.")
            end
        end)
    end

    -- Function to save the message ID to the database
    function saveMessageID(messageID)
        MySQL.execute("INSERT INTO zombiekills_messages (message_id) VALUES (?)", { messageID }, function(affectedRows)
            if affectedRows > 0 then
                debugPrint("^2[INFO]^0 Saved new message ID:", messageID)
            else
                debugPrint("^1[ERROR]^0 Failed to save message ID.")
            end
        end)
    end

    -- Function to get the top 10 players by zombie kills
    local function getTop10Players()
        local query = nil
        if Framework == 'esx' then
            query =
            'SELECT identifier AS ID, firstname, lastname, zombiekills FROM users ORDER BY zombiekills DESC LIMIT 10'
        elseif Framework == 'qb' or Framework == 'qbx' then
            query =
            'SELECT citizenid AS ID, charinfo, zombiekills FROM players ORDER BY zombiekills DESC LIMIT 10'
        else
            debugPrint("^1[ERROR]^0 Unsupported framework detected!")
            return {}
        end

        local results = MySQL.query.await(query)
        local players = {}

        if results then
            for _, player in ipairs(results) do
                local firstname, lastname = "Unknown", "Player"

                if Framework == "esx" then
                    -- ESX: Names are stored directly in columns
                    firstname = player.firstname or "Unknown"
                    lastname = player.lastname or "Player"
                elseif Framework == "qb" or Framework == "qbx" then
                    -- QBCore: Names are inside `charinfo` JSON
                    local charinfo = json.decode(player.charinfo or "{}")
                    firstname = charinfo.firstname or "Unknown"
                    lastname = charinfo.lastname or "Player"
                end

                players[#players + 1] = {
                    name = firstname .. " " .. lastname,
                    zombiekills = player.zombiekills or 0
                }
            end
        else
            debugPrint("^1[ERROR]^0 Failed to fetch top 10 players from database.")
        end

        return players
    end

    local function sendNewLeaderboard(embed)
        PerformHttpRequest("https://discord.com/api/v10/channels/" .. Config.discord.channelID .. "/messages",
            function(err, text, headers)
                if err == 200 and text then
                    local response = json.decode(text)
                    if response and response.id then
                        if response.id ~= lastMessageID then
                            saveMessageID(response.id)
                        end
                        lastMessageID = response.id
                        debugPrint("^2[INFO]^0 New leaderboard message posted. ID:", lastMessageID)
                    else
                        debugPrint("^1[ERROR]^0 Failed to retrieve new message ID.")
                    end
                else
                    debugPrint("^1[ERROR]^0 Failed to send new leaderboard. HTTP Error:", err)
                end
            end, 'POST', json.encode({ embeds = embed }), {
                ['Content-Type'] = 'application/json',
                ['Authorization'] =
                    'Bot ' .. Config.discord.botToken
            }
        )
    end

    -- Function to send the top 10 players embed to the Discord webhook
    function sendTop10ToDiscord()
        local topPlayers = getTop10Players()
        local description = ""
        for i, player in ipairs(topPlayers) do
            local rpName = player.name
            local rankEmoji = Config.discord.topEmojis[i] or Config.discord.emoji
            description = description .. rankEmoji .. " " .. rpName .. " - " .. player.zombiekills .. " Kills\n\n"
        end

        local embed = {
            {
                ["title"] = Config.discord.title,
                ["description"] = description,
                ["color"] = 16753920,
                ["footer"] = {
                    ["text"] = "Last updated " .. os.date("%a %b %d, %I:%M%p") ..
                    "\nUpdated every " .. Config.discord.updateTime .. " minutes",
                    ["icon_url"] = Config.discord.footer
                }
            }
        }

        -- Delete the previous message if we have a valid ID
        if lastMessageID then
            local url = "https://discord.com/api/v10/channels/" ..
            Config.discord.channelID .. "/messages/" .. lastMessageID
            PerformHttpRequest(url, function(err, text, headers)
                if err == 200 then
                    debugPrint("^2[INFO]^0 Leaderboard updated (PATCH).")
                elseif err == 404 then
                    debugPrint("^1[ERROR]^0 Previous message not found. Posting new leaderboard...")
                    sendNewLeaderboard(embed)
                else
                    debugPrint("^1[ERROR]^0 Failed to update leaderboard. HTTP Error:", err)
                end
            end, 'PATCH', json.encode({
                embeds = embed,
            }), {
                ['Content-Type'] = 'application/json',
                ['Authorization'] =
                    'Bot ' .. Config.discord.botToken
            })
        else
            sendNewLeaderboard(embed)
        end
    end

    AddEventHandler("onResourceStart", function(resourceName)
        if GetCurrentResourceName() ~= resourceName then return end
        local tableExists = MySQL.query.await('SHOW TABLES LIKE "zombiekills_messages"')
        while not tableExists do
            Wait(5000)
            tableExists = MySQL.query.await('SHOW TABLES LIKE "zombiekills_messages"')
        end
        Wait(4000)
        getLastMessageID()
    end)

    -- Event to update the embed every 60 seconds
    CreateThread(function()
        Wait(6000)
        while true do
            sendTop10ToDiscord()
            Wait(Config.discord.updateTime * 60 * 1000)
        end
    end)
end
