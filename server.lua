
timermax = 21
cooldown = 0
ispriority = false
ishold = false

RegisterCommand("adminpriorityonhold", function()
	TriggerEvent('isOnHold')
end, false)

RegisterNetEvent('isPriority')
AddEventHandler('isPriority', function()
	newpriorityname = GetPlayerName(source)
	ispriority = true
	Citizen.Wait(1)
	TriggerClientEvent('UpdatePriority', -1, ispriority, newpriorityname)
end)

RegisterNetEvent('isOnHold')
AddEventHandler('isOnHold', function()
	ishold = true
	Citizen.Wait(1)
	TriggerClientEvent('UpdateHold', -1, ishold)
end)

RegisterNetEvent("cooldownt")
AddEventHandler("cooldownt", function()
	if ispriority == true then
		ispriority = false
		TriggerClientEvent('UpdatePriority', -1, ispriority)
	end
	Citizen.Wait(1)
	if ishold == true then
		ishold = false
		TriggerClientEvent('UpdateHold', -1, ishold)
	end
	Citizen.Wait(1)
	if cooldown == 0 then
		cooldown = 0
		cooldown = cooldown + timermax
		while cooldown > 0 do
			cooldown = cooldown - 1
			TriggerClientEvent('UpdateCooldown', -1, cooldown)
			Citizen.Wait(60000)
		end
	elseif cooldown ~= 0 then
		CancelEvent()
	end
end)

RegisterNetEvent("cancelcooldown")
AddEventHandler("cancelcooldown", function()
	Citizen.Wait(1)
	while cooldown > 0 do
		cooldown = cooldown - 1
		TriggerClientEvent('UpdateCooldown', -1, cooldown)
		Citizen.Wait(100)
	end
	
end)

RegisterServerEvent('SEM_InteractionMenu:GlobalChat')
AddEventHandler('SEM_InteractionMenu:GlobalChat', function(Color, Prefix, Message)
	TriggerClientEvent('chatMessage', -1, Prefix, Color, Message)
end)

RegisterServerEvent('SEM_InteractionMenu:CuffNear')
AddEventHandler('SEM_InteractionMenu:CuffNear', function(ID)
    TriggerClientEvent('SEM_InteractionMenu:Cuff', ID)
end)

RegisterServerEvent('SEM_InteractionMenu:DragNear')
AddEventHandler('SEM_InteractionMenu:DragNear', function(source, ID)
	if ID == source then
		return
	end
	TriggerClientEvent('SEM_InteractionMenu:Drag', ID, source)
end)

RegisterServerEvent('SEM_InteractionMenu:SeatNear')
AddEventHandler('SEM_InteractionMenu:SeatNear', function(ID, Vehicle)
    TriggerClientEvent('SEM_InteractionMenu:Seat', ID, Vehicle)
end)

RegisterServerEvent('SEM_InteractionMenu:UnseatNear')
AddEventHandler('SEM_InteractionMenu:UnseatNear', function(ID, Vehicle)
    TriggerClientEvent('SEM_InteractionMenu:Unseat', ID, Vehicle)
end)

RegisterServerEvent('SEM_InteractionMenu:Spikes-TriggerDeleteSpikes')
AddEventHandler('SEM_InteractionMenu:Spikes-TriggerDeleteSpikes', function(NetID)
    TriggerClientEvent('SEM_InteractionMenu:Spikes-DeleteSpikes', -1, NetID)
end)

RegisterServerEvent('SEM_InteractionMenu:Jail')
AddEventHandler('SEM_InteractionMenu:Jail', function(ID, Time)
	TriggerClientEvent('SEM_InteractionMenu:JailPlayer', ID, Time)
	TriggerClientEvent('chatMessage', -1, 'Judge', {86, 96, 252}, GetPlayerName(ID) .. ' has been Jailed for ' .. Time .. ' second(s)')
end)

RegisterServerEvent('SEM_InteractionMenu:Unjail')
AddEventHandler('SEM_InteractionMenu:Unjail', function(ID)
	TriggerClientEvent('SEM_InteractionMenu:UnjailPlayer', ID)
end)

RegisterServerEvent('SEM_InteractionMenu:Backup')
AddEventHandler('SEM_InteractionMenu:Backup', function(Code, StreetName, Coords)
	TriggerClientEvent('SEM_InteractionMenu:CallBackup', -1, Code, StreetName, Coords)
end)

RegisterServerEvent('SEM_InteractionMenu:Ads')
AddEventHandler('SEM_InteractionMenu:Ads', function(Text, Name, Loc, File)
	TriggerClientEvent('SEM_InteractionMenu:SyncAds', -1, Text, Name, Loc, File, source)
end)

BACList = {}
RegisterServerEvent('SEM_InteractionMenu:BACSet')
AddEventHandler('SEM_InteractionMenu:BACSet', function(BACLevel)
	BACList[source] = BACLevel
end)

RegisterServerEvent('SEM_InteractionMenu:BACTest')
AddEventHandler('SEM_InteractionMenu:BACTest', function(ID)
	local BACLevel = BACList[ID]
	TriggerClientEvent('SEM_InteractionMenu:BACResult', source, BACLevel)
end)

Inventories = {}
RegisterServerEvent('SEM_InteractionMenu:InventorySet')
AddEventHandler('SEM_InteractionMenu:InventorySet', function(Items)
	Inventories[source] = Items
end)

RegisterServerEvent('SEM_InteractionMenu:InventorySearch')
AddEventHandler('SEM_InteractionMenu:InventorySearch', function(ID)
	local Inventory = Inventories[ID]

	TriggerClientEvent('SEM_InteractionMenu:InventoryResult', source, Inventory)
end)

RegisterServerEvent('SEM_InteractionMenu:Hospitalize')
AddEventHandler('SEM_InteractionMenu:Hospitalize', function(ID, Time, Location)
	TriggerClientEvent('SEM_InteractionMenu:HospitalizePlayer', ID, Time, Location)
	TriggerClientEvent('chatMessage', -1, 'Doctor', {86, 96, 252}, GetPlayerName(ID) .. ' has been Hospitalized for ' .. Time .. ' second(s)')
end)

RegisterServerEvent('SEM_InteractionMenu:Unhospitalize')
AddEventHandler('SEM_InteractionMenu:Unhospitalize', function(ID)
	TriggerClientEvent('SEM_InteractionMenu:UnhospitalizePlayer', ID)
end)

RegisterServerEvent('SEM_InteractionMenu:LEOPerms')
AddEventHandler('SEM_InteractionMenu:LEOPerms', function()
    if IsPlayerAceAllowed(source, 'sem_intmenu.leo') then
		TriggerClientEvent('SEM_InteractionMenu:LEOPermsResult', source, true)
	else
		TriggerClientEvent('SEM_InteractionMenu:LEOPermsResult', source, false)
	end
end)

RegisterServerEvent('SEM_InteractionMenu:FirePerms')
AddEventHandler('SEM_InteractionMenu:FirePerms', function()
    if IsPlayerAceAllowed(source, 'sem_intmenu.fire') then
		TriggerClientEvent('SEM_InteractionMenu:FirePermsResult', source, true)
	else
		TriggerClientEvent('SEM_InteractionMenu:FirePermsResult', source, false)
	end
end)

Citizen.CreateThread(function()
	SetConvarServerInfo("Server", 1)
	SetConvarServerInfo("Framework", "Custom ESX")
end)

--Hands Up
AddEventHandler("chatMessage", function(source, name, message)
	if (startswith(message, "/")) then
		local cmd = stringsplit(message, " ")
		if cmd[1] == "/hu" then
			CancelEvent()
			TriggerClientEvent("THU", source)
		end
	end
end)

function startswith(String, Start)
	return string.sub(String,1,string.len(Start))==Start
end

function stringsplit(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={} ; i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end

--Hands Up Kneel

RegisterServerEvent("chatMessage")
AddEventHandler("chatMessage", function(source, n, message)
	if message == "/huk" then
		CancelEvent()
		TriggerClientEvent("HandsupKnees", source)
	end
end)