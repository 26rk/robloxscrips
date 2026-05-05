repeat task.wait() until _G.WindUI and _G.Window and _G.Tabs
local RunService = cloneref(game:GetService("RunService"))
local Players = cloneref(game:GetService("Players"))
local WorkSpace = cloneref(game:GetService("Workspace"))
local WindUI = _G.WindUI
local Window = _G.Window
local Tabs = _G.Tabs
local LocalPlayer = Players.LocalPlayer
local Camera = WorkSpace.CurrentCamera

local function GetBountyFolder()
    local folder = WorkSpace:FindFirstChild("BountyVehicles")
    return folder and folder:FindFirstChild("Vehicles")
end

local ESPEnabled = true
local ShowName = true
local ShowDistance = true
local ShowValue = false
local ShowBox = true
local ShowTracer = true
local NameColor = Color3.fromRGB(255, 200, 0)
local BoxColor = Color3.fromRGB(252, 211, 3)
local TracerColor = Color3.fromRGB(252, 211, 3)
local MaxDistance = 0
local TracerOrigin = "Bottom"
local LabelFontSize = 24
local ESPObjects = {}
local RegisteredVehicles = {}

local function GetVehicleRoot(vehicle)
    return vehicle.PrimaryPart or vehicle:FindFirstChild("DriveSeat") or vehicle:FindFirstChildWhichIsA("BasePart")
end

local function WorldToViewport(pos)
    local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen, screenPos.Z
end

local function GetBountyValue(vehicle)
    local val = vehicle:GetAttribute("BountyCash")
        or vehicle:GetAttribute("CashValue")
        or vehicle:GetAttribute("Value")
        or vehicle:GetAttribute("Bounty")
    return val and ("$" .. tostring(val)) or "?"
end

local function GetVehicleName(vehicle)
    return vehicle.Name or "Unknown"
end

local function NewDrawing(class, props)
    local obj = Drawing.new(class)
    for k, v in pairs(props) do obj[k] = v end
    return obj
end

local function CreateESPForVehicle(vehicle)
    if ESPObjects[vehicle] then return end
    ESPObjects[vehicle] = {
        label = NewDrawing("Text", {
            Text = "",
            Size = LabelFontSize,
            Font = Drawing.Fonts.UI,
            Color = NameColor,
            Outline = true,
            OutlineColor = Color3.fromRGB(0, 0, 0),
            Visible = false,
            Center = true,
        }),
        box = NewDrawing("Square", {
            Thickness = 3,
            Color = BoxColor,
            Filled = false,
            Visible = false,
        }),
        tracer = NewDrawing("Line", {
            Thickness = 2.5,
            Color = TracerColor,
            Visible = false,
        }),
    }
end

local function RemoveESPForVehicle(vehicle)
    local obj = ESPObjects[vehicle]
    if not obj then return end
    for _, drawing in pairs(obj) do drawing:Remove() end
    ESPObjects[vehicle] = nil
end

local function ClearAllESP()
    for vehicle in pairs(ESPObjects) do RemoveESPForVehicle(vehicle) end
end

local function UpdateESP()
    local vpSize = Camera.ViewportSize
    local char = LocalPlayer.Character
    local localPos = char and char.PrimaryPart and char.PrimaryPart.Position
    
    for vehicle, obj in pairs(ESPObjects) do
        if not vehicle or not vehicle.Parent then
            RemoveESPForVehicle(vehicle)
            continue
        end
        
        if not ESPEnabled then
            obj.label.Visible = false
            obj.box.Visible = false
            obj.tracer.Visible = false
            continue
        end
        
        local root = GetVehicleRoot(vehicle)
        if not root then
            obj.label.Visible = false
            obj.box.Visible = false
            obj.tracer.Visible = false
            continue
        end
        
        local worldPos = root.Position
        local screenPos, onScreen, depth = WorldToViewport(worldPos)
        local dist = localPos and (worldPos - localPos).Magnitude or 0
        local withinRange = (MaxDistance <= 0) or (dist <= MaxDistance)
        
        if not (withinRange and depth > 0) then
            obj.label.Visible = false
            obj.box.Visible = false
            obj.tracer.Visible = false
            continue
        end
        
        local lines = {}
        if ShowName then table.insert(lines, GetVehicleName(vehicle)) end
        if ShowValue then table.insert(lines, "Value: " .. GetBountyValue(vehicle)) end
        if ShowDistance then table.insert(lines, string.format("%.0f meters", dist)) end
        
        obj.label.Text = table.concat(lines, "\n")
        obj.label.Size = LabelFontSize
        obj.label.Color = NameColor
        
        local minX, minY = math.huge, math.huge
        local maxX, maxY = -math.huge, -math.huge
        local boxAnyVisible = false
        
        local descendants = vehicle:GetDescendants()
        for i = 1, #descendants do
            local part = descendants[i]
            if part:IsA("BasePart") then
                local sz = part.Size
                local cf = part.CFrame
                for _, offset in ipairs({
                    Vector3.new( sz.X/2,  sz.Y/2,  sz.Z/2),
                    Vector3.new(-sz.X/2, -sz.Y/2, -sz.Z/2),
                }) do
                    local sp, _, d = WorldToViewport((cf * CFrame.new(offset)).Position)
                    if d > 0 then
                        boxAnyVisible = true
                        if sp.X < minX then minX = sp.X end
                        if sp.Y < minY then minY = sp.Y end
                        if sp.X > maxX then maxX = sp.X end
                        if sp.Y > maxY then maxY = sp.Y end
                    end
                end
            end
        end
        
        if ShowBox and boxAnyVisible and maxX > minX and maxY > minY then
            obj.box.Position = Vector2.new(minX, minY)
            obj.box.Size = Vector2.new(maxX - minX, maxY - minY)
            obj.box.Color = BoxColor
            obj.box.Visible = true
            obj.label.Position = Vector2.new((minX + maxX) / 2, minY - (LabelFontSize + 6))
        else
            obj.box.Visible = false
            obj.label.Position = Vector2.new(screenPos.X, screenPos.Y - 42)
        end
        
        obj.label.Visible = (#lines > 0)
        
        if ShowTracer then
            local originY = (TracerOrigin == "Bottom") and vpSize.Y or (vpSize.Y / 2)
            obj.tracer.From = Vector2.new(vpSize.X / 2, originY)
            obj.tracer.To = screenPos
            obj.tracer.Color = TracerColor
            obj.tracer.Visible = true
        else
            obj.tracer.Visible = false
        end
    end
end

local function RegisterVehicle(vehicle)
    if not vehicle or RegisteredVehicles[vehicle] or not vehicle:IsA("Model") then return end
   
    RegisteredVehicles[vehicle] = true
    CreateESPForVehicle(vehicle)
   
    task.spawn(function()
        local root = GetVehicleRoot(vehicle)
        local timer = 0
        while not root and timer < 10 do
            task.wait(0.5)
            root = GetVehicleRoot(vehicle)
            timer = timer + 0.5
        end
        
        local name = GetVehicleName(vehicle)
        local notifContent = name .. " spawned!"
       
        if root and LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
            local dist = (root.Position - LocalPlayer.Character.PrimaryPart.Position).Magnitude
            notifContent = name .. " spawned " .. string.format("%.0f", dist) .. " meters away!"
        end
       
        WindUI:Notify({
            Title = "Bounty Car Spawned",
            Content = notifContent,
            Duration = 30,
        })
    end)
end

local function StartScan()
    task.spawn(function()
        while true do
            local folder = GetBountyFolder()
            if folder then
                for _, v in ipairs(folder:GetChildren()) do
                    RegisterVehicle(v)
                end
            end
            task.wait(5)
        end
    end)
end

local renderConn
local function StartRender()
    if renderConn then return end
    renderConn = RunService.RenderStepped:Connect(function()
        if ESPEnabled then UpdateESP() end
    end)
end

local function StopRender()
    if renderConn then renderConn:Disconnect() renderConn = nil end
    ClearAllESP()
end

StartRender()
StartScan()

local VisualsTab = Tabs.Visuals
VisualsTab:Section({ Title = "Bounty Car ESP" })
VisualsTab:Toggle({
    Title = "Bounty Car ESP",
    Desc = "Highlights bounty vehicles through walls with names, distances, and values.",
    Value = true,
    Callback = function(state)
        ESPEnabled = state
        if state then
            StartRender()
            WindUI:Notify({ Title = "Bounty Car ESP", Content = "ESP is now active.", Duration = 3 })
        else
            StopRender()
        end
    end,
})
VisualsTab:Section({ Title = "ESP Options" })
VisualsTab:Toggle({
    Title = "Show Vehicle Name",
    Desc = "Display the vehicle model name above the ESP.",
    Value = true,
    Callback = function(state) ShowName = state end,
})
VisualsTab:Toggle({
    Title = "Show Distance",
    Desc = "Display the distance (in meters) to each bounty vehicle.",
    Value = true,
    Callback = function(state) ShowDistance = state end,
})
VisualsTab:Toggle({
    Title = "Show Box",
    Desc = "Draw a bounding box around each bounty vehicle.",
    Value = true,
    Callback = function(state) ShowBox = state end,
})
VisualsTab:Toggle({
    Title = "Show Tracer",
    Desc = "Draw a line from your screen to each bounty vehicle.",
    Value = true,
    Callback = function(state) ShowTracer = state end,
})
VisualsTab:Dropdown({
    Title = "Tracer Origin",
    Desc = "Where on your screen tracers originate from.",
    Values = { "Bottom", "Center" },
    Multi = false,
    Value = "Bottom",
    Callback = function(v) TracerOrigin = v end,
})
VisualsTab:Section({ Title = "ESP Colors" })
VisualsTab:Colorpicker({
    Title = "Label Color",
    Desc = "Color of the vehicle name / info text.",
    Default = NameColor,
    Callback = function(c)
        NameColor = c
        for _, obj in pairs(ESPObjects) do obj.label.Color = NameColor end
    end,
})
VisualsTab:Colorpicker({
    Title = "Box Color",
    Desc = "Color of the bounding box drawn around vehicles.",
    Default = BoxColor,
    Callback = function(c)
        BoxColor = c
        for _, obj in pairs(ESPObjects) do obj.box.Color = BoxColor end
    end,
})
VisualsTab:Colorpicker({
    Title = "Tracer Color",
    Desc = "Color of the tracer lines.",
    Default = TracerColor,
    Callback = function(c)
        TracerColor = c
        for _, obj in pairs(ESPObjects) do obj.tracer.Color = TracerColor end
    end,
})
VisualsTab:Section({ Title = "Filters" })
VisualsTab:Slider({
    Title = "Max Distance",
    Desc = "Maximum distance (meters) to show ESP. Set to 0 for unlimited.",
    Value = { Min = 0, Max = 5000, Default = 0 },
    Step = 100,
    Callback = function(v) MaxDistance = tonumber(v) or 0 end,
})
VisualsTab:Slider({
    Title = "Label Font Size",
    Desc = "Size of the text labels drawn on screen.",
    Value = { Min = 10, Max = 24, Default = 24 },
    Step = 1,
    Callback = function(v)
        LabelFontSize = tonumber(v) or 24
        for _, obj in pairs(ESPObjects) do obj.label.Size = LabelFontSize end
    end,
})
WindUI:Notify({
    Title = "Bounty Car ESP loaded",
    Content = "ESP is active. Configure settings in the Visuals tab.",
    Duration = 4,
})
