local env = select(2, ...)
local L = env.L
local UIFont = env.modules:Import("packages\\ui-font")
local UIKit = env.modules:Import("packages\\ui-kit")
local Frame, LayoutGrid, LayoutHorizontal, LayoutVertical, Text, ScrollContainer, LazyScrollContainer, ScrollBar, ScrollContainerEdge, Input, LinearSlider, HitRect, List, SecureButton = unpack(UIKit.UI.Frames)
local GenericEnum = env.modules:Import("packages\\generic-enum")
local UICCommon = env.modules:Import("packages\\uic-common")

ManifoldSettingsFrameAnchor = CreateFrame("Frame", "ManifoldSettingsFrameAnchor", UIParent)
ManifoldSettingsFrameAnchor:Hide()

do --ManifoldSettingsFrame
    local name = "ManifoldSettingsFrame"
    local id = "ManifoldSettingsFrame"

    local frame = Frame(name, {
            LayoutVertical(name .. ".Content", {
                Text(name .. ".Heading")
                    :id("Heading", id)
                    :fontObject(UIFont.UIFontObjectNormal14)
                    :textColor(GenericEnum.UIColorRGB.NORMAL_FONT_COLOR)
                    :size(UIKit.UI.FIT, UIKit.UI.FIT)
                    :text(L["OPTIONS_HEADING"]),

                UICCommon.RedTextButton(name .. ".OptionButton")
                    :id("OptionButton", id)
                    :size(275, 35)
            })
                :id("Content", id)
                :point(UIKit.Enum.Point.Center)
                :size(UIKit.UI.P_FILL, UIKit.UI.P_FILL)
                :layoutAlignmentH(UIKit.Enum.Direction.Justified)
                :layoutAlignmentV(UIKit.Enum.Direction.Justified)
                :layoutSpacing(16)
        })
        :parent(ManifoldSettingsFrameAnchor)
        :point(UIKit.Enum.Point.Center)
        :size(UIKit.UI.P_FILL, UIKit.UI.P_FILL)
        :_Render()

    frame.Heading = UIKit.GetElementById("Heading", id)
    frame.OptionButton = UIKit.GetElementById("OptionButton", id)
    ManifoldSettingsFrame = frame

    frame.OptionButton:SetText(L["OPTIONS_BUTTON"])
    frame.OptionButton:HookClick(function()
        ManifoldAPI_ToggleSettingsUI()
        ManifoldOptionsFrame:Raise()
    end)
end

local Category = Settings.RegisterCanvasLayoutCategory(ManifoldSettingsFrameAnchor, env.NAME)
Settings.RegisterAddOnCategory(Category)

ManifoldSettingsFrameAnchor:SetScript("OnShow", function(self)
    ManifoldSettingsFrame:_Render()
end)
