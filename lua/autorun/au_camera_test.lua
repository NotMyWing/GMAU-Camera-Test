if SERVER then
	util.AddNetworkString("CameraTest Open")

	hook.Add("PlayerUse", "AU Camera Test", function(ply, ent)
		if ent:GetName() == "cameraTest" then
			-- This isn't particularly nice, I know.
			-- I just don't have any fancy wrappers yet.
			local playerTable = GAMEMODE.GameData.Lookup_PlayerByEntity[playerTable]
			if not playerTable then
				return
			end

			local cameraPoint = ents.FindByName("cameraTestTarget")[1]

			if GAMEMODE:Player_OpenVGUI(playerTable, "cameraTest") then
				net.Start("CameraTest Open")
				net.WriteVector(cameraPoint:GetPos())
				net.WriteAngle(cameraPoint:GetAngles())
				net.Send(ply)
			end
		end
	end)
else
	local noop = function() end

	net.Receive("CameraTest Open", function()
		local position = net.ReadVector()
		local angle = net.ReadAngle()

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
	end)
end