local player = game.Players.LocalPlayer

local function bringCar()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end

    local root = character.HumanoidRootPart
    local targetCFrame = root.CFrame * CFrame.new(0, 6, 0)

    local vehicle = nil
    local vehiclesFolder = workspace:FindFirstChild("Vehicles") or workspace

    for _, v in ipairs(vehiclesFolder:GetDescendants()) do
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

    pcall(function()
        if vehicle.PrimaryPart then
            vehicle:SetPrimaryPartCFrame(targetCFrame)
        else
            local mainPart = vehicle:FindFirstChild("Chassis") or vehicle:FindFirstChildWhichIsA("BasePart")
            if mainPart then
                mainPart.CFrame = targetCFrame
            end
        end
    end)

    wait(0.25)

    local seat = vehicle:FindFirstChild("DriverSeat") or vehicle:FindFirstChildWhichIsA("VehicleSeat")
    if seat and character:FindFirstChild("Humanoid") then
        seat:Sit(character.Humanoid)
    else
        character:PivotTo(targetCFrame * CFrame.new(0, 2, 0))
    end
end

game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton3 then
        bringCar()
    end
end)
