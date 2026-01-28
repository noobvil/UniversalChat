local RunService = game:GetService("RunService")
local AnimationEngine = loadfile("UniversalChat/modules/AnimationEngine.lua")()

local NotificationSystem = {}

local TOAST_W, TOAST_H = 240,40
local TOAST_TIME = 3

function NotificationSystem:Init(UI)
    self.UI = UI
    self.PulseTimer = 0

    self.ToastBG = Instance.new("Frame")
    self.ToastBG.Name = "ToastBG"
    self.ToastBG.BackgroundColor3 = Color3.fromRGB(48, 50, 55)
    self.ToastBG.BorderSizePixel = 0
    self.ToastBG.BackgroundTransparency = 1
    self.ToastBG.Visible = false
    self.ToastBG.Parent = UI.Gui

    self.ToastText = Instance.new("TextLabel")
    self.ToastText.Name = "ToastText"
    self.ToastText.BackgroundTransparency = 1
    self.ToastText.Size = UDim2.new(1, -16, 1, -8)
    self.ToastText.Position = UDim2.fromOffset(8, 4)
    self.ToastText.Font = Enum.Font.SourceSansBold
    self.ToastText.TextSize = 18
    self.ToastText.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.ToastText.TextXAlignment = Enum.TextXAlignment.Left
    self.ToastText.TextYAlignment = Enum.TextYAlignment.Center
    self.ToastText.TextTransparency = 1
    self.ToastText.Parent = self.ToastBG

    RunService.RenderStepped:Connect(function(dt)
        self:Update(dt)
    end)
end

function NotificationSystem:ShowToast(message)
    local cam = workspace.CurrentCamera
    local y = cam.ViewportSize.Y - 60

    self.ToastBG.Position = UDim2.fromOffset(20, y - TOAST_H)
    self.ToastBG.Size     = UDim2.fromOffset(TOAST_W, TOAST_H)
    self.ToastBG.Visible  = true

    self.ToastText.Text = message
    self.ToastText.Visible = true

    AnimationEngine:Tween(self.ToastBG, "BackgroundTransparency", 0, 0.25)
    AnimationEngine:Tween(self.ToastText, "TextTransparency", 0, 0.25)

    self.ToastStart = tick()
end

function NotificationSystem:NotifyNewMessage(user)
    if self.UI.Minimized then
        self:ShowToast("New message from "..user)
    end

    self.PulseTimer = 1
end

function NotificationSystem:NotifyDirectMessage(user)
    self:ShowToast("New DM from " .. user)
    self.PulseTimer = 1
end

function NotificationSystem:Update(dt)
    if self.ToastStart then
        local t = tick() - self.ToastStart
        if t > TOAST_TIME then
            AnimationEngine:Tween(self.ToastBG, "BackgroundTransparency", 1, 0.25)
            AnimationEngine:Tween(self.ToastText, "TextTransparency", 1, 0.25)
            if t > TOAST_TIME + 0.3 then
                self.ToastBG.Visible = false
                self.ToastText.Visible = false
                self.ToastStart = nil
            end
        end
    end

    if self.PulseTimer > 0 then
        self.PulseTimer -= dt
        local pulse = math.abs(math.sin(self.PulseTimer * 8))
        self.UI.TitleBar.BackgroundColor3 = Color3.fromRGB(
            30 + pulse*80,
            31 + pulse*80,
            34 + pulse*80
        )
    else
        self.UI.TitleBar.BackgroundColor3 = Color3.fromRGB(30,31,34)
    end
end

return NotificationSystem
