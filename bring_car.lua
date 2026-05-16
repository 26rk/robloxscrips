local player = game.Players.LocalPlayer
local lastUsed = 0
local COOLDOWN = 1.8

local function bringCar()
    if tick() - lastUsed < COOLDOWN then return end
    lastUsed = tick()

    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local root = character.HumanoidRootPart
    local originalCFrame = root.CFrame

    local vehicle = nil
    local folder = workspace:FindFirstChild("Vehicles") or workspace
    for _, v in ipairs(folder:GetChildren()) do
        if v:IsA("Model") then
            local control = v:FindFirstChild("Control_Values")
            if control and control:FindFirstChild("Owner") and control.Owner.Value == player.Name then
                vehicle = v
                break
            end
            if v:FindFirstChild("Owner") and v.Owner.Value == player then
                vehicle = v
                break
            end
        end
    end

    if not vehicle then return end

    local seat = vehicle:FindFirstChild("DriverSeat") or vehicle:FindFirstChildWhichIsA("VehicleSeat")
    if not seat then return end

    wait(math.random(8,15)/100)
    
    pcall(function()
        root.CFrame = seat.CFrame * CFrame.new(0, 2, 0)
    end)

    wait(0.12)

    pcall(function()
        seat:Sit(character.Humanoid)
    end)

    wait(0.25 + math.random(1,4)/100)

    pcall(function()
        if vehicle.PrimaryPart then
            vehicle:SetPrimaryPartCFrame(originalCFrame * CFrame.new(0, 5, 0))
        else
            local part = vehicle:FindFirstChild("Chassis") or vehicle:FindFirstChildWhichIsA("BasePart")
            if part then
                part.CFrame = originalCFrame * CFrame.new(0, 5, 0)
            end
        end
    end)
end

game:GetService("UserInputService").InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton3 then
        bringCar()
    end
end)
