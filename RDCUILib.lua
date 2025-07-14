--[[
    RDCUILib (Roblox Decompiler Core UI Library)
    ImGui-style immediate mode UI framework for Roblox exploit environments
    Uses Drawing API for performance and compatibility
    
    Written by depso & improved for immediate mode paradigm
    MIT License
    Copyright (c) 2024 Depso
]]

local RDCUILib = {}

-- Services
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Global state
local DrawingObjects = {}
local Windows = {}
local CurrentWindow = nil
local CurrentY = 0
local ItemSpacing = 4
local FramePadding = Vector2.new(8, 4)
local WindowPadding = Vector2.new(8, 8)
local Colors = {
    WindowBg = Color3.fromRGB(15, 15, 15),
    ChildBg = Color3.fromRGB(0, 0, 0),
    PopupBg = Color3.fromRGB(20, 20, 20),
    Border = Color3.fromRGB(43, 43, 43),
    BorderShadow = Color3.fromRGB(0, 0, 0),
    FrameBg = Color3.fromRGB(41, 74, 122),
    FrameBgHovered = Color3.fromRGB(66, 150, 250),
    FrameBgActive = Color3.fromRGB(15, 135, 250),
    TitleBg = Color3.fromRGB(10, 10, 10),
    TitleBgActive = Color3.fromRGB(41, 74, 122),
    TitleBgCollapsed = Color3.fromRGB(0, 0, 0),
    MenuBarBg = Color3.fromRGB(36, 36, 36),
    ScrollbarBg = Color3.fromRGB(5, 5, 5),
    ScrollbarGrab = Color3.fromRGB(79, 79, 79),
    ScrollbarGrabHovered = Color3.fromRGB(105, 105, 105),
    ScrollbarGrabActive = Color3.fromRGB(130, 130, 130),
    CheckMark = Color3.fromRGB(66, 150, 250),
    SliderGrab = Color3.fromRGB(61, 133, 224),
    SliderGrabActive = Color3.fromRGB(66, 150, 250),
    Button = Color3.fromRGB(66, 150, 250),
    ButtonHovered = Color3.fromRGB(66, 150, 250),
    ButtonActive = Color3.fromRGB(15, 135, 250),
    Header = Color3.fromRGB(66, 150, 250),
    HeaderHovered = Color3.fromRGB(66, 150, 250),
    HeaderActive = Color3.fromRGB(15, 135, 250),
    Separator = Color3.fromRGB(43, 43, 43),
    ResizeGrip = Color3.fromRGB(66, 150, 250),
    ResizeGripHovered = Color3.fromRGB(66, 150, 250),
    ResizeGripActive = Color3.fromRGB(15, 135, 250),
    Tab = Color3.fromRGB(58, 58, 58),
    TabHovered = Color3.fromRGB(104, 104, 104),
    TabActive = Color3.fromRGB(130, 130, 130),
    TabUnfocused = Color3.fromRGB(28, 28, 28),
    TabUnfocusedActive = Color3.fromRGB(53, 53, 53),
    PlotLines = Color3.fromRGB(61, 133, 224),
    PlotLinesHovered = Color3.fromRGB(255, 110, 89),
    PlotHistogram = Color3.fromRGB(230, 179, 0),
    PlotHistogramHovered = Color3.fromRGB(255, 140, 0),
    TextSelectedBg = Color3.fromRGB(66, 150, 250),
    DragDropTarget = Color3.fromRGB(255, 255, 0),
    NavHighlight = Color3.fromRGB(66, 150, 250),
    NavWindowingHighlight = Color3.fromRGB(255, 255, 255),
    NavWindowingDimBg = Color3.fromRGB(204, 204, 204),
    ModalWindowDimBg = Color3.fromRGB(204, 204, 204),
    Text = Color3.fromRGB(255, 255, 255),
    TextDisabled = Color3.fromRGB(128, 128, 128)
}

-- Utility functions
local function CreateDrawingObject(className, properties)
    local obj = Drawing.new(className)
    for prop, value in pairs(properties or {}) do
        obj[prop] = value
    end
    obj.Visible = true
    table.insert(DrawingObjects, obj)
    return obj
end

local function GetMousePosition()
    return UserInputService:GetMouseLocation()
end

local function IsMouseInBounds(position, size)
    local mousePos = GetMousePosition()
    return mousePos.X >= position.X and mousePos.X <= position.X + size.X and
           mousePos.Y >= position.Y and mousePos.Y <= position.Y + size.Y
end

local function IsMouseClicked()
    return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
end

-- Window management
function RDCUILib.Begin(title, open, flags)
    flags = flags or {}
    
    local window = Windows[title]
    if not window then
        window = {
            title = title,
            position = Vector2.new(100, 100),
            size = Vector2.new(400, 300),
            open = true,
            collapsed = false,
            focused = false,
            dragging = false,
            resizing = false,
            dragOffset = Vector2.new(0, 0),
            minSize = Vector2.new(200, 100),
            flags = flags,
            drawingObjects = {}
        }
        Windows[title] = window
    end
    
    if open ~= nil then
        window.open = open
    end
    
    if not window.open then
        return false
    end
    
    CurrentWindow = window
    CurrentY = window.position.Y + 30 + WindowPadding.Y -- Title bar height + padding
    
    -- Create window background
    if not window.background then
        window.background = CreateDrawingObject("Square", {
            Position = window.position,
            Size = window.size,
            Color = Colors.WindowBg,
            Filled = true,
            Transparency = 0.95
        })
        table.insert(window.drawingObjects, window.background)
    end
    
    -- Create window border
    if not window.border then
        window.border = CreateDrawingObject("Square", {
            Position = window.position,
            Size = window.size,
            Color = Colors.Border,
            Filled = false,
            Thickness = 1
        })
        table.insert(window.drawingObjects, window.border)
    end
    
    -- Create title bar
    if not window.titleBar then
        window.titleBar = CreateDrawingObject("Square", {
            Position = window.position,
            Size = Vector2.new(window.size.X, 30),
            Color = Colors.TitleBg,
            Filled = true
        })
        table.insert(window.drawingObjects, window.titleBar)
    end
    
    -- Create title text
    if not window.titleText then
        window.titleText = CreateDrawingObject("Text", {
            Text = title,
            Position = window.position + Vector2.new(8, 15),
            Color = Colors.Text,
            Size = 14,
            Font = 2,
            Outline = true
        })
        table.insert(window.drawingObjects, window.titleText)
    end
    
    -- Create close button if not disabled
    if not flags.NoClose and not window.closeButton then
        window.closeButton = CreateDrawingObject("Text", {
            Text = "×",
            Position = window.position + Vector2.new(window.size.X - 20, 15),
            Color = Color3.fromRGB(255, 100, 100),
            Size = 16,
            Font = 2,
            Outline = true,
            Center = true
        })
        table.insert(window.drawingObjects, window.closeButton)
    end
    
    -- Update positions and sizes
    window.background.Position = window.position
    window.background.Size = window.size
    window.border.Position = window.position
    window.border.Size = window.size
    window.titleBar.Position = window.position
    window.titleBar.Size = Vector2.new(window.size.X, 30)
    window.titleText.Position = window.position + Vector2.new(8, 15)
    
    if window.closeButton then
        window.closeButton.Position = window.position + Vector2.new(window.size.X - 20, 15)
    end
    
    return true
end

function RDCUILib.End()
    CurrentWindow = nil
end

-- Basic widgets
function RDCUILib.Text(text)
    if not CurrentWindow then return end
    
    local textObj = CreateDrawingObject("Text", {
        Text = text,
        Position = Vector2.new(CurrentWindow.position.X + WindowPadding.X, CurrentY),
        Color = Colors.Text,
        Size = 14,
        Font = 2,
        Outline = true
    })
    
    CurrentY = CurrentY + 20 + ItemSpacing
    return textObj
end

function RDCUILib.Button(label, size)
    if not CurrentWindow then return false end
    
    size = size or Vector2.new(100, 25)
    local buttonPos = Vector2.new(CurrentWindow.position.X + WindowPadding.X, CurrentY)
    
    local button = CreateDrawingObject("Square", {
        Position = buttonPos,
        Size = size,
        Color = Colors.Button,
        Filled = true
    })
    
    local buttonText = CreateDrawingObject("Text", {
        Text = label,
        Position = buttonPos + Vector2.new(size.X / 2, size.Y / 2),
        Color = Colors.Text,
        Size = 14,
        Font = 2,
        Outline = true,
        Center = true
    })
    
    local isHovered = IsMouseInBounds(buttonPos, size)
    local isClicked = isHovered and IsMouseClicked()
    
    if isHovered then
        button.Color = isClicked and Colors.ButtonActive or Colors.ButtonHovered
    else
        button.Color = Colors.Button
    end
    
    CurrentY = CurrentY + size.Y + ItemSpacing
    return isClicked
end

function RDCUILib.Checkbox(label, checked)
    if not CurrentWindow then return checked end
    
    local checkboxSize = Vector2.new(16, 16)
    local checkboxPos = Vector2.new(CurrentWindow.position.X + WindowPadding.X, CurrentY)
    
    local checkbox = CreateDrawingObject("Square", {
        Position = checkboxPos,
        Size = checkboxSize,
        Color = Colors.FrameBg,
        Filled = true
    })
    
    local checkboxBorder = CreateDrawingObject("Square", {
        Position = checkboxPos,
        Size = checkboxSize,
        Color = Colors.Border,
        Filled = false,
        Thickness = 1
    })
    
    if checked then
        local checkmark = CreateDrawingObject("Text", {
            Text = "✓",
            Position = checkboxPos + Vector2.new(8, 8),
            Color = Colors.CheckMark,
            Size = 12,
            Font = 2,
            Outline = true,
            Center = true
        })
    end
    
    local labelText = CreateDrawingObject("Text", {
        Text = label,
        Position = checkboxPos + Vector2.new(20, 8),
        Color = Colors.Text,
        Size = 14,
        Font = 2,
        Outline = true
    })
    
    local isHovered = IsMouseInBounds(checkboxPos, Vector2.new(200, 16))
    local isClicked = isHovered and IsMouseClicked()
    
    if isHovered then
        checkbox.Color = Colors.FrameBgHovered
    end
    
    CurrentY = CurrentY + 20 + ItemSpacing
    
    if isClicked then
        return not checked
    end
    
    return checked
end

function RDCUILib.SliderFloat(label, value, min, max, format)
    if not CurrentWindow then return value end
    
    format = format or "%.3f"
    local sliderSize = Vector2.new(200, 20)
    local sliderPos = Vector2.new(CurrentWindow.position.X + WindowPadding.X, CurrentY)
    
    -- Slider track
    local track = CreateDrawingObject("Square", {
        Position = sliderPos,
        Size = sliderSize,
        Color = Colors.FrameBg,
        Filled = true
    })
    
    -- Slider grab
    local percentage = (value - min) / (max - min)
    local grabX = sliderPos.X + (percentage * sliderSize.X)
    local grab = CreateDrawingObject("Circle", {
        Position = Vector2.new(grabX, sliderPos.Y + sliderSize.Y / 2),
        Radius = 8,
        Color = Colors.SliderGrab,
        Filled = true
    })
    
    -- Value text
    local valueText = CreateDrawingObject("Text", {
        Text = string.format(format, value),
        Position = sliderPos + Vector2.new(sliderSize.X + 10, 10),
        Color = Colors.Text,
        Size = 14,
        Font = 2,
        Outline = true
    })
    
    -- Label text
    local labelText = CreateDrawingObject("Text", {
        Text = label,
        Position = Vector2.new(CurrentWindow.position.X + WindowPadding.X, CurrentY - 18),
        Color = Colors.Text,
        Size = 14,
        Font = 2,
        Outline = true
    })
    
    local isHovered = IsMouseInBounds(sliderPos, sliderSize)
    local isClicked = isHovered and IsMouseClicked()
    
    if isHovered then
        grab.Color = Colors.SliderGrabActive
    end
    
    if isClicked then
        local mouseX = GetMousePosition().X
        local newPercentage = math.clamp((mouseX - sliderPos.X) / sliderSize.X, 0, 1)
        value = min + (newPercentage * (max - min))
    end
    
    CurrentY = CurrentY + 40 + ItemSpacing
    return value
end

function RDCUILib.InputText(label, text, flags)
    if not CurrentWindow then return text end
    
    flags = flags or {}
    local inputSize = Vector2.new(200, 25)
    local inputPos = Vector2.new(CurrentWindow.position.X + WindowPadding.X, CurrentY)
    
    -- Input background
    local inputBg = CreateDrawingObject("Square", {
        Position = inputPos,
        Size = inputSize,
        Color = Colors.FrameBg,
        Filled = true
    })
    
    -- Input border
    local inputBorder = CreateDrawingObject("Square", {
        Position = inputPos,
        Size = inputSize,
        Color = Colors.Border,
        Filled = false,
        Thickness = 1
    })
    
    -- Input text
    local inputText = CreateDrawingObject("Text", {
        Text = text or "",
        Position = inputPos + Vector2.new(5, 12),
        Color = Colors.Text,
        Size = 14,
        Font = 2,
        Outline = true
    })
    
    -- Label
    local labelText = CreateDrawingObject("Text", {
        Text = label,
        Position = Vector2.new(CurrentWindow.position.X + WindowPadding.X, CurrentY - 18),
        Color = Colors.Text,
        Size = 14,
        Font = 2,
        Outline = true
    })
    
    local isHovered = IsMouseInBounds(inputPos, inputSize)
    
    if isHovered then
        inputBorder.Color = Colors.FrameBgHovered
    end
    
    CurrentY = CurrentY + 45 + ItemSpacing
    return text
end

function RDCUILib.Combo(label, currentItem, items)
    if not CurrentWindow then return currentItem end
    
    local comboSize = Vector2.new(200, 25)
    local comboPos = Vector2.new(CurrentWindow.position.X + WindowPadding.X, CurrentY)
    
    -- Combo background
    local comboBg = CreateDrawingObject("Square", {
        Position = comboPos,
        Size = comboSize,
        Color = Colors.FrameBg,
        Filled = true
    })
    
    -- Combo border
    local comboBorder = CreateDrawingObject("Square", {
        Position = comboPos,
        Size = comboSize,
        Color = Colors.Border,
        Filled = false,
        Thickness = 1
    })
    
    -- Current item text
    local itemText = CreateDrawingObject("Text", {
        Text = items[currentItem] or "Select...",
        Position = comboPos + Vector2.new(5, 12),
        Color = Colors.Text,
        Size = 14,
        Font = 2,
        Outline = true
    })
    
    -- Dropdown arrow
    local arrow = CreateDrawingObject("Text", {
        Text = "▼",
        Position = comboPos + Vector2.new(comboSize.X - 15, 12),
        Color = Colors.Text,
        Size = 12,
        Font = 2,
        Outline = true
    })
    
    -- Label
    local labelText = CreateDrawingObject("Text", {
        Text = label,
        Position = Vector2.new(CurrentWindow.position.X + WindowPadding.X, CurrentY - 18),
        Color = Colors.Text,
        Size = 14,
        Font = 2,
        Outline = true
    })
    
    local isHovered = IsMouseInBounds(comboPos, comboSize)
    local isClicked = isHovered and IsMouseClicked()
    
    if isHovered then
        comboBg.Color = Colors.FrameBgHovered
    end
    
    CurrentY = CurrentY + 45 + ItemSpacing
    return currentItem
end

function RDCUILib.Separator()
    if not CurrentWindow then return end
    
    local separatorPos = Vector2.new(CurrentWindow.position.X + WindowPadding.X, CurrentY)
    local separatorSize = Vector2.new(CurrentWindow.size.X - WindowPadding.X * 2, 1)
    
    local separator = CreateDrawingObject("Line", {
        From = separatorPos,
        To = separatorPos + Vector2.new(separatorSize.X, 0),
        Color = Colors.Separator,
        Thickness = 1
    })
    
    CurrentY = CurrentY + 10 + ItemSpacing
end

function RDCUILib.Spacing()
    if not CurrentWindow then return end
    CurrentY = CurrentY + ItemSpacing
end

function RDCUILib.NewLine()
    if not CurrentWindow then return end
    CurrentY = CurrentY + 20
end

-- Tree nodes and collapsing headers
function RDCUILib.CollapsingHeader(label, open)
    if not CurrentWindow then return open end
    
    local headerSize = Vector2.new(CurrentWindow.size.X - WindowPadding.X * 2, 25)
    local headerPos = Vector2.new(CurrentWindow.position.X + WindowPadding.X, CurrentY)
    
    -- Header background
    local headerBg = CreateDrawingObject("Square", {
        Position = headerPos,
        Size = headerSize,
        Color = Colors.Header,
        Filled = true
    })
    
    -- Arrow
    local arrow = CreateDrawingObject("Text", {
        Text = open and "▼" or "▶",
        Position = headerPos + Vector2.new(5, 12),
        Color = Colors.Text,
        Size = 12,
        Font = 2,
        Outline = true
    })
    
    -- Header text
    local headerText = CreateDrawingObject("Text", {
        Text = label,
        Position = headerPos + Vector2.new(20, 12),
        Color = Colors.Text,
        Size = 14,
        Font = 2,
        Outline = true
    })
    
    local isHovered = IsMouseInBounds(headerPos, headerSize)
    local isClicked = isHovered and IsMouseClicked()
    
    if isHovered then
        headerBg.Color = Colors.HeaderHovered
    end
    
    CurrentY = CurrentY + 30 + ItemSpacing
    
    if isClicked then
        return not open
    end
    
    return open
end

function RDCUILib.TreeNode(label, open)
    return RDCUILib.CollapsingHeader(label, open)
end

-- Progress bars
function RDCUILib.ProgressBar(fraction, size, overlay)
    if not CurrentWindow then return end
    
    size = size or Vector2.new(200, 20)
    local progressPos = Vector2.new(CurrentWindow.position.X + WindowPadding.X, CurrentY)
    
    -- Progress background
    local progressBg = CreateDrawingObject("Square", {
        Position = progressPos,
        Size = size,
        Color = Colors.FrameBg,
        Filled = true
    })
    
    -- Progress fill
    local fillWidth = size.X * math.clamp(fraction, 0, 1)
    if fillWidth > 0 then
        local progressFill = CreateDrawingObject("Square", {
            Position = progressPos,
            Size = Vector2.new(fillWidth, size.Y),
            Color = Colors.PlotHistogram,
            Filled = true
        })
    end
    
    -- Overlay text
    if overlay then
        local overlayText = CreateDrawingObject("Text", {
            Text = overlay,
            Position = progressPos + Vector2.new(size.X / 2, size.Y / 2),
            Color = Colors.Text,
            Size = 14,
            Font = 2,
            Outline = true,
            Center = true
        })
    end
    
    CurrentY = CurrentY + size.Y + ItemSpacing
end

-- Window manipulation
function RDCUILib.SetNextWindowPos(pos, cond)
    -- Implementation for setting next window position
end

function RDCUILib.SetNextWindowSize(size, cond)
    -- Implementation for setting next window size
end

-- Input handling
function RDCUILib.IsItemHovered()
    -- Implementation for checking if last item is hovered
    return false
end

function RDCUILib.IsItemClicked(button)
    -- Implementation for checking if last item is clicked
    return false
end

-- Cleanup function
function RDCUILib.Cleanup()
    for _, obj in ipairs(DrawingObjects) do
        if obj.Remove then
            obj:Remove()
        end
    end
    table.clear(DrawingObjects)
    table.clear(Windows)
end

-- Update function (should be called every frame)
function RDCUILib.Update()
    -- Handle window dragging and resizing
    for title, window in pairs(Windows) do
        if not window.open then continue end
        
        local mousePos = GetMousePosition()
        local titleBarBounds = {
            position = window.position,
            size = Vector2.new(window.size.X, 30)
        }
        
        -- Handle window dragging
        if IsMouseInBounds(titleBarBounds.position, titleBarBounds.size) and IsMouseClicked() then
            if not window.dragging then
                window.dragging = true
                window.dragOffset = mousePos - window.position
            end
        end
        
        if window.dragging then
            if IsMouseClicked() then
                window.position = mousePos - window.dragOffset
            else
                window.dragging = false
            end
        end
        
        -- Handle close button
        if window.closeButton then
            local closeButtonBounds = {
                position = window.position + Vector2.new(window.size.X - 30, 0),
                size = Vector2.new(30, 30)
            }
            
            if IsMouseInBounds(closeButtonBounds.position, closeButtonBounds.size) and IsMouseClicked() then
                window.open = false
            end
        end
    end
end

-- Initialize update loop
RunService.Heartbeat:Connect(RDCUILib.Update)

-- Cleanup on game shutdown
game:GetService("Players").LocalPlayer.AncestryChanged:Connect(function(_, parent)
    if not parent then
        RDCUILib.Cleanup()
    end
end)

return RDCUILib
