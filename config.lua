Config = {}

Config.MenuButton = 244

Config.MenuWidth = 50

Config.MenuPosition = 'left'

Config.MenuTitle = 'GoldenRP Menu'

Config.CommandDistanceChecked = true

Config.CommandDistance = 50

Config.DisplayStationBlips = true

Config.Radar = 1

Config.VehEnterCuffed = true

Config.UnrackWeapons = false

Config.DisplayProps = true

Config.Props = {
    {name = 'Police Barrier', spawncode = 'prop_barrier_work05'},
    {name = 'Barrier', spawncode = 'prop_barrier_work06a'},
    {name = 'Traffic Cone', spawncode = 'prop_roadcone01a'},
    {name = 'Cone', spawncode = 'prop_roadcone02b'},
    {name = 'Work Barrier', spawncode = 'prop_mp_barrier_02b'},
    {name = 'Work Barrier 2', spawncode = 'prop_barrier_work01a'},
    {name = 'Lighting', spawncode = 'prop_worklight_03b'},
    {name = 'Tent', spawncode = 'prop_gazebo_02'},
}

Config.LEOStations = {
    {name = 'Sandy Shores', coords = {x = 1850.04, y = 3679.36, z = 34.26 , h = 208.84}},
    {name = 'Paleto Bay', coords = {x = -438.51, y = 6017.93, z = 31.49 , h = 352.90}},
    
    {name = 'Mission Row', coords = {x = 432.08, y = -985.25, z = 30.71 , h = 44.02}},
    {name = 'Davis', coords = {x = 373.99, y = -1607.59, z = 29.29 , h = 192.15}},
    {name = 'Vinewood', coords = {x = 638.03, y = -1.85, z = 82.78 , h = 290.18}},
    {name = 'Vespucci', coords = {x = -1090.87, y = -807.29, z = 19.26 , h = 64.92}},

    {name = 'NOOSE Headquarters', coords = {x = 2504.29, y = -384.11, z = 94.12, h = 264.01}},
}

Config.FireStations = {
    {name = 'Sandy Shores', coords = {x = 1693.57, y = 3582.68, z = 35.62 , h = 227.29}},
    {name = 'Paleto Bay', coords = {x = -382.50, y = 6116.76, z = 31.47 , h = 7.29}},
    
    {name = 'Davis', coords = {x = 201.16, y = -1631.67, z = 29.75, h = 296.67}},
    {name = 'Rockford Hill', coords = {x = -636.47, y = -117.02, z = 38.02, h = 79.64}},
    {name = 'El Burro Heights', coords = {x = 1191.83, y = -1461.74, z = 34.88, h = 329.54}},
}

Config.CivAdverts = {
	{name = '24/7', loc = 'CHAR_FLOYD', file = '247'},
    {name = 'Ammunation', loc = 'CHAR_AMMUNATION', file = 'CHAR_AMMUNATION'},
    {name = 'Bugstars', loc = 'CHAR_BUGSTARS', file = 'CHAR_BUGSTARS'},
    {name = 'Cluckin\' Bell', loc = 'CHAR_FLOYD', file = 'BELL'},
    {name = 'Downtown Cab Co.', loc = 'CHAR_TAXI', file = 'CHAR_TAXI'},
    {name = 'Dynasty 8', loc = 'CHAR_FLOYD', file = 'D8'},
    {name = 'Fleeca Bank', loc = 'CHAR_BANK_FLEECA', file = 'CHAR_BANK_FLEECA'},
    {name = 'Gruppe6', loc = 'CHAR_FLOYD', file = 'GRUPPE6'},
    {name = 'Merry Weather', loc = 'CHAR_MP_MERRYWEATHER', file = 'CHAR_MP_MERRYWEATHER'},
    {name = 'Limited Gasoline', loc = 'CHAR_FLOYD', file = 'LTD'},
    {name = 'Liquor Ace', loc = 'CHAR_FLOYD', file = 'ACE'},
    {name = 'Smoke on the Water', loc = 'CHAR_FLOYD', file = 'SOTW'},
    {name = 'Pegasus', loc = 'CHAR_PEGASUS_DELIVERY', file = 'CHAR_PEGASUS_DELIVERY'},
    {name = 'Los Santos Customs', loc = 'CHAR_LS_CUSTOMS', file = 'CHAR_LS_CUSTOMS'},
    {name = 'Los Santos Traffic Info', loc = 'CHAR_LS_TOURIST_BOARD', file = 'CHAR_LS_TOURIST_BOARD'},
    {name = 'Los Santos Water and Power', loc = 'CHAR_FLOYD', file = 'LSWP'},
    {name = 'Mors Mutual Insurance', loc = 'CHAR_MP_MORS_MUTUAL', file = 'CHAR_MP_MORS_MUTUAL'},
    {name = 'PostOP', loc = 'CHAR_FLOYD', file = 'OP'},
    {name = 'Vanilla Unicorn', loc = 'CHAR_MP_STRIPCLUB_PR', file = 'CHAR_MP_STRIPCLUB_PR'},
    {name = 'Weazel News', loc = 'CHAR_FLOYD', file = 'NEWS'},
    {name = 'Facebook', loc = 'CHAR_FACEBOOK', file = 'CHAR_FACEBOOK'},
    {name = 'Life Invader', loc = 'CHAR_LIFEINVADER', file = 'CHAR_LIFEINVADER'},
    {name = 'YouTube', loc = 'CHAR_YOUTUBE', file = 'CHAR_YOUTUBE'},
}

Config.VehicleOptions = true

--Nearest Postal
config = {
	versionCheck = false, -- enables version checking (if this is enabled and there is no new version it won't display a message anyways)
	text = {
		format = '~y~Nearest Postal~w~: %s',
		-- ScriptHook PLD Position
		--posX = 0.225,
		--posY = 0.963,
		-- vMenu PLD Position
		posX = 0.175,
		posY = 0.875
	},
	blip = {
		blipText = 'Postal Route %s',
		sprite = 8,
		color = 3, -- default 3 (light blue)
		distToDelete = 100.0, -- in meters
		deleteText = 'Route deleted',
		drawRouteText = 'Drawing a route to %s',
		notExistText = "That postal doesn't exist"
	}
}