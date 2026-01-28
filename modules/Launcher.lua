return function(
    UI_Core,
    AnimationEngine,
    ScrollController,
    InputField,
    MessageRenderer,
    NotificationSystem,
    HistoryManager,
    FirebaseClient
)

    local Players = game:GetService("Players")
    local HttpService = game:GetService("HttpService")
    local LocalPlayer = Players.LocalPlayer
    local cam = workspace.CurrentCamera
    local screen = cam.ViewportSize

    local WIDTH, HEIGHT = 380, 420
    local X = (screen.X - WIDTH) / 2
    local Y = (screen.Y - HEIGHT) / 2

    local UI = UI_Core:CreateWindow("Universal Chat")
    UI:SetPosition(X, Y)

    local margin = 12
    local tabBarHeight = 24
    local tabBarY = 32
    local presencePanelWidth = 140
    local presencePanelGap = 8
    local presenceToggleWidth = 18
    local scrollX = margin
    local scrollY = tabBarY + tabBarHeight + 6
    local scrollW = WIDTH - margin * 2
    local scrollH = HEIGHT - (scrollY + 92)

    local Scroll = ScrollController.new(UI.ContentFrame, scrollX, scrollY, scrollW, scrollH)

    local channelLabel = Instance.new("TextLabel")
    channelLabel.Name = "ChannelLabel"
    channelLabel.BackgroundTransparency = 1
    channelLabel.Position = UDim2.fromOffset(margin, 10)
    channelLabel.Size = UDim2.new(1, -(margin * 2), 0, 18)
    channelLabel.Font = Enum.Font.SourceSansBold
    channelLabel.TextSize = 16
    channelLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    channelLabel.TextScaled = true
    channelLabel.TextXAlignment = Enum.TextXAlignment.Left
    channelLabel.Text = "#global"
    channelLabel.Parent = UI.ContentFrame

    local tabBar = Instance.new("ScrollingFrame")
    tabBar.Name = "ChannelTabs"
    tabBar.BackgroundColor3 = Color3.fromRGB(40, 43, 48)
    tabBar.BorderSizePixel = 0
    tabBar.Position = UDim2.fromOffset(margin, tabBarY)
    tabBar.Size = UDim2.new(1, -(margin * 2), 0, tabBarHeight)
    tabBar.ScrollBarThickness = 4
    tabBar.ScrollingDirection = Enum.ScrollingDirection.X
    tabBar.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabBar.ClipsDescendants = true
    tabBar.Parent = UI.ContentFrame

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 6)
    tabLayout.Parent = tabBar

    local function updateTabCanvas()
        tabBar.CanvasSize = UDim2.fromOffset(tabLayout.AbsoluteContentSize.X, 0)
    end
    tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateTabCanvas)

    local presenceToggle = Instance.new("TextButton")
    presenceToggle.Name = "PresenceToggle"
    presenceToggle.BackgroundColor3 = Color3.fromRGB(40, 43, 48)
    presenceToggle.BorderSizePixel = 0
    presenceToggle.Position = UDim2.new(1, presencePanelGap, 0, scrollY)
    presenceToggle.Size = UDim2.fromOffset(presenceToggleWidth, scrollH)
    presenceToggle.Font = Enum.Font.SourceSansBold
    presenceToggle.TextSize = 14
    presenceToggle.TextColor3 = Color3.fromRGB(200, 200, 200)
    presenceToggle.Text = "<"
    presenceToggle.Parent = UI.ContentFrame

    local presencePanel = Instance.new("Frame")
    presencePanel.Name = "PresencePanel"
    presencePanel.BackgroundColor3 = Color3.fromRGB(40, 43, 48)
    presencePanel.BorderSizePixel = 0
    presencePanel.Position = UDim2.new(1, presencePanelGap + presenceToggleWidth, 0, scrollY)
    presencePanel.Size = UDim2.fromOffset(presencePanelWidth, scrollH)
    presencePanel.Parent = UI.ContentFrame

    local presenceTitle = Instance.new("TextLabel")
    presenceTitle.Name = "PresenceTitle"
    presenceTitle.BackgroundTransparency = 1
    presenceTitle.Position = UDim2.fromOffset(6, 6)
    presenceTitle.Size = UDim2.new(1, -12, 0, 16)
    presenceTitle.Font = Enum.Font.SourceSansBold
    presenceTitle.TextSize = 14
    presenceTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
    presenceTitle.TextXAlignment = Enum.TextXAlignment.Left
    presenceTitle.Text = "Online (0)"
    presenceTitle.Parent = presencePanel

    local presenceList = Instance.new("ScrollingFrame")
    presenceList.Name = "PresenceList"
    presenceList.BackgroundTransparency = 1
    presenceList.Position = UDim2.fromOffset(0, 26)
    presenceList.Size = UDim2.new(1, 0, 1, -32)
    presenceList.BorderSizePixel = 0
    presenceList.CanvasSize = UDim2.new(0, 0, 0, 0)
    presenceList.ScrollBarThickness = 4
    presenceList.Parent = presencePanel

    local presenceLayout = Instance.new("UIListLayout")
    presenceLayout.SortOrder = Enum.SortOrder.LayoutOrder
    presenceLayout.Padding = UDim.new(0, 4)
    presenceLayout.Parent = presenceList

    local function updatePresenceCanvas()
        presenceList.CanvasSize = UDim2.fromOffset(0, presenceLayout.AbsoluteContentSize.Y + 4)
    end
    presenceLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updatePresenceCanvas)

    local presenceExpanded = true
    local function setPresenceExpanded(expanded)
        presenceExpanded = expanded and true or false
        presencePanel.Visible = presenceExpanded
        if presenceExpanded then
            presenceToggle.Text = "<"
        else
            presenceToggle.Text = ">"
        end
    end
    presenceToggle.MouseButton1Click:Connect(function()
        setPresenceExpanded(not presenceExpanded)
    end)
    setPresenceExpanded(presenceExpanded)

    local baseWindowHeight = HEIGHT
    local Input = InputField.new(
        UI.ContentFrame,
        margin,
        HEIGHT - 80,
        WIDTH - margin * 2,
        40
    )
    Input.OnHeightChanged = function(newHeight)
        local extraHeight = newHeight - Input.MinHeight
        UI:SetHeight(baseWindowHeight + extraHeight)
    end
    Input:SetCommandSuggestions({
        {"/channel", "Switch to a channel"},
        {"/c", "Alias for /channel"},
        {"/join", "Open a channel without closing others"},
        {"/leave", "Close an open channel"},
        {"/dm", "Direct message a user"},
        {"/pm", "Alias for /dm"},
        {"/w", "Alias for /dm"},
        {"/clear", "Clear local chat history in this channel"},
        {"/server", "Switch to this server's channel"},
        {"/public", "Switch to #global"},
        {"/global", "Switch to #global"}
    })

    NotificationSystem:Init(UI)

    local ONLINE_COLOR = Color3.fromRGB(67, 181, 129)
    local OFFLINE_COLOR = Color3.fromRGB(160, 160, 160)
    local nameLabelsByUser = {}
    local userIdCache = {}
    local avatarCache = {}
    local pendingUserIdRequests = {}
    local pendingAvatarRequests = {}
    local CLOSED_DMS_FILE = "UniversalChat/closed_dms.json"

    if LocalPlayer and LocalPlayer.UserId then
        userIdCache[LocalPlayer.Name] = LocalPlayer.UserId
    end

    local function ensureClosedDMFile()
        if not isfolder("UniversalChat") then
            makefolder("UniversalChat")
        end
        if not isfile(CLOSED_DMS_FILE) then
            writefile(CLOSED_DMS_FILE, "{}")
        end
    end

    local function loadClosedDMs()
        ensureClosedDMFile()
        local raw = readfile(CLOSED_DMS_FILE)
        local ok, data = pcall(function()
            return HttpService:JSONDecode(raw)
        end)
        if not ok or type(data) ~= "table" then
            writefile(CLOSED_DMS_FILE, "{}")
            return {}
        end
        return data
    end

    local function saveClosedDMs(data)
        ensureClosedDMFile()
        writefile(CLOSED_DMS_FILE, HttpService:JSONEncode(data or {}))
    end

    local function isDMChannelKey(channelKey)
        return tostring(channelKey or ""):sub(1, 3) == "dm_"
    end

    local closedDMs = loadClosedDMs()

    local function markDMClosed(channelKey)
        if not isDMChannelKey(channelKey) then
            return
        end
        closedDMs[channelKey] = os.time()
        saveClosedDMs(closedDMs)
    end

    local function clearDMClosed(channelKey)
        if not isDMChannelKey(channelKey) then
            return
        end
        if closedDMs[channelKey] then
            closedDMs[channelKey] = nil
            saveClosedDMs(closedDMs)
        end
    end

    local function getNameColor(user)
        if FirebaseClient:IsUserOnline(user) then
            return ONLINE_COLOR
        end
        return OFFLINE_COLOR
    end

    local function resolveUserId(username, callback)
        if not username or username == "" then
            if callback then
                callback(nil)
            end
            return
        end

        if userIdCache[username] then
            if callback then
                callback(userIdCache[username])
            end
            return
        end

        if pendingUserIdRequests[username] then
            if callback then
                table.insert(pendingUserIdRequests[username], callback)
            end
            return
        end

        pendingUserIdRequests[username] = {}
        if callback then
            table.insert(pendingUserIdRequests[username], callback)
        end

        task.spawn(function()
            local resolvedId = nil
            local ok, id = pcall(function()
                return Players:GetUserIdFromNameAsync(username)
            end)
            if ok and id and id > 0 then
                resolvedId = id
            else
                local url = "https://api.roblox.com/users/get-by-username?username=" .. HttpService:UrlEncode(username)
                local success, response = pcall(function()
                    return HttpService:RequestAsync({
                        Url = url,
                        Method = "GET"
                    })
                end)
                if success and response and response.Success and response.Body then
                    local decoded = nil
                    local okDecode = pcall(function()
                        decoded = HttpService:JSONDecode(response.Body)
                    end)
                    if okDecode and type(decoded) == "table" and decoded.Id then
                        resolvedId = tonumber(decoded.Id)
                    end
                end
            end

            if resolvedId then
                userIdCache[username] = resolvedId
            end

            local callbacks = pendingUserIdRequests[username] or {}
            pendingUserIdRequests[username] = nil
            for _, cb in ipairs(callbacks) do
                cb(resolvedId)
            end
        end)
    end

    local function resolveAvatarUrl(userId, callback)
        if not userId then
            if callback then
                callback(nil)
            end
            return
        end

        if avatarCache[userId] then
            if callback then
                callback(avatarCache[userId])
            end
            return
        end

        if pendingAvatarRequests[userId] then
            if callback then
                table.insert(pendingAvatarRequests[userId], callback)
            end
            return
        end

        pendingAvatarRequests[userId] = {}
        if callback then
            table.insert(pendingAvatarRequests[userId], callback)
        end

        task.spawn(function()
            local resolvedUrl = nil
            local okThumb, content, isReady = pcall(function()
                return Players:GetUserThumbnailAsync(
                    userId,
                    Enum.ThumbnailType.HeadShot,
                    Enum.ThumbnailSize.Size48x48
                )
            end)
            if okThumb and content and content ~= "" and (isReady or isReady == nil) then
                resolvedUrl = content
            end

            if not resolvedUrl then
                local url = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds="
                    .. tostring(userId)
                    .. "&size=48x48&format=Png&isCircular=true"
                local success, response = pcall(function()
                    return HttpService:RequestAsync({
                        Url = url,
                        Method = "GET"
                    })
                end)
                if success and response and response.Success and response.Body then
                    local decoded = nil
                    local okDecode = pcall(function()
                        decoded = HttpService:JSONDecode(response.Body)
                    end)
                    if okDecode and decoded and type(decoded.data) == "table" then
                        local first = decoded.data[1]
                        if first and first.imageUrl then
                            resolvedUrl = first.imageUrl
                        end
                    end
                end
            end

            if resolvedUrl then
                avatarCache[userId] = resolvedUrl
            end

            local callbacks = pendingAvatarRequests[userId] or {}
            pendingAvatarRequests[userId] = nil
            for _, cb in ipairs(callbacks) do
                cb(resolvedUrl)
            end
        end)
    end

    local function trackNameLabel(user, label)
        if not label then
            return
        end
        if not nameLabelsByUser[user] then
            nameLabelsByUser[user] = {}
        end
        table.insert(nameLabelsByUser[user], label)
    end

    local function refreshNameColors()
        for user, labels in pairs(nameLabelsByUser) do
            local color = getNameColor(user)
            for _, label in ipairs(labels) do
                if label and label.Parent then
                    label.TextColor3 = color
                end
            end
        end
    end

    local serverChannelKey
    local currentChannelLabel
    local currentChannelKey

    local function buildDMAllowedKeys()
        if type(currentChannelLabel) == "string" and currentChannelLabel:sub(1, 3) == "dm-" then
            local target = currentChannelLabel:sub(4)
            if target ~= "" then
                local localKey = FirebaseClient:NormalizeKey(LocalPlayer.Name)
                local targetKey = FirebaseClient:NormalizeKey(target)
                return {
                    [localKey] = true,
                    [targetKey] = true
                }
            end
        end

        if isDMChannelKey(currentChannelKey) then
            local stripped = tostring(currentChannelKey or ""):sub(4)
            local first, second = stripped:match("(.+)_([^_]+)")
            if first and second then
                return {
                    [first] = true,
                    [second] = true
                }
            end
        end

        return nil
    end

    local function updatePresenceList(presence)
        local onlineUsers = {}
        local filterServerId = nil
        local dmAllowedKeys = buildDMAllowedKeys()
        if not dmAllowedKeys then
            if (currentChannelLabel == "server" and serverChannelKey)
                or (serverChannelKey and currentChannelKey == serverChannelKey) then
                filterServerId = game.JobId or ""
            elseif isDMChannelKey(currentChannelKey) then
                dmAllowedKeys = {}
                for part in tostring(currentChannelKey or ""):gmatch("[^_]+") do
                    dmAllowedKeys[part] = true
                end
            end
        end
        for key, entry in pairs(presence or {}) do
            if type(entry) == "table" then
                if dmAllowedKeys then
                    if not dmAllowedKeys[key] then
                        continue
                    end
                elseif filterServerId then
                    if entry.serverId ~= filterServerId then
                        continue
                    end
                end
                local name = entry.user or key
                if name and name ~= "" and FirebaseClient:IsUserOnline(name) then
                    table.insert(onlineUsers, name)
                end
            end
        end

        table.sort(onlineUsers, function(a, b)
            return tostring(a):lower() < tostring(b):lower()
        end)

        for _, child in ipairs(presenceList:GetChildren()) do
            if child:IsA("TextLabel") then
                child:Destroy()
            end
        end

        presenceTitle.Text = "Online (" .. tostring(#onlineUsers) .. ")"

        if #onlineUsers == 0 then
            local emptyLabel = Instance.new("TextLabel")
            emptyLabel.Name = "EmptyState"
            emptyLabel.BackgroundTransparency = 1
            emptyLabel.Size = UDim2.new(1, -12, 0, 16)
            emptyLabel.Position = UDim2.fromOffset(6, 0)
            emptyLabel.Font = Enum.Font.SourceSans
            emptyLabel.TextSize = 13
            emptyLabel.TextColor3 = Color3.fromRGB(140, 140, 140)
            emptyLabel.TextXAlignment = Enum.TextXAlignment.Left
            emptyLabel.Text = "No one online"
            emptyLabel.Parent = presenceList
            return
        end

        for i, name in ipairs(onlineUsers) do
            local label = Instance.new("TextLabel")
            label.Name = "User_" .. tostring(i)
            label.BackgroundTransparency = 1
            label.Size = UDim2.new(1, -12, 0, 16)
            label.Position = UDim2.fromOffset(6, 0)
            label.Font = Enum.Font.SourceSans
            label.TextSize = 13
            label.TextColor3 = ONLINE_COLOR
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Text = tostring(name)
            label.Parent = presenceList
        end
    end

    local function RenderMessage(msg)
        local layoutOrder = 0
        if type(msg.time) == "number" then
            layoutOrder = -msg.time
        end
        local r = MessageRenderer:RenderMessage(
            Scroll.Frame,
            {
                user = msg.user,
                userId = msg.userId,
                avatarUrl = msg.avatarUrl,
                showAvatar = true,
                text = msg.text,
                time = msg.time,
                self = (msg.user == LocalPlayer.Name),
                nameColor = getNameColor(msg.user),
                channelLabel = msg.channelLabel,
                layoutOrder = layoutOrder
            }
        )
        trackNameLabel(msg.user, r.Sender)
        return r
    end

    local function enrichMessageIdentity(msg, renderHandle)
        if msg.userId then
            resolveAvatarUrl(msg.userId, function(url)
                if url and renderHandle and renderHandle.Avatar then
                    renderHandle.Avatar.Image = url
                    renderHandle.Avatar.ImageTransparency = 0
                end
                msg.avatarUrl = url
            end)
            return
        end

        resolveUserId(msg.user, function(userId)
            if not userId then
                return
            end
            msg.userId = userId
            resolveAvatarUrl(userId, function(url)
                if url and renderHandle and renderHandle.Avatar then
                    renderHandle.Avatar.Image = url
                    renderHandle.Avatar.ImageTransparency = 0
                end
                msg.avatarUrl = url
            end)
        end)
    end

    local function sanitizeChannelLabel(text)
        local trimmed = (text or ""):match("^%s*(.-)%s*$")
        if trimmed == "" then
            trimmed = "global"
        end
        return trimmed
    end

    local function dmChannelKey(userA, userB)
        local rawA = tostring(userA or "")
        local rawB = tostring(userB or "")
        local a = FirebaseClient:NormalizeKey(rawA)
        local b = FirebaseClient:NormalizeKey(rawB)
        local aLetter = rawA:sub(1, 1):lower()
        local bLetter = rawB:sub(1, 1):lower()
        if aLetter == "" then
            aLetter = a:sub(1, 1)
        end
        if bLetter == "" then
            bLetter = b:sub(1, 1)
        end
        if aLetter > bLetter or (aLetter == bLetter and a > b) then
            a, b = b, a
        end
        return "dm_" .. a .. "_" .. b
    end

    local function dmPartnerFromKey(channelKey)
        local parts = {}
        for part in tostring(channelKey or ""):gmatch("[^_]+") do
            table.insert(parts, part)
        end
        if parts[1] ~= "dm" then
            return nil
        end

        local localKey = FirebaseClient:NormalizeKey(LocalPlayer.Name)
        if parts[2] == localKey then
            return parts[3]
        end
        if parts[3] == localKey then
            return parts[2]
        end
        return parts[2] or parts[3]
    end

    local function getServerChannelKey()
        local jobId = game.JobId
        if not jobId or jobId == "" then
            return nil
        end
        return FirebaseClient:NormalizeKey("server_" .. jobId)
    end

    serverChannelKey = getServerChannelKey()
    local defaultChannelLabel = serverChannelKey and "server" or "global"
    currentChannelLabel = defaultChannelLabel
    currentChannelKey = serverChannelKey or FirebaseClient:NormalizeKey(currentChannelLabel)
    local activeChannels = {}
    local activeChannelOrder = {}
    local activeChannelCount = 0

    local function resolveAuthToken()
        local env = getgenv and getgenv() or _G
        if not env then
            return nil
        end
        return env.FirebaseAuthIdToken
            or env.FirebaseAuthToken
            or env.FirebaseDatabaseSecret
            or env.FirebaseToken
    end

    local setChannel

    local function renderTabs()
        for _, child in ipairs(tabBar:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        for i, key in ipairs(activeChannelOrder) do
            local label = activeChannels[key] or key
            local button = Instance.new("TextButton")
            button.Name = "Tab_" .. label
            button.BackgroundColor3 = key == currentChannelKey and Color3.fromRGB(88, 101, 242)
                or Color3.fromRGB(54, 57, 63)
            button.BorderSizePixel = 0
            button.Size = UDim2.new(0, 60, 1, 0)
            button.AutomaticSize = Enum.AutomaticSize.X
            button.Font = Enum.Font.SourceSansBold
            button.TextSize = 14
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
            button.Text = "#" .. label
            button.LayoutOrder = i
            button.Parent = tabBar

            local padding = Instance.new("UIPadding")
            padding.PaddingLeft = UDim.new(0, 8)
            padding.PaddingRight = UDim.new(0, 8)
            padding.Parent = button

            button.MouseButton1Click:Connect(function()
                if key == currentChannelKey then
                    return
                end
                setChannel(label, key)
                NotificationSystem:ShowToast("Switched to #" .. label)
            end)
        end
        updateTabCanvas()
    end

    local function updateChannelLabel()
        local labels = {}
        for _, key in ipairs(activeChannelOrder) do
            table.insert(labels, "#" .. (activeChannels[key] or key))
        end
        channelLabel.Text = "Sending: #" .. currentChannelLabel .. " | Open: " .. table.concat(labels, ", ")
        Input:SetPlaceholder("Message #" .. currentChannelLabel .. " (or /dm name)")
        renderTabs()
    end

    local function loadChannelHistory()
        Scroll:Clear()
        local history = HistoryManager:Load(currentChannelKey)
        local latestEntry = history[1]
        if latestEntry and latestEntry.time then
            FirebaseClient:SeedLastTime(currentChannelKey, latestEntry.time)
        end
        for _, msg in ipairs(history) do
            msg.channelLabel = activeChannelCount > 1 and activeChannels[msg.channel] or nil
            local renderHandle = RenderMessage(msg)
            enrichMessageIdentity(msg, renderHandle)
        end
        Scroll:ScrollToTop()
    end

    local function updateFirebaseActiveChannels()
        FirebaseClient:SetExtraChannels(activeChannelOrder)
    end

    local function addActiveChannel(label, key)
        if not key or key == "" then
            return
        end
        if not activeChannels[key] then
            table.insert(activeChannelOrder, key)
            activeChannelCount = activeChannelCount + 1
        end
        activeChannels[key] = label
        updateFirebaseActiveChannels()
    end

    local function removeActiveChannel(key)
        if not key or key == "" then
            return
        end
        if not activeChannels[key] then
            return
        end
        activeChannels[key] = nil
        for i, channelKey in ipairs(activeChannelOrder) do
            if channelKey == key then
                table.remove(activeChannelOrder, i)
                activeChannelCount = math.max(activeChannelCount - 1, 0)
                break
            end
        end
        updateFirebaseActiveChannels()
    end

    local function findActiveKeyByLabel(label)
        for key, channelLabel in pairs(activeChannels) do
            if channelLabel == label then
                return key
            end
        end
        return nil
    end

    setChannel = function(label, key)
        currentChannelLabel = sanitizeChannelLabel(label)
        if currentChannelLabel == "server" and serverChannelKey then
            currentChannelKey = serverChannelKey
        else
            currentChannelKey = key or FirebaseClient:NormalizeKey(currentChannelLabel)
        end
        clearDMClosed(currentChannelKey)
        FirebaseClient:SetChannel(currentChannelKey)
        addActiveChannel(currentChannelLabel, currentChannelKey)
        updateChannelLabel()
        loadChannelHistory()
        updatePresenceList(FirebaseClient.Presence)
    end

    if serverChannelKey then
        addActiveChannel("global", FirebaseClient:NormalizeKey("global"))
    end
    addActiveChannel(currentChannelLabel, currentChannelKey)
    updateChannelLabel()
    loadChannelHistory()

    Input.OnSubmit = function(text)
        local command, args = text:match("^%s*/(%w+)%s*(.*)$")
        if command then
            command = command:lower()
            if command == "channel" or command == "c" then
                local channelName = sanitizeChannelLabel(args)
                setChannel(channelName)
                NotificationSystem:ShowToast("Switched to #" .. channelName)
                return
            elseif command == "join" then
                local channelName = sanitizeChannelLabel(args)
                local channelKey = nil
                if channelName == "server" and serverChannelKey then
                    channelKey = serverChannelKey
                elseif channelName:sub(1, 3) == "dm-" then
                    local target = channelName:sub(4)
                    channelKey = dmChannelKey(LocalPlayer.Name, target)
                else
                    channelKey = FirebaseClient:NormalizeKey(channelName)
                end
                clearDMClosed(channelKey)
                addActiveChannel(channelName, channelKey)
                updateChannelLabel()
                loadChannelHistory()
                NotificationSystem:ShowToast("Opened #" .. channelName)
                return
            elseif command == "leave" then
                local trimmedArgs = (args or ""):match("^%s*(.-)%s*$")
                local channelName = trimmedArgs == "" and currentChannelLabel or sanitizeChannelLabel(trimmedArgs)
                local channelKey = nil
                if channelName == "server" and serverChannelKey then
                    channelKey = serverChannelKey
                else
                    channelKey = findActiveKeyByLabel(channelName) or FirebaseClient:NormalizeKey(channelName)
                end
                if channelKey == currentChannelKey then
                    NotificationSystem:ShowToast("Use /channel to switch before leaving this channel.")
                    return
                end
                removeActiveChannel(channelKey)
                markDMClosed(channelKey)
                updateChannelLabel()
                loadChannelHistory()
                NotificationSystem:ShowToast("Closed #" .. channelName)
                return
            elseif command == "dm" or command == "pm" or command == "w" then
                local target = sanitizeChannelLabel(args)
                if target == "global" then
                    NotificationSystem:ShowToast("Usage: /dm <username>")
                    return
                end
                if FirebaseClient:NormalizeKey(target) == FirebaseClient:NormalizeKey(LocalPlayer.Name) then
                    NotificationSystem:ShowToast("You can't DM yourself.")
                    return
                end
                local key = dmChannelKey(LocalPlayer.Name, target)
                setChannel("dm-" .. target, key)
                NotificationSystem:ShowToast("Direct message: " .. target)
                return
            elseif command == "public" or command == "global" then
                setChannel("global", FirebaseClient:NormalizeKey("global"))
                NotificationSystem:ShowToast("Switched to #global")
                return
            elseif command == "server" then
                if not serverChannelKey then
                    NotificationSystem:ShowToast("Server channel unavailable in this environment.")
                    return
                end
                setChannel("server", serverChannelKey)
                NotificationSystem:ShowToast("Switched to #server")
                return
            elseif command == "clear" then
                HistoryManager:ClearChannel(currentChannelKey)
                Scroll:Clear()
                nameLabelsByUser = {}
                NotificationSystem:ShowToast("Cleared local history for #" .. currentChannelLabel)
                return
            end
        end

        local timestamp = os.time()
        FirebaseClient:SendMessage(LocalPlayer.Name, text, currentChannelKey, timestamp, LocalPlayer.UserId)

        local entry = {
            user = LocalPlayer.Name,
            userId = LocalPlayer.UserId,
            text = text,
            time = timestamp,
            channel = currentChannelKey
        }

        local added = HistoryManager:AddMessage(entry.user, entry.text, entry.time, entry.channel, entry.userId)
        if added then
            entry.channelLabel = activeChannelCount > 1 and activeChannels[entry.channel] or nil
            local renderHandle = RenderMessage(entry)
            enrichMessageIdentity(entry, renderHandle)
            Scroll:ScrollToTop()
        end
    end

    FirebaseClient:Init(
        HistoryManager,
        MessageRenderer,
        NotificationSystem,
        UI,
        Scroll
    )
    local authToken = resolveAuthToken()
    if authToken and authToken ~= "" then
        FirebaseClient:SetAuthToken(authToken)
    end

    FirebaseClient:SetChannel(currentChannelKey)
    updateFirebaseActiveChannels()
    updatePresenceList(FirebaseClient.Presence)
    FirebaseClient:Start(function(msg)
        if msg.channel ~= currentChannelKey then
            return
        end
        msg.channelLabel = activeChannelCount > 1 and activeChannels[msg.channel] or nil
        local renderHandle = RenderMessage(msg)
        enrichMessageIdentity(msg, renderHandle)
        Scroll:ScrollToTop()
    end, function(msg)
        if msg.user == LocalPlayer.Name then
            return
        end
        if tostring(msg.channel):sub(1, 3) ~= "dm_" then
            return
        end
        local closedAt = closedDMs[msg.channel]
        if closedAt and tonumber(msg.time) and msg.time <= closedAt then
            return
        end
        local partner = msg.user or dmPartnerFromKey(msg.channel) or "dm"
        if UI.Minimized then
            UI.Minimized = false
            UI:UpdateVisibility()
        end
        clearDMClosed(msg.channel)
        setChannel("dm-" .. partner, msg.channel)
    end, function(presence)
        refreshNameColors()
        updatePresenceList(presence)
    end)

    print("[UniversalChat] Loaded successfully.")

end
