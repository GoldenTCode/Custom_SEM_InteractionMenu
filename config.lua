Config = {}

Config.MenuButton = 244

Config.MenuWidth = 50

Config.MenuTitle = 'GoldenRP Menu'

Config.CommandDistanceChecked = true

Config.CommandDistance = 50

Config.DisplayStationBlips = true

Config.StationBlipsDispalyed = 0

Config.Radar = 1

Config.VehEnterCuffed = true

Config.UnrackWeapons = false

Config.DisplayProps = true

Config.LEOProps = {
    {name = 'Police Barrier', spawncode = 'prop_barrier_work05'},
    {name = 'Barrier', spawncode = 'prop_barrier_work06a'},
    {name = 'Traffic Cone', spawncode = 'prop_roadcone01a'},
    {name = 'Work Barrier', spawncode = 'prop_mp_barrier_02b'},
    {name = 'Work Barrier 2', spawncode = 'prop_barrier_work01a'},
    {name = 'Lighting', spawncode = 'prop_worklight_03b'},
}

Config.CivAdverts = {
	{name = '24/7', loc = 'CHAR_FLOYD', file = '247'},
    {name = 'Ammunation', loc = 'CHAR_AMMUNATION', file = 'CHAR_AMMUNATION'},
    {name = 'Bugstars', loc = 'CHAR_FLOYD', file = 'BUG'},
    {name = 'Cluckin\' Bell', loc = 'CHAR_FLOYD', file = 'BELL'},
    {name = 'Downtown Cab Co.', loc = 'CHAR_TAXI', file = 'CHAR_TAXI'},
    {name = 'Dynasty 8', loc = 'CHAR_FLOYD', file = 'D8'},
    {name = 'Fleeca Bank', loc = 'CHAR_BANK_FLEECA', file = 'CHAR_BANK_FLEECA'},
    {name = 'Gruppe6', loc = 'CHAR_FLOYD', file = 'GRUPPE6'},
    {name = 'Limited Gasoline', loc = 'CHAR_FLOYD', file = 'LTD'},
    {name = 'Liquor Ace', loc = 'CHAR_FLOYD', file = 'ACE'},
    {name = 'Los Santos Customs', loc = 'CHAR_LS_CUSTOMS', file = 'CHAR_LS_CUSTOMS'},
    {name = 'Los Santos Traffic Info', loc = 'CHAR_LS_TOURIST_BOARD', file = 'CHAR_LS_TOURIST_BOARD'},
    {name = 'Los Santos Water and Power', loc = 'CHAR_FLOYD', file = 'LSWP'},
    {name = 'Mors Mutual Insurance', loc = 'CHAR_MP_MORS_MUTUAL', file = 'CHAR_MP_MORS_MUTUAL'},
    {name = 'PostOP', loc = 'CHAR_FLOYD', file = 'OP'},
    {name = 'Vanilla Unicorn', loc = 'CHAR_MP_STRIPCLUB_PR', file = 'CHAR_MP_STRIPCLUB_PR'},
    {name = 'Weazel News', loc = 'CHAR_FLOYD', file = 'NEWS'},
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

--Location PLD
-- Use the following variable(s) to adjust the position.
	-- adjust the x-axis (left/right)
	x = 1.001
	-- adjust the y-axis (top/bottom)
	y = 0.977
-- If you do not see the HUD after restarting script you adjusted the x/y axis too far.
	
-- Use the following variable(s) to adjust the color(s) of each element.
	-- Use the following variables to adjust the color of the border around direction.
	border_r = 240
	border_g = 200
	border_b = 80
	border_a = 255
	
	-- Use the following variables to adjust the color of the direction user is facing.
	dir_r = 255
	dir_g = 255
	dir_b = 255
	dir_a = 255
	
	-- Use the following variables to adjust the color of the street user is currently on.
	curr_street_r = 255
	curr_street_g = 255
	curr_street_b = 255
	curr_street_a = 255
	
	-- Use the following variables to adjust the color of the street around the player. (this will also change the town the user is in)
	str_around_r = 240
	str_around_g = 200 
	str_around_b = 80
	str_around_a = 255
	
	-- Use the following variables to adjust the color of the city the player is in (without there being a street around them)
	town_r = 255
	town_g = 255
	town_b = 255
	town_a = 255
	
	-- Determine rather the HUD should only display when player(s) are inside a vehicle or not
	checkForVehicle = false