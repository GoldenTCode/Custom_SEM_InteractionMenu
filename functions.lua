
function Notify(Text)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(Text)
    DrawNotification(true, true)
end

function NotifyHelp(Text)
	SetTextComponentFormat('STRING')
	AddTextComponentString(Text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function KeyboardInput(TextEntry, MaxStringLenght)
	AddTextEntry('FMMC_KEY_TIP1', TextEntry)
	DisplayOnscreenKeyboard(1, 'FMMC_KEY_TIP1', '', '', '', '', '', MaxStringLenght)
	BlockInput = true

	while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
		Citizen.Wait(0)
	end
		
	if UpdateOnscreenKeyboard() ~= 2 then
		local Result = GetOnscreenKeyboardResult()
		Citizen.Wait(500)
		BlockInput = false
		return Result
	else
		Citizen.Wait(500)
		BlockInput = false
		return nil
	end
end

function GetClosestPlayer()
    local Ped = PlayerPedId()

    for _, Player in ipairs(GetActivePlayers()) do
        if GetPlayerPed(Player) ~= GetPlayerPed(-1) then
            local Ped2 = GetPlayerPed(Player)
            local x, y, z = table.unpack(GetEntityCoords(Ped))
            if (GetDistanceBetweenCoords(GetEntityCoords(Ped2), x, y, z) <  2) then
                return GetPlayerServerId(Player)
            end
        end
    end

    Notify('~r~No Player Nearby!')
    return false
end

function GetDistance(ID)
    local Ped = GetPlayerPed(-1)
    local Ped2 = GetPlayerPed(ID)
    local x, y, z = table.unpack(GetEntityCoords(Ped))
    return GetDistanceBetweenCoords(GetEntityCoords(Ped2), x, y, z)
end

--LEO Functions
function EnableShield()
    ShieldActive = true
    local Ped = GetPlayerPed(-1)
    local PedPos = GetEntityCoords(Ped, false)

    if IsPedInAnyVehicle(GetPlayerPed(-1), true) then
        Notify('~r~You cannot be in a vehicle when getting your shield out!')
        ShieldActive = false
        return
    end
    
    RequestAnimDict('combat@gestures@gang@pistol_1h@beckon')
    while not HasAnimDictLoaded('combat@gestures@gang@pistol_1h@beckon') do
        Citizen.Wait(100)
    end

    TaskPlayAnim(Ped, 'combat@gestures@gang@pistol_1h@beckon', '0', 8.0, -8.0, -1, (2 + 16 + 32), 0.0, 0, 0, 0)

    RequestModel(GetHashKey('prop_ballistic_shield'))
    while not HasModelLoaded(GetHashKey('prop_ballistic_shield')) do
        Citizen.Wait(100)
    end

    local shield = CreateObject(GetHashKey('prop_ballistic_shield'), PedPos.x, PedPos.y, PedPos.z, 1, 1, 1)
    shieldEntity = shield
    AttachEntityToEntity(shieldEntity, Ped, GetEntityBoneIndexByName(Ped, 'IK_L_Hand'), 0.0, -0.05, -0.10, -30.0, 180.0, 40.0, 0, 0, 1, 0, 0, 1)
    SetWeaponAnimationOverride(Ped, 'Gang1H')

    if HasPedGotWeapon(Ped, 'weapon_combatpistol', 0) or GetSelectedPedWeapon(Ped) == 'weapon_combatpistol' then
        SetCurrentPedWeapon(Ped, 'weapon_combatpistol', 1)
        HadPistol = true
    else
        GiveWeaponToPed(Ped, 'weapon_combatpistol', 300, 0, 1)
        SetCurrentPedWeapon(Ped, 'weapon_combatpistol', 1)
        HadPistol = false
    end
    SetEnableHandcuffs(Ped, true)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if ShieldActive == true then
            DisableControlAction(1, 23, true) --F | Enter Vehicle
            DisableControlAction(1, 75, true) --F | Exit Vehicle
        end
    end
end)

function DisableShield()
    local Ped = GetPlayerPed(-1)
    DeleteEntity(shieldEntity)
    ClearPedTasksImmediately(Ped)
    SetWeaponAnimationOverride(Ped, 'Default')
    SetCurrentPedWeapon(Ped, 'weapon_unarmed', 1)

    if not HadPistol then
        RemoveWeaponFromPed(Ped, 'weapon_combatpistol')
    end
    SetEnableHandcuffs(Ped, false)
    HadPistol = false
    ShieldActive = false
end



--Civ Functions
function Ad(Text, Name, Loc, File, ID)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(Text)
    EndTextCommandThefeedPostMessagetext(Loc, File, true, 1, Name, '~b~Advertisement #' .. ID)
    DrawNotification(false, true)
end



--Vehicle Functions
function DeleteVehicle(entity)
    Citizen.InvokeNative( 0xEA386986E786A54F, Citizen.PointerValueIntInitialized(entity))
end


--Prop Functions
function SpawnProp(Object, Name)
    local Player = PlayerPedId()
    local Coords = GetEntityCoords(Player)
    local Heading = GetEntityHeading(Player)

    RequestModel(Object)
    while not HasModelLoaded(Object) do
        Citizen.Wait(0)
    end

    local OffsetCoords = GetOffsetFromEntityInWorldCoords(Player, 0.0, 0.75, 0.0)
    local Prop = CreateObjectNoOffset(Object, OffsetCoords, false, true, false)
    SetEntityHeading(Prop, Heading)
    PlaceObjectOnGroundProperly(Prop)
    SetEntityCollision(Prop, false, true)
    SetEntityAlpha(Prop, 100)
    FreezeEntityPosition(Prop, true)
    SetModelAsNoLongerNeeded(Object)

    Notify('Press ~g~E ~w~to place\nPress ~r~R ~w~to cancel')

    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)

            local OffsetCoords = GetOffsetFromEntityInWorldCoords(Player, 0.0, 0.75, 0.0)
            local Heading = GetEntityHeading(Player)

			SetEntityCoordsNoOffset(Prop, OffsetCoords)
			SetEntityHeading(Prop, Heading)
            PlaceObjectOnGroundProperly(Prop)
			DisableControlAction(1, 38, true) --E
			DisableControlAction(1, 140, true) --R
            
            
            if IsDisabledControlJustPressed(1, 38) then --E
                local PropCoords = GetEntityCoords(Prop)
                local PropHeading = GetEntityHeading(Prop)
                DeleteObject(Prop)

                RequestModel(Object)
                while not HasModelLoaded(Object) do
                    Citizen.Wait(0)
                end

                local Prop = CreateObjectNoOffset(Object, PropCoords, false, true, true)
                SetEntityHeading(Prop, PropHeading)
                PlaceObjectOnGroundProperly(Prop)
                FreezeEntityPosition(Prop, true)
				SetEntityInvincible(Prop, true)
                SetModelAsNoLongerNeeded(Object)
                return
            end

            if IsDisabledControlJustPressed(1, 140) then --R
                DeleteObject(Prop)
                return
            end
        end
    end)
end

function DeleteProp(Object)
    local Hash = GetHashKey(Object)
    local x, y, z = table.unpack(GetEntityCoords(PlayerPedId(), true))
    if DoesObjectOfTypeExistAtCoords(x, y, z, 1.5, Hash, true) then
        local Prop = GetClosestObjectOfType(x, y, z, 1.5, Hash, false, false, false)
        DeleteObject(Prop)
        Notify('~r~Prop Removed!')
    end
end

function DeleteEntity(Entity)
	Citizen.InvokeNative(0xAE3CBE5BF394C9C9, Citizen.PointerValueIntInitialized(Entity))
end
