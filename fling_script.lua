local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

if getgenv()._fling_gui_loaded then return end
getgenv()._fling_gui_loaded = true

repeat task.wait() until LocalPlayer.Character

getgenv().FlingEnabled = false
getgenv().FlingTargetName = ""
getgenv().BlackScreenEnabled = true
getgenv().MuteSoundsEnabled = true

local originalVolumes = {}
local isMuted = false

local FlingMusic = Instance.new("Sound")
FlingMusic.Name = "FlingElevatorMusic"
FlingMusic.SoundId = "rbxassetid://9043887091"
FlingMusic.Volume = 0.8
FlingMusic.Looped = true
FlingMusic.Parent = SoundService

local function muteGameSounds()
    if isMuted then return end
    isMuted = true
    originalVolumes = {}
    
    pcall(function()
        for _, child in ipairs(SoundService:GetChildren()) do
            if child:IsA("SoundGroup") then
                originalVolumes[child] = child.Volume
                child.Volume = 0
            end
        end
    end)
    
    pcall(function()
        for _, sound in ipairs(workspace:GetDescendants()) do
            if sound:IsA("Sound") and sound ~= FlingMusic then
                originalVolumes[sound] = sound.Volume
                sound.Volume = 0
            end
        end
    end)
    
    pcall(function()
        for _, sound in ipairs(SoundService:GetDescendants()) do
            if sound:IsA("Sound") and sound ~= FlingMusic then
                originalVolumes[sound] = sound.Volume
                sound.Volume = 0
            end
        end
    end)
    
    pcall(function()
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if playerGui then
            for _, sound in ipairs(playerGui:GetDescendants()) do
                if sound:IsA("Sound") then
                    originalVolumes[sound] = sound.Volume
                    sound.Volume = 0
                end
            end
        end
    end)
    
    pcall(function()
        if LocalPlayer.Character then
            for _, sound in ipairs(LocalPlayer.Character:GetDescendants()) do
                if sound:IsA("Sound") then
                    originalVolumes[sound] = sound.Volume
                    sound.Volume = 0
                end
            end
        end
    end)
    
    FlingMusic:Play()
end

local function unmuteGameSounds()
    if not isMuted then return end
    isMuted = false
    
    FlingMusic:Stop()
    
    for sound, volume in pairs(originalVolumes) do
        pcall(function()
            if sound and sound.Parent then
                sound.Volume = volume
            end
        end)
    end
    originalVolumes = {}
end

getgenv().FlingTeams = {
    Civilian = true,
    DOT = true,
    Fire = true,
    Jail = true,
    Police = true,
    Sheriff = true,
    Moderator = true,
    Moderators = true,
    ["Game Moderator"] = true,
    ["Server Moderator"] = true,
    Staff = true,
    Admin = true,
    Administrator = true,
    Mod = true
}
local currentIndex = 0
local menuOpen = true

local BlackScreenGui = Instance.new("ScreenGui")
BlackScreenGui.Name = "BlackScreen"
BlackScreenGui.ResetOnSpawn = false
BlackScreenGui.DisplayOrder = 999
BlackScreenGui.IgnoreGuiInset = true
BlackScreenGui.Parent = (gethui and gethui()) or game.CoreGui

local BlackFrame = Instance.new("Frame")
BlackFrame.Name = "Black"
BlackFrame.Size = UDim2.new(1, 0, 1, 0)
BlackFrame.Position = UDim2.new(0, 0, 0, 0)
BlackFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
BlackFrame.BorderSizePixel = 0
BlackFrame.Visible = false
BlackFrame.Parent = BlackScreenGui

local BlackText = Instance.new("TextLabel")
BlackText.Size = UDim2.new(1, 0, 0, 100)
BlackText.Position = UDim2.new(0, 0, 0.4, 0)
BlackText.BackgroundTransparency = 1
BlackText.Text = "Hello 26rk here, I just made your screen black\nbecause it will might hurt your eyes\nYou can disable this in the Fling Menu\n\nNow just sit back and relax while a whole server is being tossed around! 🤑"
BlackText.TextColor3 = Color3.fromRGB(255, 255, 255)
BlackText.TextSize = 28
BlackText.Font = Enum.Font.GothamBold
BlackText.Parent = BlackFrame

local BlackSubText = Instance.new("TextLabel")
BlackSubText.Size = UDim2.new(1, 0, 0, 30)
BlackSubText.Position = UDim2.new(0, 0, 0.55, 0)
BlackSubText.BackgroundTransparency = 1
BlackSubText.Text = "Flinging in progress..."
BlackSubText.TextColor3 = Color3.fromRGB(150, 150, 150)
BlackSubText.TextSize = 16
BlackSubText.Font = Enum.Font.Gotham
BlackSubText.Parent = BlackFrame

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FlingMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 1000
ScreenGui.Parent = (gethui and gethui()) or game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 340, 0, 560)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -280)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(60, 60, 70)
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 15)
TitleFix.Position = UDim2.new(0, 0, 1, -15)
TitleFix.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Name = "Title"
TitleText.Size = UDim2.new(1, -100, 0, 25)
TitleText.Position = UDim2.new(0, 15, 0, 8)
TitleText.BackgroundTransparency = 1
TitleText.Text = "Fling Script"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 18
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(1, -100, 0, 15)
SubTitle.Position = UDim2.new(0, 15, 0, 30)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "Press Right Ctrl to toggle"
SubTitle.TextColor3 = Color3.fromRGB(120, 120, 130)
SubTitle.TextSize = 11
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "Close"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0, 10)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
CloseBtn.Text = ""
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = TitleBar

local CloseBtnCorner = Instance.new("UICorner")
CloseBtnCorner.CornerRadius = UDim.new(0, 6)
CloseBtnCorner.Parent = CloseBtn

local CloseX = Instance.new("TextLabel")
CloseX.Size = UDim2.new(1, 0, 1, 0)
CloseX.BackgroundTransparency = 1
CloseX.Text = "X"
CloseX.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseX.TextSize = 14
CloseX.Font = Enum.Font.GothamBold
CloseX.Parent = CloseBtn

local MinBtn = Instance.new("TextButton")
MinBtn.Name = "Minimize"
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -75, 0, 10)
MinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
MinBtn.Text = ""
MinBtn.AutoButtonColor = false
MinBtn.Parent = TitleBar

local MinBtnCorner = Instance.new("UICorner")
MinBtnCorner.CornerRadius = UDim.new(0, 6)
MinBtnCorner.Parent = MinBtn

local MinLine = Instance.new("TextLabel")
MinLine.Size = UDim2.new(1, 0, 1, 0)
MinLine.BackgroundTransparency = 1
MinLine.Text = "-"
MinLine.TextColor3 = Color3.fromRGB(255, 255, 255)
MinLine.TextSize = 20
MinLine.Font = Enum.Font.GothamBold
MinLine.Parent = MinBtn

local Content = Instance.new("ScrollingFrame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -20, 1, -60)
Content.Position = UDim2.new(0, 10, 0, 55)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 4
Content.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 90)
Content.CanvasSize = UDim2.new(0, 0, 0, 700)
Content.Parent = MainFrame

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Padding = UDim.new(0, 10)
ContentLayout.Parent = Content

local StatusGui = Instance.new("ScreenGui")
StatusGui.Name = "FlingStatus"
StatusGui.ResetOnSpawn = false
StatusGui.DisplayOrder = 1001
StatusGui.Parent = (gethui and gethui()) or game.CoreGui

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0, 180, 0, 35)
StatusLabel.Position = UDim2.new(1, -195, 1, -50)
StatusLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
StatusLabel.Text = "  Fling: OFF"
StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
StatusLabel.TextSize = 16
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = StatusGui

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 8)
StatusCorner.Parent = StatusLabel

local StatusStroke = Instance.new("UIStroke")
StatusStroke.Color = Color3.fromRGB(60, 60, 70)
StatusStroke.Thickness = 1
StatusStroke.Parent = StatusLabel

local function CreateSection(title)
    local Section = Instance.new("Frame")
    Section.Size = UDim2.new(1, 0, 0, 30)
    Section.BackgroundTransparency = 1
    Section.Parent = Content
    
    local SectionText = Instance.new("TextLabel")
    SectionText.Size = UDim2.new(1, 0, 1, 0)
    SectionText.BackgroundTransparency = 1
    SectionText.Text = title
    SectionText.TextColor3 = Color3.fromRGB(255, 255, 255)
    SectionText.TextSize = 15
    SectionText.Font = Enum.Font.GothamBold
    SectionText.TextXAlignment = Enum.TextXAlignment.Left
    SectionText.Parent = Section
    
    return Section
end

local function CreateToggle(title, desc, default, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 60)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Parent = Content
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 8)
    ToggleCorner.Parent = ToggleFrame
    
    local ToggleTitle = Instance.new("TextLabel")
    ToggleTitle.Size = UDim2.new(1, -80, 0, 22)
    ToggleTitle.Position = UDim2.new(0, 15, 0, 10)
    ToggleTitle.BackgroundTransparency = 1
    ToggleTitle.Text = title
    ToggleTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleTitle.TextSize = 14
    ToggleTitle.Font = Enum.Font.GothamSemibold
    ToggleTitle.TextXAlignment = Enum.TextXAlignment.Left
    ToggleTitle.Parent = ToggleFrame
    
    local ToggleDesc = Instance.new("TextLabel")
    ToggleDesc.Size = UDim2.new(1, -80, 0, 18)
    ToggleDesc.Position = UDim2.new(0, 15, 0, 32)
    ToggleDesc.BackgroundTransparency = 1
    ToggleDesc.Text = desc
    ToggleDesc.TextColor3 = Color3.fromRGB(100, 100, 110)
    ToggleDesc.TextSize = 11
    ToggleDesc.Font = Enum.Font.Gotham
    ToggleDesc.TextXAlignment = Enum.TextXAlignment.Left
    ToggleDesc.TextTruncate = Enum.TextTruncate.AtEnd
    ToggleDesc.Parent = ToggleFrame
    
    local ToggleBtn = Instance.new("Frame")
    ToggleBtn.Size = UDim2.new(0, 50, 0, 28)
    ToggleBtn.Position = UDim2.new(1, -65, 0.5, -14)
    ToggleBtn.BackgroundColor3 = default and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(50, 50, 58)
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Parent = ToggleFrame
    
    local ToggleBtnCorner = Instance.new("UICorner")
    ToggleBtnCorner.CornerRadius = UDim.new(1, 0)
    ToggleBtnCorner.Parent = ToggleBtn
    
    local ToggleCircle = Instance.new("Frame")
    ToggleCircle.Size = UDim2.new(0, 22, 0, 22)
    ToggleCircle.Position = default and UDim2.new(1, -25, 0.5, -11) or UDim2.new(0, 3, 0.5, -11)
    ToggleCircle.BackgroundColor3 = default and Color3.fromRGB(35, 35, 42) or Color3.fromRGB(255, 255, 255)
    ToggleCircle.BorderSizePixel = 0
    ToggleCircle.Parent = ToggleBtn
    
    local CircleCorner = Instance.new("UICorner")
    CircleCorner.CornerRadius = UDim.new(1, 0)
    CircleCorner.Parent = ToggleCircle
    
    local toggled = default
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(1, 0, 1, 0)
    ToggleButton.BackgroundTransparency = 1
    ToggleButton.Text = ""
    ToggleButton.Parent = ToggleFrame
    
    local function updateToggle(state)
        toggled = state
        TweenService:Create(ToggleBtn, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
            BackgroundColor3 = toggled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(50, 50, 58)
        }):Play()
        TweenService:Create(ToggleCircle, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
            Position = toggled and UDim2.new(1, -25, 0.5, -11) or UDim2.new(0, 3, 0.5, -11),
            BackgroundColor3 = toggled and Color3.fromRGB(35, 35, 42) or Color3.fromRGB(255, 255, 255)
        }):Play()
        callback(toggled)
    end
    
    ToggleButton.MouseButton1Click:Connect(function()
        updateToggle(not toggled)
    end)
    
    return ToggleFrame, updateToggle
end

local function CreateInput(title, desc, placeholder, default, callback)
    local InputFrame = Instance.new("Frame")
    InputFrame.Size = UDim2.new(1, 0, 0, 85)
    InputFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    InputFrame.BorderSizePixel = 0
    InputFrame.Parent = Content
    
    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 8)
    InputCorner.Parent = InputFrame
    
    local InputTitle = Instance.new("TextLabel")
    InputTitle.Size = UDim2.new(1, -20, 0, 22)
    InputTitle.Position = UDim2.new(0, 15, 0, 10)
    InputTitle.BackgroundTransparency = 1
    InputTitle.Text = title
    InputTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    InputTitle.TextSize = 14
    InputTitle.Font = Enum.Font.GothamSemibold
    InputTitle.TextXAlignment = Enum.TextXAlignment.Left
    InputTitle.Parent = InputFrame
    
    local InputDesc = Instance.new("TextLabel")
    InputDesc.Size = UDim2.new(1, -20, 0, 15)
    InputDesc.Position = UDim2.new(0, 15, 0, 30)
    InputDesc.BackgroundTransparency = 1
    InputDesc.Text = desc
    InputDesc.TextColor3 = Color3.fromRGB(100, 100, 110)
    InputDesc.TextSize = 11
    InputDesc.Font = Enum.Font.Gotham
    InputDesc.TextXAlignment = Enum.TextXAlignment.Left
    InputDesc.Parent = InputFrame
    
    local InputBox = Instance.new("TextBox")
    InputBox.Size = UDim2.new(1, -30, 0, 30)
    InputBox.Position = UDim2.new(0, 15, 0, 48)
    InputBox.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    InputBox.BorderSizePixel = 0
    InputBox.Text = default
    InputBox.PlaceholderText = placeholder
    InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    InputBox.PlaceholderColor3 = Color3.fromRGB(80, 80, 90)
    InputBox.TextSize = 13
    InputBox.Font = Enum.Font.Gotham
    InputBox.ClearTextOnFocus = false
    InputBox.Parent = InputFrame
    
    local InputBoxCorner = Instance.new("UICorner")
    InputBoxCorner.CornerRadius = UDim.new(0, 6)
    InputBoxCorner.Parent = InputBox
    
    local InputPadding = Instance.new("UIPadding")
    InputPadding.PaddingLeft = UDim.new(0, 10)
    InputPadding.Parent = InputBox
    
    InputBox.FocusLost:Connect(function()
        callback(InputBox.Text)
    end)
    
    return InputFrame
end

local function CreateCheckbox(title, default, callback)
    local CheckFrame = Instance.new("Frame")
    CheckFrame.Size = UDim2.new(1, 0, 0, 32)
    CheckFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    CheckFrame.BorderSizePixel = 0
    CheckFrame.Parent = Content
    
    local CheckCorner = Instance.new("UICorner")
    CheckCorner.CornerRadius = UDim.new(0, 6)
    CheckCorner.Parent = CheckFrame
    
    local CheckBox = Instance.new("Frame")
    CheckBox.Size = UDim2.new(0, 18, 0, 18)
    CheckBox.Position = UDim2.new(0, 12, 0.5, -9)
    CheckBox.BackgroundColor3 = default and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(50, 50, 58)
    CheckBox.BorderSizePixel = 0
    CheckBox.Parent = CheckFrame
    
    local CheckBoxCorner = Instance.new("UICorner")
    CheckBoxCorner.CornerRadius = UDim.new(0, 4)
    CheckBoxCorner.Parent = CheckBox
    
    local CheckText = Instance.new("TextLabel")
    CheckText.Size = UDim2.new(1, -50, 1, 0)
    CheckText.Position = UDim2.new(0, 40, 0, 0)
    CheckText.BackgroundTransparency = 1
    CheckText.Text = title
    CheckText.TextColor3 = Color3.fromRGB(200, 200, 210)
    CheckText.TextSize = 13
    CheckText.Font = Enum.Font.Gotham
    CheckText.TextXAlignment = Enum.TextXAlignment.Left
    CheckText.Parent = CheckFrame
    
    local checked = default
    
    local CheckBtn = Instance.new("TextButton")
    CheckBtn.Size = UDim2.new(1, 0, 1, 0)
    CheckBtn.BackgroundTransparency = 1
    CheckBtn.Text = ""
    CheckBtn.Parent = CheckFrame
    
    CheckBtn.MouseButton1Click:Connect(function()
        checked = not checked
        TweenService:Create(CheckBox, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
            BackgroundColor3 = checked and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(50, 50, 58)
        }):Play()
        callback(checked)
    end)
    
    return CheckFrame
end

local function CreateButton(title, desc, callback)
    local BtnFrame = Instance.new("Frame")
    BtnFrame.Size = UDim2.new(1, 0, 0, 55)
    BtnFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    BtnFrame.BorderSizePixel = 0
    BtnFrame.Parent = Content
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = BtnFrame
    
    local BtnTitle = Instance.new("TextLabel")
    BtnTitle.Size = UDim2.new(1, -50, 0, 20)
    BtnTitle.Position = UDim2.new(0, 15, 0, 10)
    BtnTitle.BackgroundTransparency = 1
    BtnTitle.Text = title
    BtnTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    BtnTitle.TextSize = 14
    BtnTitle.Font = Enum.Font.GothamSemibold
    BtnTitle.TextXAlignment = Enum.TextXAlignment.Left
    BtnTitle.Parent = BtnFrame
    
    local BtnDesc = Instance.new("TextLabel")
    BtnDesc.Size = UDim2.new(1, -50, 0, 15)
    BtnDesc.Position = UDim2.new(0, 15, 0, 30)
    BtnDesc.BackgroundTransparency = 1
    BtnDesc.Text = desc
    BtnDesc.TextColor3 = Color3.fromRGB(100, 100, 110)
    BtnDesc.TextSize = 11
    BtnDesc.Font = Enum.Font.Gotham
    BtnDesc.TextXAlignment = Enum.TextXAlignment.Left
    BtnDesc.Parent = BtnFrame
    
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""
    Btn.Parent = BtnFrame
    
    Btn.MouseButton1Click:Connect(function()
        TweenService:Create(BtnFrame, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        }):Play()
        task.wait(0.1)
        TweenService:Create(BtnFrame, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(35, 35, 42)
        }):Play()
        callback()
    end)
    
    return BtnFrame
end

CreateSection("Fling Controls")

local _, updateFlingToggle = CreateToggle("Fling All Players", "Toggle with Right Ctrl key or click here", false, function(value)
    getgenv().FlingEnabled = value
    StatusLabel.Text = "  Fling: " .. (value and "ON" or "OFF")
    StatusLabel.TextColor3 = value and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    
    if getgenv().BlackScreenEnabled then
        BlackFrame.Visible = value
        if value then
            muteGameSounds()
        else
            unmuteGameSounds()
        end
    end
end)

local InputFrame = Instance.new("Frame")
InputFrame.Size = UDim2.new(1, 0, 0, 85)
InputFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
InputFrame.BorderSizePixel = 0
InputFrame.Parent = Content

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 8)
InputCorner.Parent = InputFrame

local InputTitle = Instance.new("TextLabel")
InputTitle.Size = UDim2.new(1, -20, 0, 22)
InputTitle.Position = UDim2.new(0, 15, 0, 10)
InputTitle.BackgroundTransparency = 1
InputTitle.Text = "Target Player"
InputTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
InputTitle.TextSize = 14
InputTitle.Font = Enum.Font.GothamSemibold
InputTitle.TextXAlignment = Enum.TextXAlignment.Left
InputTitle.Parent = InputFrame

local InputDesc = Instance.new("TextLabel")
InputDesc.Size = UDim2.new(1, -20, 0, 15)
InputDesc.Position = UDim2.new(0, 15, 0, 30)
InputDesc.BackgroundTransparency = 1
InputDesc.Text = "Leave empty to fling everyone, or enter specific player"
InputDesc.TextColor3 = Color3.fromRGB(100, 100, 110)
InputDesc.TextSize = 11
InputDesc.Font = Enum.Font.Gotham
InputDesc.TextXAlignment = Enum.TextXAlignment.Left
InputDesc.Parent = InputFrame

local InputBox = Instance.new("TextBox")
InputBox.Size = UDim2.new(1, -30, 0, 30)
InputBox.Position = UDim2.new(0, 15, 0, 48)
InputBox.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
InputBox.BorderSizePixel = 0
InputBox.Text = ""
InputBox.PlaceholderText = "Enter username or User ID..."
InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
InputBox.PlaceholderColor3 = Color3.fromRGB(80, 80, 90)
InputBox.TextSize = 13
InputBox.Font = Enum.Font.Gotham
InputBox.ClearTextOnFocus = false
InputBox.Parent = InputFrame

local InputBoxCorner = Instance.new("UICorner")
InputBoxCorner.CornerRadius = UDim.new(0, 6)
InputBoxCorner.Parent = InputBox

local InputPadding = Instance.new("UIPadding")
InputPadding.PaddingLeft = UDim.new(0, 10)
InputPadding.Parent = InputBox

local DropdownFrame = Instance.new("ScrollingFrame")
DropdownFrame.Size = UDim2.new(1, -30, 0, 0)
DropdownFrame.Position = UDim2.new(0, 15, 0, 80)
DropdownFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
DropdownFrame.BorderSizePixel = 0
DropdownFrame.Visible = false
DropdownFrame.ScrollBarThickness = 4
DropdownFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 90)
DropdownFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
DropdownFrame.Parent = InputFrame
DropdownFrame.ZIndex = 10

local DropdownCorner = Instance.new("UICorner")
DropdownCorner.CornerRadius = UDim.new(0, 6)
DropdownCorner.Parent = DropdownFrame

local DropdownLayout = Instance.new("UIListLayout")
DropdownLayout.SortOrder = Enum.SortOrder.LayoutOrder
DropdownLayout.Padding = UDim.new(0, 2)
DropdownLayout.Parent = DropdownFrame

local function updateDropdown(searchText)
    for _, child in ipairs(DropdownFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    if searchText == "" then
        DropdownFrame.Visible = false
        InputFrame.Size = UDim2.new(1, 0, 0, 85)
        return
    end
    
    local matches = {}
    searchText = string.lower(searchText)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local name = string.lower(player.Name)
            local displayName = string.lower(player.DisplayName)
            if name:find(searchText) or displayName:find(searchText) or tostring(player.UserId):find(searchText) then
                table.insert(matches, player)
            end
        end
    end
    
    if #matches == 0 then
        DropdownFrame.Visible = false
        InputFrame.Size = UDim2.new(1, 0, 0, 85)
        return
    end
    
    for _, player in ipairs(matches) do
        local PlayerButton = Instance.new("TextButton")
        PlayerButton.Size = UDim2.new(1, -8, 0, 30)
        PlayerButton.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
        PlayerButton.BorderSizePixel = 0
        PlayerButton.Text = ""
        PlayerButton.AutoButtonColor = false
        PlayerButton.Parent = DropdownFrame
        PlayerButton.ZIndex = 11
        
        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 4)
        BtnCorner.Parent = PlayerButton
        
        local PlayerName = Instance.new("TextLabel")
        PlayerName.Size = UDim2.new(1, -10, 1, 0)
        PlayerName.Position = UDim2.new(0, 10, 0, 0)
        PlayerName.BackgroundTransparency = 1
        PlayerName.Text = player.DisplayName .. " (@" .. player.Name .. ")"
        PlayerName.TextColor3 = Color3.fromRGB(255, 255, 255)
        PlayerName.TextSize = 12
        PlayerName.Font = Enum.Font.Gotham
        PlayerName.TextXAlignment = Enum.TextXAlignment.Left
        PlayerName.Parent = PlayerButton
        PlayerName.ZIndex = 11
        
        PlayerButton.MouseButton1Click:Connect(function()
            InputBox.Text = player.Name
            getgenv().FlingTargetName = player.Name
            DropdownFrame.Visible = false
            InputFrame.Size = UDim2.new(1, 0, 0, 85)
        end)
        
        PlayerButton.MouseEnter:Connect(function()
            TweenService:Create(PlayerButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            }):Play()
        end)
        
        PlayerButton.MouseLeave:Connect(function()
            TweenService:Create(PlayerButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(30, 30, 38)
            }):Play()
        end)
    end
    
    local dropdownHeight = math.min(#matches * 32, 150)
    DropdownFrame.Size = UDim2.new(1, -30, 0, dropdownHeight)
    DropdownFrame.CanvasSize = UDim2.new(0, 0, 0, #matches * 32)
    DropdownFrame.Visible = true
    InputFrame.Size = UDim2.new(1, 0, 0, 85 + dropdownHeight + 5)
end

InputBox:GetPropertyChangedSignal("Text"):Connect(function()
    updateDropdown(InputBox.Text)
end)

InputBox.FocusLost:Connect(function()
    task.wait(0.2)
    DropdownFrame.Visible = false
    InputFrame.Size = UDim2.new(1, 0, 0, 85)
    getgenv().FlingTargetName = InputBox.Text
end)

InputBox.Focused:Connect(function()
    if InputBox.Text ~= "" then
        updateDropdown(InputBox.Text)
    end
end)

CreateSection("Display Settings")

CreateToggle("Black Screen", "Hide screen while flinging to protect your eyes", true, function(value)
    getgenv().BlackScreenEnabled = value
    if not value then
        BlackFrame.Visible = false
        unmuteGameSounds()
    elseif getgenv().FlingEnabled then
        BlackFrame.Visible = true
        muteGameSounds()
    end
end)

CreateSection("Team Filter")

local teamOptions = {"Civilian", "DOT", "Fire", "Jail", "Police", "Sheriff"}
for _, team in ipairs(teamOptions) do
    CreateCheckbox(team, true, function(checked)
        getgenv().FlingTeams[team] = checked
    end)
end

CreateSection("Quick Actions")

CreateButton("Fling Nearest Player", "Instantly target and fling the closest player", function()
    local nearestPlayer = nil
    local nearestDist = math.huge
    
    local myChar = LocalPlayer.Character
    if not myChar then return end
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local tHRP = p.Character:FindFirstChild("HumanoidRootPart")
            if tHRP then
                local dist = (tHRP.Position - myHRP.Position).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearestPlayer = p
                end
            end
        end
    end
    
    if nearestPlayer then
        getgenv().FlingTargetName = nearestPlayer.Name
        getgenv().FlingEnabled = true
        updateFlingToggle(true)
    end
end)

CreateButton("Stop Fling", "Immediately stop flinging", function()
    getgenv().FlingEnabled = false
    getgenv().FlingTargetName = ""
    updateFlingToggle(false)
    BlackFrame.Visible = false
    unmuteGameSounds()
end)

Content.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)

local dragging, dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    StatusGui:Destroy()
    BlackScreenGui:Destroy()
    getgenv()._fling_gui_loaded = false
    getgenv().FlingEnabled = false
end)

MinBtn.MouseButton1Click:Connect(function()
    menuOpen = not menuOpen
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
        Size = menuOpen and UDim2.new(0, 340, 0, 560) or UDim2.new(0, 340, 0, 50)
    }):Play()
end)

UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        getgenv().FlingEnabled = not getgenv().FlingEnabled
        updateFlingToggle(getgenv().FlingEnabled)
    end
end)

local function getTargetParts(player)
    local parts = {}
    if not player.Character then return parts end
    
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then table.insert(parts, hrp) end
    
    local torso = player.Character:FindFirstChild("Torso") or player.Character:FindFirstChild("UpperTorso")
    if torso then table.insert(parts, torso) end
    
    local head = player.Character:FindFirstChild("Head")
    if head then table.insert(parts, head) end
    
    local hum = player.Character:FindFirstChildOfClass("Humanoid")
    if hum and hum.SeatPart then
        table.insert(parts, hum.SeatPart)
        
        local seat = hum.SeatPart
        local vehicle = seat.Parent
        if vehicle then
            local body = vehicle:FindFirstChild("Body")
            if body then
                for _, part in ipairs(body:GetDescendants()) do
                    if part:IsA("BasePart") then
                        table.insert(parts, part)
                    end
                end
            end
            
            for _, part in ipairs(vehicle:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "Wheel" then
                    table.insert(parts, part)
                end
            end
            
            if vehicle.Parent and vehicle.Parent:IsA("Model") then
                for _, part in ipairs(vehicle.Parent:GetDescendants()) do
                    if part:IsA("BasePart") then
                        table.insert(parts, part)
                    end
                end
            end
        end
    end
    
    return parts
end

local function getMainTargetPart(player)
    if not player.Character then return nil end
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

local function getVehicleBodyCenter(player)
    if not player.Character then return nil end
    
    local hum = player.Character:FindFirstChildOfClass("Humanoid")
    if hum and hum.SeatPart then
        local seat = hum.SeatPart
        local vehicle = seat.Parent
        if vehicle then
            local body = vehicle:FindFirstChild("Body")
            if body then
                local largestPart = nil
                local largestSize = 0
                for _, part in ipairs(body:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "Wheel" and not part.Name:find("Seat") then
                        local size = part.Size.X * part.Size.Y * part.Size.Z
                        if size > largestSize then
                            largestSize = size
                            largestPart = part
                        end
                    end
                end
                if largestPart then return largestPart end
            end
            
            local largestPart = nil
            local largestSize = 0
            for _, part in ipairs(vehicle:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "Wheel" and not part.Name:find("Seat") then
                    local size = part.Size.X * part.Size.Y * part.Size.Z
                    if size > largestSize then
                        largestSize = size
                        largestPart = part
                    end
                end
            end
            if largestPart then return largestPart end
            
            return seat
        end
    end
    
    return nil
end

local function getPlayerTeam(player)
    local teamName = "Civilian"
    
    pcall(function()
        if player.Team then 
            teamName = player.Team.Name 
        end
    end)
    
    pcall(function()
        local data = player:FindFirstChild("DataFolder")
        if data then
            local info = data:FindFirstChild("Information")
            if info then
                local team = info:FindFirstChild("Team")
                if team and team.Value and team.Value ~= "" then 
                    teamName = team.Value 
                end
            end
        end
    end)
    
    return teamName
end

local function shouldFlingPlayer(player)
    if getgenv().FlingTargetName ~= "" then
        local targetId = tonumber(getgenv().FlingTargetName)
        if targetId then
            return player.UserId == targetId
        else
            local searchName = string.lower(getgenv().FlingTargetName)
            return string.lower(player.Name):find(searchName) or string.lower(player.DisplayName):find(searchName)
        end
    end
    
    local team = getPlayerTeam(player)
    
    if getgenv().FlingTeams[team] == true then
        return true
    end
    
    return false
end
local function teleportPlayerToMe(targetPlayer)
    local myChar = LocalPlayer.Character
    local targetChar = targetPlayer.Character
    
    if myChar and targetChar then
        local myHRP = myChar:FindFirstChild("HumanoidRootPart")
        local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
        
        if myHRP and targetHRP then
            targetHRP.CFrame = myHRP.CFrame + Vector3.new(0, 5, 0)
        end
    end
end
task.spawn(function()
    while true do
        pcall(function()
            if getgenv().FlingEnabled and LocalPlayer.Character then
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
    local flungPlayers = {}
    local flingConnection = nil
    
    while true do
        if getgenv().FlingEnabled then
            local allPlayers = {}
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local target = getMainTargetPart(p)
                    if target and shouldFlingPlayer(p) and not flungPlayers[p.UserId] then
                        table.insert(allPlayers, p)
                    end
                end
            end
            
            if #allPlayers == 0 then
                flungPlayers = {}
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        local target = getMainTargetPart(p)
                        if target and shouldFlingPlayer(p) then
                            table.insert(allPlayers, p)
                        end
                    end
                end
            end
            
            if #allPlayers > 0 then
                local player = allPlayers[1]
                
                if not flingConnection then
                    BlackSubText.Text = "Flinging: " .. player.Name .. "..."
                    teleportPlayerToMe(player)
task.wait(0.5)
                    local myChar = LocalPlayer.Character
                    if myChar then
                        local myHRP = myChar:FindFirstChild("HumanoidRootPart")
                        if myHRP then
                            local att0 = Instance.new("Attachment", myHRP)
                            local att1 = Instance.new("Attachment", myHRP)
                            local bv = Instance.new("BodyVelocity", myHRP)
                            local bav = Instance.new("BodyAngularVelocity", myHRP)
                            
                            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                            bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                            
                            bv.Velocity = Vector3.new(0, 0, 0)
                            bav.AngularVelocity = Vector3.new(0, 0, 0)
                            
                            local targetHum = player.Character:FindFirstChildOfClass("Humanoid")
                            local flingDuration = 3
                            
                            
                            if targetHum and targetHum.SeatPart then
                                inVehicle = true
                                flingDuration = 5
                                BlackSubText.Text = "Flinging: " .. player.Name .. " (in vehicle will take 5 seconds to fling)..."
                                
                                local seat = targetHum.SeatPart
                                if seat and seat:IsA("VehicleSeat") or seat:IsA("Seat") then
                                    local vehicle = seat.Parent
                                    if vehicle then
                                        for _, part in ipairs(vehicle:GetDescendants()) do
                                            if (part:IsA("VehicleSeat") or part:IsA("Seat")) and part ~= seat and not part.Occupant then
                                                pcall(function()
                                                    myHRP.CFrame = part.CFrame + Vector3.new(0, 2, 0)
                                                    task.wait(0.1)
                                                    part:Sit(myChar:FindFirstChildOfClass("Humanoid"))
                                                end)
                                                break
                                            end
                                        end
                                    end
                                end
                            end
                            
                            local startTime = tick()
                            
                            flingConnection = RunService.Heartbeat:Connect(function()
                            if not getgenv().FlingEnabled then
                                    flingConnection:Disconnect()
                                    flingConnection = nil
                                    pcall(function() att0:Destroy() end)
                                    pcall(function() att1:Destroy() end)
                                    pcall(function() bv:Destroy() end)
                                    pcall(function() bav:Destroy() end)
                                    flungPlayers[player.UserId] = true
                                    return
                                end
                                
                                if tick() - startTime > flingDuration then
                                    flingConnection:Disconnect()
                                    flingConnection = nil
                                    pcall(function() att0:Destroy() end)
                                    pcall(function() att1:Destroy() end)
                                    pcall(function() bv:Destroy() end)
                                    pcall(function() bav:Destroy() end)
                                    flungPlayers[player.UserId] = true
                                    return
                                end
                            
                            local tPart = getVehicleBodyCenter(player) or getMainTargetPart(player)
                            if not tPart then return end
                            
                            myChar = LocalPlayer.Character
                            if not myChar then return end
                            myHRP = myChar:FindFirstChild("HumanoidRootPart")
                            if not myHRP then return end
                            
                            local targetVel = tPart.AssemblyLinearVelocity
                            local speed = targetVel.Magnitude
local targetHum = player.Character:FindFirstChildOfClass("Humanoid")
local inVehicle = targetHum and targetHum.SeatPart ~= nil
                            local moveDir = speed > 1 and targetVel.Unit or tPart.CFrame.LookVector
if not inVehicle and speed < 30 then
    local walkPrediction = 15
    if speed > 16 then
        walkPrediction = 35
    elseif speed > 0.5 then
        walkPrediction = 25
        walkPrediction = 5
    end
    leadDistance = walkPrediction
end
local leadDistance = 30

if not inVehicle then
    if speed < 3 then
        leadDistance = 5
    elseif speed >= 3 and speed < 10 then
        leadDistance = 5
    elseif speed >= 10 and speed < 16 then
        leadDistance = 8
    elseif speed >= 16 then
        leadDistance = 12
    end
else
    if speed > 117 then
        leadDistance = 350
    elseif speed > 102 then
        leadDistance = 300
    elseif speed > 88 then
        leadDistance = 250
    elseif speed > 73 then
        leadDistance = 200
    elseif speed > 58 then
        leadDistance = 150
    elseif speed > 44 then
        leadDistance = 110
    elseif speed > 29 then
        leadDistance = 80
    else
        leadDistance = 50
    end
end
                            
local oscillationSpeed = 8
local oscillationDistance = leadDistance * 2

local offset = math.sin(tick() * oscillationSpeed) * oscillationDistance

local oscillationPos = tPart.Position + (moveDir * offset)

myHRP.CFrame = CFrame.new(oscillationPos)
myHRP.Velocity = Vector3.new(math.random(-25000, 25000), math.random(20000, 50000), math.random(-25000, 25000))
myHRP.RotVelocity = Vector3.new(math.random(-25000, 25000), math.random(-25000, 25000), math.random(-25000, 25000))     end)
                        end
                    end
                end
                task.wait(0.1)
            else
                task.wait(1)
            end
        else
            flungPlayers = {}
            BlackSubText.Text = "Waiting to start..."
            if flingConnection then
                flingConnection:Disconnect()
                flingConnection = nil
            end
            task.wait(0.1)
        end
    end
end)
