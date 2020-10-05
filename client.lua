

--Cuffing Event
RegisterNetEvent('SEM_InteractionMenu:Cuff')
AddEventHandler('SEM_InteractionMenu:Cuff', function()
	Ped = GetPlayerPed(-1)
	if (DoesEntityExist(Ped)) then
		Citizen.CreateThread(function()
            RequestAnimDict('mp_arresting')
            while not HasAnimDictLoaded('mp_arresting') do
                Citizen.Wait(0)
            end

            if isCuffed then
                isCuffed = false
                SetEnableHandcuffs(Ped, false)
                ClearPedTasks(Ped)
            else
                isCuffed = true
				SetEnableHandcuffs(Ped, true)
				TaskPlayAnim(Ped, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0, 0, 0, 0)
            end
		end)
	end
end)

--Cuff Animation & Restructions
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if isCuffed and not IsEntityPlayingAnim(GetPlayerPed(PlayerId()), 'mp_arresting', 'idle', 3) then
			Citizen.Wait(3000)
			TaskPlayAnim(GetPlayerPed(PlayerId()), 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0, 0, 0, 0)
		end

		if isCuffed then
            if not Config.VehEnterCuffed then
                DisableControlAction(1, 23, true) --F | Enter Vehicle
                DisableControlAction(1, 75, true) --F | Exit Vehicle
            end
			DisableControlAction(1, 140, true) --R
			DisableControlAction(1, 141, true) --Q
			DisableControlAction(1, 142, true) --LMB
			SetPedPathCanUseLadders(GetPlayerPed(PlayerId()), false)
			if IsPedInAnyVehicle(GetPlayerPed(PlayerId()), false) then
				DisableControlAction(0, 59, true) --Vehicle Driving
			end
		end
	end
end)

--Nearest Postal
local raw = LoadResourceFile(GetCurrentResourceName(), GetResourceMetadata(GetCurrentResourceName(), 'postal_file'))
local postals = json.decode(raw)

local nearest = nil
local pBlip = nil

-- thread for nearest and blip
Citizen.CreateThread(
	function()
		while true do
			local x, y = table.unpack(GetEntityCoords(GetPlayerPed(-1)))

			local ndm = -1 -- nearest distance magnitude
			local ni = -1 -- nearest index
			for i, p in ipairs(postals) do
				local dm = (x - p.x) ^ 2 + (y - p.y) ^ 2 -- distance magnitude
				if ndm == -1 or dm < ndm then
					ni = i
					ndm = dm
				end
			end

			--setting the nearest
			if ni ~= -1 then
				local nd = math.sqrt(ndm) -- nearest distance
				nearest = {i = ni, d = nd}
			end

			-- if blip exists
			if pBlip then
				local b = {x = pBlip.p.x, y = pBlip.p.y} -- blip coords
				local dm = (b.x - x) ^ 2 + (b.y - y) ^ 2 -- distance magnitude
				if dm < config.blip.distToDelete ^ 2 then
					-- delete blip if close
					RemoveBlip(pBlip.hndl)
					pBlip = nil
				end
			end

			Wait(100)
		end
	end
)

IsHudHidden = false
DisplayLocation = true

Citizen.CreateThread(
	function()
		while true do
			if nearest and IsHudHidden == false then
				local text = config.text.format:format(postals[nearest.i].code, nearest.d)
				SetTextScale(0.46, 0.46)
				SetTextFont(4)
				SetTextOutline()
				BeginTextCommandDisplayText('STRING')
				AddTextComponentSubstringPlayerName(text)
				EndTextCommandDisplayText(config.text.posX, config.text.posY)
			end
			Wait(0)
		end
	end
)
AddEventHandler("hidenearestpostalhud", function(hide)
    IsHudHidden = true
end)
AddEventHandler("shownearestpostalhud", function(show)
    IsHudHidden = false
end)

RegisterCommand(
	'postal',
	function(source, args, raw)
		if #args < 1 then
			if pBlip then
				RemoveBlip(pBlip.hndl)
				pBlip = nil
				TriggerEvent(
					'chat:addMessage',
					{
						color = {255, 0, 0},
						args = {
							'Postals',
							config.blip.deleteText
						}
					}
				)
			end
			return
		end
		local n = string.upper(args[1])

		local fp = nil
		for _, p in ipairs(postals) do
			if string.upper(p.code) == n then
				fp = p
			end
		end

		if fp then
			if pBlip then
				RemoveBlip(pBlip.hndl)
			end
			pBlip = {hndl = AddBlipForCoord(fp.x, fp.y, 0.0), p = fp}
			SetBlipRoute(pBlip.hndl, true)
			SetBlipSprite(pBlip.hndl, config.blip.sprite)
			SetBlipColour(pBlip.hndl, config.blip.color)
			SetBlipRouteColour(pBlip.hndl, config.blip.color)
			BeginTextCommandSetBlipName('STRING')
			AddTextComponentSubstringPlayerName(config.blip.blipText:format(pBlip.p.code))
			EndTextCommandSetBlipName(pBlip.hndl)

			TriggerEvent(
				'chat:addMessage',
				{
					color = {255, 0, 0},
					args = {
						'Postals',
						config.blip.drawRouteText:format(fp.code)
					}
				}
			)
		else
			TriggerEvent(
				'chat:addMessage',
				{
					color = {255, 0, 0},
					args = {
						'Postals',
						config.blip.notExistText
					}
				}
			)
		end
	end
)

local dev = false
if dev then
	local devLocal = json.decode(raw)
	local next = 0

	RegisterCommand(
		'setnext',
		function(src, args, raw)
			local n = tonumber(args[1])
			if n ~= nil then
				next = n
				print('next ' .. next)
				return
			end
			print('invalid ' .. n)
		end
	)
	RegisterCommand(
		'next',
		function(src, args, raw)
			for i, d in ipairs(devLocal) do
				if d.code == tostring(next) then
					print('duplicate ' .. next)
					return
				end
			end
			local coords = GetEntityCoords(GetPlayerPed(-1))
			table.insert(devLocal, {code = tostring(next), x = coords.x, y = coords.y})
			print('insert ' .. next)
			next = next + 1
		end
	)
	RegisterCommand(
		'rl',
		function(src, args, raw)
			if #devLocal > 0 then
				local data = table.remove(devLocal, #devLocal)
				print('remove ' .. data.code)
				print('next ' .. next)
				next = next - 1
			else
				print('invalid')
			end
		end
	)
	RegisterCommand(
		'remove',
		function(src, args, raw)
			if #args < 1 then
				print('invalid')
			else
				for i, d in ipairs(devLocal) do
					if d.code == args[1] then
						table.remove(devLocal, i)
						print('remove ' .. d.code)
						return
					end
				end
				print('invalid')
			end
		end
	)
	RegisterCommand(
		'json',
		function(src, args, raw)
			print(json.encode(devLocal))
		end
	)
end

--Dragging Event
local Drag = false
local OfficerDrag = -1
RegisterNetEvent('SEM_InteractionMenu:Drag')
AddEventHandler('SEM_InteractionMenu:Drag', function(ID)
	Drag = not Drag
	OfficerDrag = ID
	
	if not Drag then
        DetachEntity(PlayerPedId(), true, false)
	end
end)

--Drag Attachment
Citizen.CreateThread(function()
    while true do
      Wait(0)
        if Drag then
            local Ped = GetPlayerPed(GetPlayerFromServerId(OfficerDrag))
            local Ped2 = PlayerPedId()
            AttachEntityToEntity(Ped2, Ped, 4103, 0.35, 0.38, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
            DisableControlAction(1, 140, true) --R
			DisableControlAction(1, 141, true) --Q
			DisableControlAction(1, 142, true) --LMB
        end
    end
end)



--Force Seat Player Event
RegisterNetEvent('SEM_InteractionMenu:Seat')
AddEventHandler('SEM_InteractionMenu:Seat', function(Veh)
	local Pos = GetEntityCoords(PlayerPedId())
	local EntityWorld = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 20.0, 0.0)
    local RayHandle = CastRayPointToPoint(Pos.x, Pos.y, Pos.z, EntityWorld.x, EntityWorld.y, EntityWorld.z, 10, PlayerPedId(), 0)
    local _, _, _, _, VehicleHandle = GetRaycastResult(RayHandle)
    if VehicleHandle ~= nil then
		SetPedIntoVehicle(PlayerPedId(), VehicleHandle, 1)
	end
end)



--Force Unseat Player Event
RegisterNetEvent('SEM_InteractionMenu:Unseat')
AddEventHandler('SEM_InteractionMenu:Unseat', function(ID)
	local Ped = GetPlayerPed(ID)
	ClearPedTasksImmediately(Ped)
	PlayerPos = GetEntityCoords(PlayerPedId(),  true)
	local X = PlayerPos.x - 0
	local Y = PlayerPos.y - 0

    SetEntityCoords(PlayerPedId(), X, Y, PlayerPos.z)
end)



--Spike Strip Events & Functions
local SpawnedSpikes = {}
local SpikeModel = 'P_ld_stinger_s'
local SpikesSpawned = false
local NearSpikes = false
local IsPedNear = false

--Spike Strip Spawn Event
RegisterNetEvent('SEM_InteractionMenu:Spikes-SpawnSpikes')
AddEventHandler('SEM_InteractionMenu:Spikes-SpawnSpikes', function()
    if IsPedInAnyVehicle(GetPlayerPed(-1), false) then
        Notify('~r~You can\'t set spikes while in a vehicle!')
        return
    end

    local SpawnCoords = GetOffsetFromEntityInWorldCoords(GetPlayerPed(PlayerId()) , 0.0, 2.0, 0.0)
    for a = 1, 3 do
        local Spike = CreateObject(GetHashKey(SpikeModel), SpawnCoords.x, SpawnCoords.y, SpawnCoords.z, 1, 1, 1)
        local NetID = NetworkGetNetworkIdFromEntity(Spike)
        SetNetworkIdExistsOnAllMachines(NetID, true)
        SetNetworkIdCanMigrate(NetID, false)
        SetEntityHeading(Spike, GetEntityHeading(GetPlayerPed(PlayerId()) ))
        PlaceObjectOnGroundProperly(Spike)
        FreezeEntityPosition(Spike, true)
        SpawnCoords = GetOffsetFromEntityInWorldCoords(Spike, 0.0, 4.0, 0.0)
        table.insert(SpawnedSpikes, NetID)
    end
    SpikesSpawned = true
end)

--Spike Strip Delete Event
RegisterNetEvent('SEM_InteractionMenu:Spikes-DeleteSpikes')
AddEventHandler('SEM_InteractionMenu:Spikes-DeleteSpikes', function(NetID)
    Citizen.CreateThread(function()
        local Spike = NetworkGetEntityFromNetworkId(NetID)
        DeleteEntity(Spike)
    end)
end)

--Spike Strip Check Distance Ped
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local Ped = PlayerPedId()
        local PedPos = GetEntityCoords(Ped, false)

        local Spikes = GetClosestObjectOfType(PedPos.x, PedPos.y, PedPos.z, 80.0, GetHashKey(SpikeModel), 1, 1, 1)
        local SpikesPos = GetEntityCoords(Spikes, false)

        local Distance = Vdist(PedPos.x, PedPos.y, PedPos.z, SpikesPos.x, SpikesPos.y, SpikesPos.z)

        if SpikesSpawned then
            if Distance ~= 0 and Distance < 5 then
                NotifyHelp('~b~Remove Spike Strips~w~, Press ~INPUT_CHARACTER_WHEEL~ + ~INPUT_PHONE~')
                if (IsControlPressed(1, 19) and IsControlJustPressed(1, 27)) and GetLastInputMethod(2) then
                    RemoveSpikes()
                    SpikesSpawned = false
                end
            elseif Distance > 5 and Distance < 25 then
                NotifyHelp('~o~Move Closer to Remove the Spike Strips!')
            elseif Distance > 150 then
                RemoveSpikes()
                SpikesSpawned = false
            end
        end
    end
end)

--Spike Strip Check Distance Veh
Citizen.CreateThread(function()
    while true do
        if IsPedInAnyVehicle(GetPlayerPed(PlayerId()) , false) then
            local Vehicle = GetVehiclePedIsIn(GetPlayerPed(PlayerId()) , false)
            if GetPedInVehicleSeat(Vehicle, -1) == GetPlayerPed(PlayerId())  then
                local VehiclePos = GetEntityCoords(Vehicle, false)
                local Spikes = GetClosestObjectOfType(VehiclePos.x, VehiclePos.y, VehiclePos.z, 80.0, GetHashKey(SpikeModel), 1, 1, 1)
                local SpikePos = GetEntityCoords(Spikes, false)
                local Distance = Vdist(VehiclePos.x, VehiclePos.y, VehiclePos.z, SpikePos.x, SpikePos.y, SpikePos.z)

                if Spikes ~= 0 then
                    NearSpikes = true
                else
                    NearSpikes = false
                end
            else
                NearSpikes = false
            end
        else
            NearSpikes = false
        end

        Citizen.Wait(0)
    end
end)

--Spike Strip Tire Popping
Citizen.CreateThread(function()
    while true do
        if NearSpikes then
            local Tires = {
                {bone = 'wheel_lf', index = 0},
                {bone = 'wheel_rf', index = 1},
                {bone = 'wheel_lm', index = 2},
                {bone = 'wheel_rm', index = 3},
                {bone = 'wheel_lr', index = 4},
                {bone = 'wheel_rr', index = 5}
            }

            for a = 1, #Tires do
                local Vehicle = GetVehiclePedIsIn(GetPlayerPed(PlayerId()) , false)
                local TirePos = GetWorldPositionOfEntityBone(Vehicle, GetEntityBoneIndexByName(Vehicle, Tires[a].bone))
                local Spike = GetClosestObjectOfType(TirePos.x, TirePos.y, TirePos.z, 15.0, GetHashKey(SpikeModel), 1, 1, 1)
                local SpikePos = GetEntityCoords(Spike, false)
                local Distance = Vdist(TirePos.x, TirePos.y, TirePos.z, SpikePos.x, SpikePos.y, SpikePos.z)

                if Distance < 1.8 then
                    if not IsVehicleTyreBurst(Vehicle, Tires[a].index, true) or IsVehicleTyreBurst(Vehicle, Tires[a].index, false) then
                        SetVehicleTyreBurst(Vehicle, Tires[a].index, false, 1000.0)
                    end
                end
            end
        end

        Citizen.Wait(0)
    end
end)

--Spike Strip Remove Function
function RemoveSpikes()
    for a = 1, #SpawnedSpikes do
        TriggerServerEvent('SEM_InteractionMenu:Spikes-TriggerDeleteSpikes', SpawnedSpikes[a])
    end
    Notify('~r~Spikes Strips Removed!')
    SpawnedSpikes = {}
end




--Object Spawn Event
RegisterNetEvent('SEM_InteractionMenu:Object:SpawnObjects')
AddEventHandler('SEM_InteractionMenu:Object:SpawnObjects', function(ObjectName, Name)
    if IsPedInAnyVehicle(GetPlayerPed(-1), false) then
        Notify('~r~You can\'t spawn objects while in a vehicle!')
        return
    end

    local SpawnCoords = GetOffsetFromEntityInWorldCoords(GetPlayerPed(PlayerId()) , 0.0, 0.5, 0.0)
    
    local Object = CreateObject(GetHashKey(ObjectName), SpawnCoords.x, SpawnCoords.y, SpawnCoords.z, true, true, true)
    local NetID = NetworkGetNetworkIdFromEntity(Object)
    SetNetworkIdExistsOnAllMachines(NetID, true)
    SetNetworkIdCanMigrate(NetID, false)
    SetEntityHeading(Object, GetEntityHeading(GetPlayerPed(PlayerId()) ))
    PlaceObjectOnGroundProperly(Object)
    FreezeEntityPosition(Object, true)
    Notify('~b~Object Spawned: ~g~' .. Name)
end)



--Civilian Adverts
RegisterNetEvent('SEM_InteractionMenu:SyncAds')
AddEventHandler('SEM_InteractionMenu:SyncAds',function(Text, Name, Loc, File, ID)
    Ad(Text, Name, Loc, File, ID)
end)



--Inventory
RegisterNetEvent('SEM_InteractionMenu:InventoryResult')
AddEventHandler('SEM_InteractionMenu:InventoryResult', function(Inventory)
    Citizen.Wait(5000)

    if Inventory ==  nil then
        Inventory = 'Empty'
    end

    Notify('~b~Inventory Items: ~g~' .. Inventory)
end)

--Station Blips
Citizen.CreateThread(function()
        local function CreateBlip(x, y, z, Name, Colour, Sprite)
            StationBlip = AddBlipForCoord(x, y, z)
            SetBlipSprite(StationBlip, Sprite)
            SetBlipDisplay(StationBlip, 3)
            SetBlipScale(StationBlip, 1.0)
            SetBlipColour(StationBlip, Colour)
            SetBlipAsShortRange(StationBlip, true)
        
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(Name)
            EndTextCommandSetBlipName(StationBlip)
        end

        for _, Station in pairs(Config.LEOStations) do
            CreateBlip(Station.coords.x, Station.coords.y, Station.coords.z, 'Police Station', 38, 60)
        end
        for _, Station in pairs(Config.FireStations) do
            CreateBlip(Station.coords.x, Station.coords.y, Station.coords.z, 'Fire Station', 1, 60)
        end
end)

--BAC
RegisterNetEvent('SEM_InteractionMenu:BACResult')
AddEventHandler('SEM_InteractionMenu:BACResult', function(BACLevel)
    Citizen.Wait(5000)

    if BACLevel == nil then
        BACLevel = 0.00
    end

    if tonumber(BACLevel) < 0.08 then
        Notify('~b~BAC Level: ~g~' .. tostring(BACLevel))
    else
        Notify('~b~BAC Level: ~r~' .. tostring(BACLevel))
    end
end)



--Commands
Citizen.CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/eng', 'Toggles Engine')
    TriggerEvent('chat:addSuggestion', '/hood', 'Toggles Vehicle\'s Hood')
    TriggerEvent('chat:addSuggestion', '/trunk', 'Toggles Vehicle\'s Trunk')
    TriggerEvent('chat:addSuggestion', '/clear', 'Clears all Weapons')
    TriggerEvent('chat:addSuggestion', '/cuff', 'Cuff Player', {{name = 'ID', help = 'Players Server ID'}})
    TriggerEvent('chat:addSuggestion', '/drag', 'Drag Player', {{name = 'ID', help = 'Players Server ID'}})
    TriggerEvent('chat:addSuggestion', '/dropweapon', 'Drops Weapon in Hand')
end)
cuffme = true
RegisterCommand('cuff', function(source, args, rawCommand)
        if args[1] ~= nil then
            local ID = tonumber(args[1])
            TriggerServerEvent('SEM_InteractionMenu:CuffNear', ID)
		elseif args[1] == 'me' then
			local playernameme = GetPlayerId(source)
			local ID = tonumber(playernameme)
			TriggerServerEvent('SEM_InteractionMenu:CuffNear', ID)
		end
end)

RegisterCommand('cuffme', function(source, args, rawCommand)
local cuffmeped = GetPlayerPed(source)
TriggerServerEvent('SEM_InteractionMenu:CuffNear', cuffmeped)
end)

RegisterCommand('drag', function(source, args, rawCommand)
        if args[1] ~= nil then
            local ID = tonumber(args[1])
                if GetDistance(source) <= 5.0 then
                    TriggerServerEvent('SEM_InteractionMenu:DragNear', ID)
                else
                    Notify('~r~That player is too far away')
                end
		end
end)

RegisterCommand('dropweapon', function(source, args, rawCommand)
    local CurrentWeapon = GetSelectedPedWeapon(GetPlayerPed(-1))
    SetPedDropsInventoryWeapon(GetPlayerPed(-1), CurrentWeapon, -2.0, 0.0, 0.5, 30)
    Notify('~r~Weapon Dropped!')
end)

RegisterCommand('clear', function(source, args, rawCommand)
    SetEntityHealth(GetPlayerPed(-1), 200)
    RemoveAllPedWeapons(GetPlayerPed(-1), true)
    Notify('~r~All Weapons Cleared!')
end)

RegisterCommand('canim', function(source, args, rawCommand)
local ped = GetPlayerPed(-1)
local playerCoords = GetEntityCoords(PlayerPedId())
		local animDict = "anim@amb@nightclub@dancers@crowddance_single_props@med_intensity"
		local animName = "mi_dance_prop_09_v1_male^4"
		TaskPlayAnim(ped, animDict, animName, 3.0, 3.0, 10000, 10, 1.0, 0, 0, 0)
end)

RegisterCommand('eng', function(source, args, rawCommand)
    local Veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if Veh ~= nil and Veh ~= 0 and GetPedInVehicleSeat(Veh, 0) then
        SetVehicleEngineOn(Veh, (not GetIsVehicleEngineRunning(Veh)), false, true)
        Notify('~g~Engine Toggled!')
    end
end)

RegisterCommand('hood', function(source, args, rawCommand)
	local player = source
	local ped = GetPlayerPed(player)
    local Veh = GetVehiclePedIsIn(PlayerPedId(), false)
	local coordA = GetEntityCoords(ped, 1)
	local coordB = GetOffsetFromEntityInWorldCoords(ped, 0.0, 5.0, 0.0)
	local targetVehicle = getVehicleInDirection(coordA, coordB)
	
    if targetVehicle ~= 0 then
        if GetVehicleDoorAngleRatio(targetVehicle, 4) > 0 then
            SetVehicleDoorShut(targetVehicle, 4, false)
        else
            SetVehicleDoorOpen(targetVehicle, 4, false, false)
        end
	else if targetVehicle == 0 then
		if GetVehicleDoorAngleRatio(Veh, 4) > 0 then
			SetVehicleDoorShut(Veh, 4, false)
        else
            SetVehicleDoorOpen(Veh, 4, false, false)
		end
	end
	end
	Notify('~g~Hood Toggled!')
end)

RegisterCommand('trunk', function(source, args, rawCommand)
    local player = source
	local ped = GetPlayerPed(player)
    local Veh = GetVehiclePedIsIn(PlayerPedId(), false)
	local coordA = GetEntityCoords(ped, 1)
	local coordB = GetOffsetFromEntityInWorldCoords(ped, 0.0, 5.0, 0.0)
	local targetVehicle = getVehicleInDirection(coordA, coordB)
	
    if targetVehicle ~= 0 then
        if GetVehicleDoorAngleRatio(targetVehicle, 5) > 0 then
            SetVehicleDoorShut(targetVehicle, 5, false)
        else
            SetVehicleDoorOpen(targetVehicle, 5, false, false)
		end
	else if targetVehicle == 0 then
		if GetVehicleDoorAngleRatio(Veh, 5) > 0 then
			SetVehicleDoorShut(Veh, 5, false)
        else
            SetVehicleDoorOpen(Veh, 5, false, false)
		end
	end
	end
		Notify('~g~Trunk Toggled!')
end)

function getVehicleInDirection(coordFrom, coordTo)
	local rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 10, GetPlayerPed(-1), 0)
	local a, b, c, d, vehicle = GetRaycastResult(rayHandle)
	return vehicle
end

--SpeedLimit
local speedlimit = "~r~~h~You havent added this street!"

AddEventHandler("hidespeedlimithud", function(hide)
    speedlimitshow = false
end)
AddEventHandler("showspeedlimithud", function(show)
    speedlimitshow = true
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerloc = GetEntityCoords(GetPlayerPed(-1))
        local streethash = GetStreetNameAtCoord(playerloc.x, playerloc.y, playerloc.z)
        street = GetStreetNameFromHashKey(streethash)

    if IsPedInAnyVehicle(GetPlayerPed(-1)) and not IsPedInAnyBoat(GetPlayerPed(-1)) and not IsPedInAnyHeli(GetPlayerPed(-1)) and not IsPedInAnyPlane(GetPlayerPed(-1)) then
            if street == "Joshua Rd" then
                speedlimit = 50
            elseif street == "East Joshua Road" then
                speedlimit = 50
            elseif street == "Marina Dr" then
                speedlimit = 35
            elseif street == "Alhambra Dr" then
                speedlimit = 35
            elseif street == "Niland Ave" then
                speedlimit = 35
            elseif street == "Zancudo Ave" then
                speedlimit = 35
            elseif street == "Armadillo Ave" then
                speedlimit = 35
            elseif street == "Algonquin Blvd" then
                speedlimit = 35
            elseif street == "Mountain View Dr" then
                speedlimit = 35
            elseif street == "Cholla Springs Ave" then
                speedlimit = 35
            elseif street == "Panorama Dr" then
                speedlimit = 40
            elseif street == "Lesbos Ln" then
                speedlimit = 35
            elseif street == "Calafia Rd" then
                speedlimit = 30
            elseif street == "North Calafia Way" then
                speedlimit = 30
            elseif street == "Cassidy Trail" then
                speedlimit = 25
            elseif street == "Seaview Rd" then
                speedlimit = 35
            elseif street == "Grapeseed Main St" then
                speedlimit = 35
            elseif street == "Grapeseed Ave" then
                speedlimit = 35
            elseif street == "Joad Ln" then
                speedlimit = 35
            elseif street == "Union Rd" then
                speedlimit = 40
            elseif street == "O'Neil Way" then
                speedlimit = 25
            elseif street == "Senora Fwy" then
                speedlimit = 65
            elseif street == "Catfish View" then
                speedlimit = 35
            elseif street == "Great Ocean Hwy" then
                speedlimit = 60
            elseif street == "Paleto Blvd" then
                speedlimit = 35
            elseif street == "Duluoz Ave" then
                speedlimit = 35
            elseif street == "Procopio Dr" then
                speedlimit = 35
            elseif street == "Cascabel Ave" then
                speedlimit = 30
            elseif street == "Procopio Promenade" then
                speedlimit = 25
            elseif street == "Pyrite Ave" then
                speedlimit = 30
            elseif street == "Fort Zancudo Approach Rd" then
                speedlimit = 25
            elseif street == "Barbareno Rd" then
                speedlimit = 30
            elseif street == "Ineseno Road" then
                speedlimit = 30
            elseif street == "West Eclipse Blvd" then
                speedlimit = 35
            elseif street == "Playa Vista" then
                speedlimit = 30
            elseif street == "Bay City Ave" then
                speedlimit = 30
            elseif street == "Del Perro Fwy" then
                speedlimit = 65
            elseif street == "Equality Way" then
                speedlimit = 30
            elseif street == "Red Desert Ave" then
                speedlimit = 30
            elseif street == "Magellan Ave" then
                speedlimit = 25
            elseif street == "Sandcastle Way" then
                speedlimit = 30
            elseif street == "Vespucci Blvd" then
                speedlimit = 40
            elseif street == "Prosperity St" then
                speedlimit = 30
            elseif street == "San Andreas Ave" then
                speedlimit = 40
            elseif street == "North Rockford Dr" then
                speedlimit = 35
            elseif street == "South Rockford Dr" then
                speedlimit = 35
            elseif street == "Marathon Ave" then
                speedlimit = 30
            elseif street == "Boulevard Del Perro" then
                speedlimit = 35
            elseif street == "Cougar Ave" then
                speedlimit = 30
            elseif street == "Liberty St" then
                speedlimit = 30
            elseif street == "Bay City Incline" then
                speedlimit = 40
            elseif street == "Conquistador St" then
                speedlimit = 25
            elseif street == "Cortes St" then
                speedlimit = 25
            elseif street == "Vitus St" then
                speedlimit = 25
            elseif street == "Aguja St" then
                speedlimit = 25
            elseif street == "Goma St" then
                speedlimit = 25
            elseif street == "Melanoma St" then
                speedlimit = 25
            elseif street == "Palomino Ave" then
                speedlimit = 35
            elseif street == "Invention Ct" then
                speedlimit = 25
            elseif street == "Imagination Ct" then
                speedlimit = 25
            elseif street == "Rub St" then
                speedlimit = 25
            elseif street == "Tug St" then
                speedlimit = 25
            elseif street == "Ginger St" then
                speedlimit = 30
            elseif street == "Lindsay Circus" then
                speedlimit = 30
            elseif street == "Calais Ave" then
                speedlimit = 35
            elseif street == "Adam's Apple Blvd" then
                speedlimit = 40
            elseif street == "Alta St" then
                speedlimit = 40
            elseif street == "Integrity Way" then
                speedlimit = 30
            elseif street == "Swiss St" then
                speedlimit = 30
            elseif street == "Strawberry Ave" then
                speedlimit = 40
            elseif street == "Capital Blvd" then
                speedlimit = 30
            elseif street == "Crusade Rd" then
                speedlimit = 30
            elseif street == "Innocence Blvd" then
                speedlimit = 40
            elseif street == "Davis Ave" then
                speedlimit = 40
            elseif street == "Little Bighorn Ave" then
                speedlimit = 35
            elseif street == "Roy Lowenstein Blvd" then
                speedlimit = 35
            elseif street == "Jamestown St" then
                speedlimit = 30
            elseif street == "Carson Ave" then
                speedlimit = 35
            elseif street == "Grove St" then
                speedlimit = 30
            elseif street == "Brouge Ave" then
                speedlimit = 30
            elseif street == "Covenant Ave" then
                speedlimit = 30
            elseif street == "Dutch London St" then
                speedlimit = 40
            elseif street == "Signal St" then
                speedlimit = 30
            elseif street == "Elysian Fields Fwy" then
                speedlimit = 50
            elseif street == "Plaice Pl" then
                speedlimit = 30
            elseif street == "Chum St" then
                speedlimit = 40
            elseif street == "Chupacabra St" then
                speedlimit = 30
            elseif street == "Miriam Turner Overpass" then
                speedlimit = 30
            elseif street == "Autopia Pkwy" then
                speedlimit = 35
            elseif street == "Exceptionalists Way" then
                speedlimit = 35
            elseif street == "La Puerta Fwy" then
                speedlimit = 60
            elseif street == "New Empire Way" then
                speedlimit = 30
            elseif street == "Runway1" then
                speedlimit = "--"
            elseif street == "Greenwich Pkwy" then
                speedlimit = 35
            elseif street == "Kortz Dr" then
                speedlimit = 30
            elseif street == "Banham Canyon Dr" then
                speedlimit = 40
            elseif street == "Buen Vino Rd" then
                speedlimit = 40
            elseif street == "Route 68" then
                speedlimit = 55
            elseif street == "Zancudo Grande Valley" then
                speedlimit = 40
            elseif street == "Zancudo Barranca" then
                speedlimit = 40
            elseif street == "Galileo Rd" then
                speedlimit = 40
            elseif street == "Mt Vinewood Dr" then
                speedlimit = 40
            elseif street == "Marlowe Dr" then
                speedlimit = 40
            elseif street == "Milton Rd" then
                speedlimit = 35
            elseif street == "Kimble Hill Dr" then
                speedlimit = 35
            elseif street == "Normandy Dr" then
                speedlimit = 35
            elseif street == "Hillcrest Ave" then
                speedlimit = 35
            elseif street == "Hillcrest Ridge Access Rd" then
                speedlimit = 35
            elseif street == "North Sheldon Ave" then
                speedlimit = 35
            elseif street == "Lake Vinewood Dr" then
                speedlimit = 35
            elseif street == "Lake Vinewood Est" then
                speedlimit = 35
            elseif street == "Baytree Canyon Rd" then
                speedlimit = 40
            elseif street == "North Conker Ave" then
                speedlimit = 35
            elseif street == "Wild Oats Dr" then
                speedlimit = 35
            elseif street == "Whispymound Dr" then
                speedlimit = 35
            elseif street == "Didion Dr" then
                speedlimit = 35
            elseif street == "Cox Way" then
                speedlimit = 35
            elseif street == "Picture Perfect Drive" then
                speedlimit = 35
            elseif street == "South Mo Milton Dr" then
                speedlimit = 35
            elseif street == "Cockingend Dr" then
                speedlimit = 35
            elseif street == "Mad Wayne Thunder Dr" then
                speedlimit = 35
            elseif street == "Hangman Ave" then
                speedlimit = 35
            elseif street == "Dunstable Ln" then
                speedlimit = 35
            elseif street == "Dunstable Dr" then
                speedlimit = 35
            elseif street == "Greenwich Way" then
                speedlimit = 35
            elseif street == "Greenwich Pl" then
                speedlimit = 35
            elseif street == "Hardy Way" then
                speedlimit = 35
            elseif street == "Richman St" then
                speedlimit = 35
            elseif street == "Ace Jones Dr" then
                speedlimit = 35
            elseif street == "Los Santos Freeway" then
                speedlimit = 65
            elseif street == "Senora Rd" then
                speedlimit = 40
            elseif street == "Nowhere Rd" then
                speedlimit = 25
            elseif street == "Smoke Tree Rd" then
                speedlimit = 35
            elseif street == "Cholla Rd" then
                speedlimit = 35
            elseif street == "Cat-Claw Ave" then
                speedlimit = 35
            elseif street == "Senora Way" then
                speedlimit = 40
            elseif street == "Palomino Fwy" then
                speedlimit = 60
            elseif street == "Shank St" then
                speedlimit = 25
            elseif street == "Macdonald St" then
                speedlimit = 35
            elseif street == "Route 68 Approach" then
                speedlimit = 55
            elseif street == "Vinewood Park Dr" then
                speedlimit = 35
            elseif street == "Vinewood Blvd" then
                speedlimit = 40
            elseif street == "Mirror Park Blvd" then
                speedlimit = 35
            elseif street == "Glory Way" then
                speedlimit = 35
            elseif street == "Bridge St" then
                speedlimit = 35
            elseif street == "West Mirror Drive" then
                speedlimit = 35
            elseif street == "Nikola Ave" then
                speedlimit = 35
            elseif street == "East Mirror Dr" then
                speedlimit = 35
            elseif street == "Nikola Pl" then
                speedlimit = 25
            elseif street == "Mirror Pl" then
                speedlimit = 35
            elseif street == "El Rancho Blvd" then
                speedlimit = 40
            elseif street == "Olympic Fwy" then
                speedlimit = 60
            elseif street == "Fudge Ln" then
                speedlimit = 25
            elseif street == "Amarillo Vista" then
                speedlimit = 25
            elseif street == "Labor Pl" then
                speedlimit = 35
            elseif street == "El Burro Blvd" then
                speedlimit = 35
            elseif street == "Sustancia Rd" then
                speedlimit = 45
            elseif street == "South Shambles St" then
                speedlimit = 30
            elseif street == "Hanger Way" then
                speedlimit = 30
            elseif street == "Orchardville Ave" then
                speedlimit = 30
            elseif street == "Popular St" then
                speedlimit = 40
            elseif street == "Buccaneer Way" then
                speedlimit = 45
            elseif street == "Abattoir Ave" then
                speedlimit = 35
            elseif street == "Voodoo Place" then
                speedlimit = 30
            elseif street == "Mutiny Rd" then
                speedlimit = 35
            elseif street == "South Arsenal St" then
                speedlimit = 35
            elseif street == "Forum Dr" then
                speedlimit = 35
            elseif street == "Morningwood Blvd" then
                speedlimit = 35
            elseif street == "Dorset Dr" then
                speedlimit = 40
            elseif street == "Caesars Place" then
                speedlimit = 25
            elseif street == "Spanish Ave" then
                speedlimit = 30
            elseif street == "Portola Dr" then
                speedlimit = 30
            elseif street == "Edwood Way" then
                speedlimit = 25
            elseif street == "San Vitus Blvd" then
                speedlimit = 40
            elseif street == "Eclipse Blvd" then
                speedlimit = 35
            elseif street == "Gentry Lane" then
                speedlimit = 30
            elseif street == "Las Lagunas Blvd" then
                speedlimit = 40
            elseif street == "Power St" then
                speedlimit = 40
            elseif street == "Mt Haan Rd" then
                speedlimit = 40
            elseif street == "Elgin Ave" then
                speedlimit = 40
            elseif street == "Hawick Ave" then
                speedlimit = 35
            elseif street == "Meteor St" then
                speedlimit = 30
            elseif street == "Alta Pl" then
                speedlimit = 30
            elseif street == "Occupation Ave" then
                speedlimit = 35
            elseif street == "Carcer Way" then
                speedlimit = 40
            elseif street == "Eastbourne Way" then
                speedlimit = 30
            elseif street == "Rockford Dr" then
                speedlimit = 35
            elseif street == "Abe Milton Pkwy" then
                speedlimit = 35
            elseif street == "Laguna Pl" then
                speedlimit = 30
            elseif street == "Sinners Passage" then
                speedlimit = 30
            elseif street == "Atlee St" then
                speedlimit = 30
            elseif street == "Sinner St" then
                speedlimit = 30
            elseif street == "Supply St" then
                speedlimit = 30
            elseif street == "Amarillo Way" then
                speedlimit = 35
            elseif street == "Tower Way" then
                speedlimit = 35
            elseif street == "Decker St" then
                speedlimit = 35
            elseif street == "Tackle St" then
                speedlimit = 25
            elseif street == "Low Power St" then
                speedlimit = 35
            elseif street == "Clinton Ave" then
                speedlimit = 35
            elseif street == "Fenwell Pl" then
                speedlimit = 35
            elseif street == "Utopia Gardens" then
                speedlimit = 25
			elseif street == "Peaceful Street" then
				speedlimit = 25
            elseif street == "Cavalry Blvd" then
                speedlimit = 35
            elseif street == "South Boulevard Del Perro" then
                speedlimit = 35
            elseif street == "Americano Way" then
                speedlimit = 25
            elseif street == "Sam Austin Dr" then
                speedlimit = 25
            elseif street == "East Galileo Ave" then
                speedlimit = 35
            elseif street == "Galileo Park" then
                speedlimit = 35
            elseif street == "West Galileo Ave" then
                speedlimit = 35
            elseif street == "Tongva Dr" then
                speedlimit = 40
            elseif street == "Zancudo Rd" then
                speedlimit = 35
            elseif street == "Movie Star Way" then
                speedlimit = 35
            elseif street == "Heritage Way" then
                speedlimit = 35
            elseif street == "Perth St" then
                speedlimit = 25
            elseif street == "Chianski Passage" then
                speedlimit = 30
	    elseif street == "Lolita Ave" then
		speedlimit = 35
	    elseif street == "Meringue Ln" then
		speedlimit = 35
	    elseif street == "Strangeways Dr" then
		speedlimit = 30
            else
                speedlimit = "  ~r~N/A  "
            end
			
			if speedlimitshow == true then
            DrawTxt(0.514, 1.235, 1.0,1.0,0.45,"~y~Speedlimit: ~w~"..speedlimit.."~y~ mph", 252,186,3,200)
			end
		end
    end
end)

function DrawTxt(x,y ,width,height,scale, text, r,g,b,a)
    SetTextFont(6)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - width/2, y - height/2 + 0.005)
end

--Hands Up Animation

RegisterNetEvent("THU")
AddEventHandler("THU", function()
	
	local playerPed = GetPlayerPed(-1)
	if DoesEntityExist(playerPed) then
		Citizen.CreateThread(function()
			RequestAnimDict("random@getawaydriver")
			while not HasAnimDictLoaded("random@getawaydriver") do
				Citizen.Wait(100)
			end
			
			if IsEntityPlayingAnim(playerPed, "random@getawaydriver", "idle_2_hands_up", 3) then
				ClearPedSecondaryTask(playerPed)
			else
				TaskPlayAnim(playerPed, "random@getawaydriver", "idle_2_hands_up", 8.0, -8, -1, 50, 0, 0, 0, 0)
			end		
		end)
	end
end)

-- Hands Up Kneel Animation
local HUKToggle = false

RegisterNetEvent("HandsupKnees")
AddEventHandler("HandsupKnees", function()
	HUKToggle = not HUKToggle
	ToggleHUK(HUKToggle)
end)
	
	function ToggleHUK(toggle)

	local lPed = PlayerPedId()
	
	if(toggle) then
	
			 RequestAnimDict("random")
			RequestAnimDict("random@getawaydriver")
			while not HasAnimDictLoaded("random@getawaydriver") do
				Citizen.Wait(100)
			end
			
			TaskPlayAnim(lPed, "random@getawaydriver", "idle_2_hands_up", 1.0, -1, -1, 0, 0, 0, 0, 0)
				Citizen.Wait(3500)
				TaskPlayAnim(lPed, "random@getawaydriver", "idle_a", 1.0, -1, -1, 1, 0, 0, 0, 0)
				SetEnableHandcuffs(lPed, true)
			
		else
			if IsEntityPlayingAnim(lPed, "random@getawaydriver", "idle_a", 3) and IsEntityPlayingAnim(lPed, "mp_arresting", "idle", 3) then
				StopAnimTask(lPed, "random@getawaydriver", "idle_a", 3)
				StopAnimTask(lPed, "random@getawaydriver", "idle_2_hands_up", 3)
				TaskPlayAnim(lPed, "random@getawaydriver", "hands_up_2_idle", 1.0, -1, -1, 0, 0, 0, 0, 0)
				ClearPedSecondaryTask(lPed)
				TaskPlayAnim(lPed, "mp_arresting", "idle", 8.0, -8, -1, 49, 0, 0, 0, 0)
				SetEnableHandcuffs(lPed, true)
				
				elseif IsEntityPlayingAnim(lPed, "random@getawaydriver", "idle_a", 3) then
				StopAnimTask(lPed, "random@getawaydriver", "idle_a", 3)
				StopAnimTask(lPed, "random@getawaydriver", "idle_2_hands_up", 3)
				TaskPlayAnim(lPed, "random@getawaydriver", "hands_up_2_idle", 1.0, -1, -1, 0, 0, 0, 0, 0)
				ClearPedSecondaryTask(lPed)
				SetEnableHandcuffs(lPed, false)

			end		
		end
	end