fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'Madd Inspired by Goku | .astrozz'
description 'Scoreboard with Zombiekills'
version '1.0.0'

client_scripts {
    'bridge/client.lua',
    'client/cl_main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'config.lua',
    'bridge/server.lua',
    'server/sv_main.lua',
    'server/discord.lua',
}

files {
    'html/index.html',
    'html/assets/*.js',
    'html/assets/*.css'
}

ui_page 'html/index.html'

dependencies {
    'hrs_zombies_V2',
    'oxmysql'
}
