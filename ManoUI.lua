--[[
    MicroUI (micro-ui.lua)
    A compact, feature-rich, Fluent-styled UI library for Roblox.
    Designed to be small, mini, and fully functional.
]]

local MicroUI = {}
MicroUI.__index = MicroUI

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- Configuration & Theme (Fluent-inspired Palette)
local Theme = {
    Background = Color3.fromRGB(28, 28, 30),
    Border = Color3.fromRGB(63, 63, 70),
    Accent = Color3.fromRGB(0, 120, 212), -- Fluent Blue
    AccentHover = Color3.fromRGB(24, 142, 232),
    TextPrimary = Color3.fromRGB(245, 245, 245),
    TextSecondary = Color3.fromRGB(160, 160, 168),
    ComponentBackground = Color3.fromRGB(39, 39, 42),
    ComponentBorder = Color3.fromRGB(51, 51, 55),
    ComponentHover = Color3.fromRGB(45, 45, 49),
}

-- Utility: Simple Tweens
local function tween(object, duration, properties)
    local info = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local anim = TweenService:Create(object, info, properties)
    anim:Play()
    return anim
end

-- Utility: Make Draggable (Compact & Reliable)
local function makeDraggable(frame, handle)
    local dragging = false
    local dragInput, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Create Window
function MicroUI.CreateWindow(title)
    local self = setmetatable({}, MicroUI)
    
    -- Main ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MicroUI_Container"
    ScreenGui.ResetOnSpawn = false
    -- Try to parent to CoreGui, fallback to PlayerGui
    local success, _ = pcall(function()
        ScreenGui.Parent = CoreGui
    end)
    if not success then
        ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end
    self.Gui = ScreenGui

    -- Main Window Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainWindow"
    MainFrame.Size = UDim2.new(0, 310, 0, 360)
    MainFrame.Position = UDim2.new(0.5, -155, 0.5, -180)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    -- Rounded Corners
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = MainFrame

    -- Fluent Thin Dark Border
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Theme.Border
    MainStroke.Thickness = 1
    MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    MainStroke.Parent = MainFrame

    -- Title/Drag Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 32)
    TitleBar.BackgroundTransparency = 1
    TitleBar.Parent = MainFrame

    local TitleText = Instance.new("TextLabel")
    TitleText.Name = "TitleText"
    TitleText.Size = UDim2.new(1, -60, 1, 0)
    TitleText.Position = UDim2.new(0, 12, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = title or "Micro UI"
    TitleText.TextColor3 = Theme.TextPrimary
    TitleText.Font = Enum.Font.Goblin -- Modern structured font look, or SourceSansSemibold
    TitleText.TextSize = 13
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = TitleBar
    pcall(function() TitleText.Font = Enum.Font.SourceSansSemibold end) -- Fallback fallback

    -- Compact Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "CloseButton"
    CloseBtn.Size = UDim2.new(0, 32, 0, 32)
    CloseBtn.Position = UDim2.new(1, -32, 0, 0)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Theme.TextSecondary
    CloseBtn.TextSize = 20
    CloseBtn.Font = Enum.Font.SourceSans
    CloseBtn.Parent = TitleBar

    CloseBtn.MouseEnter:Connect(function()
        tween(CloseBtn, 0.15, {TextColor3 = Color3.fromRGB(232, 17, 35)})
    end)
    CloseBtn.MouseLeave:Connect(function()
        tween(CloseBtn, 0.15, {TextColor3 = Theme.TextSecondary})
    end)
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    -- Enable Dragging
    makeDraggable(MainFrame, TitleBar)

    -- Tab System Container (Mini sidebar format to save space)
    local TabSidebar = Instance.new("ScrollingFrame")
    TabSidebar.Name = "TabSidebar"
    TabSidebar.Size = UDim2.new(0, 75, 1, -42)
    TabSidebar.Position = UDim2.new(0, 6, 0, 36)
    TabSidebar.BackgroundTransparency = 1
    TabSidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabSidebar.ScrollBarThickness = 0
    TabSidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TabSidebar.Parent = MainFrame

    local SidebarLayout = Instance.new("UIListLayout")
    SidebarLayout.Padding = UDim.new(0, 4)
    SidebarLayout.Parent = TabSidebar

    -- Content Area Container
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, -93, 1, -42)
    ContentContainer.Position = UDim2.new(0, 87, 0, 36)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = MainFrame

    self.Tabs = {}
    self.SelectedTab = nil
    self.TabSidebar = TabSidebar
    self.ContentContainer = ContentContainer

    return self
end

-- Create Tab
function MicroUI:CreateTab(name)
    local tab = {}
    tab.Name = name
    tab.Active = false

    -- Sidebar Tab Button
    local TabBtn = Instance.new("TextButton")
    TabBtn.Name = name .. "_TabBtn"
    TabBtn.Size = UDim2.new(1, 0, 0, 26)
    TabBtn.BackgroundColor3 = Theme.ComponentBackground
    TabBtn.BackgroundTransparency = 1
    TabBtn.Text = name
    TabBtn.TextColor3 = Theme.TextSecondary
    TabBtn.Font = Enum.Font.SourceSansSemibold
    TabBtn.TextSize = 12
    TabBtn.Parent = self.TabSidebar

    local TabBtnCorner = Instance.new("UICorner")
    TabBtnCorner.CornerRadius = UDim.new(0, 4)
    TabBtnCorner.Parent = TabBtn

    -- Page container
    local Page = Instance.new("ScrollingFrame")
    Page.Name = name .. "_Page"
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.ScrollBarThickness = 2
    Page.ScrollBarImageColor3 = Theme.Border
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.Parent = self.ContentContainer

    local PageLayout = Instance.new("UIListLayout")
    PageLayout.Padding = UDim.new(0, 6)
    PageLayout.Parent = Page

    local PagePadding = Instance.new("UIPadding")
    PagePadding.PaddingLeft = UDim.new(0, 2)
    PagePadding.PaddingRight = UDim.new(0, 4)
    PagePadding.PaddingTop = UDim.new(0, 2)
    PagePadding.PaddingBottom = UDim.new(0, 4)
    PagePadding.Parent = Page

    tab.Button = TabBtn
    tab.Page = Page

    -- Tab Activation Function
    local function selectTab()
        for _, t in ipairs(self.Tabs) do
            t.Active = false
            t.Page.Visible = false
            tween(t.Button, 0.2, {
                BackgroundTransparency = 1,
                TextColor3 = Theme.TextSecondary
            })
        end
        tab.Active = true
        tab.Page.Visible = true
        tween(TabBtn, 0.2, {
            BackgroundTransparency = 0,
            BackgroundColor3 = Theme.ComponentBackground,
            TextColor3 = Theme.TextPrimary
        })
    end

    TabBtn.MouseButton1Click:Connect(selectTab)
    table.insert(self.Tabs, tab)

    -- Auto select first tab
    if #self.Tabs == 1 then
        selectTab()
    end

    -- Element API for each Page
    local elements = {}

    -- Label Element
    function elements:AddLabel(text)
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, 0, 0, 22)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.TextColor3 = Theme.TextSecondary
        Label.Font = Enum.Font.SourceSans
        Label.TextSize = 12
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Page

        local labelObj = {}
        function labelObj:SetText(newText)
            Label.Text = newText
        end
        return labelObj
    end

    -- Button Element
    function elements:AddButton(text, callback)
        callback = callback or function() end
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, 0, 0, 28)
        Btn.BackgroundColor3 = Theme.ComponentBackground
        Btn.Text = text
        Btn.TextColor3 = Theme.TextPrimary
        Btn.Font = Enum.Font.SourceSansSemibold
        Btn.TextSize = 12
        Btn.Parent = Page

        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 4)
        BtnCorner.Parent = Btn

        local BtnStroke = Instance.new("UIStroke")
        BtnStroke.Color = Theme.ComponentBorder
        BtnStroke.Thickness = 1
        BtnStroke.Parent = Btn

        -- Interactive animations
        Btn.MouseEnter:Connect(function()
            tween(Btn, 0.15, {BackgroundColor3 = Theme.ComponentHover})
        end)
        Btn.MouseLeave:Connect(function()
            tween(Btn, 0.15, {BackgroundColor3 = Theme.ComponentBackground})
        end)
        Btn.MouseButton1Down:Connect(function()
            tween(Btn, 0.05, {BackgroundTransparency = 0.3})
        end)
        Btn.MouseButton1Up:Connect(function()
            tween(Btn, 0.05, {BackgroundTransparency = 0})
            pcall(callback)
        end)
    end

    -- Toggle Element
    function elements:AddToggle(text, default, callback)
        callback = callback or function() end
        local state = default or false

        local ToggleFrame = Instance.new("TextButton")
        ToggleFrame.Size = UDim2.new(1, 0, 0, 28)
        ToggleFrame.BackgroundColor3 = Theme.ComponentBackground
        ToggleFrame.Text = ""
        ToggleFrame.Parent = Page

        local TFCorner = Instance.new("UICorner")
        TFCorner.CornerRadius = UDim.new(0, 4)
        TFCorner.Parent = ToggleFrame

        local TFStroke = Instance.new("UIStroke")
        TFStroke.Color = Theme.ComponentBorder
        TFStroke.Thickness = 1
        TFStroke.Parent = ToggleFrame

        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(1, -45, 1, 0)
        Title.Position = UDim2.new(0, 8, 0, 0)
        Title.BackgroundTransparency = 1
        Title.Text = text
        Title.TextColor3 = Theme.TextPrimary
        Title.Font = Enum.Font.SourceSans
        Title.TextSize = 12
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Parent = ToggleFrame

        -- Switch Housing (The Track)
        local Track = Instance.new("Frame")
        Track.Size = UDim2.new(0, 26, 0, 14)
        Track.Position = UDim2.new(1, -34, 0.5, -7)
        Track.BackgroundColor3 = state and Theme.Accent or Theme.Border
        Track.Parent = ToggleFrame

        local TrackCorner = Instance.new("UICorner")
        TrackCorner.CornerRadius = UDim.new(1, 0)
        TrackCorner.Parent = Track

        -- Switch Circle (The Slider Knob)
        local Knob = Instance.new("Frame")
        Knob.Size = UDim2.new(0, 10, 0, 10)
        Knob.Position = state and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5)
        Knob.BackgroundColor3 = Theme.TextPrimary
        Knob.Parent = Track

        local KnobCorner = Instance.new("UICorner")
        KnobCorner.CornerRadius = UDim.new(1, 0)
        KnobCorner.Parent = Knob

        local function updateToggle()
            if state then
                tween(Track, 0.2, {BackgroundColor3 = Theme.Accent})
                tween(Knob, 0.2, {Position = UDim2.new(1, -12, 0.5, -5)})
            else
                tween(Track, 0.2, {BackgroundColor3 = Theme.Border})
                tween(Knob, 0.2, {Position = UDim2.new(0, 2, 0.5, -5)})
            end
            pcall(callback, state)
        end

        ToggleFrame.MouseButton1Click:Connect(function()
            state = not state
            updateToggle()
        end)

        ToggleFrame.MouseEnter:Connect(function()
            tween(ToggleFrame, 0.15, {BackgroundColor3 = Theme.ComponentHover})
        end)
        ToggleFrame.MouseLeave:Connect(function()
            tween(ToggleFrame, 0.15, {BackgroundColor3 = Theme.ComponentBackground})
        end)

        return {
            SetState = function(_, newState)
                state = newState
                updateToggle()
            end
        }
    end

    -- Slider Element
    function elements:AddSlider(text, min, max, default, callback)
        min = min or 0
        max = max or 100
        default = math.clamp(default or min, min, max)
        callback = callback or function() end

        local value = default

        local SliderFrame = Instance.new("Frame")
        SliderFrame.Size = UDim2.new(1, 0, 0, 36)
        SliderFrame.BackgroundColor3 = Theme.ComponentBackground
        SliderFrame.Parent = Page

        local SFCorner = Instance.new("UICorner")
        SFCorner.CornerRadius = UDim.new(0, 4)
        SFCorner.Parent = SliderFrame

        local SFStroke = Instance.new("UIStroke")
        SFStroke.Color = Theme.ComponentBorder
        SFStroke.Thickness = 1
        SFStroke.Parent = SliderFrame

        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(1, -60, 0, 16)
        Title.Position = UDim2.new(0, 8, 0, 4)
        Title.BackgroundTransparency = 1
        Title.Text = text
        Title.TextColor3 = Theme.TextPrimary
        Title.Font = Enum.Font.SourceSans
        Title.TextSize = 11
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Parent = SliderFrame

        local ValLabel = Instance.new("TextLabel")
        ValLabel.Size = UDim2.new(0, 50, 0, 16)
        ValLabel.Position = UDim2.new(1, -58, 0, 4)
        ValLabel.BackgroundTransparency = 1
        ValLabel.Text = tostring(value)
        ValLabel.TextColor3 = Theme.Accent
        ValLabel.Font = Enum.Font.SourceSansSemibold
        ValLabel.TextSize = 11
        ValLabel.TextXAlignment = Enum.TextXAlignment.Right
        ValLabel.Parent = SliderFrame

        -- Slider Bar Background
        local SliderBarBg = Instance.new("TextButton")
        SliderBarBg.Name = "SliderTrack"
        SliderBarBg.Size = UDim2.new(1, -16, 0, 4)
        SliderBarBg.Position = UDim2.new(0, 8, 1, -10)
        SliderBarBg.BackgroundColor3 = Theme.Border
        SliderBarBg.Text = ""
        SliderBarBg.Parent = SliderFrame

        local SBarBgCorner = Instance.new("UICorner")
        SBarBgCorner.CornerRadius = UDim.new(1, 0)
        SBarBgCorner.Parent = SliderBarBg

        -- Active Fill Progress
        local SliderBarFill = Instance.new("Frame")
        SliderBarFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
        SliderBarFill.BackgroundColor3 = Theme.Accent
        SliderBarFill.BorderSizePixel = 0
        SliderBarFill.Parent = SliderBarBg

        local SBarFillCorner = Instance.new("UICorner")
        SBarFillCorner.CornerRadius = UDim.new(1, 0)
        SBarFillCorner.Parent = SliderBarFill

        local dragging = false

        local function updateSlider(input)
            local pos = math.clamp((input.Position.X - SliderBarBg.AbsolutePosition.X) / SliderBarBg.AbsoluteSize.X, 0, 1)
            value = math.floor(min + ((max - min) * pos))
            ValLabel.Text = tostring(value)
            tween(SliderBarFill, 0.1, {Size = UDim2.new(pos, 0, 1, 0)})
            pcall(callback, value)
        end

        SliderBarBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                updateSlider(input)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                updateSlider(input)
            end
        end)

        return {
            SetValue = function(_, val)
                value = math.clamp(val, min, max)
                ValLabel.Text = tostring(value)
                local pos = (value - min) / (max - min)
                tween(SliderBarFill, 0.1, {Size = UDim2.new(pos, 0, 1, 0)})
                pcall(callback, value)
            end
        }
    end

    -- Textbox (Input) Element
    function elements:AddTextbox(text, placeholder, callback)
        callback = callback or function() end

        local BoxFrame = Instance.new("Frame")
        BoxFrame.Size = UDim2.new(1, 0, 0, 32)
        BoxFrame.BackgroundColor3 = Theme.ComponentBackground
        BoxFrame.Parent = Page

        local BFCorner = Instance.new("UICorner")
        BFCorner.CornerRadius = UDim.new(0, 4)
        BFCorner.Parent = BoxFrame

        local BFStroke = Instance.new("UIStroke")
        BFStroke.Color = Theme.ComponentBorder
        BFStroke.Thickness = 1
        BFStroke.Parent = BoxFrame

        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(0.4, 0, 1, 0)
        Title.Position = UDim2.new(0, 8, 0, 0)
        Title.BackgroundTransparency = 1
        Title.Text = text
        Title.TextColor3 = Theme.TextPrimary
        Title.Font = Enum.Font.SourceSans
        Title.TextSize = 12
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Parent = BoxFrame

        local Input = Instance.new("TextBox")
        Input.Size = UDim2.new(0.6, -14, 0, 20)
        Input.Position = UDim2.new(0.4, 6, 0.5, -10)
        Input.BackgroundColor3 = Theme.Background
        Input.Text = ""
        Input.PlaceholderText = placeholder or "Type..."
        Input.PlaceholderColor3 = Theme.TextSecondary
        Input.TextColor3 = Theme.TextPrimary
        Input.Font = Enum.Font.SourceSans
        Input.TextSize = 11
        Input.ClipsDescendants = true
        Input.Parent = BoxFrame

        local InputCorner = Instance.new("UICorner")
        InputCorner.CornerRadius = UDim.new(0, 3)
        InputCorner.Parent = Input

        local InputStroke = Instance.new("UIStroke")
        InputStroke.Color = Theme.ComponentBorder
        InputStroke.Thickness = 1
        InputStroke.Parent = Input

        Input.FocusLost:Connect(function(enterPressed)
            pcall(callback, Input.Text, enterPressed)
        end)

        Input.Focused:Connect(function()
            tween(InputStroke, 0.15, {Color = Theme.Accent})
        end)
        Input.FocusLost:Connect(function()
            tween(InputStroke, 0.15, {Color = Theme.ComponentBorder})
        end)
    end

    -- Dropdown Element
    function elements:AddDropdown(text, list, callback)
        list = list or {}
        callback = callback or function() end

        local dropdownActive = false
        local selectedValue = list[1] or ""

        local DropdownFrame = Instance.new("Frame")
        DropdownFrame.Size = UDim2.new(1, 0, 0, 30)
        DropdownFrame.BackgroundColor3 = Theme.ComponentBackground
        DropdownFrame.ClipsDescendants = true
        DropdownFrame.Parent = Page

        local DFCorner = Instance.new("UICorner")
        DFCorner.CornerRadius = UDim.new(0, 4)
        DFCorner.Parent = DropdownFrame

        local DFStroke = Instance.new("UIStroke")
        DFStroke.Color = Theme.ComponentBorder
        DFStroke.Thickness = 1
        DFStroke.Parent = DropdownFrame

        -- Top interactable row
        local DropBtn = Instance.new("TextButton")
        DropBtn.Size = UDim2.new(1, 0, 0, 30)
        DropBtn.BackgroundTransparency = 1
        DropBtn.Text = ""
        DropBtn.Parent = DropdownFrame

        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(0.4, 0, 1, 0)
        Title.Position = UDim2.new(0, 8, 0, 0)
        Title.BackgroundTransparency = 1
        Title.Text = text
        Title.TextColor3 = Theme.TextPrimary
        Title.Font = Enum.Font.SourceSans
        Title.TextSize = 12
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Parent = DropBtn

        local SelLabel = Instance.new("TextLabel")
        SelLabel.Size = UDim2.new(0.6, -24, 1, 0)
        SelLabel.Position = UDim2.new(0.4, 4, 0, 0)
        SelLabel.BackgroundTransparency = 1
        SelLabel.Text = selectedValue
        SelLabel.TextColor3 = Theme.Accent
        SelLabel.Font = Enum.Font.SourceSansSemibold
        SelLabel.TextSize = 11
        SelLabel.TextXAlignment = Enum.TextXAlignment.Right
        SelLabel.Parent = DropBtn

        local Arrow = Instance.new("TextLabel")
        Arrow.Size = UDim2.new(0, 16, 0, 16)
        Arrow.Position = UDim2.new(1, -20, 0.5, -8)
        Arrow.BackgroundTransparency = 1
        Arrow.Text = "▼"
        Arrow.TextColor3 = Theme.TextSecondary
        Arrow.Font = Enum.Font.SourceSans
        Arrow.TextSize = 10
        Arrow.Parent = DropBtn

        -- List container
        local ItemList = Instance.new("Frame")
        ItemList.Size = UDim2.new(1, -12, 0, #list * 22)
        ItemList.Position = UDim2.new(0, 6, 0, 30)
        ItemList.BackgroundTransparency = 1
        ItemList.Parent = DropdownFrame

        local ListLayout = Instance.new("UIListLayout")
        ListLayout.Padding = UDim.new(0, 2)
        ListLayout.Parent = ItemList

        local function populate()
            for _, item in ipairs(list) do
                local ItemBtn = Instance.new("TextButton")
                ItemBtn.Size = UDim2.new(1, 0, 0, 20)
                ItemBtn.BackgroundColor3 = Theme.Background
                ItemBtn.Text = item
                ItemBtn.TextColor3 = Theme.TextPrimary
                ItemBtn.Font = Enum.Font.SourceSans
                ItemBtn.TextSize = 11
                ItemBtn.Parent = ItemList

                local ItemCorner = Instance.new("UICorner")
                ItemCorner.CornerRadius = UDim.new(0, 3)
                ItemCorner.Parent = ItemBtn

                ItemBtn.MouseButton1Click:Connect(function()
                    selectedValue = item
                    SelLabel.Text = selectedValue
                    dropdownActive = false
                    tween(DropdownFrame, 0.2, {Size = UDim2.new(1, 0, 0, 30)})
                    tween(Arrow, 0.2, {Rotation = 0})
                    pcall(callback, item)
                end)
            end
        end

        populate()

        DropBtn.MouseButton1Click:Connect(function()
            dropdownActive = not dropdownActive
            if dropdownActive then
                tween(DropdownFrame, 0.2, {Size = UDim2.new(1, 0, 0, 30 + (#list * 22) + 6)})
                tween(Arrow, 0.2, {Rotation = 180})
            else
                tween(DropdownFrame, 0.2, {Size = UDim2.new(1, 0, 0, 30)})
                tween(Arrow, 0.2, {Rotation = 0})
            end
        end)

        return {
            Refresh = function(_, newList)
                for _, child in ipairs(ItemList:GetChildren()) do
                    if child:IsA("TextButton") then
                        child:Destroy()
                    end
                end
                list = newList
                populate()
                if dropdownActive then
                    DropdownFrame.Size = UDim2.new(1, 0, 0, 30 + (#list * 22) + 6)
                end
            end
        }
    end

    return elements
end

return MicroUI
