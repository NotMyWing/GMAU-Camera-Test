if SERVER then
	-- There's no way we can retrieve the entity name on the client side.
	-- Gotta mark it this way.
	hook.Add("GMAU GameStart", "AU Camera Test", function()
		for _, ent in pairs(ents.GetAll()) do
			if ent:GetName() == "cameraTest" then
				ent:SetNW2Bool("Camera", true)
			end
		end
	end)

	hook.Add("PlayerUse", "AU Camera Test", function(ply, ent)
		if ent:GetName() == "cameraTest" then
			-- This isn't particularly nice, I know.
			-- I just don't have any fancy wrappers yet.
			local playerTable = GAMEMODE.GameData.Lookup_PlayerByEntity[ply]
			if not playerTable then
				return
			end

			local cameraPoint = ents.FindByName("cameraTestTarget")[1]

			local payload = {
				cameraData = {
					position = cameraPoint:GetPos(),
					angle = cameraPoint:GetAngles()
				}
			}
			GAMEMODE:Player_OpenVGUI(playerTable, "cameraTest", payload) 
		end
	end)
else
	local noop = function() end

	local material = Material("cameratest/security.png", "smooth")

	-- Tell the game mode to replace the use button with "Security".
	hook.Add("GMAU UseButtonOverride", "AU CameraTest Button", function(ent)
		if ent:GetNW2Bool("Camera") then
			return material
		end
	end)

	hook.Add("GMAU OpenVGUI", "CameraTest Open", function(payload)
		if not payload.cameraData then
			return
		end

		local position = payload.cameraData.position
		local angle = payload.cameraData.angle

		local base = vgui.Create("AmongUsVGUIBase")
		local panel = vgui.Create("DPanel")

		size = 0.7 * math.min(ScrW(), ScrH())
		panel:SetSize(size, size)
		panel:SetBackgroundColor(Color(64, 64, 64))

		insetPanel = panel:Add("DPanel")
		insetPanel:DockMargin(size * 0.03, size * 0.03, size * 0.03, size * 0.03)
		insetPanel:Dock(FILL)

		insetPanel.Paint = function(_, w, h)
			-- XD
			oldHalo = halo.Render
			halo.Render = noop

			local x, y = _:LocalToScreen(0, 0)
			render.RenderView( {
				aspectratio = w/h,
				origin = position,
				angles = angle,
				x = x,
				y = y,
				w = w,
				h = h,
				fov = 90,
				drawviewmodel = false,
			})

			halo.Render = oldHalo
		end

		base:Setup(panel)
		base:Popup()

		GAMEMODE:HUD_OpenVGUI(base)

		return true
	end)
end

return {
	Tasks = {
		"swipeCard"
	}
}
