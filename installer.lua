local http = request or http_request or syn.request

local function GET(url)
    local res = http({Url = url, Method = "GET"})
    return res and res.Body or ""
end

local BASE = "https://raw.githubusercontent.com/noobvil/UniversalChat/main/"

local FILES = {
    "main.lua",

    "modules/Launcher.lua",
    "modules/UI_Core.lua",
    "modules/AnimationEngine.lua",
    "modules/ScrollController.lua",
    "modules/InputField.lua",
    "modules/MessageRenderer.lua",
    "modules/NotificationSystem.lua",
    "modules/HistoryManager.lua",
    "modules/FirebaseClient.lua",
}

if not isfolder("UniversalChat") then makefolder("UniversalChat") end
if not isfolder("UniversalChat/modules") then makefolder("UniversalChat/modules") end

local function Download(path)
    local content = GET(BASE .. path)
    writefile("UniversalChat/" .. path, content)
    print("[UniversalChat] Downloaded:", path)
end

for _, f in ipairs(FILES) do
    Download(f)
end

print("\n[UniversalChat] Update complete.")
print("[UniversalChat] Launching...")

loadfile("UniversalChat/main.lua")()
