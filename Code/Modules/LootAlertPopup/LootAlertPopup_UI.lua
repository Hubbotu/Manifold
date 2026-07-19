local env = select(2, ...)
local UIFont = env.modules:Import("packages\\ui-font")
local UIKit = env.modules:Import("packages\\ui-kit")
local Frame, LayoutGrid, LayoutHorizontal, LayoutVertical, Text, ScrollContainer, LazyScrollContainer, ScrollBar, ScrollContainerEdge, Input, LinearSlider, HitRect, List, SecureButton, ModelScene = unpack(UIKit.UI.Frames)
local LootAlertPopup_Preload = env.modules:Import("@\\LootAlertPopup\\Preload")

do --ManifoldLootAlertPopup
    local CONTENT_SIZE = 18

    local name = "Manifold_LootAlertPopup"
    local id = "Manifold_LootAlertPopup"

    local frame = Frame(name, {
            Frame(name .. ".Content", {
                Frame(name .. ".Background")
                    :id("Background", id)
                    :frameLevel(1000)
                    :size(UIKit.Define.Fill{ delta = -8 })
                    :background(LootAlertPopup_Preload.UIDEF.UIFrame),

                Frame(name .. ".Main", {
                    LayoutHorizontal(name .. ".Instruction", {
                        Frame(name .. ".Instruction.Hint")
                            :id("Instruction.Hint", id)
                            :frameLevel(1002)
                            :size(CONTENT_SIZE, CONTENT_SIZE)
                            :background(LootAlertPopup_Preload.UIDEF.LMB),

                        Text(name .. ".Instruction.Text")
                            :id("Instruction.Text", id)
                            :frameLevel(1002)
                            :size(UIKit.Define.Fit{}, CONTENT_SIZE)
                            :fontObject(UIFont.UIFontObjectNormal12)
                            :textColor(LootAlertPopup_Preload.PrimaryTextColor)
                    })
                        :id("Instruction", id)
                        :frameLevel(1002)
                        :point(UIKit.Enum.Point.Left)
                        :size(UIKit.Define.Fit{}, CONTENT_SIZE)
                        :layoutAlignmentV(UIKit.Enum.Direction.Justified)
                        :layoutSpacing(2),

                    LayoutHorizontal(name .. ".ItemComparison", {
                        Frame(name .. ".ItemComparison.Icon")
                            :id("ItemComparison.Icon", id)
                            :frameLevel(1002)
                            :size(CONTENT_SIZE, CONTENT_SIZE)
                            :background(UIKit.UI.TEXTURE_NIL),

                        Text(name .. ".ItemComparison.ItemLevel")
                            :id("ItemComparison.ItemLevel", id)
                            :frameLevel(1002)
                            :size(UIKit.Define.Fit{}, CONTENT_SIZE)
                            :fontObject(UIFont.UIFontObjectNormal12)
                            :textColor(LootAlertPopup_Preload.ItemComparisonTextColor)
                    })
                        :id("ItemComparison", id)
                        :frameLevel(1002)
                        :point(UIKit.Enum.Point.Right)
                        :size(UIKit.Define.Fit{}, CONTENT_SIZE)
                        :layoutAlignmentV(UIKit.Enum.Direction.Justified)
                        :layoutSpacing(-2),

                    Frame(name .. ".Spinner")
                        :id("Spinner", id)
                        :frameLevel(1002)
                        :point(UIKit.Enum.Point.Right)
                        :size(CONTENT_SIZE, CONTENT_SIZE)
                        :background(LootAlertPopup_Preload.UIDEF.Spinner)
                        :backgroundColor(LootAlertPopup_Preload.PrimaryTextColor),

                    Frame(name .. ".Tick")
                        :id("Tick", id)
                        :frameLevel(1002)
                        :point(UIKit.Enum.Point.Right)
                        :size(CONTENT_SIZE, CONTENT_SIZE)
                        :background(LootAlertPopup_Preload.UIDEF.Tick)
                })
                    :id("Main", id)
                    :frameLevel(1001)
                    :point(UIKit.Enum.Point.Center)
                    :size(UIKit.Define.Percentage{ value = 100, operator = "-", delta = CONTENT_SIZE }, UIKit.Define.Percentage{ value = 100, operator = "-", delta = CONTENT_SIZE })
            })
                :id("Content", id)
                :frameLevel(1001)
                :point(UIKit.Enum.Point.Center)
                :size(UIKit.Define.Percentage{ value = 100 }, UIKit.Define.Percentage{ value = 100 })
        })
        :parent(UIParent)
        :frameStrata(UIKit.Enum.FrameStrata.Tooltip, 999)
        :size(175, 32)
        :clampedToScreen(true)
        :_Render()

    frame.Background = UIKit.GetElementById("Background", id)
    frame.BackgroundTexture = frame.Background:GetTextureFrame()
    frame.Content = UIKit.GetElementById("Content", id)
    frame.Main = UIKit.GetElementById("Main", id)
    frame.Instruction = UIKit.GetElementById("Instruction", id)
    frame.Instruction.Hint = UIKit.GetElementById("Instruction.Hint", id)
    frame.Instruction.Text = UIKit.GetElementById("Instruction.Text", id)
    frame.ItemComparison = UIKit.GetElementById("ItemComparison", id)
    frame.ItemComparison.Icon = UIKit.GetElementById("ItemComparison.Icon", id)
    frame.ItemComparison.ItemLevel = UIKit.GetElementById("ItemComparison.ItemLevel", id)
    frame.Spinner = UIKit.GetElementById("Spinner", id)
    frame.Tick = UIKit.GetElementById("Tick", id)
    ManifoldLootAlertPopup = frame
end
