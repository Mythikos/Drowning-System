include("autorun/config.lua")

if DS.Enabled then 
	if DS.Config.DrowningSystem then
		if DS.Config.DrawDrowningHud then	
			function DS_PaintHUD()
				if not IsValid(LocalPlayer()) then return end
								
				local HudPos = {}
				HudPos["BottomMiddle"] = {
					x = ScrW() * 0.500,
					y = ScrH() * 0.950
				}

				local stat_perc = nil
				if DS.Config.EnableVIPSystem then
					if DS.Config.CapAt100 then
						stat_perc = math.floor((LocalPlayer():GetNWInt("DS_TimeBeforeDrowning") / DS.Config.VIPTimeBeforeDrowning) * 100)
					else
						stat_perc = math.floor((LocalPlayer():GetNWInt("DS_TimeBeforeDrowning") / DS.Config.TimeBeforeDrowning) * 100)
					end
				else
					stat_perc = math.floor((LocalPlayer():GetNWInt("DS_TimeBeforeDrowning") / DS.Config.TimeBeforeDrowning) * 100)
				end

				if stat_perc <= 0 then stat_perc = 0 end	
												
				if tobool(LocalPlayer():GetNWInt("DS_IsSubmerged")) and LocalPlayer():Alive() then
					draw.RoundedBox(2, HudPos["BottomMiddle"].x - 60, HudPos["BottomMiddle"].y, 120, 20, Color(0,0,0,130))
					draw.SimpleText(DS.Config.StatName..": "..stat_perc.."%", DS.Config.StatFont,  HudPos["BottomMiddle"].x, HudPos["BottomMiddle"].y + 8, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end
			end	
			hook.Add("PostDrawHUD", "Paint the drowning hud", DS_PaintHUD)
		end
	end
end