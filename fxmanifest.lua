--[[
──────────────────────────────────────────────────────────────────

	SEM_InteractionMenu (fxmanifest.lua) - Created by Scott M
	Current Version: v1.5.1 (June 2020)
	
	Support: https://semdevelopment.com/discord
	
		!!! Change vaules in the 'config.lua' !!!
	DO NOT EDIT THIS IF YOU DON'T KNOW WHAT YOU ARE DOING

──────────────────────────────────────────────────────────────────
]]



fx_version 'bodacious'
games {'gta5'}

--DO NOT REMOVE THESE
title 'Golden_Menu'
description 'GoldenRP M Menu'
author 'Customized by Xd_Golden_Tiger. Full Credits go to Scott M'
version 'v1.5.1' --This is required for the version checker, DO NOT change or remove

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
