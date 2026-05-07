repeat task.wait() until game:IsLoaded()

local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local freecamEnabled = true
local speed = 65

player.CameraMaxZoomDistance = 10000
player.CameraMinZoomDistance = 0.5

Camera.CameraType = Enum.CameraType.Scriptable

local lastMousePos = Vector2.new()
local mouseSensitivity = 0.25

RunService.RenderStepped:Connect(function(dt)
    if not freecamEnabled then return end
        
    local move = Vector3.new()
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += Camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= Camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= Camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += Camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end

    if move.Magnitude > 0 then
        Camera.CFrame += move.Unit * speed * dt
    end

    local mouseDelta = UserInputService:GetMouseDelta()
    local rx = mouseDelta.Y * mouseSensitivity
    local ry = mouseDelta.X * mouseSensitivity

    local cf = Camera.CFrame
    local newCFrame = cf * CFrame.Angles(-math.rad(rx), -math.rad(ry), 0)
    Camera.CFrame = newCFrame
end)
