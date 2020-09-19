local postalFile = 'ocrp-postals.json'

fx_version 'bodacious'
games {'gta5'}

title 'Golden_Menu'
description 'GoldenRP M Menu'
author 'Customized by Xd_Golden_Tiger. Full Credits go to Scott M'
version 'v1.5.3'

client_scripts {
    'dependencies/NativeUI.lua',
    'client.lua',
    'config.lua',
    'functions.lua',
    'menu.lua',
}

server_scripts {
    'config.lua',
    'server.lua',
    'functions.lua',
}


file(postalFile)
postal_file(postalFile)