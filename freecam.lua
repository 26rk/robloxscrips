local pi = math.pi
local abs = math.abs
local clamp = math.clamp
local exp = math.exp
local rad = math.rad
local sign = math.sign
local sqrt = math.sqrt
local tan = math.tan

local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Settings = UserSettings()
local GameSettings = Settings.GameSettings

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    LocalPlayer = Players.LocalPlayer
end

local Camera = Workspace.CurrentCamera
Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    local newCamera = Workspace.CurrentCamera
    if newCamera then Camera = newCamera end
end)

local NAV_GAIN = Vector3.new(1, 1, 1)*64
local PAN_GAIN = Vector2.new(0.75, 1)*8
local FOV_GAIN = 300
local PITCH_LIMIT = rad(90)
local VEL_STIFFNESS = 1.5
local PAN_STIFFNESS = 1.0
local FOV_STIFFNESS = 4.0

local Spring = {} do
    Spring.__index = Spring
    function Spring.new(freq, pos)
        local self = setmetatable({}, Spring)
        self.f = freq
        self.p = pos
        self.v = pos*0
        return self
    end
    function Spring:Update(dt, goal)
        local f = self.f*2*pi
        local p0 = self.p
        local v0 = self.v
        local offset = goal - p0
        local decay = exp(-f*dt)
        local p1 = goal + (v0*dt - offset*(f*dt + 1))*decay
        local v1 = (f*dt*(offset*f - v0) + v0)*decay
        self.p = p1
        self.v = v1
        return p1
    end
    function Spring:Reset(pos)
        self.p = pos
        self.v = pos*0
    end
end

local cameraPos = Vector3.new()
local cameraRot = Vector2.new()
local cameraFov = 0
local velSpring = Spring.new(VEL_STIFFNESS, Vector3.new())
local panSpring = Spring.new(PAN_STIFFNESS, Vector2.new())
local fovSpring = Spring.new(FOV_STIFFNESS, 0)

local Input = {} do
    local thumbstickCurve do
        local K_CURVATURE = 2.0
        local K_DEADZONE = 0.15
        local function fCurve(x) return (exp(K_CURVATURE*x) - 1)/(exp(K_CURVATURE) - 1) end
        local function fDeadzone(x) return fCurve((x - K_DEADZONE)/(1 - K_DEADZONE)) end
        function thumbstickCurve(x) return sign(x)*clamp(fDeadzone(abs(x)), 0, 1) end
    end

    local gamepad = { ButtonX = 0, ButtonY = 0, ButtonL2 = 0, ButtonR2 = 0, Thumbstick1 = Vector2.new(), Thumbstick2 = Vector2.new() }
    local keyboard = { W = 0, A = 0, S = 0, D = 0, E = 0, Q = 0, U = 0, H = 0, J = 0, K = 0, I = 0, Y = 0, Up = 0, Down = 0, LeftShift = 0, RightShift = 0 }
    local mouse = { Delta = Vector2.new(), MouseWheel = 0 }

    local NAV_GAMEPAD_SPEED = Vector3.new(1, 1, 1)
    local NAV_KEYBOARD_SPEED = Vector3.new(1, 1, 1)
    local PAN_MOUSE_SPEED = Vector2.new(1, 1)*(pi/48)
    local PAN_GAMEPAD_SPEED = Vector2.new(1, 1)*(pi/8)
    local FOV_WHEEL_SPEED = 1.0
    local FOV_GAMEPAD_SPEED = 0.25
    local NAV_ADJ_SPEED = 0.75
    local NAV_SHIFT_MUL = 0.25
    local navSpeed = 1

    function Input.Vel(dt)
        navSpeed = clamp(navSpeed + dt*(keyboard.Up - keyboard.Down)*NAV_ADJ_SPEED, 0.01, 4)
        local kGamepad = Vector3.new(thumbstickCurve(gamepad.Thumbstick1.X), thumbstickCurve(gamepad.ButtonR2) - thumbstickCurve(gamepad.ButtonL2), thumbstickCurve(-gamepad.Thumbstick1.Y))*NAV_GAMEPAD_SPEED
        local kKeyboard = Vector3.new(keyboard.D - keyboard.A + keyboard.K - keyboard.H, keyboard.E - keyboard.Q + keyboard.I - keyboard.Y, keyboard.S - keyboard.W + keyboard.J - keyboard.U)*NAV_KEYBOARD_SPEED
        local shift = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
        return (kGamepad + kKeyboard)*(navSpeed*(shift and NAV_SHIFT_MUL or 1))
    end

    function Input.Pan(dt)
        local kGamepad = Vector2.new(thumbstickCurve(gamepad.Thumbstick2.Y), thumbstickCurve(-gamepad.Thumbstick2.X))*PAN_GAMEPAD_SPEED
        local kMouse = mouse.Delta*PAN_MOUSE_SPEED
        mouse.Delta = Vector2.new()
        return kGamepad + kMouse
    end

    function Input.Fov(dt)
        return (gamepad.ButtonX - gamepad.ButtonY)*FOV_GAMEPAD_SPEED + mouse.MouseWheel*FOV_WHEEL_SPEED
    end
end

local function StepFreecam(dt)
    local vel = velSpring:Update(dt, Input.Vel(dt))
    local pan = panSpring:Update(dt, Input.Pan(dt))
    local fov = fovSpring:Update(dt, Input.Fov(dt))
    local zoomFactor = sqrt(tan(rad(70/2))/tan(rad(cameraFov/2)))
    cameraFov = clamp(cameraFov + fov*FOV_GAIN*(dt/zoomFactor), 1, 120)
    cameraRot = cameraRot + pan*PAN_GAIN*(dt/zoomFactor)
    cameraRot = Vector2.new(clamp(cameraRot.x, -PITCH_LIMIT, PITCH_LIMIT), cameraRot.y % (2*pi))
    local cameraCFrame = CFrame.new(cameraPos)*CFrame.fromOrientation(cameraRot.x, cameraRot.y, 0)*CFrame.new(vel*NAV_GAIN*dt)
    cameraPos = cameraCFrame.p
    Camera.CFrame = cameraCFrame
    Camera.Focus = cameraCFrame
    Camera.FieldOfView = cameraFov
end

local PlayerState = {} do
    local mouseBehavior, mouseIconEnabled, cameraType, cameraFocus, cameraCFrame, cameraFieldOfView
    local screenGuis = {}

    function PlayerState.Push()
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)

        local pgui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if pgui then
            for _, gui in pairs(pgui:GetChildren()) do
                if gui:IsA("ScreenGui") and gui.Enabled then
                    table.insert(screenGuis, gui)
                    gui.Enabled = false
                end
            end
        end

        cameraFieldOfView = Camera.FieldOfView
        Camera.FieldOfView = 70
        cameraType = Camera.CameraType
        Camera.CameraType = Enum.CameraType.Custom
        cameraCFrame = Camera.CFrame
        cameraFocus = Camera.Focus
        mouseIconEnabled = UserInputService.MouseIconEnabled
        UserInputService.MouseIconEnabled = false
        mouseBehavior = UserInputService.MouseBehavior
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end

    function PlayerState.Pop()
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, true)
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)

        for _, gui in pairs(screenGuis) do
            if gui.Parent then gui.Enabled = true end
        end

        Camera.FieldOfView = cameraFieldOfView
        Camera.CameraType = cameraType
        Camera.CFrame = cameraCFrame
        Camera.Focus = cameraFocus
        UserInputService.MouseIconEnabled = mouseIconEnabled
        UserInputService.MouseBehavior = mouseBehavior
        screenGuis = {}
    end
end

local enabled = false

local function ToggleFreecam()
    if enabled then
        RunService:UnbindFromRenderStep("Freecam")
        PlayerState.Pop()
    else
        local cf = Camera.CFrame
        cameraRot = Vector2.new(cf:ToEulerAnglesYXZ())
        cameraPos = cf.Position
        cameraFov = Camera.FieldOfView
        velSpring:Reset(Vector3.new())
        panSpring:Reset(Vector2.new())
        fovSpring:Reset(0)
        PlayerState.Push()
        RunService:BindToRenderStep("Freecam", Enum.RenderPriority.Camera.Value, StepFreecam)
    end
    enabled = not enabled
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Numpad0 then
        ToggleFreecam()
    end
end)
