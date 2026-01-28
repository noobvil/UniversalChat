local RunService = game:GetService("RunService")

local AnimationEngine = {}
AnimationEngine.ActiveTweens = {}

local function EaseOut(t) return 1-(1-t)^3 end
local function EaseInOut(t) return t<0.5 and 4*t^3 or 1-((-2*t+2)^3)/2 end

function AnimationEngine.Lerp(a,b,t) return a+(b-a)*t end

function AnimationEngine:Tween(obj, prop, target, duration, ease)
    duration = duration or 0.4
    ease = ease or "InOut"

    local start = obj[prop]
    local alive = true
    local elapsed = 0

    RunService.RenderStepped:Connect(function(dt)
        if not alive then return end
        elapsed += dt
        local t = math.clamp(elapsed / duration, 0, 1)

        local e = ease == "Out" and EaseOut(t)
              or ease == "InOut" and EaseInOut(t)
              or t

        if typeof(start) == "number" then
            obj[prop] = AnimationEngine.Lerp(start, target, e)
        else -- Vector2 or Color3
            obj[prop] = start:Lerp(target, e)
        end

        if t >= 1 then alive = false end
    end)
end

function AnimationEngine:Fade(obj, target, dur)
    self:Tween(obj, "Transparency", target, dur)
end

return AnimationEngine
