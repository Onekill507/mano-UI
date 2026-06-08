--[[
    usage.lua
    A complete demonstration script showcasing how to use the MicroUI library
    defined in your Canvas. Run this in your Roblox executor.
]]

-- 1. Load the MicroUI Library
-- In a real scenario, you can load it via loadstring if hosted, e.g.:
-- local MicroUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/.../micro-ui.lua"))()
-- For local testing in Roblox Studio, you can require it or paste it into a ModuleScript:
local MicroUI = nil
local success, err = pcall(function()
    -- Attempt to find it if it was run beforehand or stored in ReplicatedStorage
    MicroUI = shared.MicroUI or require(game:GetService("ReplicatedStorage"):WaitForChild("MicroUI"))
end)

if not MicroUI then
    -- Fallback: If not found as a module, we assume the library has been executed globally
    -- and attached itself to a global or shared variable.
    MicroUI = _G.MicroUI or shared.MicroUI
end

-- If both fail, let's notify the user (using a fallback print since we cannot alert)
if not MicroUI then
    warn("MicroUI Library not found! Make sure to run micro-ui.lua first or define shared.MicroUI = MicroUI at the end of it.")
    return
end

-- 2. Create the Fluent-style Compact Window
local Window = MicroUI.CreateWindow("Micro Executor v1.0")

-- 3. Create Tabs (Saves horizontal space with its mini-sidebar design)
local PlayerTab = Window:CreateTab("Player")
local TeleportTab = Window:CreateTab("Teleport")
local VisualsTab = Window:CreateTab("Visuals")
local SettingsTab = Window:CreateTab("Settings")

----------------------------------------------------
-- PLAYER TAB CONFIGURATION
----------------------------------------------------
PlayerTab:AddLabel("Local Player Modifiers")

-- WalkSpeed Slider
local speedSlider = PlayerTab:AddSlider("WalkSpeed", 16, 150, 16, function(value)
    local character = game.Players.LocalPlayer.Character
    if character and character:FindFirstChildOfClass("Humanoid") then
        character:FindFirstChildOfClass("Humanoid").WalkSpeed = value
    end
end)

-- JumpPower Slider
local jumpSlider = PlayerTab:AddSlider("JumpPower", 50, 250, 50, function(value)
    local character = game.Players.LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.UseJumpPower = true
        humanoid.JumpPower = value
    end
end)

-- Infinite Jump Toggle
local infiniteJumpEnabled = false
PlayerTab:AddToggle("Infinite Jump", false, function(state)
    infiniteJumpEnabled = state
end)

game:GetService("UserInputService").JumpRequest:Connect(function()
    if infiniteJumpEnabled then
        local character = game.Players.LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

----------------------------------------------------
-- TELEPORT TAB CONFIGURATION
----------------------------------------------------
TeleportTab:AddLabel("World Navigation")

-- Coordinate Teleporter Textbox
local targetCoordinates = ""
TeleportTab:AddTextbox("XYZ Coordinates", "e.g. 0, 50, 0", function(text, enterPressed)
    if enterPressed then
        targetCoordinates = text
    end
end)

TeleportTab:AddButton("Teleport to Coordinates", function()
    local character = game.Players.LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if rootPart and targetCoordinates ~= "" then
        local split = string.split(targetCoordinates, ",")
        local x = tonumber(split[1]) or 0
        local y = tonumber(split[2]) or 0
        local z = tonumber(split[3]) or 0
        rootPart.CFrame = CFrame.new(x, y, z)
    end
end)

-- Dropdown Teleporter for Key Landmarks
local landmarkDropdown = TeleportTab:AddDropdown("Select Landmark", {"Lobby", "Spawn Area", "VIP Room", "Item Shop"}, function(selectedItem)
    local character = game.Players.LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    if selectedItem == "Lobby" then
        rootPart.CFrame = CFrame.new(0, 10, 0) -- Update to matches your game's coordinates
    elseif selectedItem == "Spawn Area" then
        rootPart.CFrame = CFrame.new(100, 10, 100)
    elseif selectedItem == "VIP Room" then
        rootPart.CFrame = CFrame.new(-250, 15, 50)
    elseif selectedItem == "Item Shop" then
        rootPart.CFrame = CFrame.new(50, 5, -150)
    end
end)

----------------------------------------------------
-- VISUALS TAB CONFIGURATION
----------------------------------------------------
VisualsTab:AddLabel("Render & Environment Settings")

-- Ambient lighting adjusters
VisualsTab:AddToggle("Full Brightness", false, function(state)
    if state then
        game:GetService("Lighting").Ambient = Color3.fromRGB(255, 255, 255)
        game:GetService("Lighting").Brightness = 2
    else
        game:GetService("Lighting").Ambient = Color3.fromRGB(128, 128, 128)
        game:GetService("Lighting").Brightness = 1
    end
end)

-- Player ESP mock toggle
VisualsTab:AddToggle("Player ESP", false, function(state)
    -- In a live execution context, you would insert your highlight/ESP loop here
    print("ESP Status changed to: ", state)
end)

----------------------------------------------------
-- SETTINGS TAB CONFIGURATION
----------------------------------------------------
SettingsTab:AddLabel("UI Configuration")

-- Reset parameters button
SettingsTab:AddButton("Reset Values to Default", function()
    speedSlider:SetValue(16)
    jumpSlider:SetValue(50)
end)

-- UI Destruction
SettingsTab:AddButton("Unload UI Library", function()
    Window.Gui:Destroy()
end)

print("MicroUI Usage Script loaded and executed successfully!")
