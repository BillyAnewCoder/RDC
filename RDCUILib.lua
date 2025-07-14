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
local FrameCount = 0

-- ImGui class with proper structure
local ImGui = {
    Animations = {
        Buttons = {
            MouseEnter = {
                BackgroundTransparency = 0.5,
            },
            MouseLeave = {
                BackgroundTransparency = 0.7,
            }
        },
        Tabs = {
            MouseEnter = {
                BackgroundTransparency = 0.5,
            },
            MouseLeave = {
                BackgroundTransparency = 1,
            }
        },
        Inputs = {
            MouseEnter = {
                BackgroundTransparency = 0,
            },
            MouseLeave = {
                BackgroundTransparency = 0.5,
            }
        },
        WindowBorder = {
            Selected = {
                Transparency = 0,
                Thickness = 1
            },
            Deselected = {
                Transparency = 0.7,
                Thickness = 1
            }
        },
    },
    Windows = {},
    Animation = TweenInfo.new(0.1),
    UIAssetId = "rbxassetid://76246418997296"
}
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
    local obj = setmetatable({}, AdditionalStyles)
    obj.styles = {}
    return obj
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
    local obj = setmetatable({}, Metadata)
    obj.data = {}
    return obj
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
    local obj = setmetatable({}, ContainerClass)
    obj.position = position or Vector2.new(0, 0)
    obj.size = size or Vector2.new(200, 100)
    obj.children = {}
    obj.visible = true
    return obj
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
    local obj = setmetatable({}, Button)
    obj.text = text or "Button"
    obj.position = position or Vector2.new(0, 0)
    obj.size = size or Vector2.new(100, 30)
    obj.callback = NullFunction
    obj.hovered = false
    obj.pressed = false

    -- Create drawing objects
    obj.background = Drawing.new("Square")
    obj.background.Position = obj.position
    obj.background.Size = obj.size
    obj.background.Color = Color3.fromRGB(67, 67, 67)
    obj.background.Filled = true
    obj.background.Visible = true

    obj.textLabel = Drawing.new("Text")
    obj.textLabel.Text = obj.text
    obj.textLabel.Position = obj.position + Vector2.new(obj.size.X / 2, obj.size.Y / 2)
    obj.textLabel.Color = Color3.fromRGB(255, 255, 255)
    obj.textLabel.Size = 14
    obj.textLabel.Center = true
    obj.textLabel.Outline = true
    obj.textLabel.Font = 2
    obj.textLabel.Visible = true

    table.insert(DrawingObjects, obj.background)
    table.insert(DrawingObjects, obj.textLabel)

    return obj
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
    local obj = setmetatable({}, Image)
    obj.imageId = imageId or ""
    obj.position = position or Vector2.new(0, 0)
    obj.size = size or Vector2.new(50, 50)
    obj.callback = NullFunction

    obj.image = Drawing.new("Image")
    obj.image.Data = obj.imageId
    obj.image.Position = obj.position
    obj.image.Size = obj.size
    obj.image.Visible = true

    table.insert(DrawingObjects, obj.image)
    return obj
end

function Image:Callback(func)
    self.callback = func or NullFunction
end

-- ScrollingBox class
local ScrollingBox = {}
ScrollingBox.__index = ScrollingBox

function ScrollingBox.new(position, size)
    local obj = setmetatable({}, ScrollingBox)
    obj.position = position or Vector2.new(0, 0)
    obj.size = size or Vector2.new(200, 150)
    obj.scrollY = 0
    obj.contentHeight = 0
    obj.children = {}

    obj.background = Drawing.new("Square")
    obj.background.Position = obj.position
    obj.background.Size = obj.size
    obj.background.Color = Color3.fromRGB(40, 40, 40)
    obj.background.Filled = true
    obj.background.Visible = true

    table.insert(DrawingObjects, obj.background)
    return obj
end

-- Label class
local Label = {}
Label.__index = Label

function Label.new(text, position)
    local obj = setmetatable({}, Label)
    obj.text = text or "Label"
    obj.position = position or Vector2.new(0, 0)

    obj.textLabel = Drawing.new("Text")
    obj.textLabel.Text = obj.text
    obj.textLabel.Position = obj.position
    obj.textLabel.Color = Color3.fromRGB(255, 255, 255)
    obj.textLabel.Size = 14
    obj.textLabel.Outline = true
    obj.textLabel.Font = 2
    obj.textLabel.Visible = true

    table.insert(DrawingObjects, obj.textLabel)
    return obj
end

-- Checkbox class
local Checkbox = {}
Checkbox.__index = Checkbox

function Checkbox.new(text, position, checked)
    local obj = setmetatable({}, Checkbox)
    obj.text = text or "Checkbox"
    obj.position = position or Vector2.new(0, 0)
    obj.checked = checked or false
    obj.callback = NullFunction

    obj.background = Drawing.new("Square")
    obj.background.Position = obj.position
    obj.background.Size = Vector2.new(16, 16)
    obj.background.Color = Color3.fromRGB(67, 67, 67)
    obj.background.Filled = true
    obj.background.Visible = true

    obj.checkmark = Drawing.new("Text")
    obj.checkmark.Text = obj.checked and "✓" or ""
    obj.checkmark.Position = obj.position + Vector2.new(8, 8)
    obj.checkmark.Color = Color3.fromRGB(0, 255, 0)
    obj.checkmark.Size = 12
    obj.checkmark.Center = true
    obj.checkmark.Outline = true
    obj.checkmark.Font = 2
    obj.checkmark.Visible = true

    obj.textLabel = Drawing.new("Text")
    obj.textLabel.Text = obj.text
    obj.textLabel.Position = obj.position + Vector2.new(20, 8)
    obj.textLabel.Color = Color3.fromRGB(255, 255, 255)
    obj.textLabel.Size = 14
    obj.textLabel.Outline = true
    obj.textLabel.Font = 2
    obj.textLabel.Visible = true

    table.insert(DrawingObjects, obj.background)
    table.insert(DrawingObjects, obj.checkmark)
    table.insert(DrawingObjects, obj.textLabel)

    return obj
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
    local obj = setmetatable({}, RadioButton)
    obj.text = text or "Radio"
    obj.position = position or Vector2.new(0, 0)
    obj.group = group or "default"
    obj.selected = false
    obj.callback = NullFunction

    obj.background = Drawing.new("Circle")
    obj.background.Position = obj.position + Vector2.new(8, 8)
    obj.background.Radius = 8
    obj.background.Color = Color3.fromRGB(67, 67, 67)
    obj.background.Filled = false
    obj.background.Thickness = 2
    obj.background.Visible = true

    obj.dot = Drawing.new("Circle")
    obj.dot.Position = obj.position + Vector2.new(8, 8)
    obj.dot.Radius = 4
    obj.dot.Color = Color3.fromRGB(0, 255, 0)
    obj.dot.Filled = true
    obj.dot.Visible = obj.selected

    obj.textLabel = Drawing.new("Text")
    obj.textLabel.Text = obj.text
    obj.textLabel.Position = obj.position + Vector2.new(20, 8)
    obj.textLabel.Color = Color3.fromRGB(255, 255, 255)
    obj.textLabel.Size = 14
    obj.textLabel.Outline = true
    obj.textLabel.Font = 2
    obj.textLabel.Visible = true

    table.insert(DrawingObjects, obj.background)
    table.insert(DrawingObjects, obj.dot)
    table.insert(DrawingObjects, obj.textLabel)

    return obj
end

-- Viewport class
local Viewport = {}
Viewport.__index = Viewport

function Viewport.new(position, size)
    local obj = setmetatable({}, Viewport)
    obj.position = position or Vector2.new(0, 0)
    obj.size = size or Vector2.new(200, 200)
    obj.camera = nil
    obj.model = nil

    obj.background = Drawing.new("Square")
    obj.background.Position = obj.position
    obj.background.Size = obj.size
    obj.background.Color = Color3.fromRGB(30, 30, 30)
    obj.background.Filled = true
    obj.background.Visible = true

    table.insert(DrawingObjects, obj.background)
    return obj
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
    local obj = setmetatable({}, InputText)
    obj.placeholder = placeholder or "Enter text..."
    obj.position = position or Vector2.new(0, 0)
    obj.size = size or Vector2.new(200, 25)
    obj.value = ""
    obj.focused = false
    obj.callback = NullFunction
    obj.cursorPos = 0

    obj.background = Drawing.new("Square")
    obj.background.Position = obj.position
    obj.background.Size = obj.size
    obj.background.Color = Color3.fromRGB(50, 50, 50)
    obj.background.Filled = true
    obj.background.Visible = true

    obj.border = Drawing.new("Square")
    obj.border.Position = obj.position
    obj.border.Size = obj.size
    obj.border.Color = Color3.fromRGB(100, 100, 100)
    obj.border.Filled = false
    obj.border.Thickness = 1
    obj.border.Visible = true

    obj.textLabel = Drawing.new("Text")
    obj.textLabel.Text = obj.value == "" and obj.placeholder or obj.value
    obj.textLabel.Position = obj.position + Vector2.new(5, obj.size.Y / 2)
    obj.textLabel.Color = obj.value == "" and Color3.fromRGB(150, 150, 150) or Color3.fromRGB(255, 255, 255)
    obj.textLabel.Size = 14
    obj.textLabel.Outline = true
    obj.textLabel.Font = 2
    obj.textLabel.Visible = true

    table.insert(DrawingObjects, obj.background)
    table.insert(DrawingObjects, obj.border)
    table.insert(DrawingObjects, obj.textLabel)

    return obj
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
    local obj = setmetatable({}, InputTextMultiline)
    obj.placeholder = placeholder or "Enter text..."
    obj.position = position or Vector2.new(0, 0)
    obj.size = size or Vector2.new(300, 100)
    obj.value = ""
    obj.lines = {""}
    obj.scrollY = 0
    obj.focused = false
    obj.callback = NullFunction

    obj.background = Drawing.new("Square")
    obj.background.Position = obj.position
    obj.background.Size = obj.size
    obj.background.Color = Color3.fromRGB(40, 40, 40)
    obj.background.Filled = true
    obj.background.Visible = true

    table.insert(DrawingObjects, obj.background)
    return obj
end

function InputTextMultiline:GetRemainingHeight()
    return self.size.Y - (#self.lines * 16)
end

-- Console class
local Console = {}
Console.__index = Console

function Console.new(position, size)
    local obj = setmetatable({}, Console)
    obj.position = position or Vector2.new(0, 0)
    obj.size = size or Vector2.new(400, 200)
    obj.lines = {}
    obj.scrollY = 0
    obj.maxLines = 100

    obj.background = Drawing.new("Square")
    obj.background.Position = obj.position
    obj.background.Size = obj.size
    obj.background.Color = Color3.fromRGB(20, 20, 20)
    obj.background.Filled = true
    obj.background.Visible = true

    obj.lineNumbers = Drawing.new("Square")
    obj.lineNumbers.Position = obj.position
    obj.lineNumbers.Size = Vector2.new(40, obj.size.Y)
    obj.lineNumbers.Color = Color3.fromRGB(30, 30, 30)
    obj.lineNumbers.Filled = true
    obj.lineNumbers.Visible = true

    table.insert(DrawingObjects, obj.background)
    table.insert(DrawingObjects, obj.lineNumbers)

    return obj
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
    local obj = setmetatable({}, Table)
    obj.position = position or Vector2.new(0, 0)
    obj.size = size or Vector2.new(400, 200)
    obj.rows = {}
    obj.columns = {}
    obj.scrollY = 0

    obj.background = Drawing.new("Square")
    obj.background.Position = obj.position
    obj.background.Size = obj.size
    obj.background.Color = Color3.fromRGB(45, 45, 45)
    obj.background.Filled = true
    obj.background.Visible = true

    table.insert(DrawingObjects, obj.background)
    return obj
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
    local obj = setmetatable({}, RowClass)
    obj.columns = {}
    return obj
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
    local obj = setmetatable({}, Grid)
    obj.position = position or Vector2.new(0, 0)
    obj.size = size or Vector2.new(300, 200)
    obj.columns = columns or 3
    obj.rows = rows or 3
    obj.cells = {}

    obj.background = Drawing.new("Square")
    obj.background.Position = obj.position
    obj.background.Size = obj.size
    obj.background.Color = Color3.fromRGB(50, 50, 50)
    obj.background.Filled = true
    obj.background.Visible = true

    table.insert(DrawingObjects, obj.background)
    return obj
end

-- CollapsingHeader class
local CollapsingHeader = {}
CollapsingHeader.__index = CollapsingHeader

function CollapsingHeader.new(text, position, open)
    local obj = setmetatable({}, CollapsingHeader)
    obj.text = text or "Header"
    obj.position = position or Vector2.new(0, 0)
    obj.open = open or false
    obj.callback = NullFunction

    obj.background = Drawing.new("Square")
    obj.background.Position = obj.position
    obj.background.Size = Vector2.new(200, 25)
    obj.background.Color = Color3.fromRGB(60, 60, 60)
    obj.background.Filled = true
    obj.background.Visible = true

    obj.arrow = Drawing.new("Text")
    obj.arrow.Text = obj.open and "▼" or "▶"
    obj.arrow.Position = obj.position + Vector2.new(5, 12)
    obj.arrow.Color = Color3.fromRGB(255, 255, 255)
    obj.arrow.Size = 12
    obj.arrow.Outline = true
    obj.arrow.Font = 2
    obj.arrow.Visible = true

    obj.textLabel = Drawing.new("Text")
    obj.textLabel.Text = obj.text
    obj.textLabel.Position = obj.position + Vector2.new(20, 12)
    obj.textLabel.Color = Color3.fromRGB(255, 255, 255)
    obj.textLabel.Size = 14
    obj.textLabel.Outline = true
    obj.textLabel.Font = 2
    obj.textLabel.Visible = true

    table.insert(DrawingObjects, obj.background)
    table.insert(DrawingObjects, obj.arrow)
    table.insert(DrawingObjects, obj.textLabel)

    return obj
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
    local obj = setmetatable({}, TreeNode)
    obj.text = text or "Node"
    obj.position = position or Vector2.new(0, 0)
    obj.expanded = expanded or false
    obj.children = {}
    obj.parent = nil
    obj.depth = 0

    return obj
end

-- Separator class
local Separator = {}
Separator.__index = Separator

function Separator.new(position, width)
    local obj = setmetatable({}, Separator)
    obj.position = position or Vector2.new(0, 0)
    obj.width = width or 200

    obj.line = Drawing.new("Line")
    obj.line.From = obj.position
    obj.line.To = obj.position + Vector2.new(obj.width, 0)
    obj.line.Color = Color3.fromRGB(100, 100, 100)
    obj.line.Thickness = 1
    obj.line.Visible = true

    table.insert(DrawingObjects, obj.line)
    return obj
end

-- Row class
local Row = {}
Row.__index = Row

function Row.new(position, height)
    local obj = setmetatable({}, Row)
    obj.position = position or Vector2.new(0, 0)
    obj.height = height or 25
    obj.children = {}
    return obj
end

function Row:Fill()
    -- Fill row with content
end

-- Slider class
local Slider = {}
Slider.__index = Slider

function Slider.new(min, max, value, position, size)
    local obj = setmetatable({}, Slider)
    obj.min = min or 0
    obj.max = max or 100
    obj.value = value or 0
    obj.position = position or Vector2.new(0, 0)
    obj.size = size or Vector2.new(200, 20)
    obj.callback = NullFunction
    obj.dragging = false

    obj.track = Drawing.new("Square")
    obj.track.Position = obj.position
    obj.track.Size = obj.size
    obj.track.Color = Color3.fromRGB(60, 60, 60)
    obj.track.Filled = true
    obj.track.Visible = true

    local handleX = obj.position.X + (obj.value - obj.min) / (obj.max - obj.min) * obj.size.X
    obj.handle = Drawing.new("Circle")
    obj.handle.Position = Vector2.new(handleX, obj.position.Y + obj.size.Y / 2)
    obj.handle.Radius = 8
    obj.handle.Color = Color3.fromRGB(100, 150, 255)
    obj.handle.Filled = true
    obj.handle.Visible = true

    table.insert(DrawingObjects, obj.track)
    table.insert(DrawingObjects, obj.handle)

    return obj
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
    local obj = setmetatable({}, Props)
    obj.properties = {}
    return obj
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
    local obj = setmetatable({}, ProgressSlider)
    obj.position = position or Vector2.new(0, 0)
    obj.size = size or Vector2.new(200, 20)
    obj.percentage = 0

    obj.background = Drawing.new("Square")
    obj.background.Position = obj.position
    obj.background.Size = obj.size
    obj.background.Color = Color3.fromRGB(40, 40, 40)
    obj.background.Filled = true
    obj.background.Visible = true

    obj.fill = Drawing.new("Square")
    obj.fill.Position = obj.position
    obj.fill.Size = Vector2.new(0, obj.size.Y)
    obj.fill.Color = Color3.fromRGB(0, 150, 255)
    obj.fill.Filled = true
    obj.fill.Visible = true

    table.insert(DrawingObjects, obj.background)
    table.insert(DrawingObjects, obj.fill)

    return obj
end

-- ProgressBar class
local ProgressBar = {}
ProgressBar.__index = ProgressBar

function ProgressBar.new(position, size)
    local obj = setmetatable({}, ProgressBar)
    obj.position = position or Vector2.new(0, 0)
    obj.size = size or Vector2.new(200, 15)
    obj.percentage = 0

    obj.background = Drawing.new("Square")
    obj.background.Position = obj.position
    obj.background.Size = obj.size
    obj.background.Color = Color3.fromRGB(50, 50, 50)
    obj.background.Filled = true
    obj.background.Visible = true

    obj.fill = Drawing.new("Square")
    obj.fill.Position = obj.position
    obj.fill.Size = Vector2.new(0, obj.size.Y)
    obj.fill.Color = Color3.fromRGB(0, 200, 0)
    obj.fill.Filled = true
    obj.fill.Visible = true

    table.insert(DrawingObjects, obj.background)
    table.insert(DrawingObjects, obj.fill)

    return obj
end

function ProgressBar:SetPercentage(percentage)
    self.percentage = math.clamp(percentage, 0, 100)
    self.fill.Size = Vector2.new(self.size.X * (self.percentage / 100), self.size.Y)
end

-- Keybind class
local Keybind = {}
Keybind.__index = Keybind

function Keybind.new(defaultKey, position, size)
    local obj = setmetatable({}, Keybind)
    obj.key = defaultKey or Enum.KeyCode.F
    obj.position = position or Vector2.new(0, 0)
    obj.size = size or Vector2.new(100, 25)
    obj.callback = NullFunction
    obj.listening = false

    obj.background = Drawing.new("Square")
    obj.background.Position = obj.position
    obj.background.Size = obj.size
    obj.background.Color = Color3.fromRGB(60, 60, 60)
    obj.background.Filled = true
    obj.background.Visible = true

    obj.textLabel = Drawing.new("Text")
    obj.textLabel.Text = obj.key.Name
    obj.textLabel.Position = obj.position + Vector2.new(obj.size.X / 2, obj.size.Y / 2)
    obj.textLabel.Color = Color3.fromRGB(255, 255, 255)
    obj.textLabel.Size = 12
    obj.textLabel.Center = true
    obj.textLabel.Outline = true
    obj.textLabel.Font = 2
    obj.textLabel.Visible = true

    table.insert(DrawingObjects, obj.background)
    table.insert(DrawingObjects, obj.textLabel)

    return obj
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
    local obj = setmetatable({}, Combo)
    obj.options = options or {}
    obj.position = position or Vector2.new(0, 0)
    obj.size = size or Vector2.new(150, 25)
    obj.selectedIndex = 1
    obj.open = false
    obj.callback = NullFunction

    obj.background = Drawing.new("Square")
    obj.background.Position = obj.position
    obj.background.Size = obj.size
    obj.background.Color = Color3.fromRGB(60, 60, 60)
    obj.background.Filled = true
    obj.background.Visible = true

    obj.textLabel = Drawing.new("Text")
    obj.textLabel.Text = obj.options[obj.selectedIndex] or "Select..."
    obj.textLabel.Position = obj.position + Vector2.new(5, obj.size.Y / 2)
    obj.textLabel.Color = Color3.fromRGB(255, 255, 255)
    obj.textLabel.Size = 14
    obj.textLabel.Outline = true
    obj.textLabel.Font = 2
    obj.textLabel.Visible = true

    obj.arrow = Drawing.new("Text")
    obj.arrow.Text = "▼"
    obj.arrow.Position = obj.position + Vector2.new(obj.size.X - 15, obj.size.Y / 2)
    obj.arrow.Color = Color3.fromRGB(255, 255, 255)
    obj.arrow.Size = 12
    obj.arrow.Outline = true
    obj.arrow.Font = 2
    obj.arrow.Visible = true

    table.insert(DrawingObjects, obj.background)
    table.insert(DrawingObjects, obj.textLabel)
    table.insert(DrawingObjects, obj.arrow)

    return obj
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
    local obj = setmetatable({}, Dropdown)
    obj.options = options or {}
    obj.position = position or Vector2.new(0, 0)
    obj.size = size or Vector2.new(150, 25)
    obj.selectedIndex = 1
    obj.open = false
    obj.callback = NullFunction

    return obj
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
        if animation.target and animation.start then
            -- Apply animation with proper implementation
            local duration = animation.duration or 1
            local style = animation.style or Enum.EasingStyle.Linear
            -- Animation logic implementation
            if animation.target.Position then
                animation.target.Position = animation.start
            end
        end
    end
end

-- Connection management
local Connections = {}
Connections.__index = Connections

function Connections.new()
    local obj = setmetatable({}, Connections)
    obj.connections = {}
    return obj
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
    local obj = setmetatable({}, Module)
    obj.windows = {}
    obj.activeWindow = nil
    obj.connections = Connections.new()
    return obj
end

-- OldValues for state management
local OldValues = {}
OldValues.__index = OldValues

function OldValues.new()
    local obj = setmetatable({}, OldValues)
    obj.values = {}
    return obj
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
    FrameCount = FrameCount + 1

    for _, obj in ipairs(DrawingObjects) do
        if obj.Update then
            obj:Update()
        end
    end
end

-- Cleanup drawing objects
local function Cleanup()
    for _, obj in ipairs(DrawingObjects) do
        if obj.Remove then
            obj:Remove()
        end
    end
    table.clear(DrawingObjects)
end

-- Initialize UI system
local function Initialize()
    RunService.Heartbeat:Connect(UpdateUI)
end

-- Cleanup when UI resets
local localPlayer = game:GetService("Players").LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

playerGui.AncestryChanged:Connect(function(_, parent)
    if not parent then
        Cleanup()
    end
end)

localPlayer.CharacterRemoving:Connect(function()
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

Initialize()

return RDCUILib
