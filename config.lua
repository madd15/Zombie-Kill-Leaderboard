Config = {}

Config.debug = false
----------------------------------------------
--        💬 Setup text for client
----------------------------------------------
Config.client = {
    visibleByDefault = true,
    label = "Zombies",
    pos = { x = 0.02, y = 0.71 },
    rgb = { r = 255, g = 64, b = 64 },
    alpha = 255,
    size = 0.4,
    font = 4,
}
----------------------------------------------
--        💬 Setup discord webhook
----------------------------------------------
Config.discord = {
    -- Enable or disable the discord webhook
    enabled = true,
    -- Time in minutes to update the leaderboard
    updateTime = 30,
    -- The name of the webhook
    name = 'Zombie Kills Leaderboard',
    -- Discord bot token from https://discord.com/developers/applications
    botToken = '',
    -- Channel ID to send the webhook to (right click the channel and copy ID)
    channelID = '',
    -- The webhook profile image
    image = 'https://r2.fivemanage.com/C7VNUJE5Bo07WayfJSyol/image/image_2025-03-25_144330004.png',
    -- The webhook title
    title = '🏆 Top 10 Zombie Killers 🧟',
    -- The webhook footer image
    footer = 'https://r2.fivemanage.com/C7VNUJE5Bo07WayfJSyol/image/image_2025-03-25_144330004.png',
    -- The general emoji for zombie kills
    emoji = "💀",
    -- The emojis for top 3 players
    topEmojis = { "🥇", "🥈", "🥉" },
}
