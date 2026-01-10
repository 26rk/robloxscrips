local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

repeat task.wait() until LocalPlayer.Character

local function startTouchFling()
    local char = LocalPlayer.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    
    if not hrp or not hum then
        return
    end
    
    task.spawn(function()
        while true do
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum.Health = hum.MaxHealth
                        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                    end
                end
            end)
            task.wait(0.1)
        end
    end)
    
    task.spawn(function()
        while true do
            for _, player in pairs(Players:GetPlayers()) do
                if player == LocalPlayer then continue end
                if not player.Character then continue end
                
                local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
                if not targetHRP then continue end
                
                local char = LocalPlayer.Character
                if not char then break end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not hrp then break end
                
                local startTime = tick()
                while tick() - startTime < 1 do 
                    pcall(function()
                        if targetHRP and targetHRP.Parent and hrp and hrp.Parent then
                            hrp.CFrame = targetHRP.CFrame
                        end
                    end)
                    task.wait(0.05)
                end
                
                task.wait(0.3)
            end
            
            task.wait(1)
        end
    end)
end

task.wait(0.5)
startTouchFling()
