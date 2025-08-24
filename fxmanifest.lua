fx_version 'cerulean'
game 'gta5'

author 'Jokur'
description 'MorfaRP - Autorski skrypt na ekwipunek'
version '1.1.0'

client_scripts {
    'client.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}
