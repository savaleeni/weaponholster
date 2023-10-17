local SavHolsterWeapon = {
	Vars = {
		ESX = nil,
		holstered = true,
		blocked = false,
		PlayerData = {},
		COOLDOWN_POLICE = 500,
		COOLDOWN_NORMAL = 1700,
		WEAPON_UNARMED = GetHashKey("WEAPON_UNARMED"),
		WEAPONS_POLICE = { "WEAPON_PISTOL", "WEAPON_COMBATPISTOL", "WEAPON_APPISTOL" },  -- Add police weapons here
		WEAPONS_NORMAL = { "WEAPON_PISTOL", "WEAPON_COMBATPISTOL", "WEAPON_APPISTOL" }  -- Add non-police weapons here
	},
	Functions = {}
}

Citizen.CreateThread(function()
    SavHolsterWeapon.Vars.ESX = exports['es_extended']:getSharedObject()

    SavHolsterWeapon.Functions.loadAnimDict("rcmjosh4")
    SavHolsterWeapon.Functions.loadAnimDict("reaction@intimidation@cop@unarmed")
    SavHolsterWeapon.Functions.loadAnimDict("reaction@intimidation@1h")

    while SavHolsterWeapon.Vars.ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end

    SavHolsterWeapon.Vars.PlayerData = SavHolsterWeapon.Vars.ESX.GetPlayerData()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    SavHolsterWeapon.Vars.PlayerData.job = job
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)
        local ped = PlayerPedId()

        if SavHolsterWeapon.Vars.PlayerData.job ~= nil and SavHolsterWeapon.Vars.PlayerData.job.name == 'police' then
            SavHolsterWeapon.Functions.HandleWeaponAnimation(ped, SavHolsterWeapon.Vars.WEAPONS_POLICE, true, SavHolsterWeapon.Vars.COOLDOWN_POLICE)
        else
            SavHolsterWeapon.Functions.HandleWeaponAnimation(ped, SavHolsterWeapon.Vars.WEAPONS_NORMAL, false, SavHolsterWeapon.Vars.COOLDOWN_NORMAL)
        end
    end
end)

function SavHolsterWeapon.Functions.HandleWeaponAnimation(ped, weapons, police, cooldown)
    local currentWeapon = GetSelectedPedWeapon(ped)

    if not IsPedInAnyVehicle(ped, false) and not IsPedInParachuteFreeFall(ped) then
        if SavHolsterWeapon.Functions.CheckWeapon(ped, weapons) then
            if SavHolsterWeapon.Vars.holstered then
                if police then 
                SavHolsterWeapon.Vars.blocked = true
                SavHolsterWeapon.Functions.CreateDisableControlActionsThread()
                SetPedCurrentWeaponVisible(ped, 0, 1, 1, 1)
                TaskPlayAnim(ped, "reaction@intimidation@cop@unarmed", "intro", 8.0, 2.0, -1, 50, 2.0, 0, 0, 0 ) -- Change 50 to 30 if you want to stand still when removing weapon
                Citizen.Wait(cooldown)
                SetPedCurrentWeaponVisible(ped, 1, 1, 1, 1)
                TaskPlayAnim(ped, "rcmjosh4", "josh_leadout_cop2", 8.0, 2.0, -1, 48, 10, 0, 0, 0 )
                Citizen.Wait(400)
                ClearPedTasks(ped)
                SavHolsterWeapon.Vars.holstered = false
                else 
                    print("lol")
                    SavHolsterWeapon.Vars.blocked = true
                    SavHolsterWeapon.Functions.CreateDisableControlActionsThread()
                    SetPedCurrentWeaponVisible(ped, 0, 1, 1, 1)
                    TaskPlayAnim(ped, "reaction@intimidation@1h", "intro", 5.0, 1.0, -1, 50, 0, 0, 0, 0 )
                    Citizen.Wait(1250)
                    SetPedCurrentWeaponVisible(ped, 1, 1, 1, 1)
                    Citizen.Wait(cooldown)
                    ClearPedTasks(ped)
                    SavHolsterWeapon.Vars.holstered = false
                end
            else
                SavHolsterWeapon.Vars.blocked = false
            end
        else
            if not SavHolsterWeapon.Vars.holstered then
                if police then 
                TaskPlayAnim(ped, "rcmjosh4", "josh_leadout_cop2", 8.0, 2.0, -1, 48, 10, 0, 0, 0)
                Citizen.Wait(500)
                TaskPlayAnim(ped, "reaction@intimidation@cop@unarmed", "outro", 8.0, 2.0, -1, 50, 2.0, 0, 0, 0 ) -- Change 50 to 30 if you want to stand still when holstering weapon
                Citizen.Wait(60)
                ClearPedTasks(ped)
                SavHolsterWeapon.Vars.holstered = true
                else 
                    TaskPlayAnim(ped, "reaction@intimidation@1h", "outro", 8.0, 3.0, -1, 50, 0, 0, 0.125, 0 ) -- Change 50 to 30 if you want to stand still when holstering weapon
                    Citizen.Wait(1700)
                    ClearPedTasks(ped)
                    SavHolsterWeapon.Vars.holstered = true
                end
            end
        end
    else
        SetCurrentPedWeapon(ped, SavHolsterWeapon.Vars.WEAPON_UNARMED, true)
    end
end

function SavHolsterWeapon.Functions.CheckWeapon(ped, weaponList)
    if IsEntityDead(ped) then
        SavHolsterWeapon.Vars.blocked = false
        return false
    else
        for i = 1, #weaponList do
            if GetHashKey(weaponList[i]) == GetSelectedPedWeapon(ped) then
                return true
            end
        end
        return false
    end
end

function SavHolsterWeapon.Functions.CreateDisableControlActionsThread()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            if SavHolsterWeapon.Vars.blocked then
            SavHolsterWeapon.Functions.DisableControlActions() 
            else 
                return 
            end
        end
    end)
end


function SavHolsterWeapon.Functions.DisableControlActions()
    local disabledControls = { 25, 140, 141, 142, 23, 37 }
    for _, control in pairs(disabledControls) do
        DisableControlAction(1, control, true)
    end
    DisablePlayerFiring(PlayerPedId(), true)
end

function SavHolsterWeapon.Functions.loadAnimDict(dict)
	while ( not HasAnimDictLoaded(dict)) do
		RequestAnimDict(dict)
		Citizen.Wait(0)
	end
end
