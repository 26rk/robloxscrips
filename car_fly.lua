repeat task.wait() until _G.WindUI and _G.Tabs

local WindUI = _G.WindUI
local Tabs = _G.Tabs
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Player = game.Players.LocalPlayer

local carFlyActive = false
local flySpeed = 150
local currentCarFlyKeybind = Enum.KeyCode.LeftAlt

local hb, vl

local function getVehicleCollisionPart()
	local char = Player.Character
	if not char then return nil end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum or not hum.Sit then return nil end
	local seat = hum.SeatPart
	if not seat then return nil end
	local vehicle = seat.Parent
	if not vehicle or not vehicle:FindFirstChild("Body") then return nil end
	return vehicle.Body:FindFirstChild("CollisionPart")
end

local function cleanupFly()
	if hb then 
		hb:Disconnect() 
		hb = nil 
	end
	if vl then 
		pcall(function() vl:Destroy() end) 
		vl = nil 
	end
end

local function attach()
	local col = getVehicleCollisionPart()
	if not col then return end
	
	if vl then pcall(function() vl:Destroy() end) end
	
	vl = Instance.new("BodyVelocity", col)
	vl.MaxForce = Vector3.new(9e9, 9e9, 9e9)
	vl.P = 9e4
	vl.Velocity = Vector3.new()
	
	if not hb then
		hb = RunService.Heartbeat:Connect(function()
			if not carFlyActive then
				if vl then vl.Velocity = Vector3.new() end
				return
			end
			
			local col = getVehicleCollisionPart()
			if not col then
				carFlyActive = false
				return
			end
			
			local h = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
			if not h or not h.Sit then
				carFlyActive = false
				return
			end
			
			local t = Vector3.new()
			local cam = workspace.CurrentCamera.CFrame
			if UIS:IsKeyDown(Enum.KeyCode.W) then t += cam.LookVector * flySpeed end
			if UIS:IsKeyDown(Enum.KeyCode.S) then t += cam.LookVector * -flySpeed end
			if UIS:IsKeyDown(Enum.KeyCode.A) then t += cam.RightVector * -flySpeed end
			if UIS:IsKeyDown(Enum.KeyCode.D) then t += cam.RightVector * flySpeed end
			
			if vl then vl.Velocity = t end
		end)
	end
	
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
			attach()
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

		if input.KeyCode == currentCarFlyKeybind then
			carFlyActive = not carFlyActive
			carFlyToggle:SetValue(carFlyActive)
			if carFlyActive then
				attach()
			else
				cleanupFly()
			end
		end
	end)
end)
