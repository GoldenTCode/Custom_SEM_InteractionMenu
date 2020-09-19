--[[
───────────────────────────────────────────────────────────────

	SEM_InteractionMenu (menu.lua) - Created by Scott M
	Current Version: v1.5.1 (June 2020)
	
	Support | https://semdevelopment.com/discord
	
        !!! Change vaules in the 'config.lua' !!!
	DO NOT EDIT THIS IF YOU DON'T KNOW WHAT YOU ARE DOING

───────────────────────────────────────────────────────────────
]]

local cooldown = 0
local ispriority = false
local ishold = false
local togglepriority = false

EnabledUI = false
EnabledNPUI = true
EnabledSLUI = true
EnabledLUI = true
hudEnabled = false

RegisterCommand("resetpcd", function()
    TriggerServerEvent("cancelcooldown")
end, false)

RegisterNetEvent('UpdateCooldown')
AddEventHandler('UpdateCooldown', function(newCooldown)
    cooldown = newCooldown
end)

RegisterNetEvent('UpdatePriority')
AddEventHandler('UpdatePriority', function(newispriority, newpriorityname)
	priorityname = newpriorityname
    ispriority = newispriority
end)

RegisterNetEvent('UpdateHold')
AddEventHandler('UpdateHold', function(newishold)
    ishold = newishold
end)

Citizen.CreateThread(function()
	while true do
		if hudEnabled == true then
			Citizen.Wait(0)
			if ispriority == false and ishold == false and cooldown == 0 then
				DrawText2("~y~Priority Status: ~g~Inactive")
			elseif ishold == true then
				DrawText2("~y~Priority Status: ~o~On Hold")
			elseif ispriority == false then
				DrawText2("~y~Priority Status: ~r~Cooldown ~c~(".. cooldown .."m remaining)")
			elseif ispriority == true then
				DrawText2("~y~Priority Status: ~r~Active ~c~(".. priorityname ..")")
			end
		else
				Citizen.Wait(0)
				DrawText3("Not Toggled")
		end
	end
end)

RegisterNUICallback('NUIFocusOff', function()
  Gui(false)
end)

function Gui(toggle)
      SetNuiFocus(toggle, toggle)
      guiEnabled = toggle
      SendNUIMessage({
          type = "enableui",
          enable = toggle
      })
   end

	function DrawText2(text)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextScale(0.0, 0.46)
        SetTextDropshadow(1, 0, 0, 0, 255)
        SetTextEdge(1, 0, 0, 0, 255)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(0.175, 0.845)
    end
	
	function DrawText3(text)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextScale(0.0, 0.01)
        SetTextDropshadow(1, 0, 0, 0, 255)
        SetTextEdge(1, 0, 0, 0, 255)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(0.175, 0.88)
    end
	
AddEventHandler('onClientResourceStart', function(resourceName)
	TriggerEvent("showspeedlimithud", show)
    if(GetCurrentResourceName() ~= resourceName) then
      return
    end
    Gui(true)
end)

_MenuPool = NativeUI.CreatePool()
MainMenu = NativeUI.CreateMenu()

function Menu()
local MenuTitle = Config.MenuTitle
	_MenuPool:Remove()
	_MenuPool = NativeUI.CreatePool()
	MainMenu = NativeUI.CreateMenu(MenuTitle, 'MAIN MENU')
	_MenuPool:Add(MainMenu)
	MainMenu:SetMenuWidthOffset(Config.MenuWidth)
	collectgarbage()
	MainMenu:SetMenuWidthOffset(Config.MenuWidth)	
	_MenuPool:ControlDisablingEnabled(false)
	_MenuPool:MouseControlsEnabled(false)
		local LEOMenu = _MenuPool:AddSubMenu(MainMenu, 'Police Toolbox', 'Open Law Enforcement Toolbox.', true, false, "→→→")
        LEOMenu:SetMenuWidthOffset(Config.MenuWidth)
                local Cuff = NativeUI.CreateItem('Cuff', '')
                local Drag = NativeUI.CreateItem('Grab', '')
                local Seat = NativeUI.CreateItem('Seat player in vehicle', '')
                local Unseat = NativeUI.CreateItem('Unseat player from vehicle', '')
                local Radar = NativeUI.CreateItem('Toggle Radar', '')
                local Inventory = NativeUI.CreateItem('Search Player', '')
                local BAC = NativeUI.CreateItem('Test Players BAC', '')
                local Spikes = NativeUI.CreateItem('Deploy Spikes', '')
                local Shield = NativeUI.CreateItem('Toggle Shield', '')
                PropsList = {}
                for _, Prop in pairs(Config.LEOProps) do
                    table.insert(PropsList, Prop.name)
                end
                local Props = NativeUI.CreateListItem('Spawn Props', PropsList, 1, '')
                local RemoveProps = NativeUI.CreateItem('Remove Props', '')
                LEOMenu:AddItem(Cuff)
                LEOMenu:AddItem(Drag)
                LEOMenu:AddItem(Seat)
                LEOMenu:AddItem(Unseat)
                LEOMenu:AddItem(Radar)
                LEOMenu:AddItem(Inventory)
                LEOMenu:AddItem(BAC)
                LEOMenu:AddItem(Spikes)
                LEOMenu:AddItem(Shield)
                if Config.DisplayProps then
                LEOMenu:AddItem(Props)
                LEOMenu:AddItem(RemoveProps)
                end
                Cuff.Activated = function(ParentMenu, SelectedItem)
                    local player = GetClosestPlayer()
                    if player ~= false then
                        TriggerServerEvent('SEM_InteractionMenu:CuffNear', player)
                    end
                end
                Drag.Activated = function(ParentMenu, SelectedItem)
                    local player = GetClosestPlayer()
                    if player ~= false then
                        TriggerServerEvent('SEM_InteractionMenu:DragNear', player)
                    end
                end
                Seat.Activated = function(ParentMenu, SelectedItem)
                    local Veh = GetVehiclePedIsIn(Ped, true)

                    local player = GetClosestPlayer()
                    if player ~= false then
                        TriggerServerEvent('SEM_InteractionMenu:SeatNear', player, Veh)
                    end
                end
                Unseat.Activated = function(ParentMenu, SelectedItem)
                    if IsPedInAnyVehicle(GetPlayerPed(-1), true) then
                        Notify('~o~You need to be outside of the vehicle')
                        return
                    end

                    local player = GetClosestPlayer()
                    if player ~= false then
                        TriggerServerEvent('SEM_InteractionMenu:UnseatNear', player)
                    end
                end
                Radar.Activated = function(ParentMenu, SelectedItem)
                    if Config.Radar ~= 0 then
                        if IsPedInAnyVehicle(GetPlayerPed(-1)) then
                            if GetVehicleClass(GetVehiclePedIsIn(GetPlayerPed(-1))) == 18 then
                                if GetPedInVehicleSeat(GetVehiclePedIsIn(GetPlayerPed(-1)) == -1) then
                                    _MenuPool:CloseAllMenus()
                                    if Config.Radar == 1 then
                                        TriggerEvent('wk:openRemote')
                                    elseif Config.Radar == 2 then
                                        TriggerEvent('wk:radarRC')
                                    else
                                        Notify('~r~Invalid Radar Option, please rectify!')
                                    end
                                else
                                    Notify('~o~You need to be in the driver seat')
                                end
                            else
                                Notify('~o~You need to be in a police vehicle')
                            end
                        else
                            Notify('~o~You need to be in a vehicle')
                        end
                    end
                end
                Inventory.Activated = function(ParentMenu, SelectedItem)
                    local player = GetClosestPlayer()
                    if player ~= false then
                        Notify('~b~Searching ...')
                        TriggerServerEvent('SEM_InteractionMenu:InventorySearch', player)
                    end
                end
                BAC.Activated = function(ParentMenu, SelectedItem)
                    local player = GetClosestPlayer()
                    if player ~= false then
                        Notify('~b~Testing ...')
                        TriggerServerEvent('SEM_InteractionMenu:BACTest', player)
                    end
                end
                Spikes.Activated = function(ParentMenu, SelectedItem)
                    TriggerEvent('SEM_InteractionMenu:Spikes-SpawnSpikes')
                end
                Shield.Activated = function(ParentMenu, SelectedItem)
                    if ShieldActive then
                        DisableShield()
                    else
                        EnableShield()
                    end
                end
                LEOMenu.OnListSelect = function(sender, item, index)
                    if item == Props then
                        for _, Prop in pairs(Config.LEOProps) do
                            if Prop.name == item:IndexToItem(index) then
                                TriggerEvent('SEM_InteractionMenu:Object:SpawnObjects', Prop.spawncode, Prop.name)
                            end
                        end
                    end
                end
                RemoveProps.Activated = function(ParentMenu, SelectedItem)
                    for _, Prop in pairs(Config.LEOProps) do
                        DeleteOBJ(Prop.spawncode)
                    end
                end

        local FireMenu = _MenuPool:AddSubMenu(MainMenu, 'Fire Toolbox', 'Open the fire toolbox.', true, false, "→→→")
        FireMenu:SetMenuWidthOffset(Config.MenuWidth)
                local Drag = NativeUI.CreateItem('Grab', '')
                local Seat = NativeUI.CreateItem('Seat player in vehicle', '')
                local Unseat = NativeUI.CreateItem('Unseat player from vehicle', '')
                FireMenu:AddItem(Drag)
                FireMenu:AddItem(Seat)
                FireMenu:AddItem(Unseat)
                Drag.Activated = function(ParentMenu, SelectedItem)
                    local player = GetClosestPlayer()
                    if player ~= false then
                        TriggerServerEvent('SEM_InteractionMenu:DragNear', player)
                    end
                end
                Seat.Activated = function(ParentMenu, SelectedItem)
                    local player = GetClosestPlayer()
                    if player ~= false then
                        TriggerServerEvent('SEM_InteractionMenu:SeatNear', player, Veh)
                    end
                end
                Unseat.Activated = function(ParentMenu, SelectedItem)
                    if IsPedInAnyVehicle(GetPlayerPed(-1), true) then
                        Notify('~o~You need to be outside of the vehicle')
                        return
                    end

                    local player = GetClosestPlayer()
                    if player ~= false then
                        TriggerServerEvent('SEM_InteractionMenu:UnseatNear', player)
                    end
                end

        local CivMenu = _MenuPool:AddSubMenu(MainMenu, 'Civilian Toolbox', 'Open the civilian toolbox.', true, false, "→→→")
        CivMenu:SetMenuWidthOffset(Config.MenuWidth)
				local TPUI = NativeUI.CreateItem('Toggle Priority UI', '')
                local HU = NativeUI.CreateItem('Hands Up', '')
                local HUK = NativeUI.CreateItem('Hands Up and Kneel', '')
				local PriorityMenu = _MenuPool:AddSubMenu(CivMenu, 'Priority Menu', 'Toggle Priority UI, Start/Stop Priority.', true, false, "→→→")
				local StartPriority = NativeUI.CreateItem('Start Priority', '')
				local EndPriority = NativeUI.CreateItem('End Priority', '')
                local Inventory = NativeUI.CreateItem('Set Player Inventory', '')
                local BAC = NativeUI.CreateItem('Set BAC Level', '')
                local DropWeapon = NativeUI.CreateItem('Drop Weapon', '')
				PriorityMenu:AddItem(TPUI)
                CivMenu:AddItem(HU)
                CivMenu:AddItem(HUK)
				PriorityMenu:AddItem(StartPriority)
				PriorityMenu:AddItem(EndPriority)
                CivMenu:AddItem(Inventory)
                CivMenu:AddItem(BAC)
                CivMenu:AddItem(DropWeapon)
				
				TPUI.Activated = function(ParentMenu, SelectedItem)
				EnabledUI = not EnabledUI
				if EnabledUI then
					hudEnabled = true
				elseif EnabledUI == false then
					hudEnabled = false
				else
					hudEnabled = true
				end
				end
				
				StartPriority.Activated = function(ParentMenu, SelectedItem)
						TriggerServerEvent('isPriority')
				end
				
				EndPriority.Activated = function(ParentMenu, SelectedItem)
						TriggerServerEvent('cooldownt')
				end
				
				
				
				
                HU.Activated = function(ParentMenu, SelectedItem)
                    local Ped = PlayerPedId()
                    local togglehu = false
					togglehu = not togglehu
					if togglehu then
						if (DoesEntityExist(Ped) and not IsEntityDead(Ped)) and not HandCuffed then
							ExecuteCommand('hu')
						end
					elseif togglehu == true then
						if (DoesEntityExist(Ped) and not IsEntityDead(Ped)) and not HandCuffed then
							ExecuteCommand('hu')
						end
					else
						if (DoesEntityExist(Ped) and not IsEntityDead(Ped)) and not HandCuffed then
							ExecuteCommand('hu')
						end
					end
                end
                HUK.Activated = function(ParentMenu, SelectedItem)
                    local Ped = PlayerPedId()
					local togglehuk = false
					togglehuk = not togglehuk
					if togglehuk then
						if (DoesEntityExist(Ped) and not IsEntityDead(Ped)) and not HandCuffed then
							ExecuteCommand('huk')
						end
					elseif togglehuk == true then
						if (DoesEntityExist(Ped) and not IsEntityDead(Ped)) and not HandCuffed then
							ExecuteCommand('huk')
						end
					else
						if (DoesEntityExist(Ped) and not IsEntityDead(Ped)) and not HandCuffed then
							ExecuteCommand('huk')
						end
					end
                end
                Inventory.Activated = function(ParentMenu, SelectedItem)
                    local Items = KeyboardInput('Items:', 75)
                    if Items == nil or Items == '' then
                        Notify('~r~No Items Provided!')
                        return
                    end

                    TriggerServerEvent('SEM_InteractionMenu:InventorySet', Items)
                    Notify('~g~Inventory Set!')
                end
                BAC.Activated = function(ParentMenu, SelectedItem)
                    local BACLevel = KeyboardInput('BAC Level - Legal Limit: 0.08', 5)
                    if BACLevel == nil or BACLevel == '' then
                        Notify('~r~No BAC Level Provided!')
                        return
                    end

                    TriggerServerEvent('SEM_InteractionMenu:BACSet', tonumber(BACLevel))
                    if tonumber(BACLevel) < 0.08 then
                        Notify('~b~BAC Level Set: ~g~' .. tostring(BACLevel))
                    else
                        Notify('~b~BAC Level Set: ~r~' .. tostring(BACLevel))
                    end
                end
                DropWeapon.Activated = function(ParentMenu, SelectedItem)
                    local CurrentWeapon = GetSelectedPedWeapon(PlayerPedId())
                    SetCurrentPedWeapon(PlayerPedId(), 'weapon_unarmed', true)
                    SetPedDropsInventoryWeapon(GetPlayerPed(-1), CurrentWeapon, -2.0, 0.0, 0.5, 30)
                    Notify('~r~Weapon Dropped!')
                end
                local CivAdverts = _MenuPool:AddSubMenu(CivMenu, 'Advert Menu', 'Open the civilian advert menu.', true, false, "→→→")
                CivAdverts:SetMenuWidthOffset(Config.MenuWidth)
                    for _, Ad in pairs(Config.CivAdverts) do
                        local Advert  = NativeUI.CreateItem(Ad.name, '')
                        CivAdverts:AddItem(Advert)
                        Advert.Activated = function(ParentMenu, SelectedItem)
                            local Message = KeyboardInput('Message:', 128)
                            if Message == nil or Message == '' then
                                Notify('~r~No Advert Message Provided!')
                                return
                            end
                
                            TriggerServerEvent('SEM_InteractionMenu:Ads', Message, Ad.name, Ad.loc, Ad.file)
                        end
                    end

        local VehicleMenu = _MenuPool:AddSubMenu(MainMenu, 'Vehicle Options', 'Open the vehicle menu.', true, false, "→→→")
        VehicleMenu:SetMenuWidthOffset(Config.MenuWidth)
            local Seats = {-1, 0, 1, 2}
            local Windows = {'Front', 'Rear', 'All'}
            local Doors = {'Driver', 'Passenger', 'Rear Right', 'Rear Left', 'Hood', 'Trunk', 'All'}
            local Engine = NativeUI.CreateItem('Toggle Engine', '')
            local ILights = NativeUI.CreateItem('Toggle Interior Light', '')
            local Seat = NativeUI.CreateSliderItem('Change Seats', Seats, 1, '')
            local Window = NativeUI.CreateListItem('Windows', Windows, 1, '')
            local Door = NativeUI.CreateListItem('Doors', Doors, 1, '')
            VehicleMenu:AddItem(Engine)
            VehicleMenu:AddItem(ILights)
            VehicleMenu:AddItem(Seat)
            VehicleMenu:AddItem(Window)
            VehicleMenu:AddItem(Door)
            Engine.Activated = function(ParentMenu, SelectedItem)
                local Vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                if Vehicle ~= nil and Vehicle ~= 0 and GetPedInVehicleSeat(Vehicle, 0) then
                    SetVehicleEngineOn(Vehicle, (not GetIsVehicleEngineRunning(Vehicle)), false, true)
                    Notify('~g~Engine Toggled!')
                else
                    Notify('~r~You\'re not in a Vehicle!')
                end
            end
            ILights.Activated = function(ParentMenu, SelectedItem)
                local Vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

                if IsPedInVehicle(PlayerPedId(), Vehicle, false) then
                    if IsVehicleInteriorLightOn(Vehicle) then
                        SetVehicleInteriorlight(Vehicle, false)
                    else
                        SetVehicleInteriorlight(Vehicle, true)
                    end
                else
                    Notify('~r~You\'re not in a Vehicle!')
                end
            end
            VehicleMenu.OnSliderChange = function(sender, item, index)
                if item == Seat then
                    VehicleSeat = item:IndexToItem(index)
                    local Veh = GetVehiclePedIsIn(GetPlayerPed(-1),false)
                    SetPedIntoVehicle(PlayerPedId(), Veh, VehicleSeat)
                end
            end
            VehicleMenu.OnListSelect = function(sender, item, index)
                local Ped = GetPlayerPed(-1)
                local Veh = GetVehiclePedIsIn(Ped, false)

                if item == Window then
                    VehicleWindow = item:IndexToItem(index)
                    if VehicleWindow == 'Front' then
                        if IsPedInAnyVehicle(Ped, false) then
                            if (GetPedInVehicleSeat(Veh, -1) == Ped) then 
                                SetEntityAsMissionEntity(Veh, true, true)
                                if (WindowFrontRolled) then
                                    RollDownWindow(Veh, 0)
                                    RollDownWindow(Veh, 1)
                                    WindowFrontRolled = false
                                else
                                    RollUpWindow(Veh, 0)
                                    RollUpWindow(Veh, 1)
                                    WindowFrontRolled = true
                                end
                            end
                        end
                    elseif VehicleWindow == 'Rear' then
                        if IsPedInAnyVehicle(Ped, false) then
                            if (GetPedInVehicleSeat(Veh, -1) == Ped) then 
                                SetEntityAsMissionEntity(Veh, true, true)
                                if (WindowFrontRolled) then
                                    RollDownWindow(Veh, 2)
                                    RollDownWindow(Veh, 3)
                                    WindowFrontRolled = false
                                else
                                    RollUpWindow(Veh, 2)
                                    RollUpWindow(Veh, 3)
                                    WindowFrontRolled = true
                                end
                            end
                        end
                    elseif VehicleWindow == 'All' then
                        if IsPedInAnyVehicle(Ped, false) then
                            if (GetPedInVehicleSeat(Veh, -1) == Ped) then 
                                SetEntityAsMissionEntity(Veh, true, true)
                                if (WindowFrontRolled) then
                                    RollDownWindow(Veh, 0)
                                    RollDownWindow(Veh, 1)
                                    RollDownWindow(Veh, 2)
                                    RollDownWindow(Veh, 3)
                                    WindowFrontRolled = false
                                else
                                    RollUpWindow(Veh, 0)
                                    RollUpWindow(Veh, 1)
                                    RollUpWindow(Veh, 2)
                                    RollUpWindow(Veh, 3)
                                    WindowFrontRolled = true
                                end
                            end
                        end
                    end
                elseif item == Door then
                    local Doors = {'Driver', 'Passenger', 'Rear Left', 'Rear Right', 'Hood', 'Trunk', 'All'}
                    VehicleDoor = item:IndexToItem(index)
                    if VehicleDoor == 'Driver' then
                        if Veh ~= nil and Veh ~= 0 and Veh ~= 1 then
                            if GetVehicleDoorAngleRatio(Veh, 0) > 0 then
                                SetVehicleDoorShut(Veh, 0, false)
                            else
                                SetVehicleDoorOpen(Veh, 0, false, false)
                            end
                        end
                    elseif VehicleDoor == 'Passenger' then
                        if Veh ~= nil and Veh ~= 0 and Veh ~= 1 then
                            if GetVehicleDoorAngleRatio(Veh, 1) > 0 then
                                SetVehicleDoorShut(Veh, 1, false)
                            else
                                SetVehicleDoorOpen(Veh, 1, false, false)
                            end
                        end
                    elseif VehicleDoor == 'Rear Left' then
                        if Veh ~= nil and Veh ~= 0 and Veh ~= 1 then
                            if GetVehicleDoorAngleRatio(Veh, 2) > 0 then
                                SetVehicleDoorShut(Veh, 2, false)
                            else
                                SetVehicleDoorOpen(Veh, 2, false, false)
                            end
                        end
                    elseif VehicleDoor == 'Rear Right' then
                        if Veh ~= nil and Veh ~= 0 and Veh ~= 1 then
                            if GetVehicleDoorAngleRatio(Veh, 3) > 0 then
                                SetVehicleDoorShut(Veh, 3, false)
                            else
                                SetVehicleDoorOpen(Veh, 3, false, false)
                            end
                        end
                    elseif VehicleDoor == 'Hood' then
                        if Veh ~= nil and Veh ~= 0 and Veh ~= 1 then
                            if GetVehicleDoorAngleRatio(Veh, 4) > 0 then
                                SetVehicleDoorShut(Veh, 4, false)
                            else
                                SetVehicleDoorOpen(Veh, 4, false, false)
                            end
                        end
                    elseif VehicleDoor == 'Trunk' then
                        if Veh ~= nil and Veh ~= 0 and Veh ~= 1 then
                            if GetVehicleDoorAngleRatio(Veh, 5) > 0 then
                                SetVehicleDoorShut(Veh, 5, false)
                            else
                                SetVehicleDoorOpen(Veh, 5, false, false)
                            end
                        end
                    elseif VehicleDoor == 'All' then
                        if Veh ~= nil and Veh ~= 0 and Veh ~= 1 then
                            if GetVehicleDoorAngleRatio(Veh, 0) > 0 then
                                SetVehicleDoorShut(Veh, 0, false)
                                SetVehicleDoorShut(Veh, 1, false)
                                SetVehicleDoorShut(Veh, 2, false)
                                SetVehicleDoorShut(Veh, 3, false)
                                SetVehicleDoorShut(Veh, 4, false)
                                SetVehicleDoorShut(Veh, 5, false)
                            else
                                SetVehicleDoorOpen(Veh, 0, false, false)
                                SetVehicleDoorOpen(Veh, 1, false, false)
                                SetVehicleDoorOpen(Veh, 2, false, false)
                                SetVehicleDoorOpen(Veh, 3, false, false)
                                SetVehicleDoorOpen(Veh, 4, false, false)
                                SetVehicleDoorOpen(Veh, 5, false, false)
                            end
                        end
                    end
                end
            end

                local FixVeh = NativeUI.CreateItem('Repair Vehicle', '')
                local CleanVeh = NativeUI.CreateItem('Clean Vehicle', '')
                local DelVeh = NativeUI.CreateItem('~r~Delete Vehicle', '')
                VehicleMenu:AddItem(FixVeh)
                VehicleMenu:AddItem(CleanVeh)
                VehicleMenu:AddItem(DelVeh)
                FixVeh.Activated = function(ParentMenu, SelectedItem)
                    local Vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                    if Vehicle ~= nil and Vehicle ~= 0 then
                        SetVehicleEngineHealth(Vehicle, 100)
                        SetVehicleFixed(Vehicle)
                        Notify('~g~Vehicle Repaired!')
                    else
                        Notify('~r~You\'re not in a Vehicle!')
                    end

                end
                CleanVeh.Activated = function(ParentMenu, SelectedItem)
                    local Vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                    if Vehicle ~= nil and Vehicle ~= 0 then
                        SetVehicleDirtLevel(Vehicle, 0)
                        Notify('~g~Vehicle Cleaned!')
                    else
                        Notify('~r~You\'re not in a Vehicle!')
                    end
                end
                DelVeh.Activated = function(ParentMenu, SelectedItem)
                    if (IsPedSittingInAnyVehicle(PlayerPedId())) then 
                        local Vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

                        if (GetPedInVehicleSeat(Vehicle, -1) == PlayerPedId()) then 
                            SetEntityAsMissionEntity(Vehicle, true, true)
                            DeleteVehicle(Vehicle)

                            if (DoesEntityExist(Vehicle)) then 
                                Notify('~o~Unable to delete vehicle, try again.')
                            else 
                                Notify('~r~Vehicle Deleted!')
                            end 
                        else 
                            Notify('~r~You must be in the driver\'s seat!')
                        end 
                    else
                        Notify('~r~You\'re not in a Vehicle!')
                    end
                end
				
				local ToggleEmotes = NativeUI.CreateItem('Emote Menu', 'Open the emote menu.')
				ToggleEmotes:RightLabel("→→→")
                MainMenu:AddItem(ToggleEmotes)
				ToggleEmotes.Activated = function(ParentMenu, SelectedItem)
                     _MenuPool:CloseAllMenus()
                     TriggerEvent('dp:RecieveMenu')

                end
				local Settings = _MenuPool:AddSubMenu(MainMenu, 'Settings', 'Open the settings.', true, false, "→→→")
				Settings:SetMenuWidthOffset(Config.MenuWidth)
				local ToggleNPUI = NativeUI.CreateItem('Toggle Nearest Postal UI', '')
				local ToggleSLUI = NativeUI.CreateItem('Toggle Speed Limit UI', '')
				local ToggleLUI = NativeUI.CreateItem('Toggle Location PLD UI', '')
				local About = NativeUI.CreateItem('About GoldenRP Menu', 'This M Menu is a personalized menu that Xd_Golden_Tiger worked hard on customizing.')
				local Original = NativeUI.CreateItem('Original Credits', 'All Credits go to Scott M. Original menu: SEM_InteractionMenu.')
				Settings:AddItem(ToggleNPUI)
				Settings:AddItem(ToggleSLUI)
				Settings:AddItem(ToggleLUI)
				Settings:AddItem(About)
				Settings:AddItem(Original)
				
				ToggleNPUI.Activated = function(ParentMenu, SelectedItem)
				EnabledNPUI = not EnabledNPUI
				if EnabledNPUI then
					TriggerEvent("shownearestpostalhud", show)
				elseif EnabledNPUI == false then
					TriggerEvent("hidenearestpostalhud", hide)
				else
					TriggerEvent("shownearestpostalhud", show)
				end
				end
				
				ToggleSLUI.Activated = function(ParentMenu, SelectedItem)
				EnabledSLUI = not EnabledSLUI
				if EnabledSLUI then
					TriggerEvent("showspeedlimithud", show)
				elseif EnabledSLUI == false then
					TriggerEvent("hidespeedlimithud", hide)
				else
					TriggerEvent("showspeedlimithud", show)
				end
				end
				
				ToggleLUI.Activated = function(ParentMenu, SelectedItem)
				EnabledLUI = not EnabledLUI
				if EnabledLUI then
					TriggerEvent("showlocationhud", show)
				elseif EnabledLUI == false then
					TriggerEvent("hidelocationhud", hide)
				else
					TriggerEvent("showlocationhud", show)
				end
				end


				

				


				
				local ToggleClose = NativeUI.CreateItem('Close', 'Close the menu.')
                MainMenu:AddItem(ToggleClose)
				ToggleClose.Activated = function(ParentMenu, SelectedItem)
                     _MenuPool:CloseAllMenus()
                end
		end
			



Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		
		_MenuPool:ProcessMenus()	
		_MenuPool:ControlDisablingEnabled(false)
		_MenuPool:MouseControlsEnabled(false)
		
		if IsControlJustPressed(1, Config.MenuButton) and GetLastInputMethod(2) then
			if not MainMenu:Visible() then
				Menu()
                MainMenu:Visible(true)
            else
                _MenuPool:CloseAllMenus()
			end
		end
	end
end)
