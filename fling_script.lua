local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

repeat task.wait() until LocalPlayer.Character

local flingEnabled = false
local flingBind = Enum.KeyCode.RightControl
local currentIndex = 0

local ui = Instance.new("ScreenGui")
ui.ResetOnSpawn = false
ui.Parent = (gethui and gethui()) or game.CoreGui

local label = Instance.new("TextLabel", ui)
label.Size = UDim2.new(0, 170, 0, 32)
label.Position = UDim2.new(1, -185, 1, -80)
label.BackgroundTransparency = 1
label.Text = "Fling: OFF"
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextSize = 18
label.Font = Enum.Font.GothamSemibold
local stroke = Instance.new("UIStroke", label)
stroke.Color = Color3.fromRGB(0, 0, 0)

local TS = game:GetService("TweenService")
local function fade()
    TS:Create(label, TweenInfo.new(.17), {TextTransparency = .4}):Play()
    task.wait(.17)
    TS:Create(label, TweenInfo.new(.17), {TextTransparency = 0}):Play()
end

local function getTargetPart(player)
    if not player.Character then return nil end
    
    local hum = player.Character:FindFirstChildOfClass("Humanoid")
    if hum and hum.SeatPart then
        return hum.SeatPart
    end
    
    return player.Character:FindFirstChild("HumanoidRootPart")
end

local function getVehicleParts(player)
    local parts = {}
    if not player.Character then return parts end
    
    local hum = player.Character:FindFirstChildOfClass("Humanoid")
    if hum and hum.SeatPart then
        local seat = hum.SeatPart
        local vehicle = seat.Parent
        if vehicle then
            for _, part in ipairs(vehicle:GetDescendants()) do
                if part:IsA("BasePart") then
                    table.insert(parts, part)
                end
            end
        end
    end
    
    return parts
end

task.spawn(function()
    while true do
        pcall(function()
            if flingEnabled and LocalPlayer.Character then
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.Health = hum.MaxHealth
                    hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                end
            end
        end)
        task.wait(0.02)
    end
end)

task.spawn(function()
    while true do
        if flingEnabled then
            local allPlayers = {}
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local target = getTargetPart(p)
                    if target then
                        table.insert(allPlayers, p)
                    end
                end
            end
            
            if #allPlayers > 0 then
                currentIndex = currentIndex + 1
                if currentIndex > #allPlayers then
                    currentIndex = 1
                end
                
                local player = allPlayers[currentIndex]
                
                pcall(function()
                    local tPart = getTargetPart(player)
                    if not tPart then return end
                    
                    local myChar = LocalPlayer.Character
                    if not myChar then return end
                    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
                    if not myHRP then return end
                    
                    local vehicleParts = getVehicleParts(player)
                    local offset = 0
                    
                    for i = 1, 120 do
                        if not flingEnabled then break end
                        
                        myChar = LocalPlayer.Character
                        if not myChar then break end
                        myHRP = myChar:FindFirstChild("HumanoidRootPart")
                        if not myHRP then break end
                        
                        tPart = getTargetPart(player)
                        if not tPart then break end
                        
                        local targetVel = tPart.Velocity
                        local speed = targetVel.Magnitude
                        
                        offset = offset + 0.5
                        if offset > 15 then offset = -15 end
                        
                        local aheadTime = 0.3
                        if speed > 50 then aheadTime = 0.5 end
                        if speed > 100 then aheadTime = 0.8 end
                        
                        local predictPos = tPart.Position + (targetVel * aheadTime)
                        local lookDir = targetVel.Magnitude > 1 and targetVel.Unit or tPart.CFrame.LookVector
                        
                        local offsetPos = predictPos + (lookDir * offset)
                        
                        myHRP.CFrame = CFrame.new(offsetPos)
                        myHRP.Velocity = targetVel + Vector3.new(math.random(-9999, 9999), math.random(5000, 9999), math.random(-9999, 9999))
                        myHRP.RotVelocity = Vector3.new(math.random(-9999, 9999), math.random(-9999, 9999), math.random(-9999, 9999))
                        
                        myHRP.CFrame = tPart.CFrame * CFrame.new(offset * 0.5, 0, offset * 0.5)
                        myHRP.Velocity = Vector3.new(math.random(-9999, 9999), math.random(9999, 50000), math.random(-9999, 9999))
                        myHRP.RotVelocity = Vector3.new(math.random(-9999, 9999), math.random(-9999, 9999), math.random(-9999, 9999))
                        
                        if #vehicleParts > 0 then
                            for _, vPart in ipairs(vehicleParts) do
                                pcall(function()
                                    myHRP.CFrame = vPart.CFrame
                                    myHRP.Velocity = Vector3.new(math.random(-9999, 9999), math.random(9999, 50000), math.random(-9999, 9999))
                                end)
                            end
                        end
                        
                        RunService.Heartbeat:Wait()
                    end
                end)
            end
        end
        task.wait()
    end
end)

UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == flingBind then
        flingEnabled = not flingEnabled
        label.Text = "Fling: " .. (flingEnabled and "ON" or "OFF")
        fade()
        currentIndex = 0
    end
end)
