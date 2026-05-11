local env = select(2, ...)
local Config = env.Config
local CallbackRegistry = env.modules:Import("packages\\callback-registry")
local GenericEnum = env.modules:Import("packages\\generic-enum")
local function IsModuleEnabled() return Config.DBGlobal:GetVariable("QuestDetailTooltip") == true end

local COLOR_NORMAL = GenericEnum.ColorRGB01.NORMAL_FONT_COLOR
local COLOR_WHITE = GenericEnum.ColorRGB01.WHITE_FONT_COLOR
local COLOR_GRAY = GenericEnum.ColorRGB01.GRAY_FONT_COLOR
local COLOR_RED = GenericEnum.ColorRGB01.RED_FONT_COLOR

local EMPTY_TABLE = {}
local BLOCK_TYPE_HEADER = 0
local BLOCK_TYPE_MAP_BUTTON = 1
local LOOT_TYPE_ITEM = 0
local LOOT_TYPE_CURRENCY = 1
local RETRIEVING_DATA_TEXT = RETRIEVING_DATA
local EXPERIENCE_TEXT = EXPERIENCE_COLON

local SPELL_BUCKET_ORDER = {
    Enum.QuestCompleteSpellType.Follower, Enum.QuestCompleteSpellType.Companion,
    Enum.QuestCompleteSpellType.Tradeskill,
    Enum.QuestCompleteSpellType.Ability,
    Enum.QuestCompleteSpellType.Aura,
    Enum.QuestCompleteSpellType.Spell,
    Enum.QuestCompleteSpellType.Unlock,
    Enum.QuestCompleteSpellType.QuestlineUnlock,
    Enum.QuestCompleteSpellType.QuestlineReward,
    Enum.QuestCompleteSpellType.QuestlineUnlockPart,
    Enum.QuestCompleteSpellType.PossibleReward
}

local SPELL_BUCKET_HEADERS = {
    [Enum.QuestCompleteSpellType.Follower]            = REWARD_FOLLOWER,
    [Enum.QuestCompleteSpellType.Companion]           = REWARD_COMPANION,
    [Enum.QuestCompleteSpellType.Tradeskill]          = REWARD_TRADESKILL_SPELL,
    [Enum.QuestCompleteSpellType.Ability]             = REWARD_ABILITY,
    [Enum.QuestCompleteSpellType.Aura]                = REWARD_AURA,
    [Enum.QuestCompleteSpellType.Spell]               = REWARD_SPELL,
    [Enum.QuestCompleteSpellType.Unlock]              = REWARD_UNLOCK,
    [Enum.QuestCompleteSpellType.QuestlineUnlock]     = REWARD_QUESTLINE_UNLOCK,
    [Enum.QuestCompleteSpellType.QuestlineReward]     = REWARD_QUESTLINE_REWARD,
    [Enum.QuestCompleteSpellType.QuestlineUnlockPart] = REWARD_QUESTLINE_UNLOCK_PART,
    [Enum.QuestCompleteSpellType.PossibleReward]      = REWARD_POSSIBLE_QUEST_REWARD
}

local spellBuckets = {}

local SessionData = {
    active    = false,
    awaitData = false,
    blockType = nil,
    block     = nil,
    questID   = nil
}

local function IsSessionActive()
    return SessionData.active == true
end

local function SetSession(blockType, block, questID)
    SessionData.active = true
    SessionData.awaitData = false
    SessionData.blockType, SessionData.block, SessionData.questID = blockType, block, questID
end

local function ClearSession()
    SessionData.active = false
    SessionData.awaitData = false
    SessionData.blockType = nil
    SessionData.block = nil
    SessionData.questID = nil
end

local function IsAwaitData()
    return SessionData.awaitData == true
end

local function UpdateAwaitData()
    if HaveQuestData(SessionData.questID) and HaveQuestRewardData(SessionData.questID) then
        SessionData.awaitData = false
    else
        SessionData.awaitData = true
    end
end

local function FormatRewardLine(iconTexture, displayName, stackCount)
    local iconPart = iconTexture and ("|T%s:16:16:0:0:64:64|t "):format(iconTexture) or ""
    local countPart = (stackCount and stackCount > 1) and (stackCount .. " ") or ""
    return iconPart .. countPart .. (displayName or "")
end

local function AddColoredLine(text, color)
    GameTooltip:AddLine(text, color.r, color.g, color.b, true)
end

local function AddQualityLine(text, quality)
    local r, g, b = GetItemQualityColor(quality or 1)
    GameTooltip:AddLine(text, r, g, b)
end



local RewardUtil = {}

do
    function RewardUtil.GetQuestXPPercentText(rewardXP)
        if not rewardXP or rewardXP <= 0 then return "" end
        local xpMax = UnitXPMax("player")
        if not xpMax or xpMax <= 0 then return "" end
        local percent = (rewardXP / xpMax) * 100
        if percent <= 0 then return "" end
        return " (" .. format("%0.0f", percent) .. "%)"
    end

    function RewardUtil.GetSpellBucketType(spellRewardInfo)
        if spellRewardInfo.type and spellRewardInfo.type ~= Enum.QuestCompleteSpellType.LegacyBehavior then
            return spellRewardInfo.type
        elseif spellRewardInfo.isTradeskillSpell then
            return Enum.QuestCompleteSpellType.Tradeskill
        elseif spellRewardInfo.isBoostSpell then
            return Enum.QuestCompleteSpellType.Ability
        elseif spellRewardInfo.garrFollowerID then
            local followerData = C_Garrison.GetFollowerInfo(spellRewardInfo.garrFollowerID)
            if followerData and followerData.followerTypeID == Enum.GarrisonFollowerType.FollowerType_9_0_GarrisonFollower then
                return Enum.QuestCompleteSpellType.Companion
            end
            return Enum.QuestCompleteSpellType.Follower
        elseif spellRewardInfo.isSpellLearned then
            return Enum.QuestCompleteSpellType.Spell
        elseif spellRewardInfo.genericUnlock then
            return Enum.QuestCompleteSpellType.Unlock
        end
        return Enum.QuestCompleteSpellType.Aura
    end

    function RewardUtil.CollectSpellRewardsIntoBuckets(questID, buckets)
        local rewardSpellIDs = C_QuestInfoSystem.GetQuestRewardSpells(questID)
        if not rewardSpellIDs then return false end

        local hasValidRewards = false
        for _, spellID in ipairs(rewardSpellIDs) do
            if spellID and spellID > 0 then
                local spellRewardInfo = C_QuestInfoSystem.GetQuestRewardSpellInfo(questID, spellID)
                local alreadyKnown = C_SpellBook.IsSpellInSpellBook(spellID, Enum.SpellBookSpellBank.Player, true)
                local isValidReward = spellRewardInfo and spellRewardInfo.texture and not alreadyKnown
                    and (not spellRewardInfo.isBoostSpell or IsCharacterNewlyBoosted())
                    and (not spellRewardInfo.garrFollowerID or not C_Garrison.IsFollowerCollected(spellRewardInfo.garrFollowerID))

                if isValidReward then
                    spellRewardInfo.spellID = spellID
                    local bucketType = RewardUtil.GetSpellBucketType(spellRewardInfo)
                    buckets[bucketType] = buckets[bucketType] or {}
                    buckets[bucketType][#buckets[bucketType] + 1] = spellRewardInfo
                    hasValidRewards = true
                end
            end
        end
        return hasValidRewards
    end

    function RewardUtil.AppendSpellRewards(buckets)
        for _, bucketType in ipairs(SPELL_BUCKET_ORDER) do
            local bucket = buckets[bucketType]
            if bucket then
                local headerText = SPELL_BUCKET_HEADERS[bucketType]
                if headerText and not bucket[1].hideSpellLearnText then
                    GameTooltip:AddLine(" ")
                    AddColoredLine(headerText, COLOR_NORMAL)
                end
                for _, spellRewardInfo in ipairs(bucket) do
                    AddColoredLine(FormatRewardLine(spellRewardInfo.texture, spellRewardInfo.name), COLOR_WHITE)
                end
            end
        end
    end

    function RewardUtil.AppendChoiceRewards(questID, choiceCount)
        if choiceCount <= 0 then return end

        GameTooltip:AddLine(" ")
        AddColoredLine(choiceCount == 1 and REWARD_ITEMS_ONLY or REWARD_CHOICES, COLOR_NORMAL)

        for i = 1, choiceCount do
            local lootType = GetQuestLogChoiceInfoLootType(i, questID)
            if lootType == LOOT_TYPE_ITEM then
                local itemName, itemTexture, itemCount, itemQuality = GetQuestLogChoiceInfo(i, questID)
                if itemName then AddQualityLine(FormatRewardLine(itemTexture, itemName, itemCount), itemQuality) end
            elseif lootType == LOOT_TYPE_CURRENCY then
                local currencyData = C_QuestLog.GetQuestRewardCurrencyInfo(questID, i, true)
                if currencyData then AddQualityLine(FormatRewardLine(currencyData.texture, currencyData.name, currencyData.totalRewardAmount), currencyData.quality) end
            end
        end
    end

    function RewardUtil.AppendFixedRewards(questID, choiceCount, hasSpellRewards, hasTitle)
        if not questID then return end

        local rewardXP = GetQuestLogRewardXP(questID)
        local rewardMoney = GetQuestLogRewardMoney(questID)
        local rewardHonor = GetQuestLogRewardHonor(questID)
        local itemRewardCount = GetNumQuestLogRewards(questID)
        local currencyRewardList = C_QuestInfoSystem.GetQuestRewardCurrencies(questID) or {}
        local factionRepRewards = C_QuestLog.GetQuestLogMajorFactionReputationRewards(questID)
        local warModeActive = C_QuestLog.QuestHasWarModeBonus(questID) and C_PvP.IsWarModeDesired()
        local skillName, skillIcon, skillPointReward = GetQuestLogRewardSkillPoints()
        local hasAnyReward = (rewardXP and rewardXP > 0) or (rewardMoney and rewardMoney > 0) or (rewardHonor and rewardHonor > 0) or (itemRewardCount and itemRewardCount > 0) or #currencyRewardList > 0 or factionRepRewards or warModeActive or skillPointReward
        if not hasAnyReward then return end

        -- Title
        GameTooltip:AddLine(" ")
        AddColoredLine((choiceCount > 0 or hasSpellRewards or hasTitle) and REWARD_ITEMS or REWARD_ITEMS_ONLY, COLOR_NORMAL)

        -- General
        if rewardXP and rewardXP > 0 then
            AddColoredLine(EXPERIENCE_TEXT .. " " .. BreakUpLargeNumbers(rewardXP) .. GenericEnum.ColorHEX.GRAY_FONT_COLOR .. RewardUtil.GetQuestXPPercentText(rewardXP) .. "|r", COLOR_WHITE)
        end
        if rewardMoney and rewardMoney > 0 then AddColoredLine(GetCoinTextureString(rewardMoney), COLOR_WHITE) end
        if rewardHonor and rewardHonor > 0 then
            local honorTexture = (UnitFactionGroup("player") == PLAYER_FACTION_GROUP[0]) and "Interface\\Icons\\PVPCurrency-Honor-Horde" or "Interface\\Icons\\PVPCurrency-Honor-Alliance"
            AddColoredLine(FormatRewardLine(honorTexture, HONOR, rewardHonor), COLOR_WHITE)
        end

        -- Skill Points
        if skillPointReward and skillName then AddColoredLine(FormatRewardLine(skillIcon, format(BONUS_SKILLPOINTS, skillName), skillPointReward), COLOR_WHITE) end

        -- Items
        for i = 1, itemRewardCount do
            local itemName, itemTexture, itemCount, itemQuality = GetQuestLogRewardInfo(i, questID)
            if itemName then
                AddQualityLine(FormatRewardLine(itemTexture, itemName, itemCount), itemQuality)
            end
        end

        -- Currency
        for _, currencyData in ipairs(currencyRewardList) do
            local displayName, displayTexture, displayAmount, displayQuality = CurrencyContainerUtil.GetCurrencyContainerInfo(currencyData.currencyID, currencyData.totalRewardAmount, currencyData.name, currencyData.texture, currencyData.quality)
            AddQualityLine(FormatRewardLine(displayTexture, displayName, displayAmount), displayQuality)
        end

        -- Major Faction Reputation
        if factionRepRewards then
            for _, repReward in ipairs(factionRepRewards) do
                local factionData = C_MajorFactions.GetMajorFactionData(repReward.factionID)
                if factionData then
                    local factionIcon = ("Interface\\Icons\\UI_MajorFaction_%s"):format(factionData.textureKit)
                    local repText = QUEST_REPUTATION_REWARD_TITLE:format(factionData.name) .. " (+" .. AbbreviateNumbers(repReward.rewardAmount) .. ")"
                    AddColoredLine(FormatRewardLine(factionIcon, repText), COLOR_WHITE)
                end
            end
        end
    end

    function RewardUtil.AppendTitleReward(questID)
        local titleReward = GetQuestLogRewardTitle(questID)
        if not titleReward then return nil end

        GameTooltip:AddLine(" ")
        AddColoredLine(REWARD_TITLE, COLOR_NORMAL)
        AddColoredLine(titleReward, COLOR_WHITE)

        return titleReward
    end


    local OBJECTIVE_PREFIX = "|cff7f7f7f" .. "- " .. "|r"

    function RewardUtil.AppendPartyProgress(questID)
        if IsInGroup() then
            local partyProgressData = C_TooltipInfo.GetQuestPartyProgress(questID)
            if partyProgressData and partyProgressData.lines and #partyProgressData.lines > 0 then
                GameTooltip:AddLine(" ")
                if PARTY_QUEST_STATUS_ON then GameTooltip:AddLine(PARTY_QUEST_STATUS_ON) end

                for _, line in ipairs(partyProgressData.lines) do
                    if line.type == Enum.TooltipDataLineType.QuestPlayer then
                        GameTooltip:AddLine(line.leftText, line.leftColor, line.wrapText)
                    elseif line.type == Enum.TooltipDataLineType.QuestObjective then
                        GameTooltip:AddLine(OBJECTIVE_PREFIX .. line.leftText, 1, 1, 1, line.wrapText)
                    end
                end
            end
        end
    end
end

local function DisplayQuestTooltip(blockType, block, questID)
    GameTooltip:ClearAllPoints()
    if blockType == BLOCK_TYPE_HEADER then
        GameTooltip:SetPoint("TOPRIGHT", block.poiButton, "TOPLEFT", -8, 8)
    else
        GameTooltip:SetPoint("TOPLEFT", block, "TOPRIGHT", 8, 0)
    end
    GameTooltip:SetOwner(block, "ANCHOR_PRESERVE")


    -- Title
    AddColoredLine(C_QuestLog.GetTitleForQuestID(questID), COLOR_NORMAL)
    QuestUtil.SetQuestLegendToTooltip(questID, GameTooltip)


    -- Objectives
    local questLogIndex = C_QuestLog.GetLogIndexForQuestID(questID)
    local _, objectiveDescription = GetQuestLogQuestText(questLogIndex)
    local objectiveList = C_QuestLog.GetQuestObjectives(questID)
    local hasObjectives = objectiveList and #objectiveList > 0
    if hasObjectives or objectiveDescription then
        GameTooltip:AddLine(" ")
        if objectiveDescription then
            GameTooltip:AddLine(objectiveDescription, 1, 1, 1, true)
            if hasObjectives then GameTooltip:AddLine(" ") end
        end
        for _, objective in ipairs(objectiveList or EMPTY_TABLE) do
            AddColoredLine("- " .. objective.text, objective.finished and COLOR_GRAY or COLOR_WHITE)
        end
    end


    -- Rewards
    if IsAwaitData() then
        GameTooltip:AddLine(" ")
        AddColoredLine(RETRIEVING_DATA_TEXT, COLOR_RED)
    else
        if C_QuestLog.ShouldShowQuestRewards(questID) then
            for k in pairs(spellBuckets) do
                spellBuckets[k] = nil
            end

            local hasSpellRewards = RewardUtil.CollectSpellRewardsIntoBuckets(questID, spellBuckets)
            local choiceCount = GetNumQuestLogChoices(questID, true)
            local hasTitle = RewardUtil.AppendTitleReward(questID)

            if hasSpellRewards then RewardUtil.AppendSpellRewards(spellBuckets) end
            RewardUtil.AppendChoiceRewards(questID, choiceCount)
            RewardUtil.AppendFixedRewards(questID, choiceCount, hasSpellRewards, hasTitle)
        end
    end


    -- Nearby party members that are on this quest
    RewardUtil.AppendPartyProgress(questID)


    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(CLICK_QUEST_DETAILS, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
    GameTooltip:Show()
end

local function RefreshActiveTooltip()
    if not IsSessionActive() then return end
    DisplayQuestTooltip(SessionData.blockType, SessionData.block, SessionData.questID)
end



local function OnBlockEnter(blockType, block, questID)
    if not IsModuleEnabled() or not questID then return end
    SetSession(blockType, block, questID)
    CallbackRegistry.Trigger("QuestDetailTooltip.OnBlockEnter", blockType, block, questID)
end

EventRegistry:RegisterCallback("OnQuestBlockHeader.OnEnter", function(_, block, questID) OnBlockEnter(BLOCK_TYPE_HEADER, block, questID) end)
EventRegistry:RegisterCallback("QuestMapLogTitleButton.OnEnter", function(_, block, questID) OnBlockEnter(BLOCK_TYPE_MAP_BUTTON, block, questID) end)
GameTooltip:HookScript("OnHide", function()
    if not IsSessionActive() then return end
    CallbackRegistry.Trigger("QuestDetailTooltip.OnBlockLeave")
    ClearSession()
end)

local f = CreateFrame("Frame")
f:RegisterEvent("QUEST_DATA_LOAD_RESULT")
f:RegisterEvent("QUEST_LOG_UPDATE")
f:SetScript("OnEvent", function(self, event, ...)
    if not IsModuleEnabled() then return end
    if IsSessionActive() then
        if HaveQuestData(SessionData.questID) and HaveQuestRewardData(SessionData.questID) then
            UpdateAwaitData()
            RefreshActiveTooltip()
        end
    end
end)

CallbackRegistry.Add("QuestDetailTooltip.OnBlockEnter", function(event, blockType, block, questID)
    if not HaveQuestData(questID) or not HaveQuestRewardData(questID) then
        UpdateAwaitData()
        C_QuestLog.RequestLoadQuestByID(questID)
    end
    RefreshActiveTooltip()
end)

CallbackRegistry.Add("QuestDetailTooltip.OnBlockLeave", function(event)
    ClearSession()
end)
