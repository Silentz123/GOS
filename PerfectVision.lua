
local version = 1.00
local sEnemies = GetEnemyHeroes()
local sAllies = GetAllyHeroes()
local wards = {}
local wardNumber = 50

require "MapPosition"
require "MapPositionGOS"

PerfectVisionMenu = Menu("perfectVision", "Perfect Vision")
PerfectVisionMenu:Boolean("enabled", "Enabled",true)
PerfectVisionMenu:SubMenu("Draws", "Draws  Settings")
PerfectVisionMenu.Draws:Boolean("draw", "Draw wards", true)
PerfectVisionMenu.Draws:Slider("qualityMultiplier", "Vision Quality", 3, 1, 5, 1, nil, true)

function PrintMessage(message) print("<font color=\"#339999\"><b>Artificial Warding (Alpha):</font> </b><font color=\"#DDDDDD\">" .. message) end

OnLoad(function()
	PrintMessage("Have fun, WhiteHat.")
end)

function GetDrawPoints(index) 
	i = 1
	wardVector = Vector(wards[index][1],wards[index][2],wards[index][3])
	alpha = 0
	while(i <= 36 * PerfectVisionMenu.Draws.qualityMultiplier:Value() ) do
		alpha = alpha + 360 / 36 / PerfectVisionMenu.Draws.qualityMultiplier:Value()
		wards[index][4+i] = {}
		a = 0.1
		wards[index][4 + i][1] = wardVector.x 
		wards[index][4 + i][2] = wardVector.y
		wards[index][4 + i][3] = wardVector.z + 110
		while (not MapPosition:inWall(Vector(wards[index][4 + i][1],wards[index][4 + i][2],wards[index][4 + i][3]))) and a < 0.9 do

			a = a + 0.025
			vc = Vector(1100 * math.sin(alpha / 360 * 6.28),0,1100 * math.cos(alpha / 360 * 6.28))
			vc:normalize()
			vc = vc * 1100 * a
			wards[index][4 + i][1] = wardVector.x + vc.x
			wards[index][4 + i][2] = wardVector.y
			wards[index][4 + i][3] = wardVector.z + vc.z
		end
		i = i + 1
	end
end

OnCreateObj(function (object) 
	if(PerfectVisionMenu.enabled:Value())then
		if object and(object.name:lower():find("visionward") or object.name:lower():find("sightward")) and object.networkID ~= 0 then
			if not GetTeam(object) == GetTeam(myHero) then
				i = 1
				while i < wardNumber do
					if(wards[i])then
						i = i+1
					else
						break;
					end
				end
				wards[i] = {}
				wards[i][1] = object.x
				wards[i][2] = object.y
				wards[i][3] = object.z
				wards[i][4] = object.networkID
				GetDrawPoints(i)
			end
		end
	end
end)


OnDeleteObj(function (object) 
	if(PerfectVisionMenu.enabled:Value())then
		if object and object.name and  (object.name:lower():find("visionward") or object.name:lower():find("sightward")) and object.networkID ~= 0 then	
			i = 1
			while i < wardNumber do
				if(wards[i]) then
					if(wards[i][4] == object.networkID) then
						wards[i] = nil
						return
					end
				end
				i = i +1
			end
		end
	end
end)

OnDraw(function() 
		aaa = 0
		num = 1
		if(PerfectVisionMenu.Draws.draw:Value() and PerfectVisionMenu.enabled:Value()) then
			while num < wardNumber do
				if(wards[num]) then
					aaa = aaa + 1
					ward = wards[num]
					i = 1
					DrawCircle(wards[num][1],wards[num][2],wards[num][3],50,2,500,ARGB(128,255,0,0))
					while(ward[4+i]) do
						if ward[5+i] then
							DrawLine3D(ward[4+i][1],ward[4+i][2],ward[4+i][3],ward[5+i][1],ward[5+i][2],ward[5+i][3],3,ARGB(128,255,30,30))
						else
							DrawLine3D(ward[4+i][1],ward[4+i][2],ward[4+i][3],ward[5][1],ward[5][2],ward[5][3],3,ARGB(128,255,30,30))
						end
						i = i + 1
					end
				end
				num = num + 1
			end
		end
end)