local InputField = {}

local TextService = game:GetService("TextService")
local UIS = game:GetService("UserInputService")

local FONT_SIZE = 18
local BG_COLOR = Color3.fromRGB(56,58,64)
local FOCUS_COLOR = Color3.fromRGB(88,101,242)
local SUGGESTION_BG = Color3.fromRGB(40, 42, 48)
local SUGGESTION_BORDER = Color3.fromRGB(70, 72, 78)
local SUGGESTION_TEXT = Color3.fromRGB(200, 200, 200)
local SUGGESTION_LINE_HEIGHT = 18
local SUGGESTION_MAX = 5
local MIN_HEIGHT = 40
local MAX_HEIGHT = 140
local VERTICAL_PADDING = 8

function InputField.new(parent, x, y, w, h)
    local self = setmetatable({}, {__index = InputField})

    self.X, self.Y = x, y
    self.Width, self.Height = w, h
    self.MinHeight = h or MIN_HEIGHT
    self.MaxHeight = math.max(self.MinHeight, MAX_HEIGHT)
    self.Text = ""
    self.Focused = false
    self.CommandSuggestions = {}
    self.SuppressNextNewline = false
    self.CleaningText = false

    self.Outline = Instance.new("Frame")
    self.Outline.Name = "InputOutline"
    self.Outline.BackgroundColor3 = FOCUS_COLOR
    self.Outline.BackgroundTransparency = 1
    self.Outline.BorderSizePixel = 0
    self.Outline.Position = UDim2.fromOffset(x - 1, y - 1)
    self.Outline.Size = UDim2.fromOffset(w + 2, h + 2)
    self.Outline.Visible = true
    self.Outline.Parent = parent

    self.BG = Instance.new("Frame")
    self.BG.Name = "InputBG"
    self.BG.BackgroundColor3 = BG_COLOR
    self.BG.BorderSizePixel = 0
    self.BG.ClipsDescendants = true
    self.BG.Position = UDim2.fromOffset(1, 1)
    self.BG.Size = UDim2.new(1, -2, 1, -2)
    self.BG.Parent = self.Outline

    self.TextBox = Instance.new("TextBox")
    self.TextBox.Name = "InputText"
    self.TextBox.BackgroundTransparency = 1
    self.TextBox.Position = UDim2.fromOffset(8, 4)
    self.TextBox.Size = UDim2.new(1, -16, 0, self.MinHeight - VERTICAL_PADDING)
    self.TextBox.Font = Enum.Font.SourceSans
    self.TextBox.TextSize = FONT_SIZE
    self.TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.TextBox.TextTruncate = Enum.TextTruncate.None
    self.TextBox.TextWrapped = true
    self.TextBox.MultiLine = true
    self.TextBox.TextXAlignment = Enum.TextXAlignment.Left
    self.TextBox.TextYAlignment = Enum.TextYAlignment.Top
    self.TextBox.ClearTextOnFocus = false
    self.TextBox.Text = ""
    self.TextBox.PlaceholderText = "Message..."
    self.TextBox.Parent = self.BG

    self.SuggestionFrame = Instance.new("Frame")
    self.SuggestionFrame.Name = "InputSuggestions"
    self.SuggestionFrame.BackgroundColor3 = SUGGESTION_BG
    self.SuggestionFrame.BorderColor3 = SUGGESTION_BORDER
    self.SuggestionFrame.BorderSizePixel = 1
    self.SuggestionFrame.Position = UDim2.fromOffset(x, y + h + 4)
    self.SuggestionFrame.Size = UDim2.fromOffset(w, 0)
    self.SuggestionFrame.Visible = false
    self.SuggestionFrame.Parent = parent

    self.SuggestionText = Instance.new("TextLabel")
    self.SuggestionText.Name = "InputSuggestionsText"
    self.SuggestionText.BackgroundTransparency = 1
    self.SuggestionText.Position = UDim2.fromOffset(8, 6)
    self.SuggestionText.Size = UDim2.new(1, -16, 1, -12)
    self.SuggestionText.Font = Enum.Font.SourceSans
    self.SuggestionText.TextSize = 14
    self.SuggestionText.TextColor3 = SUGGESTION_TEXT
    self.SuggestionText.TextXAlignment = Enum.TextXAlignment.Left
    self.SuggestionText.TextYAlignment = Enum.TextYAlignment.Top
    self.SuggestionText.TextWrapped = true
    self.SuggestionText.Text = ""
    self.SuggestionText.Parent = self.SuggestionFrame

    self.TextBox.Focused:Connect(function()
        self.Focused = true
        self.Outline.BackgroundTransparency = 0
    end)

    self.TextBox.FocusLost:Connect(function(enterPressed)
        self.Focused = false
        self.Outline.BackgroundTransparency = 1
        self.SuggestionFrame.Visible = false
        if enterPressed then
            self:Submit()
        end
    end)

    UIS.InputBegan:Connect(function(input)
        if not self.TextBox:IsFocused() then
            return
        end
        if input.UserInputType ~= Enum.UserInputType.Keyboard then
            return
        end

        if input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.KeypadEnter then
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) or UIS:IsKeyDown(Enum.KeyCode.RightShift) then
                return
            end
            self.SuppressNextNewline = true
            self:Submit()
        end
    end)

    self.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
        if self.SuppressNextNewline and not self.CleaningText then
            self.SuppressNextNewline = false
            if self.TextBox.Text:find("[\r\n]") then
                self.CleaningText = true
                self.TextBox.Text = self.TextBox.Text:gsub("[%r\n]+$", "")
                self.CleaningText = false
                return
            end
        end
        self:UpdateSuggestions()
        self:UpdateHeight()
    end)

    self.TextBox:GetPropertyChangedSignal("TextBounds"):Connect(function()
        self:UpdateHeight()
    end)

    return self
end

function InputField:Focus()
    self.TextBox:CaptureFocus()
end

function InputField:Unfocus()
    self.TextBox:ReleaseFocus()
end

function InputField:Submit()
    self.Text = self.TextBox.Text:gsub("[%r\n]+$", "")
    if self.OnSubmit and self.Text:match("%S") then
        self.OnSubmit(self.Text)
    end
    self.Text = ""
    self.TextBox.Text = ""
    self.SuggestionFrame.Visible = false
    self:UpdateHeight()
end

function InputField:AddText(text)
    self.TextBox.Text ..= text
end

function InputField:Backspace()
    local current = self.TextBox.Text
    if current ~= "" then
        self.TextBox.Text = current:sub(1, -2)
    end
end

function InputField:OnClick(mx,my)
    local inside =
        mx >= self.X and mx <= self.X + self.Width and
        my >= self.Y and my <= self.Y + self.Height

    if inside then
        self:Focus()
    end
end

function InputField:SetPosition(x, y)
    self.X, self.Y = x, y
    self.Outline.Position = UDim2.fromOffset(x - 1, y - 1)
    self.SuggestionFrame.Position = UDim2.fromOffset(x, y + self.Height + 4)
end

function InputField:SetHeight(height)
    self.Height = height
    self.Outline.Size = UDim2.fromOffset(self.Width + 2, height + 2)
    self.TextBox.Size = UDim2.new(1, -16, 0, height - VERTICAL_PADDING)
    self.SuggestionFrame.Position = UDim2.fromOffset(self.X, self.Y + height + 4)
end

function InputField:SetPlaceholder(text)
    self.TextBox.PlaceholderText = text or "Message..."
end

function InputField:SetCommandSuggestions(suggestions)
    self.CommandSuggestions = suggestions or {}
    self:UpdateSuggestions()
end

function InputField:UpdateSuggestions()
    local text = self.TextBox.Text or ""
    local commandMatch = text:match("^%s*/(%S*)")
    if not commandMatch then
        self.SuggestionFrame.Visible = false
        return
    end

    local partial = commandMatch:lower()
    local matches = {}
    for _, entry in ipairs(self.CommandSuggestions) do
        local command = entry.command or entry[1] or entry
        local description = entry.description or entry[2]
        if command then
            local normalized = tostring(command):lower():gsub("^/", "")
            if partial == "" or normalized:sub(1, #partial) == partial then
                local line = tostring(command)
                if description and description ~= "" then
                    line = line .. " 鈥� " .. description
                end
                table.insert(matches, line)
                if #matches >= SUGGESTION_MAX then
                    break
                end
            end
        end
    end

    if #matches == 0 then
        self.SuggestionFrame.Visible = false
        return
    end

    self.SuggestionText.Text = table.concat(matches, "\n")
    local height = (#matches * SUGGESTION_LINE_HEIGHT) + 12
    self.SuggestionFrame.Size = UDim2.fromOffset(self.Width, height)
    self.SuggestionFrame.Visible = true
end

function InputField:UpdateHeight()
    if not self.TextBox then
        return
    end

    local availableWidth = self.TextBox.AbsoluteSize.X
    if availableWidth <= 0 then
        availableWidth = self.Width - 16
    end

    local content = self.TextBox.Text
    if content == "" then
        content = " "
    end

    local textSize = TextService:GetTextSize(
        content,
        FONT_SIZE,
        self.TextBox.Font,
        Vector2.new(availableWidth, math.huge)
    )
    local textHeight = math.max(textSize.Y, FONT_SIZE)
    local targetHeight = math.clamp(textHeight + VERTICAL_PADDING, self.MinHeight, self.MaxHeight)
    if targetHeight == self.Height then
        return
    end

    local previous = self.Height
    self:SetHeight(targetHeight)
    if self.OnHeightChanged then
        self.OnHeightChanged(targetHeight, targetHeight - previous)
    end
end

return InputField
