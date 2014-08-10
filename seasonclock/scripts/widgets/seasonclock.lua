local Widget = require "widgets/widget"
local Image = require "widgets/image"
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"

-- We need to check if this is enabled, the vanilla season manager doesn't have the necessary methods and causes the loading of a 
-- saved game to hang. 
local reignOfGiantsEnabled = false
local isFocused = false

local SeasonClock = Class(Widget, function(self)
	Widget._ctor(self, "SeasonClock")

	print ("SEASON CLOCK::CHECKING DLC")

	reignOfGiantsEnabled = IsDLCEnabled(REIGN_OF_GIANTS)

	-- Colors for the segments for the different seasons
	self.SUMMER_COLOR = Vector3(255/255,215/255,86/255)
	self.AUTUMN_COLOR = Vector3(255/255,99/255,71/255)
	self.WINTER_COLOR = Vector3(152/255,245/255,255/255)
	self.SPRING_COLOR = Vector3(50/255,198/255,166/255)
	self.DARKEN_PERCENT = .90	


	local totalDaysInYear, summerLength, autumnLength, winterLength, springLength = self:GetSeasonSegments()

	-- Setup Scaling
    self.base_scale = 1
    self:SetScale(self.base_scale,self.base_scale,self.base_scale)

	-- Setup the clock animations (FIXME: May not be needed for the season clock. Need to re-evaluate later.)
	self.anim = self:AddChild(UIAnim())
    local sc = 1
    self.anim:SetScale(sc,sc,sc)
    self.anim:GetAnimState():SetBank("clock01")
    self.anim:GetAnimState():SetBuild("clock_transitions")
    self.anim:GetAnimState():PlayAnimation("idle_day",true)


    print ("SEASON CLOCK::CALCULATING SEGMENTS")
    -- Determine the sized circle segment we need (360 / number of days in a year). We use the circle generated circle segments and place them around the face of the clock in a circle.
    self.segs = {}
	local segscale = .3
    local numsegs = totalDaysInYear
    local segmentDegree = math.floor(360/totalDaysInYear)
    print ("SEGMENT DEGREE: "..tostring(segmentDegree))
    for i = 1, numsegs do
		local seg = self:AddChild(Image("images/circlesegment_"..segmentDegree..".xml", "circlesegment_"..segmentDegree..".tex"))
        seg:SetScale(segscale,segscale,segscale)
        seg:SetHRegPoint(ANCHOR_LEFT)
        seg:SetVRegPoint(ANCHOR_BOTTOM)
        seg:SetRotation((i-1)*(360/numsegs))
        seg:SetClickable(false)
        table.insert(self.segs, seg)
    end

    print ("SEASON CLOCK::DONE CALCULATING SEGMENTS")

    print ("SEASON CLOCK::SETTING CLOCK HANDS etc")
    -- Clock rims, hands, and text
    self.rim = self:AddChild(Image("images/hud.xml", "clock_rim.tex"))
    self.hands = self:AddChild(Image("images/hud.xml", "clock_hand.tex"))
    self.text = self:AddChild(Text(BODYTEXTFONT, 33/self.base_scale))
    self.text:SetPosition(5, 0/self.base_scale, 0)
    self.rim:SetClickable(false)
    self.hands:SetClickable(false)

    print ("SEASON CLOCK::DONE SETTING CLOCK HANDS")

    -- Listen for day complete to update the hand positiion
    self.inst:ListenForEvent( "daycomplete", function(inst, data) self:SetClockHand() end, GetWorld())
    self.inst:ListenForEvent( "daycomplete", function(inst, data) self:UpdateSeasonString() end, GetWorld())

    print ("SEASON CLOCK::SETTING EVENT LISTENERS HANDS")

	-- Register as a listener for the daycomplete event. Update season info string when this happens.
	self.inst:ListenForEvent( "seasonChange", function() self:UpdateSeasonString() end, GetWorld())
	print ("SEASON CLOCK::DONE SETTING EVENT LISTENERS HANDS")

	self:CalcSegs()
	self:UpdateSeasonString()
	self:SetClockHand()
	self:Show()
end)

-- Sets the clock hand to the proper rotation based on the current day into the "year"
function SeasonClock:SetClockHand()
	print ("SEASON CLOCK::SETTOMG CLOCK HAND POSITIONS")
	local seasonManager = GetSeasonManager()
	local totalDaysInYear, summerLength, autumnLength, winterLength, springLength = self:GetSeasonSegments()
	print("TotalDaysInYear: "..tostring(totalDaysInYear).."SummerLength: "..tostring(summerLength)..". AutumnLength: "..autumnLength..". WinterLength: "..winterLength..". SpringLength: "..springLength)
	local daysIntoSeason = seasonManager:GetDaysIntoSeason()
	daysIntoSeason = self:RoundNumber(daysIntoSeason)
	local currentSeason = seasonManager:GetSeasonString()
	local daysIntoYear = 0

	print ("SEASON CLOCK::SETTOMG CLOCK HAND POSITIONS 1")

	if daysIntoSeason == 0 then
		daysIntoSeason = daysIntoSeason
	end

	print ("SEASON CLOCK::SETTOMG CLOCK HAND POSITIONS 2")
	if currentSeason == "summer" then
		daysIntoYear = daysIntoSeason  -- Since the clock starts at summer, probably a better more extensible way to do this later.
		print ("SEASON CLOCK::SETTOMG CLOCK HAND POSITIONS 3")
	elseif currentSeason == "autumn" then
		daysIntoYear = summerLength + daysIntoSeason
		print ("SEASON CLOCK::SETTOMG CLOCK HAND POSITIONS 4")
	elseif currentSeason == "winter" then
		daysIntoYear = summerLength + autumnLength + daysIntoSeason
		print ("SEASON CLOCK::SETTOMG CLOCK HAND POSITIONS 5")
	elseif currentSeason == "spring" then
		daysIntoYear = summerLength + autumnLength + winterLength + daysIntoSeason
		print ("SEASON CLOCK::SETTOMG CLOCK HAND POSITIONS 6")
	end

	print ("SEASON CLOCK::SETTOMG CLOCK HAND POSITIONS 7")
	local rotation = daysIntoYear * (360/totalDaysInYear)
	print ("SEASON CLOCK::SETTOMG CLOCK HAND POSITIONS 8")

	self.hands:SetRotation(rotation)

	print ("SEASON CLOCK::DONE SETTOMG CLOCK HAND POSITIONS")
end

-- Determines what string to update depending on whether or not the user is currently focused (ie: in the case the user is hovering on the clock and the day complete event fires)
function SeasonClock:UpdateSeasonString()
	print ("SEASON CLOCK::UPDATING SEASON STRING")
	if isFocused then
		self:UpdateNextSeasonString()
	else
		self:UpdateSeasonNameString()
	end
	print ("SEASON CLOCK::DONE UPDATING SEASON STRING")
end

function SeasonClock:UpdateSeasonNameString()
	local currentSeason = self:GetPrettySeasonName()
	self.text:SetString(currentSeason)
	self.text:SetSize(33/self.base_scale)
end

function SeasonClock:UpdateNextSeasonString()
	SeasonClock._base.OnGainFocus(self)
	local clock_str = self:GenerateCurrentSeasonClockString()
	self.text:SetString(clock_str)
	self.text:SetSize(21/self.base_scale)
end

-- Get the total number of segments...multireturn:
-- total days of all enabled seasons, days in summer, days in autumn, days in winter, days in spring.
function SeasonClock:GetSeasonSegments()
	local seasonManager = GetSeasonManager()
	local summerLength = 0
	local autumnLength = 0
	local winterLength = 0
	local springLength = 0
	local totalDaysInYear = 0

	if(reignOfGiantsEnabled) then
		summerLength = seasonManager.summerenabled and seasonManager:GetSeasonLength(SEASONS.SUMMER) or 0
		autumnLength = seasonManager.autumnenabled and seasonManager:GetSeasonLength(SEASONS.AUTUMN) or 0
		winterLength = seasonManager.winterenabled and seasonManager:GetSeasonLength(SEASONS.WINTER) or 0
		springLength = seasonManager.springenabled and seasonManager:GetSeasonLength(SEASONS.SPRING) or 0
	else
		if(seasonManager.seasonmode == "endlesssummer") then
			summerLength = seasonManager.summerlength
		elseif(seasonManager.seasonmode == "endlesswinter") then
			winterLength = seasonManager.winterlength
		else
			summerLength = seasonManager.summerlength
			winterLength = seasonManager.winterlength
		end
	end

	totalDaysInYear = summerLength + autumnLength + winterLength + springLength
	return totalDaysInYear, summerLength, autumnLength, winterLength, springLength
end

local firstSummer, firstAutumn, firstWinter, firstSpring = true, true, true, true

-- Sets the colors of all segments in the clock.
function SeasonClock:CalcSegs()
	print ("SEASON CLOCK::CALCULATING SEGMENTS")
    local dark = false

    local totalDaysInYear, summerLength, autumnLength, winterLength, springLength = self:GetSeasonSegments()

    for k,seg in pairs(self.segs) do
        local color = nil
        seg:Show()
        
        if k >= 0 and k <= summerLength then
        	color = self.SUMMER_COLOR
        elseif k > summerLength and k <= (summerLength + autumnLength) then
        	color = self.AUTUMN_COLOR
        elseif k > (summerLength + autumnLength) and k <= (summerLength + autumnLength + winterLength) then
        	color = self.WINTER_COLOR
        elseif k > (summerLength + autumnLength + winterLength) and k <= (summerLength + autumnLength + winterLength + springLength) then
        	color = self.SPRING_COLOR
        end

        if dark then
			color = color * self.DARKEN_PERCENT
		end

		seg:SetTint(color.x, color.y, color.z, 1)
		dark = not dark
    end
    print ("SEASON CLOCK::DONE CALCULATING SEGMENTS")
end

-- Gets the properly cased string representation of the current season.
-- Season param should be the season string.
function SeasonClock:GetPrettySeasonName(season)
	local seasonManager = GetSeasonManager()
	local prettyName = "ERROR"
	local seasonToCheck

	if season then
		seasonToCheck = season
	else
		seasonToCheck = seasonManager:GetSeasonString()
	end

	if seasonToCheck == "summer" then
		prettyName = STRINGS.UI.SANDBOXMENU.SUMMER
	elseif seasonToCheck == "autumn" then
		prettyName = STRINGS.UI.SANDBOXMENU.AUTUMN
	elseif seasonToCheck == "winter" then
		prettyName = STRINGS.UI.SANDBOXMENU.WINTER
	elseif seasonToCheck == "spring" then
		prettyName = STRINGS.UI.SANDBOXMENU.SPRING
	end

	return prettyName
end

-- Retrieves the season string we display on hover
function SeasonClock:GenerateCurrentSeasonClockString()
		local seasonManager = GetSeasonManager()
		local daysIn = seasonManager:GetDaysIntoSeason()
		local currentSeason = self:GetPrettySeasonName()
		local nextSeason = self:GetNextSeason()

		-- We have to potentially round the days remaining and days in. Otherwise we sometimes get values like 0.99999 or 1.88888787e-15
		local daysLeft = seasonManager:GetDaysLeftInSeason()
		daysLeft = self:RoundNumber(daysLeft)
		daysIn = self:RoundNumber(daysIn)

	return string.format("%s days into %s.\r%s days left until %s.", daysIn, currentSeason, daysLeft, self:GetNextSeason())
end

-- If the fractional part of the value is less than 0.5 we return the floor of the value, otherwise we return the ceiling of the value.
function SeasonClock:RoundNumber(value)
	local integral, fractional = math.modf(value)
	
	if(fractional < 0.5) then
		value = math.floor(value)
	else
		value = math.ceil(value)
	end
	
	return value
end

function SeasonClock:OnGainFocus()
	isFocused = true
	self:UpdateSeasonString()
	return true
end

function SeasonClock:OnLoseFocus()
	isFocused = false
	self:UpdateSeasonString()
	return true
end

function SeasonClock:GetNextSeason()
	local seasonManager = GetSeasonManager()
	local currentSeason = seasonManager:GetSeason()
	local nextSeason = "ERROR"

	-- Vanilla Game
	if(not reignOfGiantsEnabled) then 
		if(seasonManager.seasonmode == "endlesssummer") then
			nextSeason = SEASONS.SUMMER
		elseif(seasonManager.seasonmode == "endlesswinter") then
			nextSeason = SEASONS.WINTER
		elseif(seasonManager.seasonmode == "cycle" and seasonManager:IsSummer()) then
			nextSeason = SEASONS.WINTER
		elseif(seasonManager.seasonmode == "cycle" and seasonManager:IsWinter()) then
			nextSeason = SEASONS.SUMMER
		end
	-- Reign of Giants
	else
		if(seasonManager.seasonmode == "endlesssummer") then
			nextSeason = SEASONS.SUMMER
		elseif(seasonManager.seasonmode == "endlesswinter") then
			nextSeason = SEASONS.WINTER
		elseif(seasonManager.seasonmode == "endlessautumn") then
			nextSeason = SEASONS.AUTUMN
		elseif(seasonManager.seasonmode == "endlesswinter") then
			nextSeason = SEASONS.WINTER
		else
			-- Cycle mode, we need to determine what seasons are enabled to properly do this.
			local nextSeasonFound = false;
			local nextSeasons = { [SEASONS.SPRING] = SEASONS.SUMMER, [SEASONS.SUMMER] = SEASONS.AUTUMN, [SEASONS.AUTUMN] = SEASONS.WINTER, [SEASONS.WINTER] = SEASONS.SPRING }
			nextSeason = nextSeasons[currentSeason]

			-- Loop thru the next seasons until we find the next one that is enabled.
			while(not nextSeasonFound) do
				if(seasonManager:GetSeasonIsEnabled(nextSeason)) then
					nextSeasonFound = true
				else
					nextSeason = nextSeasons[nextSeason]
				end
			end
		end
	end
	
	return self:GetPrettySeasonName(nextSeason)
end

return SeasonClock