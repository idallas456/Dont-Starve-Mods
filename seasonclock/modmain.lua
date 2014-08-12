-- V1.0 Release version

-- Created by Soilworker
--------------------------------------------------------------------------------------------

Assets = {
	Asset("ATLAS", "images/circlesegment_2.xml"),
	Asset("ATLAS", "images/circlesegment_3.xml"),
	Asset("ATLAS", "images/circlesegment_4.xml"),
	Asset("ATLAS", "images/circlesegment_5.xml"),
	Asset("ATLAS", "images/circlesegment_6.xml"),
	Asset("ATLAS", "images/circlesegment_7.xml"),
	Asset("ATLAS", "images/circlesegment_8.xml"),
	Asset("ATLAS", "images/circlesegment_9.xml"),
	Asset("ATLAS", "images/circlesegment_10.xml"),
	Asset("ATLAS", "images/circlesegment_11.xml"),
	Asset("ATLAS", "images/circlesegment_12.xml"),
	Asset("ATLAS", "images/circlesegment_13.xml"),
	Asset("ATLAS", "images/circlesegment_14.xml"),
	Asset("ATLAS", "images/circlesegment_16.xml"),
	Asset("ATLAS", "images/circlesegment_18.xml"),
	Asset("ATLAS", "images/circlesegment_21.xml"),
	Asset("ATLAS", "images/circlesegment_24.xml"),
	Asset("ATLAS", "images/circlesegment_30.xml"),
	Asset("ATLAS", "images/circlesegment_36.xml"),
	Asset("ATLAS", "images/circlesegment_45.xml"),
	Asset("ATLAS", "images/circlesegment_72.xml"),
}

local SeasonClock = GLOBAL.require("widgets/seasonclock")

function AddSeasonClock( inst )
	local controls = inst.HUD.controls
	local seasonClock = SeasonClock(GetModConfigData("autumn_color"), GetModConfigData("winter_color"), GetModConfigData("spring_color"), GetModConfigData("summer_color"), GetModConfigData("hovertextoption"), GetModConfigData("hoverfontsize"), GetModConfigData("seasonfontsize"), GetModConfigData("texttodisplay"))

	controls.status:AddChild(seasonClock)
	seasonClock:SetPosition(0, -20, 0)

	-- Shift the other widgets down so ours fits nicely
	yShiftAmount = -140
	
	if GLOBAL.GetWorld() and GLOBAL.GetWorld():IsCave() and not GetModConfigData("showincave") then
		seasonClock:SetPosition(0, -20, 0)
		seasonClock:Hide()
    else
		heartCurrentPosition = controls.status.heart:GetPosition()
		stomachCurrentPosition = controls.status.stomach:GetPosition()
		brainCurrentPosition = controls.status.brain:GetPosition()

		-- Move the Sanity, Hunger, and Health icons down
		controls.status.brain:SetPosition(brainCurrentPosition.x, brainCurrentPosition.y + yShiftAmount, 0);
		controls.status.stomach:SetPosition(stomachCurrentPosition.x, stomachCurrentPosition.y + yShiftAmount, 0);
		controls.status.heart:SetPosition(heartCurrentPosition.x, heartCurrentPosition.y + yShiftAmount, 0);

		-- Shift moisture meter
		if GLOBAL.IsDLCEnabled(GLOBAL.REIGN_OF_GIANTS) then
			moistureCurrentPosition = controls.status.moisturemeter:GetPosition()
			controls.status.moisturemeter:SetPosition(moistureCurrentPosition.x, moistureCurrentPosition.y + yShiftAmount, 0);
		end

		-- Accomodate for the "Always On Status" mod.
		for _, moddir in ipairs(GLOBAL.KnownModIndex:GetModsToLoad()) do
		    if GLOBAL.KnownModIndex:GetModInfo(moddir).name == "Always On Status" then
		    	naughtyCurrentPosition = controls.status.naughty:GetPosition()
				controls.status.naughty:SetPosition(naughtyCurrentPosition.x, naughtyCurrentPosition.y + yShiftAmount, 0);

				temperatureCurrentPosition = controls.status.temperature:GetPosition()
				controls.status.temperature:SetPosition(temperatureCurrentPosition.x, temperatureCurrentPosition.y + yShiftAmount, 0);
		    end
		end
	end

end
 
--
AddSimPostInit(AddSeasonClock)