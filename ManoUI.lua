--[[
    ========================================================================
    MANO UI LIBRARY (Rayfield-Inspired Premium Aesthetic)
    ========================================================================
    A high-performance, modern, beautifully styled Roblox UI Library.
    Designed with:
    - Object-Oriented Luau
    - Fluid Procedural Spring Animations
    - Glassmorphism & Accent Glows
    - Multi-Tab Support with Smooth Transitions
    - Rich Component Suite (Buttons, Toggles, Sliders, Dropdowns, Keybinds, TextBoxes)
    ========================================================================
]]

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local ManoUI = {}
ManoUI.__index = ManoUI

-- Custom Spring Engine for snappy, modern Rayfield-like physics
local Spring = {}
do
    Spring.__index = Spring
    function Spring.new(target, speed, damper)
        return setmetatable({
            Target = target or 0,
            Position = target or 0,
            Velocity = 0,
            Speed = speed or 12,
            Damper = damper or 0.75
        }, Spring)
    end
    function Spring:Update(dt)
        local d = this or self
        local displacement = d.Target - d.Position
        local force = displacement * d.Speed * d.Speed
        local damping = -2 * d.Velocity * d.Speed * d.Damper
        local acceleration = force + damping
        
        d.Velocity = d.Velocity + acceleration * dt
        d.Position = d.Position + d.Velocity * dt
        return d.Position
    end
end

-- Utility Functions
local function CreateInstance(className, properties)
    local inst = Instance.new(className)
    for k, v in pairs(properties) do
        inst[k] = v
    end
    return inst
end

local function MakeDraggable(dragBar, mainFrame)
    local dragging = false
    local dragInput, dragStart, startPos

    dragBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            TweenService:Create(mainFrame, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            }):Play()
        end
    end)
end

function ManoUI.new(titleText)
    local self = setmetatable({}, ManoUI)
    
    self.Theme = {
        Background = Color3.fromRGB(13, 13, 16),
        Sidebar = Color3.fromRGB(18, 18, 22),
        Accent = Color3.fromRGB(0, 162, 255),
        AccentGlow = Color3.fromRGB(0, 162, 255),
        CardBackground = Color3.fromRGB(22, 22, 28),
        Text = Color3.fromRGB(240, 240, 245),
        SubText = Color3.fromRGB(130, 130, 145),
        Border = Color3.fromRGB(35, 35, 45)
    }

    -- Root ScreenGui
    self.ScreenGui = CreateInstance("ScreenGui", {
        Name = "ManoUI_Exec",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    -- Try protecting GUI
    pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(self.ScreenGui)
            self.ScreenGui.Parent = CoreGui
        elseif gethui then
            self.ScreenGui.Parent = gethui()
        else
            self.ScreenGui.Parent = CoreGui
        end
    end)
    if not self.ScreenGui.Parent then
        self.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    -- Backdrop Shadow Blur simulation (Glow Frame)
    local MainShadow = CreateInstance("Frame", {
        Name = "GlowFrame",
        Size = UDim2.new(0, 616, 0, 416),
        Position = UDim2.new(0.5, -308, 0.5, -208),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.6,
        Parent = self.ScreenGui
    })
    CreateInstance("UICorner", { CornerRadius = UDim.new(0, 16), Parent = MainShadow })
    
    -- Main Panel
    local MainFrame = CreateInstance("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, 600, 0, 400),
        Position = UDim2.new(0, 8, 0, 8),
        BackgroundColor3 = self.Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = MainShadow
    })
    self.MainFrame = MainFrame
    
    CreateInstance("UICorner", { CornerRadius = UDim.new(0, 12), Parent = MainFrame })
    CreateInstance("UIStroke", {
        Color = self.Theme.Border,
        Thickness = 1.5,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = MainFrame
    })

    -- Drag Handle top bar
    local TopBar = CreateInstance("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 45),
        BackgroundTransparency = 1,
        Parent = MainFrame
    })
    MakeDraggable(TopBar, MainShadow)

    -- Header Title with Gradient Custom Logo Glow
    local Logo = CreateInstance("TextLabel", {
        Name = "LogoText",
        Position = UDim2.new(0, 16, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(0, 200, 0, 25),
        BackgroundTransparency = 1,
        Text = titleText or "MANO UI",
        TextColor3 = self.Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TopBar
    })

    local TitleGradient = CreateInstance("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, self.Theme.Accent)
        }),
        Parent = Logo
    })

    -- Premium Design Accents: Upper thin accent bar
    local AccentLine = CreateInstance("Frame", {
        Name = "AccentLine",
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 0, 45),
        BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    CreateInstance("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, self.Theme.Accent),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 0, 255)),
            ColorSequenceKeypoint.new(1, self.Theme.Accent)
        }),
        Parent = AccentLine
    })

    -- Close Button
    local CloseBtn = CreateInstance("TextButton", {
        Name = "CloseBtn",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -40, 0.5, -15),
        BackgroundTransparency = 1,
        Text = "×",
        TextColor3 = self.Theme.SubText,
        Font = Enum.Font.GothamMedium,
        TextSize = 24,
        Parent = TopBar
    })
    CloseBtn.MouseEnter:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 75, 75)}):Play()
    end)
    CloseBtn.MouseLeave:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.2), {TextColor3 = self.Theme.SubText}):Play()
    end)
    CloseBtn.MouseButton1Click:Connect(function()
        self:Destroy()
    end)

    -- Sidebar Container
    local Sidebar = CreateInstance("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 160, 1, -47),
        Position = UDim2.new(0, 0, 0, 47),
        BackgroundColor3 = self.Theme.Sidebar,
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    self.Sidebar = Sidebar

    local SidebarLine = CreateInstance("Frame", {
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, -1, 0, 0),
        BackgroundColor3 = self.Theme.Border,
        BorderSizePixel = 0,
        Parent = Sidebar
    })

    local SidebarScroll = CreateInstance("ScrollingFrame", {
        Size = UDim2.new(1, -8, 1, -10),
        Position = UDim2.new(0, 4, 0, 5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = self.Theme.Border,
        Parent = Sidebar
    })
    self.SidebarScroll = SidebarScroll

    local SidebarLayout = CreateInstance("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6),
        Parent = SidebarScroll
    })
    
    SidebarLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        SidebarScroll.CanvasSize = UDim2.new(0, 0, 0, SidebarLayout.AbsoluteContentSize.Y + 10)
    end)

    -- Tab Content Frame
    local TabContainer = CreateInstance("Frame", {
        Name = "TabContainer",
        Size = UDim2.new(1, -165, 1, -55),
        Position = UDim2.new(0, 165, 0, 51),
        BackgroundTransparency = 1,
        Parent = MainFrame
    })
    self.TabContainer = TabContainer

    self.Tabs = {}
    self.CurrentTab = nil

    -- Handle Keybind to Toggle Library Visibility
    self.ToggleKey = Enum.KeyCode.RightControl
    self.Visible = true
    self.InputConnection = UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == self.ToggleKey then
            self:Toggle()
        end
    end)

    return self
end

function ManoUI:Toggle()
    self.Visible = not self.Visible
    local targetTrans = self.Visible and 0 or 1
    local targetPos = self.Visible and UDim2.new(0.5, -308, 0.5, -208) or UDim2.new(0.5, -308, 0.5, -100)

    TweenService:Create(self.MainFrame.Parent, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = targetPos,
        BackgroundTransparency = self.Visible and 0.6 or 1
    }):Play()

    TweenService:Create(self.MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        BackgroundTransparency = targetTrans
    }):Play()

    for _, child in pairs(self.MainFrame:GetDescendants()) do
        if child:IsA("Frame") or child:IsA("TextLabel") or child:IsA("TextBox") or child:IsA("TextButton") or child:IsA("UIStroke") then
            local isVisibleObj = self.Visible
            if not isVisibleObj then
                -- Store old transparency states if we want to restore specifically, but basic toggle works
                TweenService:Create(child, TweenInfo.new(0.2), {
                    BackgroundTransparency = 1,
                    TextTransparency = 1,
                    ImageTransparency = 1
                }):Play()
            else
                -- Instantly restore UI state on toggle-on for responsive feels
                task.spawn(function()
                    task.wait(0.1)
                    child.BackgroundTransparency = child:GetAttribute("SavedBG") or child.BackgroundTransparency
                    if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                        child.TextTransparency = 0
                    end
                end)
            end
        end
    end
end

function ManoUI:Notify(titleText, descriptionText, duration)
    duration = duration or 5
    
    local NotificationFrame = CreateInstance("Frame", {
        Name = "Notification",
        Size = UDim2.new(0, 250, 0, 75),
        Position = UDim2.new(1, 300, 1, -90),
        BackgroundColor3 = self.Theme.CardBackground,
        Parent = self.ScreenGui
    })
    CreateInstance("UICorner", { CornerRadius = UDim.new(0, 8), Parent = NotificationFrame })
    CreateInstance("UIStroke", { Color = self.Theme.Accent, Thickness = 1, Parent = NotificationFrame })

    local NotifyTitle = CreateInstance("TextLabel", {
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 10, 0, 8),
        BackgroundTransparency = 1,
        Text = titleText,
        TextColor3 = self.Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = NotificationFrame
    })

    local NotifyDesc = CreateInstance("TextLabel", {
        Size = UDim2.new(1, -20, 0, 35),
        Position = UDim2.new(0, 10, 0, 28),
        BackgroundTransparency = 1,
        Text = descriptionText,
        TextColor3 = self.Theme.SubText,
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = NotificationFrame
    })

    -- Slide In
    TweenService:Create(NotificationFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -270, 1, -90)
    }):Play()

    task.spawn(function()
        task.wait(duration)
        -- Slide Out
        local outTween = TweenService:Create(NotificationFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 300, 1, -90)
        })
        outTween:Play()
        outTween.Completed:Connect(function()
            NotificationFrame:Destroy()
        end)
    end)
end

-- ========================================================================
-- TAB BUILDER
-- ========================================================================
local Tab = {}
Tab.__index = Tab

function ManoUI:AddTab(tabName)
    local tabSelf = setmetatable({}, Tab)
    tabSelf.Library = self
    tabSelf.Active = false

    -- Sidebar Tab Indicator / Button
    local TabButton = CreateInstance("TextButton", {
        Name = tabName .. "_Btn",
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        Parent = self.SidebarScroll
    })
    tabSelf.TabButton = TabButton

    local SelectionIndicator = CreateInstance("Frame", {
        Size = UDim2.new(0, 4, 0.7, 0),
        Position = UDim2.new(0, 4, 0.15, 0),
        BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        Parent = TabButton
    })
    CreateInstance("UICorner", { CornerRadius = UDim.new(0, 2), Parent = SelectionIndicator })

    local TabLabel = CreateInstance("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        Text = tabName,
        TextColor3 = self.Theme.SubText,
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TabButton
    })

    -- Elements Container
    local ElementsScroll = CreateInstance("ScrollingFrame", {
        Name = tabName .. "_Container",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = self.Theme.Border,
        Visible = false,
        Parent = self.TabContainer
    })
    tabSelf.Container = ElementsScroll

    local ElementsLayout = CreateInstance("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Parent = ElementsScroll
    })

    ElementsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ElementsScroll.CanvasSize = UDim2.new(0, 0, 0, ElementsLayout.AbsoluteContentSize.Y + 15)
    end)

    -- Click Event for tab changing
    TabButton.MouseButton1Down:Connect(function()
        self:SelectTab(tabSelf)
    end)

    -- Hover animations
    TabButton.MouseEnter:Connect(function()
        if not tabSelf.Active then
            TweenService:Create(TabLabel, TweenInfo.new(0.2), {TextColor3 = self.Theme.Text}):Play()
        end
    end)
    TabButton.MouseLeave:Connect(function()
        if not tabSelf.Active then
            TweenService:Create(TabLabel, TweenInfo.new(0.2), {TextColor3 = self.Theme.SubText}):Play()
        end
    end)

    table.insert(self.Tabs, tabSelf)

    if #self.Tabs == 1 then
        self:SelectTab(tabSelf)
    end

    return tabSelf
end

function ManoUI:SelectTab(tabInstance)
    for _, tab in pairs(self.Tabs) do
        tab.Active = false
        tab.Container.Visible = false
        TweenService:Create(tab.TabButton:FindFirstChildOfClass("Frame"), TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
        TweenService:Create(tab.TabButton:FindFirstChildOfClass("TextLabel"), TweenInfo.new(0.2), {TextColor3 = self.Theme.SubText}):Play()
    end

    tabInstance.Active = true
    tabInstance.Container.Visible = true
    TweenService:Create(tabInstance.TabButton:FindFirstChildOfClass("Frame"), TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
    TweenService:Create(tabInstance.TabButton:FindFirstChildOfClass("TextLabel"), TweenInfo.new(0.2), {TextColor3 = self.Theme.Text}):Play()
end

-- ========================================================================
-- COMPONENT GENERATORS (Inside Tab Class)
-- ========================================================================

-- Basic Card Builder Pattern
local function CreateBaseCard(parent, title, sizeY)
    local Card = CreateInstance("Frame", {
        Size = UDim2.new(0.96, 0, 0, sizeY or 40),
        BackgroundColor3 = Color3.fromRGB(20, 20, 25),
        BorderSizePixel = 0,
        Parent = parent
    })
    Card:SetAttribute("SavedBG", Card.BackgroundTransparency)
    CreateInstance("UICorner", { CornerRadius = UDim.new(0, 8), Parent = Card })
    CreateInstance("UIStroke", { Color = Color3.fromRGB(30, 30, 38), Thickness = 1, Parent = Card })

    local TitleLabel = CreateInstance("TextLabel", {
        Size = UDim2.new(0.6, 0, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Color3.fromRGB(240, 240, 245),
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Card
    })

    return Card, TitleLabel
end

-- BUTTON COMPONENT
function Tab:AddButton(titleText, callback)
    local Card, Title = CreateBaseCard(self.Container, titleText, 42)
    callback = callback or function() end

    local ClickArea = CreateInstance("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = Card
    })

    local ButtonAccent = CreateInstance("Frame", {
        Size = UDim2.new(0, 80, 0, 26),
        Position = UDim2.new(1, -92, 0.5, -13),
        BackgroundColor3 = self.Library.Theme.Accent,
        BorderSizePixel = 0,
        Parent = Card
    })
    CreateInstance("UICorner", { CornerRadius = UDim.new(0, 6), Parent = ButtonAccent })

    local ActionLabel = CreateInstance("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "Execute",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        Parent = ButtonAccent
    })

    ClickArea.MouseButton1Down:Connect(function()
        TweenService:Create(ButtonAccent, TweenInfo.new(0.1), {Size = UDim2.new(0, 75, 0, 24), Position = UDim2.new(1, -89, 0.5, -12)}):Play()
        task.spawn(callback)
    end)

    ClickArea.MouseButton1Up:Connect(function()
        TweenService:Create(ButtonAccent, TweenInfo.new(0.1), {Size = UDim2.new(0, 80, 0, 26), Position = UDim2.new(1, -92, 0.5, -13)}):Play()
    end)

    return Card
end

-- TOGGLE COMPONENT
function Tab:AddToggle(titleText, defaultVal, callback)
    local Card, Title = CreateBaseCard(self.Container, titleText, 42)
    callback = callback or function() end
    local state = defaultVal or false

    local ToggleFrame = CreateInstance("Frame", {
        Size = UDim2.new(0, 36, 0, 20),
        Position = UDim2.new(1, -48, 0.5, -10),
        BackgroundColor3 = state and self.Library.Theme.Accent or Color3.fromRGB(40, 40, 50),
        BorderSizePixel = 0,
        Parent = Card
    })
    CreateInstance("UICorner", { CornerRadius = UDim.new(0, 10), Parent = ToggleFrame })

    local IndicatorCircle = CreateInstance("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Parent = ToggleFrame
    })
    CreateInstance("UICorner", { CornerRadius = UDim.new(0, 7), Parent = IndicatorCircle })

    local ClickArea = CreateInstance("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = Card
    })

    local function ToggleState(forced)
        if forced ~= nil then state = forced else state = not state end
        local targetColor = state and self.Library.Theme.Accent or Color3.fromRGB(40, 40, 50)
        local targetPos = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)

        TweenService:Create(ToggleFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            BackgroundColor3 = targetColor
        }):Play()

        TweenService:Create(IndicatorCircle, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = targetPos
        }):Play()

        task.spawn(callback, state)
    end

    ClickArea.MouseButton1Click:Connect(function()
        ToggleState()
    end)

    return Card, ToggleState
end

-- SLIDER COMPONENT
function Tab:AddSlider(titleText, min, max, defaultVal, callback)
    local Card, Title = CreateBaseCard(self.Container, titleText, 52)
    callback = callback or function() end
    
    local ValueText = CreateInstance("TextLabel", {
        Size = UDim2.new(0.2, 0, 0, 20),
        Position = UDim2.new(1, -65, 0, 5),
        BackgroundTransparency = 1,
        Text = tostring(defaultVal or min),
        TextColor3 = self.Library.Theme.SubText,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = Card
    })

    local SliderBarBG = CreateInstance("Frame", {
        Size = UDim2.new(1, -24, 0, 6),
        Position = UDim2.new(0, 12, 1, -14),
        BackgroundColor3 = Color3.fromRGB(45, 45, 55),
        BorderSizePixel = 0,
        Parent = Card
    })
    CreateInstance("UICorner", { CornerRadius = UDim.new(0, 3), Parent = SliderBarBG })

    local SliderFill = CreateInstance("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = self.Library.Theme.Accent,
        BorderSizePixel = 0,
        Parent = SliderBarBG
    })
    CreateInstance("UICorner", { CornerRadius = UDim.new(0, 3), Parent = SliderFill })

    local SliderKnob = CreateInstance("Frame", {
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(0, -6, 0.5, -6),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Parent = SliderFill
    })
    CreateInstance("UICorner", { CornerRadius = UDim.new(0, 6), Parent = SliderKnob })

    local dragging = false

    local function UpdateSliderValue(input)
        local percentage = math.clamp((input.Position.X - SliderBarBG.AbsolutePosition.X) / SliderBarBG.AbsoluteSize.X, 0, 1)
        local value = math.round(min + (max - min) * percentage)
        
        SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        ValueText.Text = tostring(value)
        task.spawn(callback, value)
    end

    SliderBarBG.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            UpdateSliderValue(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateSliderValue(input)
        end
    end)

    -- Initialize Defaults
    local initialPercent = math.clamp((defaultVal - min) / (max - min), 0, 1)
    SliderFill.Size = UDim2.new(initialPercent, 0, 1, 0)

    return Card
end

-- DROPDOWN COMPONENT
function Tab:AddDropdown(titleText, options, defaultVal, callback)
    local Card = CreateInstance("Frame", {
        Size = UDim2.new(0.96, 0, 0, 42),
        BackgroundColor3 = Color3.fromRGB(20, 20, 25),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = self.Container
    })
    Card:SetAttribute("SavedBG", Card.BackgroundTransparency)
    CreateInstance("UICorner", { CornerRadius = UDim.new(0, 8), Parent = Card })
    CreateInstance("UIStroke", { Color = Color3.fromRGB(30, 30, 38), Thickness = 1, Parent = Card })

    local Title = CreateInstance("TextLabel", {
        Size = UDim2.new(0.5, 0, 0, 42),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = titleText,
        TextColor3 = Color3.fromRGB(240, 240, 245),
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Card
    })

    local SelectedLabel = CreateInstance("TextLabel", {
        Size = UDim2.new(0.4, -25, 0, 42),
        Position = UDim2.new(0.6, -10, 0, 0),
        BackgroundTransparency = 1,
        Text = defaultVal or "Select...",
        TextColor3 = self.Library.Theme.SubText,
        Font = Enum.Font.GothamSemibold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = Card
    })

    local Icon = CreateInstance("TextLabel", {
        Size = UDim2.new(0, 20, 0, 42),
        Position = UDim2.new(1, -28, 0, 0),
        BackgroundTransparency = 1,
        Text = "▼",
        TextColor3 = self.Library.Theme.SubText,
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        Parent = Card
    })

    local ItemsContainer = CreateInstance("Frame", {
        Size = UDim2.new(1, -20, 0, 0),
        Position = UDim2.new(0, 10, 0, 42),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = Card
    })

    local ItemsLayout = CreateInstance("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
        Parent = ItemsContainer
    })

    local ToggleBtn = CreateInstance("TextButton", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundTransparency = 1,
        Text = "",
        Parent = Card
    })

    local isOpened = false

    local function UpdateHeight()
        local targetHeight = isOpened and (45 + ItemsLayout.AbsoluteContentSize.Y + 10) or 42
        local targetRotation = isOpened and 180 or 0
        
        TweenService:Create(Card, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(0.96, 0, 0, targetHeight)
        }):Play()

        TweenService:Create(Icon, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Rotation = targetRotation
        }):Play()
        
        -- Instantly adjust container height
        TweenService:Create(ItemsContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, -20, 0, isOpened and ItemsLayout.AbsoluteContentSize.Y or 0)
        }):Play()
    end

    ToggleBtn.MouseButton1Click:Connect(function()
        isOpened = not isOpened
        UpdateHeight()
    end)

    local function ClearOptions()
        for _, child in pairs(ItemsContainer:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
    end

    local function RenderOptions()
        ClearOptions()
        for _, opt in ipairs(options) do
            local OptBtn = CreateInstance("TextButton", {
                Size = UDim2.new(1, 0, 0, 26),
                BackgroundColor3 = Color3.fromRGB(28, 28, 35),
                BorderSizePixel = 0,
                Text = "  " .. opt,
                TextColor3 = self.Library.Theme.SubText,
                Font = Enum.Font.GothamMedium,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = ItemsContainer
            })
            CreateInstance("UICorner", { CornerRadius = UDim.new(0, 4), Parent = OptBtn })

            OptBtn.MouseButton1Click:Connect(function()
                SelectedLabel.Text = opt
                isOpened = false
                UpdateHeight()
                task.spawn(callback, opt)
            end)
        end
    end

    RenderOptions()

    -- Expose simple update functionality
    local DropdownHandle = {}
    function DropdownHandle:Refresh(newOptions)
        options = newOptions
        RenderOptions()
        if isOpened then UpdateHeight() end
    end

    return Card, DropdownHandle
end

-- KEYBIND COMPONENT
function Tab:AddKeybind(titleText, defaultBind, callback)
    local Card, Title = CreateBaseCard(self.Container, titleText, 42)
    callback = callback or function() end
    local currentBind = defaultBind

    local BindLabel = CreateInstance("TextLabel", {
        Size = UDim2.new(0, 80, 0, 24),
        Position = UDim2.new(1, -92, 0.5, -12),
        BackgroundColor3 = Color3.fromRGB(35, 35, 45),
        Text = currentBind and currentBind.Name or "NONE",
        TextColor3 = self.Library.Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        Parent = Card
    })
    CreateInstance("UICorner", { CornerRadius = UDim.new(0, 6), Parent = BindLabel })
    CreateInstance("UIStroke", { Color = Color3.fromRGB(50, 50, 60), Thickness = 1, Parent = BindLabel })

    local ClickArea = CreateInstance("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = Card
    })

    local listening = false

    ClickArea.MouseButton1Click:Connect(function()
        listening = true
        BindLabel.Text = "..."
        BindLabel.TextColor3 = self.Library.Theme.Accent
    end)

    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and listening then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                listening = false
                currentBind = input.KeyCode
                BindLabel.Text = currentBind.Name
                BindLabel.TextColor3 = self.Library.Theme.Text
                task.spawn(callback, currentBind)
            end
        elseif not processed and currentBind and input.KeyCode == currentBind then
            task.spawn(callback, currentBind)
        end
    end)

    return Card
end

-- TEXTBOX COMPONENT
function Tab:AddTextBox(titleText, placeholderText, clearOnFocus, callback)
    local Card, Title = CreateBaseCard(self.Container, titleText, 42)
    callback = callback or function() end

    local InputBox = CreateInstance("TextBox", {
        Size = UDim2.new(0, 140, 0, 26),
        Position = UDim2.new(1, -152, 0.5, -13),
        BackgroundColor3 = Color3.fromRGB(30, 30, 38),
        Text = "",
        PlaceholderText = placeholderText or "Enter text...",
        PlaceholderColor3 = self.Library.Theme.SubText,
        TextColor3 = self.Library.Theme.Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
        ClearTextOnFocus = clearOnFocus,
        Parent = Card
    })
    CreateInstance("UICorner", { CornerRadius = UDim.new(0, 6), Parent = InputBox })
    CreateInstance("UIStroke", { Color = Color3.fromRGB(45, 45, 55), Thickness = 1, Parent = InputBox })

    InputBox.FocusLost:Connect(function(enterPressed)
        task.spawn(callback, InputBox.Text, enterPressed)
    end)

    return Card
end

-- Destruct Library cleanly
function ManoUI:Destroy()
    if self.InputConnection then
        self.InputConnection:Disconnect()
    end
    self.ScreenGui:Destroy()
end

return ManoUI
