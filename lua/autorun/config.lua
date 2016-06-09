DS = {}
DS.Config = {}

-- Be sure to restart the server changing any of these

-- Is the addon enabled?
DS.Enabled = true

-- Override Gamemodes? (Recommended = true!)
-- Known Gamemodes with compatability issues are:
	-- Trouble in terrorist town
	-- Zombie Survival
	-- Flood
DS.OverrideGamemodes = true

-- Disables the addon on any of the maps listed in the table
-- If you don't want to disable any maps, just leave it blank.
-- An example of the table --> DS.Config.DisableOnMaps = {"gm_construct", "gm_flatgrass"}
DS.DisableOnMaps = {""}


----------------------------------------------------------
--					Drowning Settings                   --
----------------------------------------------------------

-- Is the drowning system on?
DS.Config.DrowningSystem = true

-- How long can a player be submerged before drowning (in seconds)
DS.Config.TimeBeforeDrowning = 7

-- Damage by percent of player health?
DS.Config.DrownByPercent = true

-- Percent of damage to deal to the player's health
-- Only works if "DrownByPercent" is true
DS.Config.DrownByPercentDamage = 6

-- How much damage will the player take per second.
-- Only works if "DrownByPercent" is false
DS.Config.DrowningDamage = 20

----------------------------------------------------------
--					VIP System Settings                 --
----------------------------------------------------------
-- Enabled the extra air VIP system?
DS.Config.EnableVIPSystem = true

-- How many seconds extra does the VIP Get?
-- Overwrites the TimeBeforeDrowning config for VIPs only
DS.Config.VIPTimeBeforeDrowning = 10.3

-- Do we ever want the value of the stat to never go over 100%?
DS.Config.CapAt100 = true

-- Input the groups that are vip or donators that will
-- recieve the extra air under water.
DS.Config.VIPGroups = { "owner", "furfag", "superadmin", "admin", "lightdonator", "donator", "superdonator", "defiance", "serenity", "lostsouls", "communitydeveloper" }

----------------------------------------------------------
--					Water Damage System Settings        --
----------------------------------------------------------
-- Does water hurt every damage cycle a player is in it?
DS.Config.WaterHurts = false

-- How fast should the player take damage (in seconds)
DS.Config.WaterDamageCycle = 0.5

-- Damage done every cycle of the timer
DS.Config.WaterDamage = 1

----------------------------------------------------------
--					Client Side Settings                --
----------------------------------------------------------
-- Draw the Hud?
DS.Config.DrawDrowningHud = true

-- Use sound effects?
DS.Config.SoundEffects = true

-- Name of the oxygen or "air" stat
DS.Config.StatName = "Oxygen"

-- The font style you would like to use for the text of the stat
DS.Config.StatFont = "TargetID"