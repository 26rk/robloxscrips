repeat task.wait() until game:IsLoaded()

local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local speed = 60
local freecamEnabled = true

Camera.CameraType = Enum.CameraType.Scriptable

player.CameraMaxZoomDistance = 10000
player.CameraMinZoomDistance = 0.5

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
        Camera.CFrame += (move.Unit * speed * dt)
    end
end)
