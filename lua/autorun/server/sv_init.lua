AddCSLuaFile("autorun/config.lua")
AddCSLuaFile("autorun/client/cl_init.lua")
include("autorun/config.lua")

resource.AddFile("sound/drowningsystem/drowning.mp3")
resource.AddFile("sound/drowningsystem/gasping.mp3")

-- Initialization messages 
if DS.Enabled then 
	-- Enabled! Yay!
	MsgC(Color(255,255,255), "-----------------------------\n")
	MsgC(Color(255,255,255), "--     Drowning System     --\n")
	MsgC(Color(255,255,255), "--") MsgC(Color(0,255,0), 	 "         Enabled         ") MsgC(Color(255,255,255), "--\n")
	MsgC(Color(255,255,255), "-----------------------------\n")
	if DS.DisableOnMaps[1] then 
		MsgC(Color(255,255,255), "-- Maps currently Disabled --\n")
		for k,v in pairs(DS.DisableOnMaps) do
			if v == "" or v == nil then
				MsgC(Color(255,255,255), "--           None          --\n")
			else
				MsgC(Color(255,255,255), k..") "..v.."\n")
			end
		end
		MsgC(Color(255,255,255), "-----------------------------\n")
	end
else
	-- Disabled. Boo ;c
	MsgC(Color(255,255,255), "-----------------------------\n")
	MsgC(Color(255,255,255), "--     Drowning System     --\n")
	MsgC(Color(255,255,255), "--") MsgC(Color(255,0,0), 	 "        Disabled         ") MsgC(Color(255,255,255), "--\n")
	MsgC(Color(255,255,255), "-----------------------------\n")
	return
end

-- Is the map we are on blocked via the config?
if table.HasValue(DS.DisableOnMaps, game.GetMap()) then return end

-- Lets check all the players water levels
function DS_CheckWaterLevel()
	-- Grab teh players
	for _,v in pairs(player.GetAll()) do
		-- Is the players water level >= 3 (Are they submerged?)
		if v:WaterLevel() >= 3 then
			-- Do we want to override known gamemodes?
			if DS.OverrideGamemodes then
				local OverrideCurrentGamemode, GamemodeName = DS_IsOverridden()
	
				-- Check to see if we are playing an overridden gamemode
				if OverrideCurrentGamemode then 
					if GamemodeName == "TTT" then
						if v.drowning then v.drowning = nil	end
						if v:Team() == TEAM_TERROR then	DS_StartDrowning(v) end
					elseif GamemodeName == "ZS" then
						if v:GetStatus("drown") then v:RemoveStatus("drown") end
						if v:Team() == TEAM_HUMAN then DS_StartDrowning(v) end
					else
						-- Should never reach this point but if it does we are ready for it
						DS_StartDrowning(v)
						end
				else
					-- Function returned false, continue normally
					DS_StartDrowning(v)
				end
			else
				-- Not overidding, continue normallly
				DS_StartDrowning(v)
			end
		end
	end
end

-- Control the water hurt timer
local WHThink = 0
function DS_WaterHurts()
	if WHThink < CurTime() then
		for _,v in pairs(player.GetAll()) do
			if v:WaterLevel() >= 1 then
				local dmginfo = DamageInfo()
			    dmginfo:SetDamageType(DMG_GENERIC)
				dmginfo:SetDamage(DS.Config.WaterDamage)
			    dmginfo:SetAttacker(game.GetWorld())
			    dmginfo:SetInflictor(game.GetWorld())
			    v:TakeDamageInfo(dmginfo)
			end	
		end

		WHThink = CurTime() + DS.Config.WaterDamageCycle
	end
end

-- The timer that controls the time before a player begins to drown and die. 
function DS_StartDrowning(ply)
	if timer.Exists("DS_Player_"..ply:UniqueID().."_Submerged") or not ply:IsValid() or not ply:Alive() then return end

	ply:SetNWInt("DS_IsSubmerged", 1)
	
	if DS_IsVIP(ply) and DS.Config.EnableVIPSystem then
		ply:SetNWInt("DS_TimeBeforeDrowning", DS.Config.VIPTimeBeforeDrowning)
	else
		ply:SetNWInt("DS_TimeBeforeDrowning", DS.Config.TimeBeforeDrowning)
	end
			
	timer.Create("DS_Player_"..ply:UniqueID().."_Submerged", 1, 0, function()
		if IsValid(ply) and ply:WaterLevel() >= 3 and ply:Alive() then
			if ply:GetNWInt("DS_TimeBeforeDrowning") > 0 then
				ply:SetNWInt("DS_TimeBeforeDrowning", ply:GetNWInt("DS_TimeBeforeDrowning") - 1)
			else
				ply:SetNWInt("DS_IsDrowning", 1)
				if DS.Config.SoundEffects then
					ply:EmitSound("drowningsystem/drowning.mp3", 60, 100)
				end

				if DS.Config.DrownByPercent then
					local HP = ply:GetMaxHealth()
					local damage = HP * (DS.Config.DrownByPercentDamage * (1 / HP))
					
					local dmginfo = DamageInfo()
			       	dmginfo:SetDamageType(DMG_DROWN)
					dmginfo:SetDamage(damage)
			        dmginfo:SetAttacker(game.GetWorld())
			        dmginfo:SetInflictor(game.GetWorld())
			        ply:TakeDamageInfo(dmginfo)
				else
					local dmginfo = DamageInfo()
			        dmginfo:SetDamageType(DMG_DROWN)
					dmginfo:SetDamage(DS.Config.DrowningDamage)
			        dmginfo:SetAttacker(game.GetWorld())
			        dmginfo:SetInflictor(game.GetWorld())
			        ply:TakeDamageInfo(dmginfo)
				end
			end
		elseif IsValid(ply) then
			if DS.Config.SoundEffects and ply:GetNWBool("DS_IsDrowning") and ply:Alive() then
				ply:EmitSound("drowningsystem/gasping.mp3", 60, 100)
			end
			timer.Destroy("DS_Player_"..ply:UniqueID().."_Submerged")
			ply:SetNWInt("DS_IsDrowning", 0)
			ply:SetNWInt("DS_IsSubmerged", 0)
		end
	end)
end

-- This function checks to see if the current gamemode is blocked.
function DS_IsOverridden()
	if gmod.GetGamemode().Name == "Trouble in Terrorist Town" then 
		return true, "TTT"
	elseif gmod.GetGamemode().Name == "Zombie Survival" then 
		return true, "ZS"
	end

	return false
end

-- This function checks to see if the players group is listed as a VIP
-- ULX
function DS_IsVIP(ply)
	for _, v in pairs(DS.Config.VIPGroups) do
		if ply:IsUserGroup(v) then
			return true
		end
	end
	return false
end

-- Lets check to see what is and isnt enabled
if DS.Config.DrowningSystem then
	hook.Add("Think", "Check all players water levels", DS_CheckWaterLevel)
end

if DS.Config.WaterHurts then
	hook.Add("Think", "Check to see if water hurts", DS_WaterHurts)
end

-- Player initial spawn - Lets set teh variabulz
function DS_PlayerInitialSpawn(ply)
	if IsValid(ply) then
		ply:SetNWInt("DS_IsDrowning", 0)
		ply:SetNWInt("DS_IsSubmerged", 0)
		ply:SetNWInt("DS_TimeBeforeDrowning", 0)
	end
end
hook.Add("PlayerInitialSpawn", "Set player variables", DS_PlayerInitialSpawn)