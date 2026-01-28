local HttpService = game:GetService("HttpService")

local HistoryManager = {}

local FILE = "UniversalChat/history.json"

local function ensureFile()
    if not isfolder("UniversalChat") then makefolder("UniversalChat") end
    if not isfile(FILE) then writefile(FILE, "[]") end
end

function HistoryManager:Load(channel)
    ensureFile()

    local raw = readfile(FILE)
    local ok, data = pcall(function()
        return HttpService:JSONDecode(raw)
    end)

    if not ok then
        writefile(FILE, "[]")
        return {}
    end

    if channel then
        local filtered = {}
        for _, entry in ipairs(data) do
            if entry.channel == channel then
                table.insert(filtered, entry)
            end
        end
        data = filtered
    end

    table.sort(data, function(a,b) return a.time > b.time end)
    return data
end

function HistoryManager:AddMessage(user, text, time, channel, userId)
    ensureFile()
    local raw = readfile(FILE)
    local data = HttpService:JSONDecode(raw)

    local newTime = tonumber(time)
    for _, entry in ipairs(data) do
        local entryTime = tonumber(entry.time)
        local sameTime = false
        if entryTime and newTime then
            sameTime = entryTime == newTime
        else
            sameTime = entry.time == time
        end
        if entry.user == user and entry.text == text and sameTime and entry.channel == channel then
            return false
        end
    end

    table.insert(data, {
        user = user,
        userId = userId,
        text = text,
        time = time,
        channel = channel
    })

    if #data > 300 then
        for _=1,#data-300 do table.remove(data,1) end
    end

    writefile(FILE, HttpService:JSONEncode(data))
    return true
end

function HistoryManager:ClearChannel(channel)
    ensureFile()
    local raw = readfile(FILE)
    local ok, data = pcall(function()
        return HttpService:JSONDecode(raw)
    end)

    if not ok then
        writefile(FILE, "[]")
        return 0
    end

    if not channel then
        local count = #data
        writefile(FILE, "[]")
        return count
    end

    local kept = {}
    local removed = 0
    for _, entry in ipairs(data) do
        if entry.channel == channel then
            removed = removed + 1
        else
            table.insert(kept, entry)
        end
    end

    writefile(FILE, HttpService:JSONEncode(kept))
    return removed
end

return HistoryManager
