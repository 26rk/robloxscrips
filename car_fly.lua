repeat task.wait() until _G.WindUI and _G.Tabs

local WindUI = _G.WindUI
local Tabs = _G.Tabs
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Player = game.Players.LocalPlayer

local carFlyActive = false
local flySpeed = 150
local smoothness = 0.15

local carFlyKeybindEnabled = true
local currentCarFlyKeybind = Enum.KeyCode.LeftAlt

local activeConnection = nil
local bodyGyro = nil
local bodyVelocity = nil

local function getVehicleCollisionPart()
	local char = Player.Character
	if not char then return nil end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum or not hum.Sit then return nil end
	local seat = hum.SeatPart
	if not seat then return nil end
	local vehicle = seat.Parent
	if not vehicle or not vehicle:FindFirstChild("Body") then return nil end
	local col = vehicle.Body:FindFirstChild("CollisionPart")
	return col
end

local function cleanupFly()
	if activeConnection then
		activeConnection:Disconnect()
		activeConnection = nil
	end
	if bodyVelocity then
		pcall(function() bodyVelocity:Destroy() end)
		bodyVelocity = nil
	end
	if bodyGyro then
		pcall(function() bodyGyro:Destroy() end)
		bodyGyro = nil
	end
end

local function startFly()
	local col = getVehicleCollisionPart()
	if not col then
		WindUI:Notify({
			Title = "Car Fly",
			Content = "You must be in a vehicle!",
			Duration = 2,
		})
		carFlyActive = false
		return
	end

	cleanupFly()

	bodyGyro = Instance.new("BodyGyro", col)
	bodyGyro.CFrame = workspace.CurrentCamera.CFrame
	bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
	bodyGyro.P = 9e4
	bodyGyro.D = 1000

	bodyVelocity = Instance.new("BodyVelocity", col)
	bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
	bodyVelocity.P = 9e4
	bodyVelocity.Velocity = Vector3.new()

	local lastVelocity = Vector3.new()

	activeConnection = RunService.Heartbeat:Connect(function()
		if not carFlyActive then
			cleanupFly()
			return
		end

		local col = getVehicleCollisionPart()
		if not col then
			carFlyActive = false
			cleanupFly()
			return
		end

		local char = Player.Character
		if not char then
			carFlyActive = false
			cleanupFly()
			return
		end

		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hum or not hum.Sit then
			carFlyActive = false
			cleanupFly()
			return
		end

		local cam = workspace.CurrentCamera.CFrame
		local movement = Vector3.new()

		if UIS:IsKeyDown(Enum.KeyCode.W) then movement = movement + cam.LookVector * flySpeed end
		if UIS:IsKeyDown(Enum.KeyCode.S) then movement = movement - cam.LookVector * flySpeed end
		if UIS:IsKeyDown(Enum.KeyCode.A) then movement = movement - cam.RightVector * flySpeed end
		if UIS:IsKeyDown(Enum.KeyCode.D) then movement = movement + cam.RightVector * flySpeed end

		lastVelocity = lastVelocity:Lerp(movement, smoothness)

		if bodyVelocity then
			bodyVelocity.Velocity = lastVelocity
		end

		if bodyGyro then
			bodyGyro.CFrame = cam
		end
	end)

	WindUI:Notify({
		Title = "Car Fly",
		Content = "Car fly enabled! Use WASD to move.",
		Duration = 2,
	})
end

Tabs.VehicleMods:Section({ Title = "Car Fly" })

local carFlyToggle = Tabs.VehicleMods:Toggle({
	Title = "Car Fly",
	Desc = "Fly your car around with WASD movement",
	Value = false,
	Callback = function(state)
		carFlyActive = state
		if state then
			startFly()
		else
			cleanupFly()
		end
	end,
})

Tabs.VehicleMods:Slider({
	Title = "Fly Speed",
	Desc = "Adjust how fast you fly",
	Value = { Min = 50, Max = 500, Default = 150 },
	Step = 25,
	Callback = function(val)
		flySpeed = tonumber(val) or 150
	end,
})

Tabs.VehicleMods:Slider({
	Title = "Smoothness",
	Desc = "Adjust movement smoothness (0 = instant, 1 = very smooth)",
	Value = { Min = 0, Max = 1, Default = 0.15 },
	Step = 0.05,
	Callback = function(val)
		smoothness = tonumber(val) or 0.15
	end,
})

local carFlyKeybindToggle = Tabs.VehicleMods:Toggle({
	Title = "Enable Car Fly Keybind",
	Desc = "Choose if you want the car fly keybind enabled",
	Value = true,
	Callback = function(state)
		carFlyKeybindEnabled = state
	end,
})

local carFlyKeybind = Tabs.VehicleMods:Keybind({
	Title = "Car Fly Keybind",
	Desc = "Toggle car fly with a single press",
	Value = "LeftAlt",
	Callback = function(v)
		currentCarFlyKeybind = Enum.KeyCode[v]
	end,
})

WindUI:Notify({
	Title = "Car Fly",
	Content = "Car fly loaded! Press Left Alt to toggle.",
	Duration = 3,
})

task.spawn(function()
	UIS.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end

		if carFlyKeybindEnabled and input.KeyCode == currentCarFlyKeybind then
			local state = carFlyToggle.Value
			carFlyToggle:SetValue(not state)
		end
	end)
end)
