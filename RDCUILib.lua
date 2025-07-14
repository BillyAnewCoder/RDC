--[[
    RDCUILib (Roblox Decompiler Core UI Library)
    ImGui-style UI framework for Roblox exploit environments
    Uses Drawing API for performance and compatibility
    
    Features:
    - Dear ImGui visual style
    - Draggable panels and windows
    - Console-friendly fonts
    - Complete widget set for decompiler interfaces
    - No Roblox Instance dependencies
]]

local RDCUILib = {}

-- Services and utilities
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- Global state
local DrawingObjects = {}
local Windows = {}
local ActiveWindow = nil
local MousePosition = Vector2.new(0, 0)
local LastMousePosition = Vector2.new(0, 0)
local DeltaTime = 0
local FrameCount = 0

-- ImGui class
local ImGui = {}
ImGui.__index = ImGui

-- Utility functions
local function NullFunction() end

local function GetService(serviceName)
    return game:GetService(serviceName)
end

local function Warn(message)
    warn("[RDCUILib] " .. tostring(message))
end

local function FetchUI()
    return CoreGui
end

-- Additional Styles class
local AdditionalStyles = {}
AdditionalStyles.__index = AdditionalStyles

function AdditionalStyles.new()
    local self = setmetatable({}, AdditionalStyles)
    self.styles = {}
    return self
end

function AdditionalStyles:SetLabel(label)
    self.label = label
end

function AdditionalStyles:SetCallback(callback)
    self.callback = callback or NullFunction
end

function AdditionalStyles:FireCallback(...)
    if self.callback then
        self.callback(...)
    end
end

function AdditionalStyles:GetValue()
    return self.value
end

function AdditionalStyles:GetName()
    return self.label or "Unnamed"
end

function AdditionalStyles:CreateInstance(className, properties)
    local obj = Drawing.new(className)
    for prop, value in pairs(properties or {}) do
        obj[prop] = value
    end
    table.insert(DrawingObjects, obj)
    return obj
end

function AdditionalStyles:ApplyColors(obj, colorScheme)
    if colorScheme then
        for prop, color in pairs(colorScheme) do
            if obj[prop] then
                obj[prop] = color
            end
        end
    end
end

function AdditionalStyles:CheckStyles()
    return self.styles
end

function AdditionalStyles:MergeMetatables(target, source)
    for k, v in pairs(source) do
        target[k] = v
    end
    return target
end

-- Metadata class
local Metadata = {}
Metadata.__index = Metadata

function Metadata.new()
    local self = setmetatable({}, Metadata)
    self.data = {}
    return self
end

function Metadata:__index(key)
    return self.data[key]
end

function Metadata:__newindex(key, value)
    self.data[key] = value
end

function Metadata:Concat(other)
    for k, v in pairs(other.data or other) do
        self.data[k] = v
    end
end

-- Container class
local ContainerClass = {}
ContainerClass.__index = ContainerClass

function ContainerClass.new(position, size)
    local self = setmetatable({}, ContainerClass)
    self.position = position or Vector2.new(0, 0)
    self.size = size or Vector2.new(200, 100)
    self.children = {}
    self.visible = true
    return self
end

function ContainerClass:NewInstance(className, properties)
    local obj = Drawing.new(className)
    for prop, value in pairs(properties or {}) do
        obj[prop] = value
    end
    table.insert(self.children, obj)
    table.insert(DrawingObjects, obj)
    return obj
end

-- Button class
local Button = {}
Button.__index = Button

function Button.new(text, position, size)
    local self = setmetatable({}, Button)
    self.text = text or "Button"
    self.position = position or Vector2.new(0, 0)
    self.size = size or Vector2.new(100, 30)
    self.callback = NullFunction
    self.hovered = false
    self.pressed = false
    
    -- Create drawing objects
    self.background = Drawing.new("Square")
    self.background.Position = self.position
    self.background.Size = self.size
    self.background.Color = Color3.fromRGB(67, 67, 67)
    self.background.Filled = true
    self.background.Visible = true
    
    self.textLabel = Drawing.new("Text")
    self.textLabel.Text = self.text
    self.textLabel.Position = self.position + Vector2.new(self.size.X / 2, self.size.Y / 2)
    self.textLabel.Color = Color3.fromRGB(255, 255, 255)
    self.textLabel.Size = 14
    self.textLabel.Center = true
    self.textLabel.Outline = true
    self.textLabel.Font = 2
    self.textLabel.Visible = true
    
    table.insert(DrawingObjects, self.background)
    table.insert(DrawingObjects, self.textLabel)
    
    return self
end

function Button:Callback(func)
    self.callback = func or NullFunction
end

function Button:Update()
    local mousePos = UserInputService:GetMouseLocation()
    local inBounds = mousePos.X >= self.position.X and mousePos.X <= self.position.X + self.size.X and
                    mousePos.Y >= self.position.Y and mousePos.Y <= self.position.Y + self.size.Y
    
    if inBounds then
        if not self.hovered then
            self.hovered = true
            self.background.Color = Color3.fromRGB(87, 87, 87)
        end
        
        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            if not self.pressed then
                self.pressed = true
                self.background.Color = Color3.fromRGB(47, 47, 47)
                self.callback()
            end
        else
            self.pressed = false
        end
    else
        if self.hovered then
            self.hovered = false
            self.background.Color = Color3.fromRGB(67, 67, 67)
        end
        self.pressed = false
    end
end

-- Image class
local Image = {}
Image.__index = Image

function Image.new(imageId, position, size)
    local self = setmetatable({}, Image)
    self.imageId = imageId or ""
    self.position = position or Vector2.new(0, 0)
    self.size = size or Vector2.new(50, 50)
    self.callback = NullFunction
    
    self.image = Drawing.new("Image")
    self.image.Data = self.imageId
    self.image.Position = self.position
    self.image.Size = self.size
    self.image.Visible = true
    
    table.insert(DrawingObjects, self.image)
    return self
end

function Image:Callback(func)
    self.callback = func or NullFunction
end

-- ScrollingBox class
local ScrollingBox = {}
ScrollingBox.__index = ScrollingBox

function ScrollingBox.new(position, size)
    local self = setmetatable({}, ScrollingBox)
    self.position = position or Vector2.new(0, 0)
    self.size = size or Vector2.new(200, 150)
    self.scrollY = 0
    self.contentHeight = 0
    self.children = {}
    
    self.background = Drawing.new("Square")
    self.background.Position = self.position
    self.background.Size = self.size
    self.background.Color = Color3.fromRGB(40, 40, 40)
    self.background.Filled = true
    self.background.Visible = true
    
    table.insert(DrawingObjects, self.background)
    return self
end

-- Label class
local Label = {}
Label.__index = Label

function Label.new(text, position)
    local self = setmetatable({}, Label)
    self.text = text or "Label"
    self.position = position or Vector2.new(0, 0)
    
    self.textLabel = Drawing.new("Text")
    self.textLabel.Text = self.text
    self.textLabel.Position = self.position
    self.textLabel.Color = Color3.fromRGB(255, 255, 255)
    self.textLabel.Size = 14
    self.textLabel.Outline = true
    self.textLabel.Font = 2
    self.textLabel.Visible = true
    
    table.insert(DrawingObjects, self.textLabel)
    return self
end

-- Checkbox class
local Checkbox = {}
Checkbox.__index = Checkbox

function Checkbox.new(text, position, checked)
    local self = setmetatable({}, Checkbox)
    self.text = text or "Checkbox"
    self.position = position or Vector2.new(0, 0)
    self.checked = checked or false
    self.callback = NullFunction
    
    self.background = Drawing.new("Square")
    self.background.Position = self.position
    self.background.Size = Vector2.new(16, 16)
    self.background.Color = Color3.fromRGB(67, 67, 67)
    self.background.Filled = true
    self.background.Visible = true
    
    self.checkmark = Drawing.new("Text")
    self.checkmark.Text = self.checked and "✓" or ""
    self.checkmark.Position = self.position + Vector2.new(8, 8)
    self.checkmark.Color = Color3.fromRGB(0, 255, 0)
    self.checkmark.Size = 12
    self.checkmark.Center = true
    self.checkmark.Outline = true
    self.checkmark.Font = 2
    self.checkmark.Visible = true
    
    self.textLabel = Drawing.new("Text")
    self.textLabel.Text = self.text
    self.textLabel.Position = self.position + Vector2.new(20, 8)
    self.textLabel.Color = Color3.fromRGB(255, 255, 255)
    self.textLabel.Size = 14
    self.textLabel.Outline = true
    self.textLabel.Font = 2
    self.textLabel.Visible = true
    
    table.insert(DrawingObjects, self.background)
    table.insert(DrawingObjects, self.checkmark)
    table.insert(DrawingObjects, self.textLabel)
    
    return self
end

function Checkbox:Callback(func)
    self.callback = func or NullFunction
end

function Checkbox:SetTicked(ticked)
    self.checked = ticked
    self.checkmark.Text = self.checked and "✓" or ""
    self.callback(self.checked)
end

function Checkbox:Toggle()
    self:SetTicked(not self.checked)
end

function Checkbox:Clicked()
    self:Toggle()
end

-- RadioButton class
local RadioButton = {}
RadioButton.__index = RadioButton

function RadioButton.new(text, position, group)
    local self = setmetatable({}, RadioButton)
    self.text = text or "Radio"
    self.position = position or Vector2.new(0, 0)
    self.group = group or "default"
    self.selected = false
    self.callback = NullFunction
    
    self.background = Drawing.new("Circle")
    self.background.Position = self.position + Vector2.new(8, 8)
    self.background.Radius = 8
    self.background.Color = Color3.fromRGB(67, 67, 67)
    self.background.Filled = false
    self.background.Thickness = 2
    self.background.Visible = true
    
    self.dot = Drawing.new("Circle")
    self.dot.Position = self.position + Vector2.new(8, 8)
    self.dot.Radius = 4
    self.dot.Color = Color3.fromRGB(0, 255, 0)
    self.dot.Filled = true
    self.dot.Visible = self.selected
    
    self.textLabel = Drawing.new("Text")
    self.textLabel.Text = self.text
    self.textLabel.Position = self.position + Vector2.new(20, 8)
    self.textLabel.Color = Color3.fromRGB(255, 255, 255)
    self.textLabel.Size = 14
    self.textLabel.Outline = true
    self.textLabel.Font = 2
    self.textLabel.Visible = true
    
    table.insert(DrawingObjects, self.background)
    table.insert(DrawingObjects, self.dot)
    table.insert(DrawingObjects, self.textLabel)
    
    return self
end

-- Viewport class
local Viewport = {}
Viewport.__index = Viewport

function Viewport.new(position, size)
    local self = setmetatable({}, Viewport)
    self.position = position or Vector2.new(0, 0)
    self.size = size or Vector2.new(200, 200)
    self.camera = nil
    self.model = nil
    
    self.background = Drawing.new("Square")
    self.background.Position = self.position
    self.background.Size = self.size
    self.background.Color = Color3.fromRGB(30, 30, 30)
    self.background.Filled = true
    self.background.Visible = true
    
    table.insert(DrawingObjects, self.background)
    return self
end

function Viewport:SetCamera(camera)
    self.camera = camera
end

function Viewport:SetModel(model)
    self.model = model
end

-- InputText class
local InputText = {}
InputText.__index = InputText

function InputText.new(placeholder, position, size)
    local self = setmetatable({}, InputText)
    self.placeholder = placeholder or "Enter text..."
    self.position = position or Vector2.new(0, 0)
    self.size = size or Vector2.new(200, 25)
    self.value = ""
    self.focused = false
    self.callback = NullFunction
    self.cursorPos = 0
    
    self.background = Drawing.new("Square")
    self.background.Position = self.position
    self.background.Size = self.size
    self.background.Color = Color3.fromRGB(50, 50, 50)
    self.background.Filled = true
    self.background.Visible = true
    
    self.border = Drawing.new("Square")
    self.border.Position = self.position
    self.border.Size = self.size
    self.border.Color = Color3.fromRGB(100, 100, 100)
    self.border.Filled = false
    self.border.Thickness = 1
    self.border.Visible = true
    
    self.textLabel = Drawing.new("Text")
    self.textLabel.Text = self.value == "" and self.placeholder or self.value
    self.textLabel.Position = self.position + Vector2.new(5, self.size.Y / 2)
    self.textLabel.Color = self.value == "" and Color3.fromRGB(150, 150, 150) or Color3.fromRGB(255, 255, 255)
    self.textLabel.Size = 14
    self.textLabel.Outline = true
    self.textLabel.Font = 2
    self.textLabel.Visible = true
    
    table.insert(DrawingObjects, self.background)
    table.insert(DrawingObjects, self.border)
    table.insert(DrawingObjects, self.textLabel)
    
    return self
end

function InputText:Callback(func)
    self.callback = func or NullFunction
end

function InputText:SetValue(value)
    self.value = tostring(value)
    self.textLabel.Text = self.value == "" and self.placeholder or self.value
    self.textLabel.Color = self.value == "" and Color3.fromRGB(150, 150, 150) or Color3.fromRGB(255, 255, 255)
    self.callback(self.value)
end

function InputText:Clear()
    self:SetValue("")
end

-- InputTextMultiline class
local InputTextMultiline = {}
InputTextMultiline.__index = InputTextMultiline

function InputTextMultiline.new(placeholder, position, size)
    local self = setmetatable({}, InputTextMultiline)
    self.placeholder = placeholder or "Enter text..."
    self.position = position or Vector2.new(0, 0)
    self.size = size or Vector2.new(300, 100)
    self.value = ""
    self.lines = {""}
    self.scrollY = 0
    self.focused = false
    self.callback = NullFunction
    
    self.background = Drawing.new("Square")
    self.background.Position = self.position
    self.background.Size = self.size
    self.background.Color = Color3.fromRGB(40, 40, 40)
    self.background.Filled = true
    self.background.Visible = true
    
    table.insert(DrawingObjects, self.background)
    return self
end

function InputTextMultiline:GetRemainingHeight()
    return self.size.Y - (#self.lines * 16)
end

-- Console class
local Console = {}
Console.__index = Console

function Console.new(position, size)
    local self = setmetatable({}, Console)
    self.position = position or Vector2.new(0, 0)
    self.size = size or Vector2.new(400, 200)
    self.lines = {}
    self.scrollY = 0
    self.maxLines = 100
    
    self.background = Drawing.new("Square")
    self.background.Position = self.position
    self.background.Size = self.size
    self.background.Color = Color3.fromRGB(20, 20, 20)
    self.background.Filled = true
    self.background.Visible = true
    
    self.lineNumbers = Drawing.new("Square")
    self.lineNumbers.Position = self.position
    self.lineNumbers.Size = Vector2.new(40, self.size.Y)
    self.lineNumbers.Color = Color3.fromRGB(30, 30, 30)
    self.lineNumbers.Filled = true
    self.lineNumbers.Visible = true
    
    table.insert(DrawingObjects, self.background)
    table.insert(DrawingObjects, self.lineNumbers)
    
    return self
end

function Console:UpdateLineNumbers()
    -- Update line number display
end

function Console:UpdateScroll()
    -- Update scroll position
end

function Console:SetText(text)
    self.lines = {}
    for line in text:gmatch("[^\r\n]+") do
        table.insert(self.lines, line)
    end
    self:UpdateLineNumbers()
end

function Console:GetValue()
    return table.concat(self.lines, "\n")
end

function Console:Clear()
    self.lines = {}
    self:UpdateLineNumbers()
end

function Console:AppendText(text)
    for line in text:gmatch("[^\r\n]+") do
        table.insert(self.lines, line)
        if #self.lines > self.maxLines then
            table.remove(self.lines, 1)
        end
    end
    self:UpdateLineNumbers()
end

-- Table class
local Table = {}
Table.__index = Table

function Table.new(position, size)
    local self = setmetatable({}, Table)
    self.position = position or Vector2.new(0, 0)
    self.size = size or Vector2.new(400, 200)
    self.rows = {}
    self.columns = {}
    self.scrollY = 0
    
    self.background = Drawing.new("Square")
    self.background.Position = self.position
    self.background.Size = self.size
    self.background.Color = Color3.fromRGB(45, 45, 45)
    self.background.Filled = true
    self.background.Visible = true
    
    table.insert(DrawingObjects, self.background)
    return self
end

function Table:CreateRow()
    local row = {
        columns = {},
        height = 25,
        selected = false
    }
    table.insert(self.rows, row)
    return row
end

-- RowClass
local RowClass = {}
RowClass.__index = RowClass

function RowClass.new()
    local self = setmetatable({}, RowClass)
    self.columns = {}
    return self
end

function RowClass:CreateColumn(text, width)
    local column = {
        text = text or "",
        width = width or 100
    }
    table.insert(self.columns, column)
    return column
end

function Table:UpdateColumns()
    -- Update column layout
end

function Table:UpdateRows()
    -- Update row display
end

function Table:ClearRows()
    self.rows = {}
end

-- Grid class
local Grid = {}
Grid.__index = Grid

function Grid.new(position, size, columns, rows)
    local self = setmetatable({}, Grid)
    self.position = position or Vector2.new(0, 0)
    self.size = size or Vector2.new(300, 200)
    self.columns = columns or 3
    self.rows = rows or 3
    self.cells = {}
    
    self.background = Drawing.new("Square")
    self.background.Position = self.position
    self.background.Size = self.size
    self.background.Color = Color3.fromRGB(50, 50, 50)
    self.background.Filled = true
    self.background.Visible = true
    
    table.insert(DrawingObjects, self.background)
    return self
end

-- CollapsingHeader class
local CollapsingHeader = {}
CollapsingHeader.__index = CollapsingHeader

function CollapsingHeader.new(text, position, open)
    local self = setmetatable({}, CollapsingHeader)
    self.text = text or "Header"
    self.position = position or Vector2.new(0, 0)
    self.open = open or false
    self.callback = NullFunction
    
    self.background = Drawing.new("Square")
    self.background.Position = self.position
    self.background.Size = Vector2.new(200, 25)
    self.background.Color = Color3.fromRGB(60, 60, 60)
    self.background.Filled = true
    self.background.Visible = true
    
    self.arrow = Drawing.new("Text")
    self.arrow.Text = self.open and "▼" or "▶"
    self.arrow.Position = self.position + Vector2.new(5, 12)
    self.arrow.Color = Color3.fromRGB(255, 255, 255)
    self.arrow.Size = 12
    self.arrow.Outline = true
    self.arrow.Font = 2
    self.arrow.Visible = true
    
    self.textLabel = Drawing.new("Text")
    self.textLabel.Text = self.text
    self.textLabel.Position = self.position + Vector2.new(20, 12)
    self.textLabel.Color = Color3.fromRGB(255, 255, 255)
    self.textLabel.Size = 14
    self.textLabel.Outline = true
    self.textLabel.Font = 2
    self.textLabel.Visible = true
    
    table.insert(DrawingObjects, self.background)
    table.insert(DrawingObjects, self.arrow)
    table.insert(DrawingObjects, self.textLabel)
    
    return self
end

function CollapsingHeader:SetOpen(open)
    self.open = open
    self.arrow.Text = self.open and "▼" or "▶"
end

function CollapsingHeader:Toggle()
    self:SetOpen(not self.open)
end

-- TreeNode class
local TreeNode = {}
TreeNode.__index = TreeNode

function TreeNode.new(text, position, expanded)
    local self = setmetatable({}, TreeNode)
    self.text = text or "Node"
    self.position = position or Vector2.new(0, 0)
    self.expanded = expanded or false
    self.children = {}
    self.parent = nil
    self.depth = 0
    
    return self
end

-- Separator class
local Separator = {}
Separator.__index = Separator

function Separator.new(position, width)
    local self = setmetatable({}, Separator)
    self.position = position or Vector2.new(0, 0)
    self.width = width or 200
    
    self.line = Drawing.new("Line")
    self.line.From = self.position
    self.line.To = self.position + Vector2.new(self.width, 0)
    self.line.Color = Color3.fromRGB(100, 100, 100)
    self.line.Thickness = 1
    self.line.Visible = true
    
    table.insert(DrawingObjects, self.line)
    return self
end

-- Row class
local Row = {}
Row.__index = Row

function Row.new(position, height)
    local self = setmetatable({}, Row)
    self.position = position or Vector2.new(0, 0)
    self.height = height or 25
    self.children = {}
    return self
end

function Row:Fill()
    -- Fill row with content
end

-- Slider class
local Slider = {}
Slider.__index = Slider

function Slider.new(min, max, value, position, size)
    local self = setmetatable({}, Slider)
    self.min = min or 0
    self.max = max or 100
    self.value = value or 0
    self.position = position or Vector2.new(0, 0)
    self.size = size or Vector2.new(200, 20)
    self.callback = NullFunction
    self.dragging = false
    
    self.track = Drawing.new("Square")
    self.track.Position = self.position
    self.track.Size = self.size
    self.track.Color = Color3.fromRGB(60, 60, 60)
    self.track.Filled = true
    self.track.Visible = true
    
    local handleX = self.position.X + (self.value - self.min) / (self.max - self.min) * self.size.X
    self.handle = Drawing.new("Circle")
    self.handle.Position = Vector2.new(handleX, self.position.Y + self.size.Y / 2)
    self.handle.Radius = 8
    self.handle.Color = Color3.fromRGB(100, 150, 255)
    self.handle.Filled = true
    self.handle.Visible = true
    
    table.insert(DrawingObjects, self.track)
    table.insert(DrawingObjects, self.handle)
    
    return self
end

function Slider:Callback(func)
    self.callback = func or NullFunction
end

function Slider:SetValue(value)
    self.value = math.clamp(value, self.min, self.max)
    local handleX = self.position.X + (self.value - self.min) / (self.max - self.min) * self.size.X
    self.handle.Position = Vector2.new(handleX, self.position.Y + self.size.Y / 2)
    self.callback(self.value)
end

-- Props classes
local Props = {}
Props.__index = Props

function Props.new()
    local self = setmetatable({}, Props)
    self.properties = {}
    return self
end

function Props:MouseMove(callback)
    self.mouseMoveCallback = callback
end

function Props:InputEnded(callback)
    self.inputEndedCallback = callback
end

function Props:OnInput(callback)
    self.inputCallback = callback
end

-- ProgressSlider class
local ProgressSlider = {}
ProgressSlider.__index = ProgressSlider

function ProgressSlider.new(position, size)
    local self = setmetatable({}, ProgressSlider)
    self.position = position or Vector2.new(0, 0)
    self.size = size or Vector2.new(200, 20)
    self.percentage = 0
    
    self.background = Drawing.new("Square")
    self.background.Position = self.position
    self.background.Size = self.size
    self.background.Color = Color3.fromRGB(40, 40, 40)
    self.background.Filled = true
    self.background.Visible = true
    
    self.fill = Drawing.new("Square")
    self.fill.Position = self.position
    self.fill.Size = Vector2.new(0, self.size.Y)
    self.fill.Color = Color3.fromRGB(0, 150, 255)
    self.fill.Filled = true
    self.fill.Visible = true
    
    table.insert(DrawingObjects, self.background)
    table.insert(DrawingObjects, self.fill)
    
    return self
end

-- ProgressBar class
local ProgressBar = {}
ProgressBar.__index = ProgressBar

function ProgressBar.new(position, size)
    local self = setmetatable({}, ProgressBar)
    self.position = position or Vector2.new(0, 0)
    self.size = size or Vector2.new(200, 15)
    self.percentage = 0
    
    self.background = Drawing.new("Square")
    self.background.Position = self.position
    self.background.Size = self.size
    self.background.Color = Color3.fromRGB(50, 50, 50)
    self.background.Filled = true
    self.background.Visible = true
    
    self.fill = Drawing.new("Square")
    self.fill.Position = self.position
    self.fill.Size = Vector2.new(0, self.size.Y)
    self.fill.Color = Color3.fromRGB(0, 200, 0)
    self.fill.Filled = true
    self.fill.Visible = true
    
    table.insert(DrawingObjects, self.background)
    table.insert(DrawingObjects, self.fill)
    
    return self
end

function ProgressBar:SetPercentage(percentage)
    self.percentage = math.clamp(percentage, 0, 100)
    self.fill.Size = Vector2.new(self.size.X * (self.percentage / 100), self.size.Y)
end

-- Keybind class
local Keybind = {}
Keybind.__index = Keybind

function Keybind.new(defaultKey, position, size)
    local self = setmetatable({}, Keybind)
    self.key = defaultKey or Enum.KeyCode.F
    self.position = position or Vector2.new(0, 0)
    self.size = size or Vector2.new(100, 25)
    self.callback = NullFunction
    self.listening = false
    
    self.background = Drawing.new("Square")
    self.background.Position = self.position
    self.background.Size = self.size
    self.background.Color = Color3.fromRGB(60, 60, 60)
    self.background.Filled = true
    self.background.Visible = true
    
    self.textLabel = Drawing.new("Text")
    self.textLabel.Text = self.key.Name
    self.textLabel.Position = self.position + Vector2.new(self.size.X / 2, self.size.Y / 2)
    self.textLabel.Color = Color3.fromRGB(255, 255, 255)
    self.textLabel.Size = 12
    self.textLabel.Center = true
    self.textLabel.Outline = true
    self.textLabel.Font = 2
    self.textLabel.Visible = true
    
    table.insert(DrawingObjects, self.background)
    table.insert(DrawingObjects, self.textLabel)
    
    return self
end

function Keybind:Callback(func)
    self.callback = func or NullFunction
end

function Keybind:SetValue(key)
    self.key = key
    self.textLabel.Text = key.Name
end

-- Combo class
local Combo = {}
Combo.__index = Combo

function Combo.new(options, position, size)
    local self = setmetatable({}, Combo)
    self.options = options or {}
    self.position = position or Vector2.new(0, 0)
    self.size = size or Vector2.new(150, 25)
    self.selectedIndex = 1
    self.open = false
    self.callback = NullFunction
    
    self.background = Drawing.new("Square")
    self.background.Position = self.position
    self.background.Size = self.size
    self.background.Color = Color3.fromRGB(60, 60, 60)
    self.background.Filled = true
    self.background.Visible = true
    
    self.textLabel = Drawing.new("Text")
    self.textLabel.Text = self.options[self.selectedIndex] or "Select..."
    self.textLabel.Position = self.position + Vector2.new(5, self.size.Y / 2)
    self.textLabel.Color = Color3.fromRGB(255, 255, 255)
    self.textLabel.Size = 14
    self.textLabel.Outline = true
    self.textLabel.Font = 2
    self.textLabel.Visible = true
    
    self.arrow = Drawing.new("Text")
    self.arrow.Text = "▼"
    self.arrow.Position = self.position + Vector2.new(self.size.X - 15, self.size.Y / 2)
    self.arrow.Color = Color3.fromRGB(255, 255, 255)
    self.arrow.Size = 12
    self.arrow.Outline = true
    self.arrow.Font = 2
    self.arrow.Visible = true
    
    table.insert(DrawingObjects, self.background)
    table.insert(DrawingObjects, self.textLabel)
    table.insert(DrawingObjects, self.arrow)
    
    return self
end

function Combo:Callback(func)
    self.callback = func or NullFunction
end

function Combo:SetValue(index)
    self.selectedIndex = index
    self.textLabel.Text = self.options[index] or "Select..."
    self.callback(index, self.options[index])
end

function Combo:SetOpen(open)
    self.open = open
end

function Combo:Closed()
    self.open = false
end

function Combo:ToggleOpen()
    self:SetOpen(not self.open)
end

-- Dropdown class
local Dropdown = {}
Dropdown.__index = Dropdown

function Dropdown.new(options, position, size)
    local self = setmetatable({}, Dropdown)
    self.options = options or {}
    self.position = position or Vector2.new(0, 0)
    self.size = size or Vector2.new(150, 25)
    self.selectedIndex = 1
    self.open = false
    self.callback = NullFunction
    
    return self
end

function Dropdown:OnInput(input)
    -- Handle input
end

function Dropdown:Close()
    self.open = false
end

function Dropdown:SetValue(value)
    for i, option in ipairs(self.options) do
        if option == value then
            self.selectedIndex = i
            break
        end
    end
end

-- Animation functions
local function GetAnimation(startValue, endValue, duration, easingStyle)
    return {
        start = startValue,
        target = endValue,
        duration = duration,
        style = easingStyle or Enum.EasingStyle.Linear
    }
end

local function Tween(object, properties, duration, easingStyle)
    local info = TweenInfo.new(duration, easingStyle or Enum.EasingStyle.Linear)
    local tween = TweenService:Create(object, info, properties)
    tween:Play()
    return tween
end

local function ApplyAnimations(animations)
    for _, animation in ipairs(animations) do
        -- Apply animation
    end
end

-- Connection management
local Connections = {}
Connections.__index = Connections

function Connections.new()
    local self = setmetatable({}, Connections)
    self.connections = {}
    return self
end

function Connections:Callback(func)
    self.callback = func or NullFunction
end

function Connections:HeaderAnimate(header, duration)
    -- Animate header
end

function Connections:ApplyDraggable(object, dragHandle)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    local function onInputBegan(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = object.Position
        end
    end
    
    local function onInputChanged(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            object.Position = startPos + Vector2.new(delta.X, delta.Y)
        end
    end
    
    local function onInputEnded(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end
    
    local conn1 = UserInputService.InputBegan:Connect(onInputBegan)
    local conn2 = UserInputService.InputChanged:Connect(onInputChanged)
    local conn3 = UserInputService.InputEnded:Connect(onInputEnded)
    
    table.insert(self.connections, conn1)
    table.insert(self.connections, conn2)
    table.insert(self.connections, conn3)
end

-- UserInputTypes
local UserInputTypes = {}

function UserInputTypes.UserInputTypeAllowed(inputType)
    local allowed = {
        [Enum.UserInputType.MouseButton1] = true,
        [Enum.UserInputType.MouseButton2] = true,
        [Enum.UserInputType.MouseMovement] = true,
        [Enum.UserInputType.Keyboard] = true
    }
    return allowed[inputType] or false
end

function UserInputTypes.Movement(input)
    return input.UserInputType == Enum.UserInputType.MouseMovement
end

function Connections:ApplyResizable(object, minSize, maxSize)
    -- Apply resizable functionality
end

function Connections:ConnectHover(object, hoverCallback, leaveCallback)
    local hovering = false
    
    local function checkHover()
        local mousePos = UserInputService:GetMouseLocation()
        local inBounds = mousePos.X >= object.Position.X and mousePos.X <= object.Position.X + object.Size.X and
                        mousePos.Y >= object.Position.Y and mousePos.Y <= object.Position.Y + object.Size.Y
        
        if inBounds and not hovering then
            hovering = true
            if hoverCallback then hoverCallback() end
        elseif not inBounds and hovering then
            hovering = false
            if leaveCallback then leaveCallback() end
        end
    end
    
    local conn = RunService.Heartbeat:Connect(checkHover)
    table.insert(self.connections, conn)
end

function Connections:Disconnect()
    for _, connection in ipairs(self.connections) do
        connection:Disconnect()
    end
    self.connections = {}
end

function Connections:ApplyWindowSelectEffect(window)
    -- Apply window selection effects
end

-- Colors
local Colors = {}

function Colors.SetSelected(object, selected)
    if selected then
        object.Color = Color3.fromRGB(100, 150, 255)
    else
        object.Color = Color3.fromRGB(67, 67, 67)
    end
end

function Colors.OnInput(object, inputType)
    if inputType == "hover" then
        object.Color = Color3.fromRGB(87, 87, 87)
    elseif inputType == "press" then
        object.Color = Color3.fromRGB(47, 47, 47)
    else
        object.Color = Color3.fromRGB(67, 67, 67)
    end
end

function Colors.SetWindowProps(window, props)
    for prop, value in pairs(props) do
        if window[prop] then
            window[prop] = value
        end
    end
end

-- Module class (Main window manager)
local Module = {}
Module.__index = Module

function Module.new()
    local self = setmetatable({}, Module)
    self.windows = {}
    self.activeWindow = nil
    self.connections = Connections.new()
    return self
end

-- OldValues for state management
local OldValues = {}
OldValues.__index = OldValues

function OldValues.new()
    local self = setmetatable({}, OldValues)
    self.values = {}
    return self
end

function OldValues:Revert()
    -- Revert to old values
end

function Module:CreateWindow(title, position, size)
    local window = {
        title = title or "Window",
        position = position or Vector2.new(100, 100),
        size = size or Vector2.new(400, 300),
        visible = true,
        open = true,
        dragging = false,
        resizing = false,
        tabs = {},
        activeTab = nil,
        content = {},
        connections = Connections.new()
    }
    
    -- Create window background
    window.background = Drawing.new("Square")
    window.background.Position = window.position
    window.background.Size = window.size
    window.background.Color = Color3.fromRGB(45, 45, 45)
    window.background.Filled = true
    window.background.Visible = window.visible
    
    -- Create window header
    window.header = Drawing.new("Square")
    window.header.Position = window.position
    window.header.Size = Vector2.new(window.size.X, 30)
    window.header.Color = Color3.fromRGB(35, 35, 35)
    window.header.Filled = true
    window.header.Visible = window.visible
    
    -- Create title text
    window.titleText = Drawing.new("Text")
    window.titleText.Text = window.title
    window.titleText.Position = window.position + Vector2.new(10, 15)
    window.titleText.Color = Color3.fromRGB(255, 255, 255)
    window.titleText.Size = 14
    window.titleText.Outline = true
    window.titleText.Font = 2
    window.titleText.Visible = window.visible
    
    -- Create close button
    window.closeButton = Drawing.new("Text")
    window.closeButton.Text = "×"
    window.closeButton.Position = window.position + Vector2.new(window.size.X - 20, 15)
    window.closeButton.Color = Color3.fromRGB(255, 100, 100)
    window.closeButton.Size = 16
    window.closeButton.Center = true
    window.closeButton.Outline = true
    window.closeButton.Font = 2
    window.closeButton.Visible = window.visible
    
    table.insert(DrawingObjects, window.background)
    table.insert(DrawingObjects, window.header)
    table.insert(DrawingObjects, window.titleText)
    table.insert(DrawingObjects, window.closeButton)
    
    -- Apply draggable functionality
    window.connections:ApplyDraggable(window, window.header)
    
    table.insert(self.windows, window)
    return window
end

function Module:Close(window)
    if window then
        window.visible = false
        window.open = false
        for _, obj in pairs({window.background, window.header, window.titleText, window.closeButton}) do
            obj.Visible = false
        end
        window.connections:Disconnect()
    end
end

function Module:GetHeaderSizeY()
    return 30
end

function Module:UpdateBody(window)
    -- Update window body content
end

function Module:SetOpen(window, open)
    window.open = open
    window.visible = open
    for _, obj in pairs({window.background, window.header, window.titleText, window.closeButton}) do
        obj.Visible = open
    end
end

function Module:SetVisible(window, visible)
    window.visible = visible
    for _, obj in pairs({window.background, window.header, window.titleText, window.closeButton}) do
        obj.Visible = visible
    end
end

function Module:SetTitle(window, title)
    window.title = title
    window.titleText.Text = title
end

function Module:Remove(window)
    self:Close(window)
    for i, w in ipairs(self.windows) do
        if w == window then
            table.remove(self.windows, i)
            break
        end
    end
end

function Module:CreateTab(window, title)
    local tab = {
        title = title or "Tab",
        window = window,
        content = {},
        active = false
    }
    
    table.insert(window.tabs, tab)
    if not window.activeTab then
        window.activeTab = tab
        tab.active = true
    end
    
    return tab
end

function Module:GetContentSize(window)
    return Vector2.new(window.size.X - 20, window.size.Y - 50)
end

function Module:SetPosition(window, position)
    local delta = position - window.position
    window.position = position
    
    window.background.Position = position
    window.header.Position = position
    window.titleText.Position = position + Vector2.new(10, 15)
    window.closeButton.Position = position + Vector2.new(window.size.X - 20, 15)
end

function Module:SetSize(window, size)
    window.size = size
    
    window.background.Size = size
    window.header.Size = Vector2.new(size.X, 30)
    window.closeButton.Position = window.position + Vector2.new(size.X - 20, 15)
end

function Module:ShowTab(window, tab)
    if window.activeTab then
        window.activeTab.active = false
    end
    window.activeTab = tab
    tab.active = true
end

function Module:Center(window)
    local screenSize = workspace.CurrentCamera.ViewportSize
    local centerPos = Vector2.new(
        (screenSize.X - window.size.X) / 2,
        (screenSize.Y - window.size.Y) / 2
    )
    self:SetPosition(window, centerPos)
end

function Module:CreateModal(title, message, buttons)
    local modal = self:CreateWindow(title, Vector2.new(0, 0), Vector2.new(300, 150))
    self:Center(modal)
    
    -- Add message text
    local messageText = Drawing.new("Text")
    messageText.Text = message or ""
    messageText.Position = modal.position + Vector2.new(20, 50)
    messageText.Color = Color3.fromRGB(255, 255, 255)
    messageText.Size = 14
    messageText.Outline = true
    messageText.Font = 2
    messageText.Visible = true
    
    table.insert(DrawingObjects, messageText)
    
    modal.messageText = messageText
    return modal
end

-- Main update loop
local function UpdateUI()
    MousePosition = UserInputService:GetMouseLocation()
    DeltaTime = RunService.Heartbeat:Wait()
    FrameCount = FrameCount + 1
    
    -- Update all interactive elements
    for _, obj in ipairs(DrawingObjects) do
        if obj.Update then
            obj:Update()
        end
    end
    
    LastMousePosition = MousePosition
end

-- Initialize UI system
local function Initialize()
    RunService.Heartbeat:Connect(UpdateUI)
    
  -- Fallback cleanup for client since BindToClose is server-only
local function Cleanup()
    for _, obj in ipairs(DrawingObjects) do
        if obj.Remove then
            obj:Remove()
        end
    end
end

-- Hook to UI unloading or reset events
game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui").AncestryChanged:Connect(function()
    Cleanup()
end)

-- Also add manual cleanup on character removing (optional)
game:GetService("Players").LocalPlayer.CharacterRemoving:Connect(function()
    Cleanup()
end)

-- Export all classes and functions
RDCUILib.ImGui = ImGui
RDCUILib.NullFunction = NullFunction
RDCUILib.GetService = GetService
RDCUILib.Warn = Warn
RDCUILib.FetchUI = FetchUI
RDCUILib.AdditionalStyles = AdditionalStyles
RDCUILib.Metadata = Metadata
RDCUILib.ContainerClass = ContainerClass
RDCUILib.Button = Button
RDCUILib.Image = Image
RDCUILib.ScrollingBox = ScrollingBox
RDCUILib.Label = Label
RDCUILib.Checkbox = Checkbox
RDCUILib.RadioButton = RadioButton
RDCUILib.Viewport = Viewport
RDCUILib.InputText = InputText
RDCUILib.InputTextMultiline = InputTextMultiline
RDCUILib.Console = Console
RDCUILib.Table = Table
RDCUILib.RowClass = RowClass
RDCUILib.Grid = Grid
RDCUILib.CollapsingHeader = CollapsingHeader
RDCUILib.TreeNode = TreeNode
RDCUILib.Separator = Separator
RDCUILib.Row = Row
RDCUILib.Slider = Slider
RDCUILib.Props = Props
RDCUILib.ProgressSlider = ProgressSlider
RDCUILib.ProgressBar = ProgressBar
RDCUILib.Keybind = Keybind
RDCUILib.Combo = Combo
RDCUILib.Dropdown = Dropdown
RDCUILib.GetAnimation = GetAnimation
RDCUILib.Tween = Tween
RDCUILib.ApplyAnimations = ApplyAnimations
RDCUILib.Connections = Connections
RDCUILib.UserInputTypes = UserInputTypes
RDCUILib.Colors = Colors
RDCUILib.Module = Module
RDCUILib.OldValues = OldValues

-- Initialize the library
Initialize()
    
return RDCUILib
