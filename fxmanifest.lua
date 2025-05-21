
fx_version 'cerulean'
game 'gta5'
lua54 'yes'
version '1.0.0'
description 'Bingo Minigame with NUI using QB-Core, ox_lib, qb-target, oxmysql'
author 'Xergxes7'

shared_scripts {

    '@ox_lib/init.lua',
    'config.lua'
} 

client_scripts {
    'client.lua',
}

ox_libs {
    'interface',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
}
