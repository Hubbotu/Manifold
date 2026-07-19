local env = select(2, ...)
local L = env.L
local Config = env.Config
local Sound = env.modules:Import("packages\\sound")
local UIFont = env.modules:Import("packages\\ui-font")
local UIKit = env.modules:Import("packages\\ui-kit")
local Frame, LayoutGrid, LayoutHorizontal, LayoutVertical, Text, ScrollContainer, LazyScrollContainer, ScrollBar, ScrollContainerEdge, Input, LinearSlider, HitRect, List, SecureButton, ModelScene = unpack(UIKit.UI.Frames)
local UIAnim = env.modules:Import("packages\\ui-anim")
local UICSharedMixin = env.modules:Import("packages\\uic-sharedmixin")
local GenericEnum = env.modules:Import("packages\\generic-enum")
local OptionsFrame_Preload = env.modules:Import("@\\OptionsFrame\\Preload")
local OptionsFrame_Templates = env.modules:New("@\\OptionsFrame\\Templates")
local OptionsFrame = env.modules:Await("@\\OptionsFrame")

local Mixin = Mixin
local CreateFromMixins = CreateFromMixins

do --Close Button
    local BACKGROUND_SIZE = UIKit.Define.Fill{ delta = -12 }

    local CloseButtonMixin = CreateFromMixins(UICSharedMixin.ButtonMixin)

    function CloseButtonMixin:OnLoad()
        self:InitButton()

        self:RegisterMouseEvents()
        self:HookButtonStateChange(self.UpdateAnimation)
        self:HookMouseUp(self.PlayInteractSound)
        self:UpdateAnimation()
    end

    function CloseButtonMixin:UpdateAnimation()
        local buttonState = self:GetButtonState()
        if buttonState == "PUSHED" then
            self.Background:background(OptionsFrame_Preload.UIDEF.UIClose_Pushed)
        elseif buttonState == "HIGHLIGHTED" then
            self.Background:background(OptionsFrame_Preload.UIDEF.UIClose_Highlighted)
        else
            self.Background:background(OptionsFrame_Preload.UIDEF.UIClose)
        end
    end

    function CloseButtonMixin:PlayInteractSound()
        Sound.PlaySound("UI", SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end

    OptionsFrame_Templates.CloseButton = UIKit.Template(function(id, name, children, ...)
        local frame = Frame(name, {
            Frame(name .. ".Background")
                :id("Background", id)
                :size(BACKGROUND_SIZE)
                :background(UIKit.UI.TEXTURE_NIL)
        })

        frame.Background = UIKit.GetElementById("Background", id)

        Mixin(frame, CloseButtonMixin)
        frame:OnLoad()

        return frame
    end)
end

do --Button
    local BACKGROUND_SIZE = UIKit.Define.Fill{ delta = -8 }
    local CONTENT_SIZE = UIKit.Define.Percentage{ value = 100, operator = "-", delta = 8 }
    local TEXT_SIZE = UIKit.UI.FILL
    local Y = 0
    local Y_HIGHLIGHTED = 0
    local Y_PUSHED = -1

    local ButtonMixin = CreateFromMixins(UICSharedMixin.ButtonMixin)

    function ButtonMixin:OnLoad()
        self:InitButton()

        self:RegisterMouseEvents()
        self:HookButtonStateChange(self.UpdateAnimation)
        self:HookMouseUp(self.PlayInteractSound)
        self:UpdateAnimation()
    end

    function ButtonMixin:SetText(text)
        self.Content.Text:SetText(text)
    end

    function ButtonMixin:UpdateAnimation()
        local buttonState = self:GetButtonState()
        self.Content:ClearAllPoints()
        if buttonState == "PUSHED" then
            self.Background:background(OptionsFrame_Preload.UIDEF.UIButton_Pushed)
            self.Content:SetPoint("CENTER", self, -Y_PUSHED, Y_PUSHED)
        elseif buttonState == "HIGHLIGHTED" then
            self.Background:background(OptionsFrame_Preload.UIDEF.UIButton_Highlighted)
            self.Content:SetPoint("CENTER", self, -Y_HIGHLIGHTED, Y_HIGHLIGHTED)
        else
            self.Background:background(OptionsFrame_Preload.UIDEF.UIButton)
            self.Content:SetPoint("CENTER", self, -Y, Y)
        end
    end

    function ButtonMixin:PlayInteractSound()
        Sound.PlaySound("UI", SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end

    OptionsFrame_Templates.Button = UIKit.Template(function(id, name, children, ...)
        local frame = Frame(name, {
            Frame(name .. ".Background")
                :id("Background", id)
                :size(BACKGROUND_SIZE)
                :background(UIKit.UI.TEXTURE_NIL),

            Frame(name .. ".Content", {
                Text(name .. ".Content.Text")
                    :id("Content.Text", id)
                    :size(TEXT_SIZE, TEXT_SIZE)
                    :fontObject(UIFont.UIFontObjectNormal12)
                    :textColor(OptionsFrame_Preload.Enum.Color.Primary)
                    :textJustifyH("CENTER")
                    :textJustifyV("MIDDLE")
            })
                :id("Content", id)
                :point(UIKit.Enum.Point.Center)
                :size(CONTENT_SIZE, CONTENT_SIZE)
        })

        frame.Background = UIKit.GetElementById("Background", id)
        frame.Content = UIKit.GetElementById("Content", id)
        frame.Content.Text = UIKit.GetElementById("Content.Text", id)

        Mixin(frame, ButtonMixin)
        frame:OnLoad()

        return frame
    end)
end

do --Scroll Bar
    local ScrollBarMixin = CreateFromMixins(UICSharedMixin.ScrollBarMixin)

    function ScrollBarMixin:OnLoad()
        self:InitScrollBar()

        self.HitRect:AddOnEnter(function() self:OnEnter() end)
        self.HitRect:AddOnLeave(function() self:OnLeave() end)
        self.HitRect:AddOnMouseDown(function() self:OnMouseDown() end)
        self.HitRect:AddOnMouseUp(function() self:OnMouseUp() end)

        self:HookButtonStateChange(self.UpdateAnimation)
        self:HookEnableChange(self.UpdateAnimation)
        self:HookMouseUp(self.PlayInteractSound)
        self:UpdateAnimation()
    end

    function ScrollBarMixin:UpdateAnimation()
        local buttonState = self:GetButtonState()

        if buttonState == "PUSHED" then
            self.Thumb:background(OptionsFrame_Preload.UIDEF.UIScrollBarThumb_Pushed)
        elseif buttonState == "HIGHLIGHTED" then
            self.Thumb:background(OptionsFrame_Preload.UIDEF.UIScrollBarThumb_Highlighted)
        else
            self.Thumb:background(OptionsFrame_Preload.UIDEF.UIScrollBarThumb)
        end
    end

    function ScrollBarMixin:PlayInteractSound()
        Sound.PlaySound("UI", SOUNDKIT.U_CHAT_SCROLL_BUTTON)
    end

    OptionsFrame_Templates.ScrollBar = UIKit.Template(function(id, name, children, ...)
        local frame =
            ScrollBar(name, {
                HitRect(name .. ".HitRect")
                    :id("HitRect", id)
                    :frameLevel(3)
                    :size(UIKit.UI.FILL)
                    :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged),

                Frame(name .. ".Thumb")
                    :id("Thumb", id)
                    :frameLevel(2)
                    :as("LINEAR_SLIDER_THUMB")
                    :size(UIKit.UI.FILL)
                    :background(OptionsFrame_Preload.UIDEF.UIScrollBarThumb)
                    :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged),

                Frame(name .. ".Track")
                    :id("Track", id)
                    :frameLevel(1)
                    :as("LINEAR_SLIDER_TRACK")
                    :size(UIKit.UI.FILL)
                    :background(OptionsFrame_Preload.UIDEF.UIScrollBarTrack)
                    :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)
            })

        frame.HitRect = UIKit.GetElementById("HitRect", id)
        frame.Thumb = UIKit.GetElementById("Thumb", id)
        frame.Track = UIKit.GetElementById("Track", id)

        Mixin(frame, ScrollBarMixin)
        frame:OnLoad()

        return frame
    end)

end

do --Search Box
    local TEXT_COLOR = OptionsFrame_Preload.Enum.Color.Primary
    local CARET_COLOR = OptionsFrame_Preload.Enum.Color.Primary
    local PLACEHOLDER_COLOR = OptionsFrame_Preload.Enum.Color.Placeholder
    local HIGHLIGHTED_COLOR = UIKit.Define.Color_RGBA{ r = 255, g = 255, b = 255, a = 0.375 }
    local INSET = 22
    local BTN_SIZE = 16
    local INPUT_SIZE = UIKit.Define.Percentage{ value = 100, operator = "-", delta = BTN_SIZE + INSET }
    local CONTENT_SIZE = UIKit.Define.Percentage{ value = 100, operator = "-", delta = INSET }
    local BACKGROUND_SIZE = UIKit.Define.Fill{ delta = 0 }


    local SearchBoxMixin = CreateFromMixins(UICSharedMixin.InputMixin)

    function SearchBoxMixin:GetInput()
        return self.Input
    end

    function SearchBoxMixin:OnLoad()
        self:InitInput()

        self:RegisterMouseEventsWithComponents(self.HitRect, self.Input)
        self:HookButtonStateChange(self.UpdateAnimation)
        self:HookEnableChange(self.UpdateAnimation)
        self:HookFocusChange(self.UpdateAnimation)
        self:GetInput():HookEvent("OnTextChanged", function() self:OnTextChanged() end)

        self:UpdateAnimation()
        self:SetPlaceholder(L["OPTIONS_SEARCH"])
    end

    function SearchBoxMixin:OnTextChanged()
        local hasText = self:GetInput():HasText()
        self.ClearButton:SetShown(hasText)
        self.Search:SetShown(not hasText)
    end

    function SearchBoxMixin:UpdateAnimation()
        local focused = self:IsFocused()
        if focused then
            if not self.AnimGroup:IsPlaying(self.Caret, "NORMAL") then
                self.AnimGroup:Play(self.Caret, "NORMAL")
            end
        end
    end

    function SearchBoxMixin:SetPlaceholder(value)
        self.Input:placeholder(value)
    end

    SearchBoxMixin.AnimGroup = UIAnim.New()
    do
        local Blink = UIAnim.Animate():property(UIAnim.Enum.Property.Alpha):easing(UIAnim.Enum.Easing.Linear):duration(0.1):from(0):to(1):loop(UIAnim.Enum.Looping.Yoyo):loopDelayEnd(0.5)
        SearchBoxMixin.AnimGroup:State("NORMAL", function(frame)
            Blink:Play(frame)
        end)
    end


    local ClearButtonMixin = CreateFromMixins(UICSharedMixin.ButtonMixin)

    function ClearButtonMixin:OnLoad(parent)
        self.parent = parent

        self:InitButton()
        self:RegisterMouseEvents()
        self:HookButtonStateChange(self.UpdateAnimation)
        self:HookClick(self.OnClick)
        self:UpdateAnimation()
    end

    function ClearButtonMixin:UpdateAnimation()
        local buttonState = self:GetButtonState()
        if buttonState == "PUSHED" or buttonState == "HIGHLIGHTED" then
            self:background(OptionsFrame_Preload.UIDEF.UIClearButton_Highlighted)
        else
            self:background(OptionsFrame_Preload.UIDEF.UIClearButton)
        end
    end

    function ClearButtonMixin:OnClick()
        self.parent:GetInput():SetText("")
        self.parent:GetInput():ClearFocus()
    end


    OptionsFrame_Templates.SearchBox = UIKit.Template(function(id, name, children, ...)
        local frame =
            Frame(name, {
                HitRect(name .. ".HitRect")
                    :id("HitRect", id)
                    :size(UIKit.UI.FILL)
                    :_excludeFromCalculations()
                    :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)
                    :frameLevel(5),

                Frame(name .. ".Background")
                    :id("Background", id)
                    :size(BACKGROUND_SIZE)
                    :background(OptionsFrame_Preload.UIDEF.UISearchBox)
                    :_excludeFromCalculations()
                    :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)
                    :frameLevel(1),

                Frame(name .. ".Content", {
                    Frame(name .. ".Search")
                        :id("Search", id)
                        :point(UIKit.Enum.Point.Right)
                        :size(BTN_SIZE, BTN_SIZE)
                        :background(OptionsFrame_Preload.UIDEF.Search)
                        :_excludeFromCalculations()
                        :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)
                        :frameLevel(2),

                    Frame(name .. ".ClearButton")
                        :id("ClearButton", id)
                        :point(UIKit.Enum.Point.Right)
                        :size(BTN_SIZE, BTN_SIZE)
                        :background(OptionsFrame_Preload.UIDEF.UIClearButton)
                        :_excludeFromCalculations()
                        :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)
                        :frameLevel(2),

                    Input(name .. ".Input", {
                        Frame(name .. ".Caret")
                            :id("Caret", id)
                            :as("INPUT_CARET")
                            :frameLevel(3)
                            :size(UIKit.UI.FILL)
                            :background(OptionsFrame_Preload.UIDEF.UISearchBoxCaret)
                            :backgroundColor(CARET_COLOR)
                            :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)
                    })
                        :id("Input", id)
                        :frameLevel(2)
                        :point(UIKit.Enum.Point.Left)
                        :size(INPUT_SIZE, UIKit.UI.FIT)
                        :fontObject(UIFont.UIFontObjectNormal12)
                        :textColor(TEXT_COLOR)
                        :inputPlaceholderFont(UIFont.UIFontNormal)
                        :inputPlaceholderFontSize(12)
                        :inputPlaceholderTextColor(PLACEHOLDER_COLOR)
                        :inputMultiLine(false)
                        :inputHighlightColor(HIGHLIGHTED_COLOR)
                        :inputCaretWidth(2)
                        :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)
                        :frameLevel(2)
                })
                    :point(UIKit.Enum.Point.Center)
                    :size(CONTENT_SIZE, CONTENT_SIZE)
            })
            :enableMouse(true)
            :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)

        frame.HitRect = UIKit.GetElementById("HitRect", id)
        frame.Background = UIKit.GetElementById("Background", id)
        frame.Search = UIKit.GetElementById("Search", id)
        frame.ClearButton = UIKit.GetElementById("ClearButton", id)
        frame.Input = UIKit.GetElementById("Input", id)
        frame.Caret = UIKit.GetElementById("Caret", id)

        Mixin(frame, SearchBoxMixin)
        frame:OnLoad()

        Mixin(frame.ClearButton, ClearButtonMixin)
        frame.ClearButton:OnLoad(frame)

        return frame
    end)
end

do --Sidebar Category
    local INSET = 12
    local INSET_WIDTH = 24
    local WIDTH = UIKit.UI.P_FILL
    local HEIGHT = UIKit.Define.Fit{ delta = INSET }
    local TEXT_WIDTH = UIKit.Define.Percentage{ value = 100, operator = "-", delta = INSET_WIDTH }
    local TEXT_HEIGHT = UIKit.UI.FIT
    local Y = 0
    local Y_HIGHLIGHTED = 0
    local Y_PUSHED = -1
    local ALPHA_MAP = {
        NORMAL      = {
            DEFAULT = 0.9,
            ACTIVE  = 0.9
        },
        HIGHLIGHTED = {
            DEFAULT = 1,
            ACTIVE  = 1
        },
        PUSHED      = {
            DEFAULT = 0.8,
            ACTIVE  = 0.8
        }
    }

    local CategoryMixin = CreateFromMixins(UICSharedMixin.ButtonMixin)

    function CategoryMixin:OnLoad()
        self.id = nil
        self.isActive = false

        self:InitButton()

        self:RegisterMouseEvents()
        self:HookButtonStateChange(self.UpdateAnimation)
        self:HookClick(function() self:OnClick() end)
        self:UpdateAnimation()
    end

    function CategoryMixin:OnClick()
        if not self.categoryID then
            return
        end
        OptionsFrame.ScrollToCategory(self.categoryID)
        self:PlayInteractSound()
    end

    function CategoryMixin:SetText(text, itemCount)
        self.Text:SetText(text)
        self.Items:SetText(tostring(itemCount or 0))
    end

    function CategoryMixin:SetActive(isActive)
        self.isActive = isActive
        self:UpdateAnimation()
    end

    function CategoryMixin:SetCategoryID(categoryID)
        self.categoryID = categoryID
    end

    function CategoryMixin:UpdateAnimation()
        local buttonState = self:GetButtonState()
        local alphaState = "NORMAL"
        if buttonState == "PUSHED" then
            alphaState = "PUSHED"
        elseif buttonState == "HIGHLIGHTED" then
            alphaState = "HIGHLIGHTED"
        end
        local alphaActiveKey = self.isActive and "ACTIVE" or "DEFAULT"
        local alpha = ALPHA_MAP[alphaState][alphaActiveKey]
        self.Container:SetAlpha(alpha)

        self.Text:ClearAllPoints()
        if buttonState == "PUSHED" then
            self.Text:SetPoint("CENTER", self, -Y_PUSHED, Y_PUSHED)
        elseif buttonState == "HIGHLIGHTED" then
            self.Text:SetPoint("CENTER", self, -Y_HIGHLIGHTED, Y_HIGHLIGHTED)
        else
            self.Text:SetPoint("CENTER", self, -Y, Y)
        end
    end

    function CategoryMixin:PlayInteractSound()
        Sound.PlaySound("UI", SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end

    CategoryMixin.AnimGroup = UIAnim.New()
    do
        local FadeInAlpha = UIAnim.Animate():property(UIAnim.Enum.Property.Alpha):duration(0.2):from(0):to(1)
        CategoryMixin.AnimGroup:State("FADE_IN", function(frame)
            frame:SetAlpha(0)
            FadeInAlpha:Play(frame)
        end)

        local FadeOutAlpha = UIAnim.Animate():property(UIAnim.Enum.Property.Alpha):duration(0.2):to(0)
        CategoryMixin.AnimGroup:State("FADE_OUT", function(frame)
            FadeOutAlpha:Play(frame)
        end)
    end

    OptionsFrame_Templates.SidebarCategory = UIKit.Template(function(id, name, children, ...)
        local frame =
            Frame(name, {
                Frame(name .. ".Container", {
                    Text(name .. ".Text")
                        :id("Text", id)
                        :point(UIKit.Enum.Point.Center)
                        :size(TEXT_WIDTH, TEXT_HEIGHT)
                        :fontObject(UIFont.UIFontObjectNormal12)
                        :textColor(OptionsFrame_Preload.Enum.Color.Primary)
                        :textJustifyH("LEFT")
                        :textJustifyV("MIDDLE"),

                    Text(name .. ".Items")
                        :id("Items", id)
                        :point(UIKit.Enum.Point.Center)
                        :size(TEXT_WIDTH, TEXT_HEIGHT)
                        :fontObject(UIFont.UIFontObjectNormal12)
                        :textColor(OptionsFrame_Preload.Enum.Color.Primary)
                        :textJustifyH("RIGHT")
                        :textJustifyV("MIDDLE")
                        :alpha(0.5)
                })
                    :id("Container", id)
                    :point(UIKit.Enum.Point.Center)
                    :size(WIDTH, HEIGHT)
            })
            :size(WIDTH, UIKit.UI.FIT)

        frame.Container = UIKit.GetElementById("Container", id)
        frame.Text = UIKit.GetElementById("Text", id)
        frame.Items = UIKit.GetElementById("Items", id)

        Mixin(frame, CategoryMixin)
        frame:OnLoad()
        frame:SetText("PH Placeholder")

        return frame
    end)
end

do --Section
    local WIDTH = UIKit.UI.P_FILL
    local HEIGHT = 48
    local HEIGHT_LEADING = 24
    local CONTENT_X = 0
    local CONTENT_WIDTH = UIKit.Define.Percentage{ value = 100, operator = "-", delta = CONTENT_X }
    local CONTENT_HEIGHT = UIKit.UI.FIT
    local ORNAMENT_SIZE = 28
    local LAYOUT_SPACING = 2
    local TEXT_WIDTH = UIKit.Define.Percentage{ value = 100, operator = "-", delta = ORNAMENT_SIZE + LAYOUT_SPACING }

    local SectionMixin = {}

    function SectionMixin:OnLoad()
        self.categoryID = nil
    end

    function SectionMixin:SetData(data)
        self:SetText(data.name)
        self:SetCategoryID(data.categoryID)
        self:SetLeading(data.isLeading)
    end

    function SectionMixin:SetText(text)
        self.Text:SetText(text)
    end

    function SectionMixin:SetCategoryID(categoryID)
        self.categoryID = categoryID
    end

    function SectionMixin:SetLeading(isLeading)
        self:height(isLeading and HEIGHT_LEADING or HEIGHT)
    end

    SectionMixin.AnimGroup = UIAnim.New()
    do
        local FadeInAlpha = UIAnim.Animate():property(UIAnim.Enum.Property.Alpha):duration(0.2):from(0):to(1)
        SectionMixin.AnimGroup:State("FADE_IN", function(frame)
            frame:SetAlpha(0)
            FadeInAlpha:Play(frame)
        end)

        local FadeOutAlpha = UIAnim.Animate():property(UIAnim.Enum.Property.Alpha):duration(0.2):to(0)
        SectionMixin.AnimGroup:State("FADE_OUT", function(frame)
            FadeOutAlpha:Play(frame)
        end)
    end

    OptionsFrame_Templates.Section = UIKit.Template(function(id, name, children, ...)
        local frame =
            Frame(name, {
                LayoutHorizontal(name, {
                    Frame(name .. ".Ornament")
                        :id("Ornament", id)
                        :size(ORNAMENT_SIZE, ORNAMENT_SIZE)
                        :background(OptionsFrame_Preload.UIDEF.Ornament),

                    Text(name .. ".Text")
                        :id("Text", id)
                        :size(TEXT_WIDTH, ORNAMENT_SIZE)
                        :fontObject(UIFont.UIFontObjectNormal12)
                        :textColor(OptionsFrame_Preload.Enum.Color.Primary)
                        :textJustifyH("LEFT")
                        :textJustifyV("MIDDLE")
                        :text("PH Placeholder")
                })
                    :point(UIKit.Enum.Point.Bottom)
                    :size(CONTENT_WIDTH, CONTENT_HEIGHT)
                    :x(CONTENT_X)
                    :layoutSpacing(LAYOUT_SPACING)
                    :layoutAlignmentV(UIKit.Enum.Direction.Justified)
            })
            :size(WIDTH, HEIGHT)

        frame.Ornament = UIKit.GetElementById("Ornament", id)
        frame.OrnamentTexture = frame.Ornament:GetTextureFrame()
        frame.Text = UIKit.GetElementById("Text", id)

        Mixin(frame, SectionMixin)
        frame:OnLoad()

        return frame
    end)
end

do --Card
    local WIDTH = 215
    local HEIGHT = WIDTH / 0.75
    local BACKGROUND_SIZE = UIKit.Define.Fill{}
    local INSET_SIZE = UIKit.Define.Fill{ delta = 12 }
    local BADGE_TEXT_WIDTH = UIKit.UI.FIT
    local BADGE_TEXT_HEIGHT = UIKit.UI.P_FILL
    local BADGE_CONTENT_SIZE = UIKit.Define.Percentage{ value = 100, operator = "-", delta = 2 }
    local IMAGE_WIDTH = UIKit.UI.P_FILL
    local IMAGE_HEIGHT = WIDTH / 2
    local CONTENT_WIDTH = UIKit.UI.P_FILL
    local CONTENT_HEIGHT = UIKit.Define.Percentage{ value = 100, operator = "-", delta = IMAGE_HEIGHT }
    local CONTENT_INSET_SIZE = UIKit.Define.Fill{ delta = 32 }
    local CONTENT_FOOTER_WIDTH = UIKit.UI.P_FILL
    local CONTENT_FOOTER_HEIGHT = 24
    local CONTENT_MAIN_WIDTH = UIKit.UI.P_FILL
    local CONTENT_MAIN_HEIGHT = UIKit.Define.Percentage{ value = 100, operator = "-", delta = CONTENT_FOOTER_HEIGHT }
    local CONTENT_MAIN_TITLE_WIDTH = UIKit.UI.P_FILL
    local CONTENT_MAIN_TITLE_HEIGHT = UIKit.Define.Fit{}
    local CONTENT_MAIN_DESCRIPTION_WIDTH = UIKit.UI.P_FILL
    local CONTENT_MAIN_DESCRIPTION_HEIGHT = UIKit.Define.Fit{}
    local CONTENT_FOOTER_BUTTON_WIDTH = UIKit.UI.P_FILL
    local CONTENT_FOOTER_BUTTON_HEIGHT = UIKit.UI.P_FILL

    local CardMixin = CreateFromMixins(UICSharedMixin.ButtonMixin)

    function CardMixin:OnLoad()
        self:InitButton()

        self.data = nil
        self.isAlwaysEnabled = nil
        self.isActivated = nil
        self.key = nil

        self.Content.Footer.Button:SetOnClick(function() self:OnClick() end)
        self.ActivationEffect:Hide()
        self.ActivationEffectMask:Hide()

        self:HookButtonStateChange(self.UpdateAnimation)
        self.HitRect:AddOnEnter(function()
            self:OnEnter()
            self.Content.Footer.Button:OnEnter()
            self:ShowTooltip()
        end)
        self.HitRect:AddOnLeave(function()
            self:OnLeave()
            self.Content.Footer.Button:OnLeave()
            self:HideTooltip()
        end)
        self.HitRect:AddOnMouseUp(function(button)
            if button == "LeftButton" then
                self.Content.Footer.Button:OnMouseUp(button)
                self.Content.Footer.Button:OnClick(button)
            elseif button == "RightButton" then
                self:OnAltAction()
            end
        end)
        self.HitRect:AddOnMouseDown(function(button)
            self.Content.Footer.Button:OnMouseDown(button)
        end)
    end

    function CardMixin:OnClick()
        if not self.key or self.isAlwaysEnabled then
            return
        end
        self.isActivated = (not self.isActivated)
        OptionsFrame.SetModuleActive(self.key, self.isActivated)
        self:Refresh(true)
    end

    function CardMixin:OnAltAction()
        if not self.data or not self.data.altActionText or not self.data.altActionFunc then return end
        self.data.altActionFunc()
    end

    function CardMixin:SetData(data)
        self.data = data
        if self.data then
            self:SetKey(data.key)
            self:SetImage(data.image)
            self:SetTitle(data.name)
            self:SetDescription(data.description)
            self:SetBadgeShown(data.new)
            self:SetAlwaysEnabled(data.alwaysEnabled)
            self:Refresh()
            self.Content.Main:_Render()
        end
    end

    function CardMixin:SetKey(key)
        self.key = key
        self:Refresh()
    end

    function CardMixin:SetBadgeShown(shown)
        self.Badge:SetShown(shown)
    end

    function CardMixin:SetImage(texturePath)
        self.Image.BackgroundTexture:SetTexture(texturePath)
    end

    function CardMixin:SetTitle(titleText)
        self.Content.Main.Title:SetText(titleText)
    end

    function CardMixin:SetDescription(descriptionText)
        local text = descriptionText
        if #text > 75 then
            text = string.sub(descriptionText, 0, 75) .. "..."
        end
        self.Content.Main.Description:SetText(text)
    end

    function CardMixin:SetAlwaysEnabled(enabled)
        self.isAlwaysEnabled = enabled
        self.Content.Footer.Button:SetShown(not enabled)
        self.Content.Footer.AlwaysEnabled:SetShown(enabled)
    end

    function CardMixin:HasTooltip()
        return GameTooltip:GetOwner() == self
    end

    function CardMixin:ShowTooltip()
        GameTooltip:ClearAllPoints()
        GameTooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", 4, 0)
        GameTooltip:SetOwner(self, "ANCHOR_PRESERVE")

        GameTooltip:AddLine(self.data.name, 1, 1, 1)
        GameTooltip:AddLine(self.data.description, nil, nil, nil, true)

        local hasActionLine = false

        if not self.data.alwaysEnabled then
            if not hasActionLine then
                GameTooltip:AddLine(" ")
                hasActionLine = true
            end
            GameTooltip:AddLine(L["OPTIONS_ACTION_PREFIX"] .. (self.isActivated and L["OPTIONS_DEACTIVATE"] or L["OPTIONS_ACTIVATE"]) .. L["OPTIONS_ACTION_SUFFIX"], GenericEnum.ColorRGB01.GREEN_FONT_COLOR.r, GenericEnum.ColorRGB01.GREEN_FONT_COLOR.g, GenericEnum.ColorRGB01.GREEN_FONT_COLOR.b)
        end

        if self.data.altActionText and self.data.altActionFunc then
            if not hasActionLine then
                GameTooltip:AddLine(" ")
                hasActionLine = true
            end
            GameTooltip:AddLine(L["OPTIONS_ALT_ACTION_PREFIX"] .. self.data.altActionText .. L["OPTIONS_ALT_ACTION_SUFFIX"], GenericEnum.ColorRGB01.GREEN_FONT_COLOR.r, GenericEnum.ColorRGB01.GREEN_FONT_COLOR.g, GenericEnum.ColorRGB01.GREEN_FONT_COLOR.b)
        end

        GameTooltip:Show()
    end

    function CardMixin:HideTooltip()
        if self:HasTooltip() then
            GameTooltip:Hide()
        end
    end

    function CardMixin:Refresh(userInput)
        self.isActivated = (Config.DBGlobal:GetVariable(self.key) == true)
        if self.isActivated then
            self.Content.Footer.Button:SetText(L["OPTIONS_DEACTIVATE"])
            self.AnimGroup:Play("ACTIVATION", self, not userInput)
        else
            self.Content.Footer.Button:SetText(L["OPTIONS_ACTIVATE"])
            self.AnimGroup:Play("DEACTIVATION", self, not userInput)
        end

        if self:HasTooltip() then --Refresh tooltip
            self:ShowTooltip()
        end
    end

    function CardMixin:UpdateAnimation()
        local buttonState = self:GetButtonState()
        if buttonState ~= "NORMAL" then
            self.Background:background(OptionsFrame_Preload.UIDEF.UICard_Highlighted)
        else
            self.Background:background(OptionsFrame_Preload.UIDEF.UICard)
        end
    end

    CardMixin.AnimGroup = UIAnim.New()
    do
        local FadeInAlpha = UIAnim.Animate():property(UIAnim.Enum.Property.Alpha):duration(0.2):from(0):to(1)
        CardMixin.AnimGroup:State("FADE_IN", function(frame)
            frame:SetAlpha(0)
            FadeInAlpha:Play(frame)
        end)

        local FadeOutAlpha = UIAnim.Animate():property(UIAnim.Enum.Property.Alpha):duration(0.2):to(0)
        CardMixin.AnimGroup:State("FADE_OUT", function(frame)
            FadeOutAlpha:Play(frame)
        end)

        local ActivationTimer = nil
        local ActivationFrameAlpha = UIAnim.Animate():wait(0.6):property(UIAnim.Enum.Property.Alpha):duration(0.2):to(1)
        local ActivationIntroAlpha = UIAnim.Animate():property(UIAnim.Enum.Property.Alpha):duration(0.5):from(0):to(1)
        local ActivationScale = UIAnim.Animate():property(UIAnim.Enum.Property.Scale):duration(1):easing(UIAnim.Enum.Easing.ExpoIn):from(0.01):to(15)
        local ActivationOutroAlpha = UIAnim.Animate():wait(1):property(UIAnim.Enum.Property.Alpha):duration(0.5):from(1):to(0)
        CardMixin.AnimGroup:State("ACTIVATION", function(frame, forceInstant)
            if frame.AnimGroup:IsPlaying(frame, "ACTIVATION") or frame.AnimGroup:IsPlaying(frame, "DEACTIVATION") then
                frame.AnimGroup:Stop()
            end

            if ActivationTimer then
                ActivationTimer:Cancel()
                ActivationTimer = nil
            end

            if forceInstant then
                frame.Container:SetAlpha(1)
                frame.ActivationEffect:Hide()
                frame.ActivationEffectMask:Hide()
            else
                frame.ActivationEffect:Show()
                frame.ActivationEffectMask:Show()
                frame.ActivationEffect:SetAlpha(0)

                ActivationFrameAlpha:Play(frame.Container)
                ActivationIntroAlpha:Play(frame.ActivationEffect)
                ActivationScale:Play(frame.ActivationEffectMask)
                ActivationOutroAlpha:Play(frame.ActivationEffect)

                C_Timer.After(0.2, function()
                    Sound.PlaySound("UI", 232153)
                end)

                ActivationTimer = C_Timer.NewTimer(2, function()
                    ActivationTimer = nil
                    frame.ActivationEffect:Hide()
                    frame.ActivationEffectMask:Hide()
                end)
            end
        end)

        local DeactivationFrameAlpha = UIAnim.Animate():property(UIAnim.Enum.Property.Alpha):duration(0.2):to(0.375)
        CardMixin.AnimGroup:State("DEACTIVATION", function(frame, forceInstant)
            if frame.AnimGroup:IsPlaying(frame, "ACTIVATION") or frame.AnimGroup:IsPlaying(frame, "DEACTIVATION") then
                frame.AnimGroup:Stop()
            end

            frame.ActivationEffect:Hide()
            frame.ActivationEffectMask:Hide()

            if forceInstant then
                frame.Container:SetAlpha(0.375)
            else
                DeactivationFrameAlpha:Play(frame.Container)
            end
        end)
    end

    OptionsFrame_Templates.Card = UIKit.Template(function(id, name, children, ...)
        local frame = Frame(name, {
                Frame(name .. ".Container", {
                    HitRect(name .. ".HitRect")
                        :id("HitRect", id)
                        :size(UIKit.UI.FILL)
                        :frameLevel(99),

                    Frame(name .. ".Background")
                        :id("Background", id)
                        :size(BACKGROUND_SIZE)
                        :background(OptionsFrame_Preload.UIDEF.UICard)
                        :frameLevel(1),

                    Frame(name .. ".Inset", {
                        Frame(name .. ".Shadow")
                            :id("Shadow", id)
                            :point(UIKit.Enum.Point.Top)
                            :size(IMAGE_WIDTH, 75)
                            :y(-IMAGE_HEIGHT)
                            :background(OptionsFrame_Preload.UIDEF.UICardShadow)
                            :alpha(0.8)
                            :frameLevel(2),

                        Frame(name .. ".Image", {
                            Frame(name .. ".Image.Mask")
                                :id("Image.Mask", id)
                                :size(UIKit.UI.FILL)
                                :maskBackground(OptionsFrame_Preload.UIDEF.UICardPreviewImageMask),

                            Frame(name .. ".Image.Background")
                                :id("Image.Background", id)
                                :size(UIKit.UI.FILL)
                                :background(UIKit.UI.TEXTURE_NIL)
                                :mask(UIKit.NewGroupCaptureString("Image.Mask", id))
                        })
                            :id("Image", id)
                            :point(UIKit.Enum.Point.Top)
                            :size(IMAGE_WIDTH, IMAGE_HEIGHT)
                            :frameLevel(3),

                        Frame(name .. ".Badge", {
                            Frame(name .. ".Badge.Background")
                                :id("Badge.Background", id)
                                :size(UIKit.Define.Fill{})
                                :background(OptionsFrame_Preload.UIDEF.UIBadge),

                            LayoutHorizontal(name .. ".Badge.Content", {
                                Frame(name .. ".Badge.Icon")
                                    :id("Badge.Icon", id)
                                    :size(14, 14)
                                    :background(OptionsFrame_Preload.UIDEF.Star),

                                Text(name .. ".Badge.Text")
                                    :id("Badge.Text", id)
                                    :size(BADGE_TEXT_WIDTH, BADGE_TEXT_HEIGHT)
                                    :fontObject(UIFont.UIFontObjectNormal11)
                                    :textColor(OptionsFrame_Preload.Enum.Color.Badge)
                                    :textJustifyH("LEFT")
                                    :textJustifyV("MIDDLE")
                                    :text(L["OPTIONS_NEW"])
                            })
                                :id("Badge.Content", id)
                                :point(UIKit.Enum.Point.Center)
                                :size(BADGE_CONTENT_SIZE, BADGE_CONTENT_SIZE)
                                :layoutAlignmentV(UIKit.Enum.Direction.Justified)
                                :layoutSpacing(2)
                        })
                            :id("Badge", id)
                            :point(UIKit.Enum.Point.TopLeft)
                            :position(3, -3)
                            :size(36, 18)
                            :frameLevel(4),

                        Frame(name .. ".Content", {
                            Frame{
                                LayoutVertical(name .. ".Content.Main", {
                                    Text(name .. ".Title")
                                        :id("Content.Main.Title", id)
                                        :size(CONTENT_MAIN_TITLE_WIDTH, CONTENT_MAIN_TITLE_HEIGHT)
                                        :fontObject(UIFont.UIFontObjectNormal14)
                                        :textColor(OptionsFrame_Preload.Enum.Color.Primary)
                                        :textJustifyH("LEFT")
                                        :textJustifyV("MIDDLE"),

                                    Text(name .. ".Description")
                                        :id("Content.Main.Description", id)
                                        :size(CONTENT_MAIN_DESCRIPTION_WIDTH, CONTENT_MAIN_DESCRIPTION_HEIGHT)
                                        :fontObject(UIFont.UIFontObjectNormal12)
                                        :textColor(OptionsFrame_Preload.Enum.Color.Primary)
                                        :textJustifyH("LEFT")
                                        :textJustifyV("TOP")
                                        :alpha(0.7)
                                })
                                    :id("Content.Main", id)
                                    :point(UIKit.Enum.Point.Top)
                                    :size(CONTENT_MAIN_WIDTH, CONTENT_MAIN_HEIGHT)
                                    :layoutSpacing(12)
                                    :frameLevel(4),

                                Frame(name .. ".Content.EdgeFade")
                                    :id("Content.EdgeFade", id)
                                    :point(UIKit.Enum.Point.Bottom)
                                    :size(CONTENT_MAIN_WIDTH, 75)
                                    :background(OptionsFrame_Preload.UIDEF.UICardEdgeFade)
                                    :frameLevel(6),

                                Frame(name .. ".Content.Footer", {
                                    OptionsFrame_Templates.Button(name .. ".Content.Footer.Button")
                                        :id("Content.Footer.Button", id)
                                        :size(CONTENT_FOOTER_BUTTON_WIDTH, CONTENT_FOOTER_BUTTON_HEIGHT)
                                        :point(UIKit.Enum.Point.Center),

                                    Text(name .. ".Content.Footer.AlwaysEnabled")
                                        :id("Content.Footer.AlwaysEnabled", id)
                                        :size(CONTENT_FOOTER_BUTTON_WIDTH, CONTENT_FOOTER_BUTTON_HEIGHT)
                                        :point(UIKit.Enum.Point.Center)
                                        :fontObject(UIFont.UIFontObjectNormal12)
                                        :textColor(OptionsFrame_Preload.Enum.Color.Primary)
                                        :text(L["OPTIONS_ALWAYS_ACTIVATED"])
                                        :alpha(0.5)
                                })
                                    :id("Content.Footer", id)
                                    :point(UIKit.Enum.Point.Bottom)
                                    :size(CONTENT_FOOTER_WIDTH, CONTENT_FOOTER_HEIGHT)
                                    :frameLevel(6)
                            }
                                :size(CONTENT_INSET_SIZE)
                        })
                            :id("Content", id)
                            :point(UIKit.Enum.Point.Bottom)
                            :size(CONTENT_WIDTH, CONTENT_HEIGHT)
                            :frameLevel(3),

                        Frame(name .. ".ActivationEffectMask")
                            :id("ActivationEffectMask", id)
                            :point(UIKit.Enum.Point.Center)
                            :size(125, 125)
                            :maskBackground(OptionsFrame_Preload.UIDEF.UICardActivationEffectMask)
                            :frameLevel(9),

                        Frame(name .. ".ActivationEffect")
                            :id("ActivationEffect", id)
                            :size(UIKit.UI.FILL)
                            :background(OptionsFrame_Preload.UIDEF.UICardActivationEffect)
                            :mask(UIKit.NewGroupCaptureString("ActivationEffectMask", id))
                            :frameLevel(9)
                            :ignoreParentAlpha(true)
                    })
                        :size(INSET_SIZE)
                })
                    :id("Container", id)
                    :point(UIKit.Enum.Point.Center)
                    :size(UIKit.UI.P_FILL, UIKit.UI.P_FILL)
            })
            :size(WIDTH, HEIGHT)

        frame.Container = UIKit.GetElementById("Container", id)
        frame.HitRect = UIKit.GetElementById("HitRect", id)
        frame.Background = UIKit.GetElementById("Background", id)
        frame.Inset = UIKit.GetElementById("Inset", id)
        frame.Shadow = UIKit.GetElementById("Shadow", id)
        frame.ShadowTexture = frame.Shadow:GetTextureFrame()
        frame.Image = UIKit.GetElementById("Image", id)
        frame.Image.Mask = UIKit.GetElementById("Image.Mask", id)
        frame.Image.Background = UIKit.GetElementById("Image.Background", id)
        frame.Image.BackgroundTexture = frame.Image.Background:GetTextureFrame()
        frame.Badge = UIKit.GetElementById("Badge", id)
        frame.Badge.Background = UIKit.GetElementById("Badge.Background", id)
        frame.Badge.Icon = UIKit.GetElementById("Badge.Icon", id)
        frame.Badge.Text = UIKit.GetElementById("Badge.Text", id)
        frame.Content = UIKit.GetElementById("Content", id)
        frame.Content.Main = UIKit.GetElementById("Content.Main", id)
        frame.Content.Main.Title = UIKit.GetElementById("Content.Main.Title", id)
        frame.Content.Main.Description = UIKit.GetElementById("Content.Main.Description", id)
        frame.Content.EdgeFade = UIKit.GetElementById("Content.EdgeFade", id)
        frame.Content.Footer = UIKit.GetElementById("Content.Footer", id)
        frame.Content.Footer.Button = UIKit.GetElementById("Content.Footer.Button", id)
        frame.Content.Footer.AlwaysEnabled = UIKit.GetElementById("Content.Footer.AlwaysEnabled", id)
        frame.ActivationEffectMask = UIKit.GetElementById("ActivationEffectMask", id)
        frame.ActivationEffect = UIKit.GetElementById("ActivationEffect", id)

        Mixin(frame, CardMixin)
        frame:OnLoad()

        return frame
    end)
end
