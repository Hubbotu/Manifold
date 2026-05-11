local env = select(2, ...)
local L = env.L
local Config = env.Config
local Path = env.modules:Import("packages\\path")
local WoWClient = env.modules:Import("packages\\wow-client")
local GenericEnum = env.modules:Import("packages\\generic-enum")
local Utils_InlineIcon = env.modules:Import("packages\\utils\\inline-icon")
local function IsModuleEnabled() return Config.DBGlobal:GetVariable("DecorTooltip") == true end

local IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local IsHoveringDecor = C_HousingDecor.IsHoveringDecor
local GetSelectedDecorInfo = C_HousingDecor.GetSelectedDecorInfo
local GetHoveredDecorInfo = C_HousingDecor.GetHoveredDecorInfo
local GetCatalogEntryInfoByRecordID = C_HousingCatalog.GetCatalogEntryInfoByRecordID
local GetActiveHouseEditorMode = C_HouseEditor.GetActiveHouseEditorMode

local Data = { isDecorTooltip = false }

local function OnLoad()
    local ICON_SIZE = 12
    local ICON_COORDS = { left = 0, right = 32, top = 0, bottom = 32 }
    local TEXTURE_SIZE = 256

    local PLACEMENT_COST_INLINE_ICON = Utils_InlineIcon.New(
        {
            path   = Path.Root .. "\\Art\\Housing\\HouseUI",
            width  = TEXTURE_SIZE,
            height = TEXTURE_SIZE,
            left   = ICON_COORDS.left,
            right  = ICON_COORDS.right,
            top    = ICON_COORDS.top,
            bottom = ICON_COORDS.bottom
        }, ICON_SIZE, ICON_SIZE, 0, 0, GenericEnum.ColorRGB255.NORMAL_FONT_COLOR
    ) .. " "

    local function IsSameDecor(selected, hovered)
        return selected and hovered and hovered.decorGUID and selected.decorGUID == hovered.decorGUID
    end

    local function ShouldBlockTooltip()
        return HouseEditorFrame.ExpertDecorModeFrame.PlacedDecorList:IsMouseOver() or WoWClient.IsPlayerTurning or WoWClient.IsPlayerLooking
    end

    local function ShowTooltip(isExpertDecorSelectionHovered)
        if ShouldBlockTooltip() then return end

        local selectedDecorInfo = GetSelectedDecorInfo()
        local hoveredDecorInfo = isExpertDecorSelectionHovered and selectedDecorInfo or GetHoveredDecorInfo()
        if not hoveredDecorInfo or IsSameDecor(selectedDecorInfo, hoveredDecorInfo) then return end

        local catalogInfo = GetCatalogEntryInfoByRecordID(Enum.HousingCatalogEntryType.Decor, hoveredDecorInfo.decorID, true)
        if not catalogInfo then return end

        local quality = hoveredDecorInfo.quality or catalogInfo.quality
        local qualityColor = (quality and ITEM_QUALITY_COLORS[quality]) or GenericEnum.ColorRGB01.WHITE_FONT_COLOR
        local normalTextColor = GenericEnum.ColorRGB01.NORMAL_FONT_COLOR

        GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR_RIGHT")
        GameTooltip:AddDoubleLine(hoveredDecorInfo.name, PLACEMENT_COST_INLINE_ICON .. catalogInfo.placementCost, qualityColor.r, qualityColor.g, qualityColor.b, normalTextColor.r, normalTextColor.g, normalTextColor.b)

        local actionKey = GetActiveHouseEditorMode() == Enum.HouseEditorMode.Cleanup and "Remove" or "Select"
        GameTooltip:AddLine(L["Modules - Housing - DecorTooltip - " .. actionKey])
        GameTooltip:Show()

        Data.isDecorTooltip = true
    end

    local function HideDecorTooltip()
        if GameTooltip:IsShown() and Data.isDecorTooltip then
            GameTooltip:Hide()
        end
    end

    local function HandleTooltip()
        if not IsModuleEnabled() then return end

        if IsSameDecor(GetSelectedDecorInfo(), GetHoveredDecorInfo()) then
            HideDecorTooltip()
            return
        end

        if (Data.isHoveringDecor or Data.isExpertDecorSelectionHovered) and Data.isValidMode then
            ShowTooltip(Data.isExpertDecorSelectionHovered)
        else
            HideDecorTooltip()
        end
    end

    EventRegistry:RegisterCallback("HousingDecorInstance.MouseOver", HandleTooltip)

    GameTooltip:HookScript("OnHide", function()
        Data.isDecorTooltip = false
    end)

    local HOUSING_EVENTS = {
        "HOUSING_BASIC_MODE_HOVERED_TARGET_CHANGED",
        "HOUSING_EXPERT_MODE_HOVERED_TARGET_CHANGED",
        "HOUSING_CUSTOMIZE_MODE_HOVERED_TARGET_CHANGED",
        "HOUSING_CLEANUP_MODE_HOVERED_TARGET_CHANGED",
        "HOUSING_DECOR_PRECISION_MANIPULATION_EVENT",
        "HOUSE_EDITOR_MODE_CHANGED",
        "WORLD_CURSOR_TOOLTIP_UPDATE"
    }

    local f = CreateFrame("Frame")
    for _, event in ipairs(HOUSING_EVENTS) do
        f:RegisterEvent(event)
    end
    f:SetScript("OnEvent", function(self, event, ...)
        if not IsModuleEnabled() then return end

        Data.isExpertDecorSelectionHovered = event == "HOUSING_DECOR_PRECISION_MANIPULATION_EVENT" and ... == Enum.TransformManipulatorEvent.Hover
        Data.isHoveringDecor = IsHoveringDecor()
        Data.isValidMode = GetActiveHouseEditorMode() ~= Enum.HouseEditorMode.Customize

        HandleTooltip()
    end)
end

if IsAddOnLoaded("Blizzard_HouseEditor") then
    OnLoad()
else
    EventUtil.ContinueOnAddOnLoaded("Blizzard_HouseEditor", OnLoad)
end
