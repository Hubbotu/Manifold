local env = select(2, ...)
local UIKit = env.modules:Import("packages\\ui-kit")
local UIFont = env.modules:Import("packages\\ui-font")
local Frame, LayoutGrid, LayoutHorizontal, LayoutVertical, Text, ScrollContainer, LazyScrollContainer, ScrollBar, ScrollContainerEdge, Input, LinearSlider, HitRect, List, SecureButton, ModelScene = unpack(UIKit.UI.Frames)
local OptionsFrame_Templates = env.modules:Import("@\\OptionsFrame\\Templates")
local OptionsFrame_Preload = env.modules:Import("@\\OptionsFrame\\Preload")


do --ManifoldOptionsFrame
    local FRAME_WIDTH = 983
    local FRAME_HEIGHT = FRAME_WIDTH / 1.6
    local CONTENT_INSET = 32
    local SIDEBAR_WIDTH = 279
    local SCROLL_TOP_PADDING = CONTENT_INSET / 2
    local SCROLL_BOTTOM_PADDING = 250

    local function OnElementVisibilityChanged(element, shouldShow, poolElementType)
        element:_excludeFromCalculations(not shouldShow)
        if shouldShow then
            element:Show()
            element.AnimGroup:SecurePlay("FADE_IN", element)
        else
            element.AnimGroup:SecurePlay("FADE_OUT", element):onFinish(function()
                element:Hide()
            end)
        end
    end

    local function OnCategoryUpdate(element, index, value)
        element:SetText(value.name, value.itemCount or 0)
        element:SetCategoryID(value.categoryID)
    end

    local function OnContentUpdate(element, index, value, visibilityChanged)
        element:SetData(value)
    end

    local name = "ManifoldOptionsFrame"
    local id = "ManifoldOptionsFrame"

    local frame = Frame(name, {
            Frame(name .. ".Background")
                :id("Background", id)
                :size(UIKit.Define.Fill{ delta = 0 })
                :background(OptionsFrame_Preload.UIDEF.UIBackground),

            Frame(name .. ".Border")
                :id("Border", id)
                :frameLevel(10)
                :size(UIKit.Define.Fill{ delta = -15 })
                :background(OptionsFrame_Preload.UIDEF.UIBorder),

            Frame(name .. ".DragRegion")
                :frameLevel(10)
                :id("DragRegion", id)
                :point(UIKit.Enum.Point.Top)
                :size(UIKit.UI.P_FILL, 20)
                :registerForDrag(true),

            OptionsFrame_Templates.CloseButton(name .. ".CloseButton")
                :frameLevel(11)
                :id("CloseButton", id)
                :point(UIKit.Enum.Point.TopRight)
                :position(4, 3)
                :size(18, 18),

            Frame(name .. ".Sidebar", {
                Frame()
                    :point(UIKit.Enum.Point.Left)
                    :background(OptionsFrame_Preload.UIDEF.UISidebar)
                    :size(UIKit.Define.Percentage{ value = 100, operator = "+", delta = 30 }, UIKit.UI.P_FILL),

                LayoutVertical{
                    OptionsFrame_Templates.SearchBox()
                        :id("SearchBox", id)
                        :size(UIKit.UI.P_FILL, 35),

                    Frame()
                        :height(5),

                    List(name .. ".Sidebar.Categories")
                        :id("Sidebar.Categories", id)
                        :poolTemplate(OptionsFrame_Templates.SidebarCategory)
                        :poolElementUpdate(OnCategoryUpdate)
                        :poolElementVisibilityChanged(OnElementVisibilityChanged)
                }
                    :point(UIKit.Enum.Point.Center)
                    :size(UIKit.Define.Percentage{ value = 100, operator = "-", delta = CONTENT_INSET }, UIKit.Define.Percentage{ value = 100, operator = "-", delta = CONTENT_INSET })
                    :layoutSpacing(3)
            })
                :id("Sidebar", id)
                :point(UIKit.Enum.Point.Left)
                :size(SIDEBAR_WIDTH, UIKit.UI.P_FILL),

            Frame(name .. ".Content", {
                ScrollContainer(name .. ".Content.ScrollContainer", {
                    LayoutGrid(name .. ".Content.ScrollContainer.Layout", {
                        List(name .. ".Content.ScrollContainer.List")
                            :id("Content.ScrollContainer.List", id)
                            :poolTemplate({
                                [OptionsFrame_Preload.Enum.ContentType.Section] = OptionsFrame_Templates.Section,
                                [OptionsFrame_Preload.Enum.ContentType.Card]    = OptionsFrame_Templates.Card
                            })
                            :poolElementUpdate(OnContentUpdate)
                            :poolElementVisibilityChanged(OnElementVisibilityChanged)
                    })
                        :id("Content.ScrollContainer.Layout", id)
                        :point(UIKit.Enum.Point.Top)
                        :y(-SCROLL_TOP_PADDING)
                        :size(UIKit.UI.P_FILL, UIKit.Define.Fit{})
                        :layoutSpacingH(5)
                        :layoutSpacingV(8)
                        :columns(3)
                })
                    :id("Content.ScrollContainer", id)
                    :point(UIKit.Enum.Point.Center)
                    :size(UIKit.UI.P_FILL, UIKit.UI.P_FILL)
                    :scrollStepSize(125)
                    :scrollInterpolation(5)
                    :scrollContainerContentWidth(UIKit.UI.P_FILL)
                    :scrollContainerContentHeight(UIKit.Define.Fit{ delta = SCROLL_BOTTOM_PADDING }),

                Text(name .. ".Content.NoResults")
                    :id("Content.NoResults", id)
                    :point(UIKit.Enum.Point.Center)
                    :size(UIKit.UI.P_FILL, UIKit.UI.P_FILL)
                    :fontObject(UIFont.UIFontObjectNormal12)
                    :textColor(OptionsFrame_Preload.Enum.Color.Primary)
                    :text(CATALOG_SHOP_NO_SEARCH_RESULTS)
                    :alpha(0.5)
            })
                :id("Content", id)
                :point(UIKit.Enum.Point.Left)
                :x(SIDEBAR_WIDTH + CONTENT_INSET / 2)
                :size(UIKit.Define.Percentage{ value = 100, operator = "-", delta = SIDEBAR_WIDTH + CONTENT_INSET / 2 + CONTENT_INSET }, UIKit.UI.P_FILL),

            OptionsFrame_Templates.ScrollBar(name .. ".ScrollBar")
                :id("ScrollBar", id)
                :point(UIKit.Enum.Point.Right)
                :position(-10, -5)
                :size(9, UIKit.Define.Percentage{ value = 100, operator = "-", delta = 42 })
                :linkedScrollContainer(UIKit.NewGroupCaptureString("Content.ScrollContainer", id))
        })
        :parent(UIParent)
        :point(UIKit.Enum.Point.Center)
        :frameStrata(UIKit.Enum.FrameStrata.Medium)
        :topLevel(true)
        :enableMouse(true)
        :movable(true)
        :clampedToScreen(true)
        :size(FRAME_WIDTH, FRAME_HEIGHT)
        :_Render()

    frame.Background = UIKit.GetElementById("Background", id)
    frame.BackgroundTexture = frame.Background:GetTextureFrame()
    frame.Border = UIKit.GetElementById("Border", id)
    frame.BorderTexture = frame.Border:GetTextureFrame()
    frame.DragRegion = UIKit.GetElementById("DragRegion", id)
    frame.CloseButton = UIKit.GetElementById("CloseButton", id)
    frame.Sidebar = UIKit.GetElementById("Sidebar", id)
    frame.SearchBox = UIKit.GetElementById("SearchBox", id)
    frame.Sidebar.Categories = UIKit.GetElementById("Sidebar.Categories", id)
    frame.Content = UIKit.GetElementById("Content", id)
    frame.Content.ScrollContainer = UIKit.GetElementById("Content.ScrollContainer", id)
    frame.Content.ScrollContainer.Layout = UIKit.GetElementById("Content.ScrollContainer.Layout", id)
    frame.Content.ScrollContainer.List = UIKit.GetElementById("Content.ScrollContainer.List", id)
    frame.Content.NoResults = UIKit.GetElementById("Content.NoResults", id)
    frame.ScrollBar = UIKit.GetElementById("ScrollBar", id)
    ManifoldOptionsFrame = frame
end
