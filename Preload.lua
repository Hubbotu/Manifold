local env = select(2, ...)
local Sound = env.modules:Import("packages\\sound")
local CallbackRegistry = env.modules:Import("packages\\callback-registry")
local UIFont = env.modules:Import("packages\\ui-font")
local SavedVariables = env.modules:Import("packages\\saved-variables")
local SlashCommand = env.modules:Import("packages\\slash-command")
local Path = env.modules:Import("packages\\path")


env.NAME = "Manifold"
env.ICON = Path.Root .. "\\Art\\Icons\\Logo"
env.ICON_ALT = Path.Root .. "\\Art\\Icons\\Logo-White"
env.VERSION_STRING = "0.1.2"
env.VERSION_NUMBER = 000102
env.DEBUG_MODE = false


local L = {}; env.L = L


local Enum = {}; env.Enum = Enum
do

end


local Config = {}; env.Config = Config
do
    Config.DBGlobal = nil
    Config.DBGlobalPersistent = nil
    Config.DBLocal = nil
    Config.DBLocalPersistent = nil

    local NAME_GLOBAL = "ManifoldDB_Global"
    local NAME_GLOBAL_PERSISTENT = "ManifoldDB_Global_Persistent"
    local NAME_LOCAL = "ManifoldDB_Local"
    local NAME_LOCAL_PERSISTENT = "ManifoldDB_Local_Persistent"

    ---@format disable
    local DB_GLOBAL_DEFAULTS            = {
        lastLoadedVersion = nil,
        fontPath = nil,

        -- Housing
        DecorMerchant = true,
        HouseChest = true,
        PlacedDecorList = true,
        DecorTooltip = false,

        -- Tooltip
        QuestDetailTooltip = true,
        ExperienceBarTooltip = true,

        -- Loot
        LootAlertPopup = true,

        -- Achievements
        AchievementLink = true,

        -- Transmog
        DressingRoom = true,
    }
    local DB_GLOBAL_PERSISTENT_DEFAULTS = {}
    local DB_LOCAL_DEFAULTS             = {
        --ExperienceBarTooltip
        ExperienceBar_Level_StartTime = nil,
        ExperienceBar_Session_StartTime = nil,
        ExperienceBar_Session_GainedXP = nil,
        ExperienceBar_Session_LastXP = nil,
    }
    local DB_LOCAL_PERSISTENT_DEFAULTS  = {}
    ---@format enable

    local DB_GLOBAL_MIGRATION           = {}

    function Config.LoadDB()
        if ManifoldDB_Global and ManifoldDB_Global.lastLoadedVersion == env.VERSION_NUMBER then
            -- Same version, skip migration
            SavedVariables.RegisterDatabase(NAME_GLOBAL).defaults(DB_GLOBAL_DEFAULTS)
            SavedVariables.RegisterDatabase(NAME_GLOBAL_PERSISTENT).defaults(DB_GLOBAL_PERSISTENT_DEFAULTS)
        else
            -- Migrate if new version
            SavedVariables.RegisterDatabase(NAME_GLOBAL).defaults(DB_GLOBAL_DEFAULTS).migrationPlan(DB_GLOBAL_MIGRATION)
            SavedVariables.RegisterDatabase(NAME_GLOBAL_PERSISTENT).defaults(DB_GLOBAL_PERSISTENT_DEFAULTS)
        end

        SavedVariables.RegisterDatabase(NAME_LOCAL).defaults(DB_LOCAL_DEFAULTS)
        SavedVariables.RegisterDatabase(NAME_LOCAL_PERSISTENT).defaults(DB_LOCAL_PERSISTENT_DEFAULTS)

        Config.DBGlobal = SavedVariables.GetDatabase(NAME_GLOBAL)
        Config.DBGlobalPersistent = SavedVariables.GetDatabase(NAME_GLOBAL_PERSISTENT)
        Config.DBLocal = SavedVariables.GetDatabase(NAME_LOCAL)
        Config.DBLocalPersistent = SavedVariables.GetDatabase(NAME_LOCAL_PERSISTENT)

        CallbackRegistry.Trigger("Preload.DatabaseReady")
    end
end


local SlashCmdRegister = {}
do
    local Handlers = {}
    do -- /manifold
        function Handlers.HandleSlashCmd_Manifold(_, tokens)
            ManifoldAPI_ToggleSettingsUI()
        end
    end

    local Schema = {
        -- /manifold
        {
            name     = "MANIFOLD",
            hook     = nil,
            command  = { "manifold" },
            callback = Handlers.HandleSlashCmd_Manifold
        }
    }

    function SlashCmdRegister.LoadSchema()
        SlashCommand.AddFromSchema(Schema)
    end
end


local SoundHandler = {}
do
    local function UpdateMainSoundLayer()
        local Settings_AudioGlobal = Config.DBGlobal:GetVariable("AudioGlobal")

        if Settings_AudioGlobal == true then
            Sound.SetEnabled("Main", true)
        elseif Settings_AudioGlobal == false then
            Sound.SetEnabled("Main", false)
        end
    end

    SavedVariables.OnChange("ManifoldDB_Global", "AudioGlobal", UpdateMainSoundLayer)

    function SoundHandler.Load()
        UpdateMainSoundLayer()
    end
end


local FontHandler = {}
do
    local function UpdateFonts()
        UIFont.CustomFont:RefreshFontList()

        local fontPath = Config.DBGlobal:GetVariable("fontPath")
        if fontPath == nil or not UIFont.CustomFont.FontExists(fontPath) then
            fontPath = UIFont.CustomFont.GetFontPathForIndex(1)
        end

        UIFont.SetNormalFont(fontPath)
        Config.DBGlobal:SetVariable("fontPath", fontPath)
    end

    SavedVariables.OnChange("ManifoldDB_Global", "fontPath", UpdateFonts)

    function FontHandler.Load()
        UpdateFonts()
    end
end


local function LoadAddon()
    Config.LoadDB()
    SlashCmdRegister.LoadSchema()
    SoundHandler.Load()

    Config.DBGlobal:SetVariable("lastLoadedVersion", env.VERSION_NUMBER)
    CallbackRegistry.Trigger("Preload.AddonReady")
end

CallbackRegistry.Add("WoWClient.OnAddonLoaded", LoadAddon)
CallbackRegistry.Add("WoWClient.OnPlayerLogin", FontHandler.Load)
