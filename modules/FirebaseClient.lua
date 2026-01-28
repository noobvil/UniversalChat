local HttpService = game:GetService("HttpService")
local FirebaseClient = {}

FirebaseClient.BaseUrl = "https://demzcgdvoajpnbyszgze.supabase.co" 
FirebaseClient.ApiKey = "sb_publishable_QWo_YtkzYkAyqfrfSo2dDg_ux0Hbjgh"
FirebaseClient.Table = "messages"

FirebaseClient.Active = false
FirebaseClient.Channel = "global"
FirebaseClient.Interval = 2
FirebaseClient.ExtraChannels = {}
local lastTimestamp = os.time()
local HistoryManager, MessageRenderer, NotificationSystem, UI, Scroll

local request = http_request or request or (syn and syn.request)

local function http(method, url, body)
    local headers = {
        ["apikey"] = FirebaseClient.ApiKey,
        ["Authorization"] = "Bearer " .. FirebaseClient.ApiKey,
        ["Content-Type"] = "application/json",
        ["Prefer"] = "return=representation"
    }
    if request then
        local r = request({Url = url, Method = method, Headers = headers, Body = body and HttpService:JSONEncode(body) or nil})
        return r and r.Body or nil
    end
    local ok, response = pcall(function()
        return HttpService:RequestAsync({Url = url, Method = method, Headers = headers, Body = body and HttpService:JSONEncode(body) or nil})
    end)
    return ok and response.Body or nil
end


function FirebaseClient:Init(h, m, n, u, s)
    HistoryManager = h; MessageRenderer = m; NotificationSystem = n; UI = u; Scroll = s
end

function FirebaseClient:NormalizeKey(key)
    return tostring(key or "default"):gsub("[%.%#%$%[%]]", "_")
end

function FirebaseClient:SetExtraChannels(channels)
    self.ExtraChannels = channels or {}
end

function FirebaseClient:GetChannelUrl(key)
    return key 
end

function FirebaseClient:SetChannel(c)
    self.Channel = c
end


function FirebaseClient:Send(user, text)
    local data = {user = user, text = text, channel = self.Channel, time = os.time()}
    return http("POST", self.BaseUrl .. "/rest/v1/" .. self.Table, data)
end

function FirebaseClient:Start(callback)
    self.Active = true
    task.spawn(function()
        while self.Active do
            local url = string.format("%s/rest/v1/%s?channel=eq.%s&time=gt.%s&order=time.asc", 
                self.BaseUrl, self.Table, self.Channel, lastTimestamp)
            local raw = http("GET", url)
            if raw then
                local data = HttpService:JSONDecode(raw)
                if data and #data > 0 then
                    for _, msg in ipairs(data) do
                        if msg.time > lastTimestamp then lastTimestamp = msg.time end
                        callback(msg)
                        if UI.Minimized then NotificationSystem:NotifyNewMessage(msg.user) end
                    end
                end
            end
            task.wait(self.Interval)
        end
    end)
end

function FirebaseClient:SetAuthToken() end
function FirebaseClient:GetPresence() return {} end
function FirebaseClient:Process() end

return FirebaseClient

    local ok, response = pcall(function()
        return HttpService:RequestAsync({
            Url = url,
            Method = method,
            Headers = headers,
            Body = body and HttpService:JSONEncode(body) or nil
        })
    end)
    return ok and response.Body or nil
end

function FirebaseClient:Init(h, m, n, u, s)
    HistoryManager = h
    MessageRenderer = m
    NotificationSystem = n
    UI = u
    Scroll = s
end

function FirebaseClient:SetChannel(c)
    self.Channel = c
end

function FirebaseClient:Send(user, text)
    local data = {
        user = user,
        text = text,
        channel = self.Channel,
        time = os.time()
    }
    return http("POST", self.BaseUrl .. "/rest/v1/" .. self.Table, data)
end

function FirebaseClient:NormalizeKey(key)
    if not key then return "default" end
    return tostring(key):gsub("[%.%#%$%[%]]", "_")
end

function FirebaseClient:Start(callback, backgroundCallback)
    self.Active = true
    task.spawn(function()
        while self.Active do
            
            local url = string.format(
                "%s/rest/v1/%s?channel=eq.%s&time=gt.%s&order=time.asc",
                self.BaseUrl, self.Table, self.Channel, lastTimestamp
            )
            
            local raw = http("GET", url)
            if raw then
                local data = HttpService:JSONDecode(raw)
                if data and #data > 0 then
                    for _, msg in ipairs(data) do
                        
                        if msg.time > lastTimestamp then
                            lastTimestamp = msg.time
                        end
                        
                        callback(msg)
                        
                        if UI.Minimized then
                            NotificationSystem:NotifyNewMessage(msg.user)
                        end
                    end
                end
            end
            task.wait(self.Interval)
        end
    end)
end
function FirebaseClient:SetExtraChannels(channels)

    self.ExtraChannels = channels or {}

end



function FirebaseClient:GetChannelUrl(key)

    return key

end



FirebaseClient.ExtraChannels = {}
function FirebaseClient:SetAuthToken() end
function FirebaseClient:GetPresence() return {} end

return FirebaseClient
