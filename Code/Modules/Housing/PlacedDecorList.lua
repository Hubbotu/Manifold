local env = select(2, ...)
local Config = env.Config
local Path = env.modules:Import("packages\\path")
local UIFont = env.modules:Import("packages\\ui-font")
local UIKit = env.modules:Import("packages\\ui-kit")
local Frame, LayoutGrid, LayoutHorizontal, LayoutVertical, Text, ScrollContainer, LazyScrollContainer, ScrollBar, ScrollContainerEdge, Input, LinearSlider, HitRect, List, SecureButton = unpack(UIKit.UI.Frames)
local UIAnim = env.modules:Import("packages\\ui-anim")
local Utils_Texture = env.modules:Import("packages\\utils\\texture")
local GenericEnum = env.modules:Import("packages\\generic-enum")
local SavedVariables = env.modules:Import("packages\\saved-variables")
local function IsModuleEnabled() return Config.DBGlobal:GetVariable("PlacedDecorList") == true end

local IsAddOnLoaded = C_AddOns.IsAddOnLoaded

local function OnLoad()
    local PlacedDecorList = HouseEditorFrame.ExpertDecorModeFrame.PlacedDecorList

    Utils_Texture.Preload(Path.Root .. "\\Art\\Housing\\HouseUI")
    local ATLAS = UIKit.Define.Texture_Atlas{ path = Path.Root .. "\\Art\\Housing\\HouseUI", inset = 0, scale = 1 }
    local UIDEF = {
        PlacementCost = ATLAS{ left = 0 / 256, right = 32 / 256, top = 0 / 256, bottom = 32 / 256 },
        Resize        = ATLAS{ left = 0 / 256, right = 32 / 256, top = 32 / 256, bottom = 64 / 256 }
    }

    do --Append placement cost to each decor list entry
        local COLOR_NORMAL = UIKit.Define.Color_HEX{ hex = "ff7B7B7B" }
        local COLOR_HIGHLIGHTED = GenericEnum.ColorRGB255.NORMAL_FONT_COLOR

        local ListInfoMixin = {}

        function ListInfoMixin:OnLoad()
            self:SetHighlighted(false)
        end

        function ListInfoMixin:SetText(text)
            self.Text:SetText(text)
        end

        function ListInfoMixin:SetHighlighted(isHighlighted)
            local color = isHighlighted and COLOR_HIGHLIGHTED or COLOR_NORMAL
            self.Icon:backgroundColor(color)
            self.Text:textColor(color)
        end

        local ListInfo = UIKit.Template(function(id, name, children, ...)
            local frame = LayoutHorizontal(name, {
                    Frame(name .. ".Icon")
                        :id("Icon", id)
                        :size(12, 12)
                        :background(UIDEF.PlacementCost),

                    Text(name .. ".Text")
                        :id("Text", id)
                        :size(UIKit.UI.FIT, 12)
                        :fontObject(UIFont.UIFontObjectNormal12)
                        :textJustifyH("RIGHT")
                        :textJustifyV("MIDDLE")
                })
                :size(UIKit.UI.FIT, 12)
                :point(UIKit.Enum.Point.Right)
                :layoutSpacing(2)
                :x(-8)

            frame.Icon = UIKit.GetElementById("Icon", id)
            frame.Text = UIKit.GetElementById("Text", id)

            Mixin(frame, ListInfoMixin)
            frame:OnLoad()

            return frame
        end)

        local function SetupListFrame(frame)
            if frame.__manifoldInitialized then return end
            frame.__manifoldInitialized = true
            frame.ListInfo = ListInfo()
                :parent(frame)
        end

        hooksecurefunc(HouseEditorPlacedDecorEntryMixin, "Init", function(self, elementData)
            if not IsModuleEnabled() then return end

            if not elementData or not elementData.decorGUID then return end
            local info = C_HousingDecor.GetDecorInstanceInfoForGUID(elementData.decorGUID)
            local catalogInfo = C_HousingCatalog.GetCatalogEntryInfoByRecordID(Enum.HousingCatalogEntryType.Decor, info.decorID, true)
            local placementCost = catalogInfo.placementCost

            SetupListFrame(self)
            self.ListInfo:SetHighlighted(self.isSelected)
            if self.ListInfo.Text:GetText() ~= placementCost then
                self.ListInfo:SetText(placementCost)
                self.ListInfo:_Render()
            end
        end)

        hooksecurefunc(HouseEditorPlacedDecorEntryMixin, "UpdateVisuals", function(self, ...)
            if self.ListInfo then
                if not IsModuleEnabled() then
                    if self.ListInfo:IsShown() then self.ListInfo:Hide() end
                    return
                end

                if not self.ListInfo:IsShown() then self.ListInfo:Show() end
                self.ListInfo:SetHighlighted(self.isSelected)
            end
        end)
    end

    do --Add resize button to PlacedDecorList
        local function InitResizeButton()
            PlacedDecorList:SetResizable(true)
            PlacedDecorList.minWidth = 225
            PlacedDecorList.minHeight = 225
            PlacedDecorList.maxWidth = 725
            PlacedDecorList.maxHeight = 725

            PlacedDecorList.ResizeButton = Frame("ResizeButton", {
                    Frame("ResizeButton.Background")
                        :size(20, 20)
                        :point(UIKit.Enum.Point.BottomRight)
                        :background(UIDEF.Resize)
                })
                :parent(PlacedDecorList)
                :size(20, 20)
                :point(UIKit.Enum.Point.BottomRight)
                :position(5, -4)
                :_Render()

            Mixin(PlacedDecorList.ResizeButton, PanelResizeButtonMixin)
            PlacedDecorList.ResizeButton:SetScript("OnEnter", PlacedDecorList.ResizeButton.OnEnter)
            PlacedDecorList.ResizeButton:SetScript("OnLeave", PlacedDecorList.ResizeButton.OnLeave)
            PlacedDecorList.ResizeButton:SetScript("OnMouseDown", PlacedDecorList.ResizeButton.OnMouseDown)
            PlacedDecorList.ResizeButton:SetScript("OnMouseUp", PlacedDecorList.ResizeButton.OnMouseUp)
            PlacedDecorList.ResizeButton:Init(PlacedDecorList, PlacedDecorList.minWidth, PlacedDecorList.minHeight, PlacedDecorList.maxWidth, PlacedDecorList.maxHeight)

            PlacedDecorList:HookScript("OnShow", function()
                if not PlacedDecorList.ResizeButton.__rendered then
                    PlacedDecorList.ResizeButton.__rendered = true
                    PlacedDecorList.ResizeButton:_Render()
                end
            end)
        end

        local function UpdateResizeButtonVisibility()
            if not PlacedDecorList.ResizeButton then
                InitResizeButton()
            end
            PlacedDecorList.ResizeButton:SetShown(IsModuleEnabled())
        end

        UpdateResizeButtonVisibility()
        SavedVariables.OnChange("ManifoldDB_Global", "PlacedDecorList", UpdateResizeButtonVisibility)
    end
end

if IsAddOnLoaded("Blizzard_HouseEditor") then
    OnLoad()
else
    EventUtil.ContinueOnAddOnLoaded("Blizzard_HouseEditor", OnLoad)
end
