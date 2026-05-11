local env = select(2, ...)
local Path = env.modules:Import("packages\\path")
local UIKit = env.modules:Import("packages\\ui-kit")
local React = env.modules:Import("packages\\react")
local GenericEnum = env.modules:Import("packages\\generic-enum")
local LootAlertPopup_Preload = env.modules:New("@\\LootAlertPopup\\Preload")

LootAlertPopup_Preload.PrimaryTextColor = React.New(GenericEnum.UIColorRGB.WHITE_FONT_COLOR)
LootAlertPopup_Preload.ItemComparisonTextColor = React.New(GenericEnum.UIColorRGB.WHITE_FONT_COLOR)

local ATLAS = UIKit.Define.Texture_Atlas{ path = Path.Root .. "\\Art\\LootAlertPopup\\LootAlertPopup" }
LootAlertPopup_Preload.UIDEF = {
    Spinner   = ATLAS{ inset = 0, scale = 1, left = 0 / 256, right = 64 / 256, top = 0 / 128, bottom = 64 / 128 },
    Tick      = ATLAS{ inset = 0, scale = 1, left = 0 / 256, right = 64 / 256, top = 64 / 128, bottom = 128 / 128 },
    LMB       = ATLAS{ inset = 0, scale = 1, left = 192 / 256, right = 256 / 256, top = 64 / 128, bottom = 128 / 128 },
    Upgrade   = ATLAS{ inset = 0, scale = 1, left = 64 / 256, right = 128 / 256, top = 64 / 128, bottom = 128 / 128 },
    Downgrade = ATLAS{ inset = 0, scale = 1, left = 128 / 256, right = 192 / 256, top = 64 / 128, bottom = 128 / 128 },
    UIFrame   = UIKit.Define.Texture_Atlas{ path = Path.Root .. "\\packages\\uic-common\\resources\\common", inset = 11, scale = 0.7, left = 4 / 512, right = 46 / 512, top = 330 / 512, bottom = 372 / 512 }
}
