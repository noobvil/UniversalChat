local ScrollController = {}

function ScrollController.new(parent, x, y, w, h)
    local self = setmetatable({}, {__index = ScrollController})

    self.X, self.Y = x, y
    self.Width, self.Height = w, h

    self.Frame = Instance.new("ScrollingFrame")
    self.Frame.Name = "Messages"
    self.Frame.BackgroundTransparency = 1
    self.Frame.BorderSizePixel = 0
    self.Frame.ScrollBarThickness = 5
    self.Frame.ScrollBarImageColor3 = Color3.fromRGB(150, 150, 150)
    self.Frame.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.Frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    self.Frame.Position = UDim2.fromOffset(x, y)
    self.Frame.Size = UDim2.fromOffset(w, h)
    self.Frame.Parent = parent

    self.Layout = Instance.new("UIListLayout")
    self.Layout.Padding = UDim.new(0, 6)
    self.Layout.SortOrder = Enum.SortOrder.LayoutOrder
    self.Layout.Parent = self.Frame

    return self
end

function ScrollController:SetContentHeight(h)
    self.Frame.CanvasSize = UDim2.new(0, 0, 0, h)
end

function ScrollController:SetBounds(x, y, w, h)
    self.X, self.Y, self.Width, self.Height = x, y, w, h
    self.Frame.Position = UDim2.fromOffset(x, y)
    self.Frame.Size = UDim2.fromOffset(w, h)
end

function ScrollController:GetOffset()
    return self.Frame.CanvasPosition.Y
end

function ScrollController:ScrollToBottom()
    local view = self.Frame.AbsoluteWindowSize.Y
    local canvas = self.Frame.CanvasSize.Y.Offset
    self.Frame.CanvasPosition = Vector2.new(0, math.max(0, canvas - view))
end

function ScrollController:ScrollToTop()
    self.Frame.CanvasPosition = Vector2.new(0, 0)
end

function ScrollController:Clear()
    for _, child in ipairs(self.Frame:GetChildren()) do
        if child ~= self.Layout then
            child:Destroy()
        end
    end
end

return ScrollController
