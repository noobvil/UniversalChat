local UIS = game:GetService("UserInputService")

local UI_Core = {}

local function getUiParent()
    local ok, parent = pcall(function()
        if gethui then return gethui() end
        return nil
    end)
    if ok and parent then return parent end
    return game:GetService("CoreGui")
end

function UI_Core:CreateWindow(title)
    local self = setmetatable({}, {__index = UI_Core})

    self.X, self.Y = 200, 200
    self.Width, self.Height = 380, 420
    self.TitleBarHeight = 32
    self.FullHeight = self.Height
    self.Minimized = false
    self.Dragging = false

    self.Gui = Instance.new("ScreenGui")
    self.Gui.Name = "UniversalChat"
    self.Gui.ResetOnSpawn = false
    self.Gui.IgnoreGuiInset = true
    self.Gui.Parent = getUiParent()

    self.BG = Instance.new("Frame")
    self.BG.Name = "Window"
    self.BG.BackgroundColor3 = Color3.fromRGB(32, 34, 37)
    self.BG.BorderSizePixel = 0
    self.BG.Position = UDim2.fromOffset(self.X, self.Y)
    self.BG.Size = UDim2.fromOffset(self.Width, self.Height)
    self.BG.Parent = self.Gui

    self.TitleBar = Instance.new("Frame")
    self.TitleBar.Name = "TitleBar"
    self.TitleBar.BackgroundColor3 = Color3.fromRGB(30, 31, 34)
    self.TitleBar.BorderSizePixel = 0
    self.TitleBar.Active = true
    self.TitleBar.Size = UDim2.new(1, 0, 0, self.TitleBarHeight)
    self.TitleBar.Parent = self.BG

    self.TitleText = Instance.new("TextLabel")
    self.TitleText.Name = "Title"
    self.TitleText.BackgroundTransparency = 1
    self.TitleText.Position = UDim2.fromOffset(10, 0)
    self.TitleText.Size = UDim2.new(1, -80, 1, 0)
    self.TitleText.Font = Enum.Font.SourceSansBold
    self.TitleText.TextSize = 18
    self.TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.TitleText.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleText.Text = title
    self.TitleText.Parent = self.TitleBar

    self.MinButton = Instance.new("TextButton")
    self.MinButton.Name = "Minimize"
    self.MinButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    self.MinButton.BorderSizePixel = 0
    self.MinButton.Position = UDim2.new(1, -30, 0, 4)
    self.MinButton.Size = UDim2.fromOffset(24, 24)
    self.MinButton.Text = "-"
    self.MinButton.Font = Enum.Font.SourceSansBold
    self.MinButton.TextSize = 18
    self.MinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.MinButton.Parent = self.TitleBar

    self.ContentFrame = Instance.new("Frame")
    self.ContentFrame.Name = "Content"
    self.ContentFrame.BackgroundTransparency = 1
    self.ContentFrame.Position = UDim2.fromOffset(0, self.TitleBarHeight)
    self.ContentFrame.Size = UDim2.new(1, 0, 1, -self.TitleBarHeight)
    self.ContentFrame.Parent = self.BG

    self.MinButton.MouseButton1Click:Connect(function()
        self.Minimized = not self.Minimized
        self:UpdateVisibility()
    end)

    UIS.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
        and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end
        local m = input.Position
        local barPos = self.TitleBar.AbsolutePosition
        local barSize = self.TitleBar.AbsoluteSize
        if m.X >= barPos.X and m.X <= barPos.X + barSize.X
        and m.Y >= barPos.Y and m.Y <= barPos.Y + barSize.Y then
            self.Dragging = true
            self.DragInput = input
            self.DragOffset = Vector2.new(m.X - self.X, m.Y - self.Y)
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input == self.DragInput then
            self.Dragging = false
            self.DragInput = nil
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if not self.Dragging then return end
        local isMouseMove = input.UserInputType == Enum.UserInputType.MouseMovement
        local isTouchMove = input.UserInputType == Enum.UserInputType.Touch and input == self.DragInput
        if not (isMouseMove or isTouchMove) then return end
        local m = input.Position
        self:SetPosition(m.X - self.DragOffset.X, m.Y - self.DragOffset.Y)
    end)

    return self
end

function UI_Core:UpdateVisibility()
    self.ContentFrame.Visible = not self.Minimized
    if self.Minimized then
        self.BG.Size = UDim2.fromOffset(self.Width, self.TitleBarHeight)
    else
        self.BG.Size = UDim2.fromOffset(self.Width, self.FullHeight)
    end
end

function UI_Core:SetPosition(x, y)
    self.X, self.Y = x, y
    self.BG.Position = UDim2.fromOffset(x, y)
end

function UI_Core:SetHeight(height)
    self.Height = height
    self.FullHeight = height
    self:UpdateVisibility()
end

return UI_Core
