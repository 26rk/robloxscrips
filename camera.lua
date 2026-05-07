repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

player.CameraMaxZoomDistance = 10000
player.CameraMinZoomDistance = 0.5

local function noclipCamera()
    pcall(function()
        if player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

RunService.RenderStepped:Connect(noclipCamera)
