--[[
    ========================================================================
    MANO UI - EXAMPLE IMPLEMENTATION
    ========================================================================
    This demonstrates how to utilize the library to create UI Tabs,
    and attach modern executor functions.
    ========================================================================
]]

-- Load the Module from your GitHub raw repository
local ManoUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Onekill507/mano-UI/refs/heads/main/ManoUI.lua"))()

-- Instantiate the Main Window UI
local Window = ManoUI.new("Mano UI Executor")

-- Send a Premium Toast Notification
Window:Notify("System Active", "Mano UI loaded successfully. Press Right Control to toggle visibility.", 6)

-- Create tab instances
local MainTab = Window:AddTab("Home")
local VisualsTab = Window:AddTab("Visuals")
local SettingsTab = Window:AddTab("Settings")

-- ========================================================================
-- HOME TAB - COMPONENTS
-- ========================================================================

-- Action Button
MainTab:AddButton("Destroy All Ceilings", function()
    Window:Notify("Executing Script...", "Removing standard level roofs.", 3)
    -- Your real game execution logic goes here!
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Part") and (obj.Name == "Roof" or obj.Name == "Ceiling") then
            obj:Destroy()
        end
    end
end)

-- Reactive Switch (Toggle)
local speedHackEnabled = false
MainTab:AddToggle("Speed Booster", false, function(state)
    speedHackEnabled = state
    Window:Notify("Toggle Switched", "Speed Enhancement set to: " .. tostring(state), 2)
    
    task.spawn(function()
        while speedHackEnabled do
            local character = game.Players.LocalPlayer.Character
            if character and character:FindFirstChild("Humanoid") then
                character.Humanoid.WalkSpeed = 35
            end
            task.wait(0.5)
        end
        -- Reset speed when disabled
        local character = game.Players.LocalPlayer.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.WalkSpeed = 16
        end
    end)
end)

-- Slider Interface
MainTab:AddSlider("Jump Power Multiplier", 50, 250, 50, function(value)
    local character = game.Players.LocalPlayer.Character
    if character and character:FindFirstChild("Humanoid") then
        character.Humanoid.JumpPower = value
        character.Humanoid.UseJumpPower = true
    end
end)

-- Text Entry Interface
MainTab:AddTextBox("Custom Name Tag", "Type display name...", true, function(enteredText, enterPressed)
    if enterPressed then
        Window:Notify("Target Locked", "Custom user tag saved as: " .. enteredText, 3)
    end
end)

-- ========================================================================
-- VISUALS TAB - COMPONENTS
-- ========================================================================

VisualsTab:AddToggle("ESP Box Enabled", false, function(state)
    Window:Notify("ESP System", "Player boxes updated.", 2)
end)

-- Dropdown Option Menu
local DropdownCard, DropdownRef = VisualsTab:AddDropdown("Render Quality", {"Low", "Medium", "High", "Ultra Premium"}, "High", function(selectedValue)
    Window:Notify("Graphics Overhaul", "Quality rendering preset set to: " .. selectedValue, 3.5)
end)

-- Action Button to update existing Dropdown Options dynamically
VisualsTab:AddButton("Unlock Hidden Presets", function()
    DropdownRef:Refresh({"Low", "Medium", "High", "Ultra Premium", "Extreme Mano V2"})
    Window:Notify("System Unlocked", "Added 'Extreme Mano V2' option to graphics presets!", 4)
end)

-- ========================================================================
-- SETTINGS TAB - COMPONENTS
-- ========================================================================

-- Interactive Keybind Mapper
SettingsTab:AddKeybind("Toggle UI Key", Enum.KeyCode.RightControl, function(newKey)
    Window.ToggleKey = newKey
    Window:Notify("System Key Changed", "You can now open/close the menu with: " .. newKey.Name, 4)
end)

SettingsTab:AddButton("Reset All Preferences", function()
    Window:Notify("Clean Reset", "Default configurations successfully restored.", 3.5)
end)
