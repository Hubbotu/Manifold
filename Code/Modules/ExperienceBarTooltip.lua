local env = select(2, ...)
local L = env.L
local Config = env.Config
local GenericEnum = env.modules:Import("packages\\generic-enum")
local SavedVariables = env.modules:Import("packages\\saved-variables")
local CallbackRegistry = env.modules:Import("packages\\callback-registry")
local function IsModuleEnabled() return Config.DBGlobal:GetVariable("ExperienceBarTooltip") == true end

local COLOR_NORMAL = GenericEnum.ColorRGB01.NORMAL_FONT_COLOR
local COLOR_WHITE = GenericEnum.ColorRGB01.WHITE_FONT_COLOR
local time = time
local UnitXP = UnitXP
local BreakUpLargeNumbers = BreakUpLargeNumbers
local SecondsToTime = SecondsToTime


local StatUtil = CreateFrame("Frame")
StatUtil:RegisterEvent("PLAYER_ENTERING_WORLD")
StatUtil:RegisterEvent("PLAYER_LEVEL_UP")
StatUtil:RegisterEvent("PLAYER_XP_UPDATE")
StatUtil:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then --Session start time
        local isInitialLogin = ...
        if isInitialLogin then
            Config.DBGlobal:SetVariable("ExperienceBar_Session_StartTime", time())
            Config.DBGlobal:SetVariable("ExperienceBar_Session_LastXP", UnitXP("player"))
            Config.DBGlobal:SetVariable("ExperienceBar_Session_GainedXP", 0)
            Config.DBGlobal:SetVariable("ExperienceBar_Level_StartTime", time())
        end
    elseif event == "PLAYER_LEVEL_UP" then --Level start time
        Config.DBGlobal:SetVariable("ExperienceBar_Level_StartTime", time())
    elseif event == "PLAYER_XP_UPDATE" then
        local maxXP = UnitXPMax("player")
        local currentXP = UnitXP("player")
        local lastXP = Config.DBGlobal:GetVariable("ExperienceBar_Session_LastXP") or 0
        local gainedXP = Config.DBGlobal:GetVariable("ExperienceBar_Session_GainedXP") or 0
        local delta = currentXP - lastXP
        gainedXP = gainedXP + delta

        if gainedXP < 0 then
            gainedXP = maxXP - lastXP + currentXP
            Config.DBGlobal:SetVariable("ExperienceBar_Level_StartTime", time())
        end

        Config.DBGlobal:SetVariable("ExperienceBar_Session_LastXP", currentXP)
        Config.DBGlobal:SetVariable("ExperienceBar_Session_GainedXP", gainedXP)
    end
end)

function StatUtil:ComputeValues()
    local currentTime = time()
    local sessionStart = Config.DBGlobal:GetVariable("ExperienceBar_Session_StartTime") or 0
    local levelStart = Config.DBGlobal:GetVariable("ExperienceBar_Level_StartTime") or 0
    local gainedXP = Config.DBGlobal:GetVariable("ExperienceBar_Session_GainedXP") or 0

    self.sessionTimeElapsed = currentTime - sessionStart
    self.levelTimeElapsed = currentTime - levelStart

    local sessionTime = self.sessionTimeElapsed
    local hourlyXP = 0
    local timeToLevel = nil

    if sessionStart > 0 then
        local sessionTimeInHours = sessionTime / 3600

        if sessionTimeInHours > 0 and gainedXP > 0 then
            hourlyXP = math.ceil(gainedXP / sessionTimeInHours)

            local remainingXP = UnitXPMax("player") - UnitXP("player")
            timeToLevel = math.ceil((remainingXP / hourlyXP) * 3600)
        end
    end

    self.xpPerHour = hourlyXP
    self.timeUntilNextLevelInSeconds = timeToLevel
end

function StatUtil:UpdateTicker()
    if IsModuleEnabled() and not self.ticker then
        self:ComputeValues()
        self.ticker = C_Timer.NewTicker(0.5, function() self:ComputeValues() end)
    elseif not IsModuleEnabled() and self.ticker then
        self.ticker:Cancel()
        self.ticker = nil
    end
end


local MainStatusTrackingBarContainer
local ExperienceBar
local tooltipUpdater

local function RefreshTooltip()
    local exhaustionStateID, exhaustionStateName, exhaustionStateMultiplier = GetRestState()
    if not exhaustionStateID then return end
    if not MainStatusTrackingBarContainer or not ExperienceBar then return end

    local tooltip = GetAppropriateTooltip()
    GameTooltip:SetOwner(ExperienceBar, "ANCHOR_RIGHT")
    GameTooltip:ClearLines()

    --Level
    local level = UnitLevel("player")
    local maxLevel = GetMaxLevelForPlayerExpansion()
    GameTooltip:AddLine(string.format("Level: %s / %s", level, maxLevel), COLOR_NORMAL.r, COLOR_NORMAL.g, COLOR_NORMAL.b)

    --XP
    local xp = UnitXP("player")
    local xpToNextLevel = UnitXPMax("player")
    local xpPercentage = string.format("%0.1f", xp / xpToNextLevel * 100)
    GameTooltip:AddLine(string.format("%s / %s" .. GenericEnum.ColorHEX.GRAY_FONT_COLOR .. " (%s%%)|r", BreakUpLargeNumbers(xp), BreakUpLargeNumbers(xpToNextLevel), xpPercentage), COLOR_WHITE.r, COLOR_WHITE.g, COLOR_WHITE.b)

    --Stats
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(L["TOOLTIP_EXPERIENCE_BAR_STATISTICS"])

    local xpPerHour = StatUtil.xpPerHour > 0 and BreakUpLargeNumbers(StatUtil.xpPerHour) or "N/A"
    GameTooltip:AddLine(string.format(L["TOOLTIP_EXPERIENCE_BAR_EXPERIENCE_PER_HOUR"], xpPerHour), COLOR_WHITE.r, COLOR_WHITE.g, COLOR_WHITE.b)

    local isLastLevel = (GetMaxLevelForPlayerExpansion() - UnitLevel("player") == 1)
    local timeUntilLevel = StatUtil.timeUntilNextLevelInSeconds and SecondsToTime(StatUtil.timeUntilNextLevelInSeconds) or "N/A"
    GameTooltip:AddLine(isLastLevel and format(L["TOOLTIP_EXPERIENCE_BAR_UNTIL_MAX_LEVEL"], timeUntilLevel) or format(L["TOOLTIP_EXPERIENCE_BAR_UNTIL_NEXT_LEVEL"], timeUntilLevel), COLOR_WHITE.r, COLOR_WHITE.g, COLOR_WHITE.b)

    --Rested xp
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(EXHAUST_TOOLTIP1:format(exhaustionStateName, exhaustionStateMultiplier * 100))

    if not IsResting() and (exhaustionStateID == 4 or exhaustionStateID == 5) then
        GameTooltip:AddLine(EXHAUST_TOOLTIP2, COLOR_WHITE.r, COLOR_WHITE.g, COLOR_WHITE.b)
    end

    if GameLimitedMode_IsBankedXPActive() then
        local bankedLevels = UnitTrialBankedLevels("player")
        local bankedXP = UnitTrialXP("player")

        if bankedLevels > 0 or bankedXP > 0 then
            GameTooltip_AddBlankLineToTooltip(tooltip)
            GameTooltip_AddNormalLine(tooltip, XP_TEXT_BANKED_XP_HEADER)
        end

        if bankedLevels > 0 then
            GameTooltip_AddHighlightLine(tooltip, TRIAL_CAP_BANKED_LEVELS_TOOLTIP:format(bankedLevels))
        elseif bankedXP > 0 then
            GameTooltip_AddHighlightLine(tooltip, TRIAL_CAP_BANKED_XP_TOOLTIP)
        end
    end

    GameTooltip:Show()
end

local function ShowTooltip()
    if not tooltipUpdater then
        RefreshTooltip()
        tooltipUpdater = C_Timer.NewTicker(0.5, RefreshTooltip)
    end
end

GameTooltip:HookScript("OnHide", function()
    if tooltipUpdater then
        tooltipUpdater:Cancel()
        tooltipUpdater = nil
    end
end)

CallbackRegistry.Add("Preload.AddonReady", function()
    StatUtil:UpdateTicker()

    MainStatusTrackingBarContainer = StatusTrackingBarManager and StatusTrackingBarManager.MainStatusTrackingBarContainer
    ExperienceBar = MainStatusTrackingBarContainer.bars and MainStatusTrackingBarContainer.bars[StatusTrackingBarInfo.BarsEnum.Experience]
    local Method_ExhaustionTooltTipText = ExperienceBar.ExhaustionTick.ExhaustionToolTipText

    ExperienceBar.ExhaustionTick.ExhaustionToolTipText = function(...)
        if not IsModuleEnabled() then
            Method_ExhaustionTooltTipText(...)
            return
        end
        ShowTooltip()
    end

end)
SavedVariables.OnChange("ManifoldDB_Global", "ExperienceBarTooltip", function() StatUtil:UpdateTicker() end)
