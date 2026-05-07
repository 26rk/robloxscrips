repeat task.wait() until game:IsLoaded()

local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")

local player = Players.LocalPlayer

player.CameraMaxZoomDistance = 10000
player.CameraMinZoomDistance = 0.5

task.spawn(function()
    while true do
        task.wait()
        if Camera.CameraType == Enum.CameraType.Custom then
            Camera.CameraSubject = player.Character and player.Character:FindFirstChild("Humanoid") or nil
        end
    end
end)

local function applyNoclip()
    pcall(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CanCollide = false
        end
    end)
end

game:GetService("RunService").RenderStepped:Connect(applyNoclip)
