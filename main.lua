local function LoadModule(name)
    return loadfile("UniversalChat/modules/" .. name .. ".lua")()
end

local UI_Core            = LoadModule("UI_Core")
local AnimationEngine    = LoadModule("AnimationEngine")
local ScrollController   = LoadModule("ScrollController")
local InputField         = LoadModule("InputField")
local MessageRenderer    = LoadModule("MessageRenderer")
local NotificationSystem = LoadModule("NotificationSystem")
local HistoryManager     = LoadModule("HistoryManager")
local FirebaseClient     = LoadModule("FirebaseClient")

local Launcher           = LoadModule("Launcher")

Launcher(
    UI_Core,
    AnimationEngine,
    ScrollController,
    InputField,
    MessageRenderer,
    NotificationSystem,
    HistoryManager,
    FirebaseClient
)
