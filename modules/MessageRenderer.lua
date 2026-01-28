local MessageRenderer = {}

local COLOR_SELF  = Color3.fromRGB(88,101,242)
local COLOR_OTHER = Color3.fromRGB(49,51,56)

local FONT = 18
local NAME_FONT = 14
local TIME_FONT = 12
local MAX = 300
local PADX = 12
local PADY = 8
local NAME_PADY = 4
local AVATAR_SIZE = 24
local AVATAR_GAP = 8

local TextService = game:GetService("TextService")

local function Measure(text)
    return TextService:GetTextSize(
        text,
        FONT,
        Enum.Font.SourceSans,
        Vector2.new(MAX, 1000)
    )
end

local function FormatTimestamp(unixTime)
    if type(unixTime) ~= "number" then
        return ""
    end

    local ok, stamp = pcall(function()
        return os.date("%I:%M %p", unixTime)
    end)

    if not ok or not stamp then
        return ""
    end

    return stamp
end

function MessageRenderer:RenderMessage(parent, msg)
    local channelLabel = msg.channelLabel and tostring(msg.channelLabel) or nil
    local layoutOrder = msg.layoutOrder or 0
    local displayName = msg.user
    local showAvatar = msg.showAvatar ~= false
    if channelLabel and channelLabel ~= "" then
        displayName = string.format("%s  鈥�  #%s", msg.user, channelLabel)
    end
    local size = Measure(msg.text)
    local timestamp = FormatTimestamp(msg.time)
    local nameSize = TextService:GetTextSize(
        displayName,
        NAME_FONT,
        Enum.Font.SourceSansBold,
        Vector2.new(MAX, 1000)
    )
    local timeSize = TextService:GetTextSize(
        timestamp,
        TIME_FONT,
        Enum.Font.SourceSans,
        Vector2.new(MAX, 1000)
    )
    local nameLineHeight = math.max(nameSize.Y, timeSize.Y)
    local h = size.Y + nameLineHeight + PADY * 2 + NAME_PADY
    local contentOffset = showAvatar and (AVATAR_SIZE + AVATAR_GAP) or 0
    local contentX = PADX + contentOffset
    local w = MAX + PADX * 2 + contentOffset

    local container = Instance.new("Frame")
    container.Name = "MessageContainer"
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, 0, 0, h + 6)
    container.LayoutOrder = layoutOrder
    container.Parent = parent

    local bubble = Instance.new("Frame")
    bubble.Name = "Bubble"
    bubble.BackgroundColor3 = msg.self and COLOR_SELF or COLOR_OTHER
    bubble.BorderSizePixel = 0
    bubble.Position = UDim2.fromOffset(0, 0)
    bubble.Size = UDim2.fromOffset(w, h)
    bubble.Parent = container

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Sender"
    nameLabel.BackgroundTransparency = 1
    nameLabel.Position = UDim2.fromOffset(contentX, PADY)
    nameLabel.Size = UDim2.new(1, -(contentX + PADX), 0, nameLineHeight)
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.TextSize = NAME_FONT
    nameLabel.TextColor3 = msg.nameColor or Color3.fromRGB(220, 220, 220)
    nameLabel.TextWrapped = true
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextYAlignment = Enum.TextYAlignment.Top
    nameLabel.Text = displayName
    nameLabel.Parent = bubble

    local timeLabel = Instance.new("TextLabel")
    timeLabel.Name = "Timestamp"
    timeLabel.BackgroundTransparency = 1
    timeLabel.Position = UDim2.fromOffset(contentX, PADY)
    timeLabel.Size = UDim2.new(1, -(contentX + PADX), 0, nameLineHeight)
    timeLabel.Font = Enum.Font.SourceSans
    timeLabel.TextSize = TIME_FONT
    timeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    timeLabel.TextWrapped = true
    timeLabel.TextXAlignment = Enum.TextXAlignment.Right
    timeLabel.TextYAlignment = Enum.TextYAlignment.Top
    timeLabel.Text = timestamp
    timeLabel.Parent = bubble

    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "MessageText"
    textLabel.BackgroundTransparency = 1
    textLabel.Position = UDim2.fromOffset(contentX, PADY + nameLineHeight + NAME_PADY)
    textLabel.Size = UDim2.new(1, -(contentX + PADX), 1, -(PADY * 2 + nameLineHeight + NAME_PADY))
    textLabel.Font = Enum.Font.SourceSans
    textLabel.TextSize = FONT
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextWrapped = true
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Top
    textLabel.Text = msg.text
    textLabel.Parent = bubble

    local avatar = nil
    if showAvatar then
        avatar = Instance.new("ImageLabel")
        avatar.Name = "Avatar"
        avatar.BackgroundTransparency = 1
        avatar.Position = UDim2.fromOffset(PADX, PADY)
        avatar.Size = UDim2.fromOffset(AVATAR_SIZE, AVATAR_SIZE)
        avatar.Image = msg.avatarUrl or ""
        avatar.ImageTransparency = (msg.avatarUrl and msg.avatarUrl ~= "") and 0 or 1
        avatar.ScaleType = Enum.ScaleType.Crop
        avatar.Parent = bubble

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = avatar
    end

    return {
        Container = container,
        Bubble = bubble,
        Sender = nameLabel,
        Avatar = avatar,
        Height = h + 6,
    }
end

return MessageRenderer
