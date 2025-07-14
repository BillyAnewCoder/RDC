local UILibrary = {
	-- Package data
	Version = "2.0.0",
	Author = "Anonymous",
	License = "MIT",

	-- Configuration
	Debug = false,
	DefaultTitle = "UI Library",
	ContainerName = "UILibrary",
	DoubleClickThreshold = 0.3,
	TooltipOffset = 15,
	IniToSave = {
		"Value"
	},
	ClassIgnored = {
		"Visible",
		"Text"
	},

	-- Objects
	Container = nil,
	Prefabs = nil,
	FocusedWindow = nil,
	HasTouchScreen = false,

	-- Classes
	Services = nil,
	Elements = {},

	-- Collections
	_FlagCache = {},
	_ErrorCache = {},
	Windows = {},
	ActiveTooltips = {},
	IniSettings = {},
	AnimationConnections = {}	
}

-- Modules
local function GetService(serviceName)
	return game:GetService(serviceName)
end

-- Services
local TweenService = GetService("TweenService")
local UserInputService = GetService("UserInputService")
local Players = GetService("Players")
local CoreGui = GetService("CoreGui")
local RunService = GetService("RunService")
local HttpService = GetService("HttpService")

-- LocalPlayer
local LocalPlayer = Players.LocalPlayer
UILibrary.PlayerGui = LocalPlayer.PlayerGui
UILibrary.Mouse = LocalPlayer:GetMouse()

local EmptyFunction = function() end

function GetAndRemove(Key, Dict)
	local Value = Dict[Key]
	if Value then
		Dict[Key] = nil
	end
	return Value
end

function MoveTableItem(Table, Item, NewPosition)
	local Index = table.find(Table, Item)
	if not Index then return end

	local Value = table.remove(Table, Index)
	table.insert(Table, NewPosition, Value)
end

function Merge(Base, New)
	for Key, Value in next, New do
		Base[Key] = Value
	end
end

function Copy(Original, Insert)
	local Table = {}
	for k, v in pairs(Original) do
		Table[k] = v
	end

	-- Merge Insert values
	if Insert then
		Merge(Table, Insert)
	end

	return Table
end

local function GetMatchPercentage(Value, Query)
	Value = tostring(Value):lower()
	Query = Query:lower()

	local Letters = Value:split("")
	local LetterCount = #Query
	local MatchedCount = 0

	for Index, Letter in pairs(Letters) do
		local Match = Query:sub(Index, Index)

		-- Compare letters
		if Letter == Match then
			MatchedCount = MatchedCount + 1
		end
	end

	local Percentage = (MatchedCount/LetterCount) * 100
	return math.floor(Percentage + 0.5)
end

local function SortByQuery(Table, Query)
	local IsArray = Table[1]
	local Sorted = {}

	for A, B in pairs(Table) do
		local Value = IsArray and B or A
		local Percentage = GetMatchPercentage(Value, Query)
		local Position = 100 - Percentage

		table.insert(Sorted, Position, Value)
	end

	return Sorted
end

function UILibrary:Warn(...)
	warn("[UILibrary]::", ...)
end

function UILibrary:Error(...)
	local Args = {...}
	local Concated = ""
	for i, v in ipairs(Args) do
		Concated = Concated .. tostring(v)
		if i < #Args then
			Concated = Concated .. " "
		end
	end
	local Message = "\n[UILibrary]:: " .. Concated
	coroutine.wrap(error)(Message)
end

function UILibrary:IsDoubleClick(TickRange)
	local ClickThreshold = self.DoubleClickThreshold
	return TickRange < ClickThreshold
end

function UILibrary:StyleContainers()
	local Container = self.Container
	local Overlays = Container.Overlays
	local Windows = Container.Windows
	
	self:SetProperties(Windows, {
		OnTopOfCoreBlur = true
	})
	self:SetProperties(Overlays, {
		OnTopOfCoreBlur = true
	})
end

function UILibrary:Init(Overwrites)
	Overwrites = Overwrites or {}

	-- Check if the library has already initialised
	if self.Initialised then return end

	-- Merge overwrites
	Merge(self, Overwrites)
	Merge(self, {
		Initialised = true,
		HasGamepad = self:IsConsoleDevice(),
		HasTouchScreen = self:IsMobileDevice(),
	})

	-- Create basic container
	self.Container = self:CreateInstance("ScreenGui", self.PlayerGui, {
		Name = self.ContainerName,
		ResetOnSpawn = false,
		DisplayOrder = 999
	})

	-- Create overlays container
	local Overlays = self:CreateInstance("Frame", self.Container, {
		Name = "Overlays",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1
	})

	-- Create windows container  
	local Windows = self:CreateInstance("Frame", self.Container, {
		Name = "Windows",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1
	})

	self.Container.Overlays = Overlays
	self.Container.Windows = Windows

	self:StyleContainers()

	-- Create tooltips container
	self.TooltipsContainer = self:CreateInstance("Frame", Overlays, {
		Name = "Tooltips",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1
	})

	local LastClick = 0

	-- Key press
	UserInputService.InputBegan:Connect(function(Input)
		if not self:IsMouseEvent(Input, true) then return end

		local ClickTick = tick()
		local ClickRange = ClickTick - LastClick
		local IsDoubleClick = self:IsDoubleClick(ClickRange)

		-- DoubleClick
		LastClick = IsDoubleClick and 0 or ClickTick

		-- WindowActiveStates
		self:UpdateWindowFocuses()
	end)

	local function InputUpdate()
		local Tooltips = self.TooltipsContainer
		local ActiveTooltips = self.ActiveTooltips
		local Visible = #ActiveTooltips > 0
		Tooltips.Visible = Visible

		if not Visible then return end

		-- Set frame position to mouse location
		local X, Y = self:GetMouseLocation()
		local Position = Overlays.AbsolutePosition

		Tooltips.Position = UDim2.fromOffset(
			X - Position.X + self.TooltipOffset, 
			Y - Position.Y + self.TooltipOffset
		)
	end

	-- Bind events
	RunService:BindToRenderStep("UILibrary_InputUpdate", Enum.RenderPriority.Input.Value, InputUpdate)
end

function UILibrary:GetVersion()
	return self.Version
end

function UILibrary:IsMobileDevice()
	return UserInputService.TouchEnabled
end

function UILibrary:IsConsoleDevice()
	return UserInputService.GamepadEnabled
end

function UILibrary:GetScreenSize()
	return workspace.CurrentCamera.ViewportSize
end

function UILibrary:CreateInstance(Class, Parent, Properties)
	local Object = Instance.new(Class, Parent)

	-- Apply Properties
	if Properties then
		self:SetProperties(Object, Properties)
	end

	return Object
end

function UILibrary:SetProperties(Object, Properties)
	for Key, Value in pairs(Properties) do
		pcall(function()
			Object[Key] = Value
		end)
	end
end

function UILibrary:ConnectMouseEvent(Object, Config)
	local Callback = Config.Callback
	local DoubleClick = Config.DoubleClick
	local OnlyMouseHovering = Config.OnlyMouseHovering

	local LastClick = 0
	local HoverSignal = nil

	if OnlyMouseHovering then
		HoverSignal = self:DetectHover(OnlyMouseHovering)
	end

	Object.Activated:Connect(function(...)
		local ClickTick = tick()
		local ClickRange = ClickTick - LastClick

		-- OnlyMouseHovering
		if HoverSignal and not HoverSignal.Hovering then return end

		-- DoubleClick
		if DoubleClick then
			if not self:IsDoubleClick(ClickRange) then
				LastClick = ClickTick
				return
			end
			LastClick = 0
		end

		Callback(...)
	end)
end

function UILibrary:GetAnimation(Animate)
	return Animate and TweenInfo.new(0.2) or TweenInfo.new(0)
end

function UILibrary:Tween(Object, Props, TweenInfo, NoAnimation)
	local tweenInfo = TweenInfo or self:GetAnimation(not NoAnimation)
	local Tween = TweenService:Create(Object, tweenInfo, Props)
	Tween:Play()
	return Tween
end

function UILibrary:IsMouseEvent(Input, IgnoreMovement)
	local Name = Input.UserInputType.Name

	-- IgnoreMovement 
	if IgnoreMovement and Name:find("Movement") then return end

	return Name:find("Touch") or Name:find("Mouse")
end

function UILibrary:DetectHover(Object, Configuration)
	local Config = Configuration or {}
	Config.Hovering = false

	-- Unpack configuration
	local OnInput = Config.OnInput
	local OnHoverChange = Config.OnHoverChange
	local Anykey = Config.Anykey
	local MouseMove = Config.MouseMove
	local MouseEnter = Config.MouseEnter
	local MouseOnly = Config.MouseOnly

	local function Update(Input, IsHovering, IsMouseEvent)
		-- Check if the input is mouse or touch
		if Input and MouseOnly then
			if not self:IsMouseEvent(Input, true) then return end
		end

		-- Set new IsHovering state
		if IsHovering ~= nil then
			local Previous = Config.Hovering
			Config.Hovering = IsHovering

			-- Invoke OnHoverChange
			if IsHovering ~= Previous and OnHoverChange then
				OnHoverChange(IsHovering)
			end
		end

		-- Mouse Enter events
		if not MouseEnter and IsMouseEvent then return end

		-- Call OnInput function
		if OnInput then
			local Value = Config.Hovering
			OnInput(Value, Input)
			return 
		end
	end

	-- Connect Events
	local Connections = {
		Object.MouseEnter:Connect(function()
			Update(nil, true, true)
		end),
		Object.MouseLeave:Connect(function()
			Update(nil, false, true)
		end)
	}

	-- Update on keyboard events or Mouse events
	if Anykey or MouseOnly then
		table.insert(Connections, UserInputService.InputBegan:Connect(function(Input)
			Update(Input)
		end))
	end

	-- Update on mouse move
	if MouseMove then
		local Connection = Object.MouseMoved:Connect(function()
			Update()
		end)
		table.insert(Connections, Connection)
	end

	function Config:Disconnect()
		for _, Connection in pairs(Connections) do
			Connection:Disconnect()
		end
	end

	return Config
end

function UILibrary:GetMouseLocation()
	local Mouse = self.Mouse
	return Mouse.X, Mouse.Y
end

function UILibrary:UpdateWindowFocuses()
	local Windows = self.Windows
	local FocusesEnabled = self.WindowFocusesEnabled

	if not FocusesEnabled then return end

	-- Update each window state
	for _, Class in pairs(Windows) do
		local Connection = Class.HoverConnection
		if not Connection then 
			goto continue
		end

		-- Check hover state
		local Hovering = Connection.Hovering
		if Hovering then
			self:SetFocusedWindow(Class)
			return
		end
		
		::continue::
	end

	self:SetFocusedWindow(nil)
end

function UILibrary:SetFocusedWindow(ActiveClass)
	local Previous = self.FocusedWindow
	local Windows = self.Windows

	-- Check if the Active window is the same as previous
	if Previous == ActiveClass then return end
	self.FocusedWindow = ActiveClass

	-- Update active state for each window
	local ZIndex = #Windows
	for _, Class in pairs(Windows) do
		local Window = Class.WindowFrame

		ZIndex = ZIndex - 1

		-- Set Window ZIndex
		if ZIndex then
			Window.ZIndex = ZIndex
		end

		-- Update Window focus state
		local Active = Class == ActiveClass
		if Class.SetFocused then
			Class:SetFocused(Active, ZIndex)
		end
	end
end

-- Create all prefabs programmatically
function UILibrary:CreatePrefabs()
	local UI = Instance.new("ScreenGui")
	UI.Name = "UILibrary"
	UI.ResetOnSpawn = false
	UI.DisplayOrder = 999
	
	local Prefabs = Instance.new("Folder")
	Prefabs.Name = "Prefabs"
	Prefabs.Parent = UI
	
	-- Button Prefab
	local Button = Instance.new("TextButton")
	Button.Name = "Button"
	Button.Size = UDim2.new(1, 0, 0, 25)
	Button.BackgroundColor3 = Color3.fromRGB(67, 67, 67)
	Button.BorderSizePixel = 0
	Button.Text = "Button"
	Button.TextColor3 = Color3.fromRGB(255, 255, 255)
	Button.TextSize = 14
	Button.Font = Enum.Font.SourceSans
	Button.Parent = Prefabs
	
	local ButtonCorner = Instance.new("UICorner")
	ButtonCorner.CornerRadius = UDim.new(0, 4)
	ButtonCorner.Parent = Button
	
	-- Label Prefab
	local Label = Instance.new("TextLabel")
	Label.Name = "Label"
	Label.Size = UDim2.new(1, 0, 0, 20)
	Label.BackgroundTransparency = 1
	Label.Text = "Label"
	Label.TextColor3 = Color3.fromRGB(255, 255, 255)
	Label.TextSize = 14
	Label.Font = Enum.Font.SourceSans
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Prefabs
	
	-- CheckBox Prefab
	local CheckBox = Instance.new("Frame")
	CheckBox.Name = "CheckBox"
	CheckBox.Size = UDim2.new(1, 0, 0, 25)
	CheckBox.BackgroundTransparency = 1
	CheckBox.Parent = Prefabs
	
	local CheckBoxLayout = Instance.new("UIListLayout")
	CheckBoxLayout.FillDirection = Enum.FillDirection.Horizontal
	CheckBoxLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	CheckBoxLayout.Padding = UDim.new(0, 5)
	CheckBoxLayout.Parent = CheckBox
	
	local Tickbox = Instance.new("ImageButton")
	Tickbox.Name = "Tickbox"
	Tickbox.Size = UDim2.new(0, 16, 0, 16)
	Tickbox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	Tickbox.BorderSizePixel = 0
	Tickbox.Parent = CheckBox
	
	local TickboxCorner = Instance.new("UICorner")
	TickboxCorner.CornerRadius = UDim.new(0, 2)
	TickboxCorner.Parent = Tickbox
	
	local Tick = Instance.new("ImageLabel")
	Tick.Name = "Tick"
	Tick.Size = UDim2.new(0.8, 0, 0.8, 0)
	Tick.Position = UDim2.new(0.1, 0, 0.1, 0)
	Tick.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	Tick.BorderSizePixel = 0
	Tick.Image = ""
	Tick.Parent = Tickbox
	
	local TickCorner = Instance.new("UICorner")
	TickCorner.CornerRadius = UDim.new(0, 1)
	TickCorner.Parent = Tick
	
	local CheckLabel = Instance.new("TextLabel")
	CheckLabel.Name = "Label"
	CheckLabel.Size = UDim2.new(1, -21, 1, 0)
	CheckLabel.BackgroundTransparency = 1
	CheckLabel.Text = "Checkbox"
	CheckLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	CheckLabel.TextSize = 14
	CheckLabel.Font = Enum.Font.SourceSans
	CheckLabel.TextXAlignment = Enum.TextXAlignment.Left
	CheckLabel.Parent = CheckBox
	
	-- TextInput Prefab
	local TextInput = Instance.new("Frame")
	TextInput.Name = "TextInput"
	TextInput.Size = UDim2.new(1, 0, 0, 25)
	TextInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	TextInput.BorderSizePixel = 0
	TextInput.Parent = Prefabs
	
	local TextInputCorner = Instance.new("UICorner")
	TextInputCorner.CornerRadius = UDim.new(0, 4)
	TextInputCorner.Parent = TextInput
	
	local TextInputStroke = Instance.new("UIStroke")
	TextInputStroke.Color = Color3.fromRGB(100, 100, 100)
	TextInputStroke.Thickness = 1
	TextInputStroke.Parent = TextInput
	
	local Input = Instance.new("TextBox")
	Input.Name = "Input"
	Input.Size = UDim2.new(1, -10, 1, 0)
	Input.Position = UDim2.new(0, 5, 0, 0)
	Input.BackgroundTransparency = 1
	Input.Text = ""
	Input.PlaceholderText = "Enter text..."
	Input.TextColor3 = Color3.fromRGB(255, 255, 255)
	Input.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
	Input.TextSize = 14
	Input.Font = Enum.Font.SourceSans
	Input.TextXAlignment = Enum.TextXAlignment.Left
	Input.ClearTextOnFocus = false
	Input.Parent = TextInput
	
	-- Slider Prefab
	local Slider = Instance.new("TextButton")
	Slider.Name = "Slider"
	Slider.Size = UDim2.new(1, 0, 0, 25)
	Slider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	Slider.BorderSizePixel = 0
	Slider.Text = ""
	Slider.Parent = Prefabs
	
	local SliderCorner = Instance.new("UICorner")
	SliderCorner.CornerRadius = UDim.new(0, 4)
	SliderCorner.Parent = Slider
	
	local SliderPadding = Instance.new("UIPadding")
	SliderPadding.PaddingLeft = UDim.new(0, 5)
	SliderPadding.PaddingRight = UDim.new(0, 5)
	SliderPadding.Parent = Slider
	
	local Grab = Instance.new("Frame")
	Grab.Name = "Grab"
	Grab.Size = UDim2.new(0, 12, 0.8, 0)
	Grab.Position = UDim2.new(0, 0, 0.5, 0)
	Grab.AnchorPoint = Vector2.new(0.5, 0.5)
	Grab.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
	Grab.BorderSizePixel = 0
	Grab.Parent = Slider
	
	local GrabCorner = Instance.new("UICorner")
	GrabCorner.CornerRadius = UDim.new(1, 0)
	GrabCorner.Parent = Grab
	
	local ValueText = Instance.new("TextLabel")
	ValueText.Name = "ValueText"
	ValueText.Size = UDim2.new(0, 50, 1, 0)
	ValueText.Position = UDim2.new(1, -50, 0, 0)
	ValueText.BackgroundTransparency = 1
	ValueText.Text = "0"
	ValueText.TextColor3 = Color3.fromRGB(255, 255, 255)
	ValueText.TextSize = 12
	ValueText.Font = Enum.Font.SourceSans
	ValueText.TextXAlignment = Enum.TextXAlignment.Right
	ValueText.Parent = Slider
	
	local SliderLabel = Instance.new("TextLabel")
	SliderLabel.Name = "Label"
	SliderLabel.Size = UDim2.new(1, -55, 1, 0)
	SliderLabel.BackgroundTransparency = 1
	SliderLabel.Text = "Slider"
	SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	SliderLabel.TextSize = 14
	SliderLabel.Font = Enum.Font.SourceSans
	SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
	SliderLabel.Parent = Slider
	
	-- Combo Prefab
	local Combo = Instance.new("TextButton")
	Combo.Name = "Combo"
	Combo.Size = UDim2.new(1, 0, 0, 25)
	Combo.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	Combo.BorderSizePixel = 0
	Combo.Text = ""
	Combo.Parent = Prefabs
	
	local ComboCorner = Instance.new("UICorner")
	ComboCorner.CornerRadius = UDim.new(0, 4)
	ComboCorner.Parent = Combo
	
	local ComboValueText = Instance.new("TextLabel")
	ComboValueText.Name = "ValueText"
	ComboValueText.Size = UDim2.new(1, -25, 1, 0)
	ComboValueText.Position = UDim2.new(0, 5, 0, 0)
	ComboValueText.BackgroundTransparency = 1
	ComboValueText.Text = "Select..."
	ComboValueText.TextColor3 = Color3.fromRGB(255, 255, 255)
	ComboValueText.TextSize = 14
	ComboValueText.Font = Enum.Font.SourceSans
	ComboValueText.TextXAlignment = Enum.TextXAlignment.Left
	ComboValueText.Parent = Combo
	
	local ComboToggle = Instance.new("Frame")
	ComboToggle.Name = "Toggle"
	ComboToggle.Size = UDim2.new(0, 20, 1, 0)
	ComboToggle.Position = UDim2.new(1, -20, 0, 0)
	ComboToggle.BackgroundTransparency = 1
	ComboToggle.Parent = Combo
	
	local ToggleButton = Instance.new("ImageButton")
	ToggleButton.Name = "ToggleButton"
	ToggleButton.Size = UDim2.new(0, 12, 0, 12)
	ToggleButton.Position = UDim2.new(0.5, 0, 0.5, 0)
	ToggleButton.AnchorPoint = Vector2.new(0.5, 0.5)
	ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ToggleButton.BorderSizePixel = 0
	ToggleButton.Image = ""
	ToggleButton.Parent = ComboToggle
	
	-- Window Prefab
	local Window = Instance.new("Frame")
	Window.Name = "Window"
	Window.Size = UDim2.new(0, 400, 0, 300)
	Window.Position = UDim2.new(0.5, 0, 0.5, 0)
	Window.AnchorPoint = Vector2.new(0.5, 0.5)
	Window.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	Window.BorderSizePixel = 0
	Window.Parent = Prefabs
	
	local WindowCorner = Instance.new("UICorner")
	WindowCorner.CornerRadius = UDim.new(0, 6)
	WindowCorner.Parent = Window
	
	local WindowStroke = Instance.new("UIStroke")
	WindowStroke.Color = Color3.fromRGB(100, 100, 100)
	WindowStroke.Thickness = 1
	WindowStroke.Parent = Window
	
	local Content = Instance.new("Frame")
	Content.Name = "Content"
	Content.Size = UDim2.new(1, 0, 1, 0)
	Content.BackgroundTransparency = 1
	Content.Parent = Window
	
	local ContentLayout = Instance.new("UIListLayout")
	ContentLayout.FillDirection = Enum.FillDirection.Vertical
	ContentLayout.Parent = Content
	
	local WindowTitleBar = Instance.new("Frame")
	WindowTitleBar.Name = "TitleBar"
	WindowTitleBar.Size = UDim2.new(1, 0, 0, 30)
	WindowTitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	WindowTitleBar.BorderSizePixel = 0
	WindowTitleBar.Parent = Content
	
	local TitleBarTopCorner = Instance.new("UICorner")
	TitleBarTopCorner.CornerRadius = UDim.new(0, 6)
	TitleBarTopCorner.Parent = WindowTitleBar
	
	local TitleBarLayout = Instance.new("UIListLayout")
	TitleBarLayout.FillDirection = Enum.FillDirection.Horizontal
	TitleBarLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	TitleBarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	TitleBarLayout.Parent = WindowTitleBar
	
	local TitleBarLeft = Instance.new("Frame")
	TitleBarLeft.Name = "Left"
	TitleBarLeft.Size = UDim2.new(1, -30, 1, 0)
	TitleBarLeft.BackgroundTransparency = 1
	TitleBarLeft.Parent = WindowTitleBar
	
	local TitleBarLeftLayout = Instance.new("UIListLayout")
	TitleBarLeftLayout.FillDirection = Enum.FillDirection.Horizontal
	TitleBarLeftLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	TitleBarLeftLayout.Padding = UDim.new(0, 5)
	TitleBarLeftLayout.Parent = TitleBarLeft
	
	local TitleBarLeftPadding = Instance.new("UIPadding")
	TitleBarLeftPadding.PaddingLeft = UDim.new(0, 10)
	TitleBarLeftPadding.Parent = TitleBarLeft
	
	local WindowToggle = Instance.new("Frame")
	WindowToggle.Name = "Toggle"
	WindowToggle.Size = UDim2.new(0, 15, 0, 15)
	WindowToggle.BackgroundTransparency = 1
	WindowToggle.Parent = TitleBarLeft
	
	local WindowToggleButton = Instance.new("ImageButton")
	WindowToggleButton.Name = "ToggleButton"
	WindowToggleButton.Size = UDim2.new(1, 0, 1, 0)
	WindowToggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	WindowToggleButton.BorderSizePixel = 0
	WindowToggleButton.Image = ""
	WindowToggleButton.Parent = WindowToggle
	
	local WindowTitle = Instance.new("TextLabel")
	WindowTitle.Name = "Title"
	WindowTitle.Size = UDim2.new(1, -20, 1, 0)
	WindowTitle.BackgroundTransparency = 1
	WindowTitle.Text = "Window"
	WindowTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	WindowTitle.TextSize = 14
	WindowTitle.Font = Enum.Font.SourceSansBold
	WindowTitle.TextXAlignment = Enum.TextXAlignment.Left
	WindowTitle.Parent = TitleBarLeft
	
	local WindowClose = Instance.new("TextButton")
	WindowClose.Name = "Close"
	WindowClose.Size = UDim2.new(0, 30, 1, 0)
	WindowClose.BackgroundTransparency = 1
	WindowClose.Text = "×"
	WindowClose.TextColor3 = Color3.fromRGB(255, 100, 100)
	WindowClose.TextSize = 18
	WindowClose.Font = Enum.Font.SourceSansBold
	WindowClose.Parent = WindowTitleBar
	
	local ToolBar = Instance.new("Frame")
	ToolBar.Name = "ToolBar"
	ToolBar.Size = UDim2.new(1, 0, 0, 25)
	ToolBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	ToolBar.BorderSizePixel = 0
	ToolBar.Parent = Content
	
	local ToolBarLayout = Instance.new("UIListLayout")
	ToolBarLayout.FillDirection = Enum.FillDirection.Horizontal
	ToolBarLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	ToolBarLayout.Padding = UDim.new(0, 2)
	ToolBarLayout.Parent = ToolBar
	
	local ToolBarPadding = Instance.new("UIPadding")
	ToolBarPadding.PaddingLeft = UDim.new(0, 5)
	ToolBarPadding.PaddingRight = UDim.new(0, 5)
	ToolBarPadding.Parent = ToolBar
	
	local TabButton = Instance.new("TextButton")
	TabButton.Name = "TabButton"
	TabButton.Size = UDim2.new(0, 80, 1, 0)
	TabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	TabButton.BorderSizePixel = 0
	TabButton.Text = "Tab"
	TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	TabButton.TextSize = 12
	TabButton.Font = Enum.Font.SourceSans
	TabButton.Visible = false
	TabButton.Parent = ToolBar
	
	local TabButtonCorner = Instance.new("UICorner")
	TabButtonCorner.CornerRadius = UDim.new(0, 3)
	TabButtonCorner.Parent = TabButton
	
	local Body = Instance.new("Frame")
	Body.Name = "Body"
	Body.Size = UDim2.new(1, 0, 1, -55)
	Body.BackgroundTransparency = 1
	Body.Parent = Content
	
	local Template = Instance.new("ScrollingFrame")
	Template.Name = "Template"
	Template.Size = UDim2.new(1, 0, 1, 0)
	Template.BackgroundTransparency = 1
	Template.BorderSizePixel = 0
	Template.ScrollBarThickness = 8
	Template.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
	Template.CanvasSize = UDim2.new(0, 0, 0, 0)
	Template.AutomaticCanvasSize = Enum.AutomaticSize.Y
	Template.Visible = false
	Template.Parent = Body
	
	local TemplateLayout = Instance.new("UIListLayout")
	TemplateLayout.FillDirection = Enum.FillDirection.Vertical
	TemplateLayout.Padding = UDim.new(0, 4)
	TemplateLayout.Parent = Template
	
	local TemplatePadding = Instance.new("UIPadding")
	TemplatePadding.PaddingLeft = UDim.new(0, 10)
	TemplatePadding.PaddingRight = UDim.new(0, 10)
	TemplatePadding.PaddingTop = UDim.new(0, 10)
	TemplatePadding.PaddingBottom = UDim.new(0, 10)
	TemplatePadding.Parent = Template
	
	local ResizeGrab = Instance.new("TextButton")
	ResizeGrab.Name = "ResizeGrab"
	ResizeGrab.Size = UDim2.new(0, 15, 0, 15)
	ResizeGrab.Position = UDim2.new(1, -15, 1, -15)
	ResizeGrab.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	ResizeGrab.BorderSizePixel = 0
	ResizeGrab.Text = ""
	ResizeGrab.TextTransparency = 0.6
	ResizeGrab.Parent = Window
	
	return UI
end

-- Create prefabs
local UI = UILibrary:CreatePrefabs()
local Prefabs = UI.Prefabs
UILibrary.Prefabs = Prefabs

-- Simple button creation
function UILibrary:CreateButton(Config)
	Config = Config or {}
	
	local Button = self:CreateInstance("TextButton", Config.Parent, {
		Size = Config.Size or UDim2.new(0, 100, 0, 30),
		Position = Config.Position or UDim2.new(0, 0, 0, 0),
		Text = Config.Text or "Button",
		BackgroundColor3 = Config.BackgroundColor3 or Color3.fromRGB(67, 67, 67),
		TextColor3 = Config.TextColor3 or Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		Font = Enum.Font.SourceSans,
		TextSize = 14
	})

	-- Add corner rounding
	local Corner = self:CreateInstance("UICorner", Button, {
		CornerRadius = UDim.new(0, 4)
	})

	-- Connect callback
	if Config.Callback then
		Button.Activated:Connect(Config.Callback)
	end

	-- Add hover effects
	Button.MouseEnter:Connect(function()
		self:Tween(Button, {BackgroundTransparency = 0.2})
	end)

	Button.MouseLeave:Connect(function()
		self:Tween(Button, {BackgroundTransparency = 0})
	end)

	return Button
end

-- Simple label creation
function UILibrary:CreateLabel(Config)
	Config = Config or {}
	
	local Label = self:CreateInstance("TextLabel", Config.Parent, {
		Size = Config.Size or UDim2.new(0, 100, 0, 20),
		Position = Config.Position or UDim2.new(0, 0, 0, 0),
		Text = Config.Text or "Label",
		BackgroundTransparency = 1,
		TextColor3 = Config.TextColor3 or Color3.fromRGB(255, 255, 255),
		Font = Enum.Font.SourceSans,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	return Label
end

-- Simple window creation
function UILibrary:CreateWindow(Config)
	Config = Config or {}
	
	-- Initialize if not already done
	if not self.Initialised then
		self:Init()
	end

	local Window = self:CreateInstance("Frame", self.Container.Windows, {
		Size = Config.Size or UDim2.new(0, 400, 0, 300),
		Position = Config.Position or UDim2.new(0.5, -200, 0.5, -150),
		BackgroundColor3 = Config.BackgroundColor3 or Color3.fromRGB(45, 45, 45),
		BorderSizePixel = 0
	})

	-- Add corner rounding
	local Corner = self:CreateInstance("UICorner", Window, {
		CornerRadius = UDim.new(0, 6)
	})

	-- Add border
	local Stroke = self:CreateInstance("UIStroke", Window, {
		Color = Color3.fromRGB(100, 100, 100),
		Thickness = 1
	})

	-- Create title bar
	local TitleBar = self:CreateInstance("Frame", Window, {
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundColor3 = Color3.fromRGB(35, 35, 35),
		BorderSizePixel = 0
	})

	-- Title bar corner
	local TitleCorner = self:CreateInstance("UICorner", TitleBar, {
		CornerRadius = UDim.new(0, 6)
	})

	-- Title text
	local Title = self:CreateInstance("TextLabel", TitleBar, {
		Size = UDim2.new(1, -30, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		Text = Config.Title or "Window",
		BackgroundTransparency = 1,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Font = Enum.Font.SourceSansBold,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	-- Close button
	local CloseButton = self:CreateInstance("TextButton", TitleBar, {
		Size = UDim2.new(0, 30, 1, 0),
		Position = UDim2.new(1, -30, 0, 0),
		Text = "×",
		BackgroundTransparency = 1,
		TextColor3 = Color3.fromRGB(255, 100, 100),
		Font = Enum.Font.SourceSansBold,
		TextSize = 18
	})

	-- Content area
	local Content = self:CreateInstance("Frame", Window, {
		Size = UDim2.new(1, -20, 1, -40),
		Position = UDim2.new(0, 10, 0, 35),
		BackgroundTransparency = 1
	})

	-- List layout for content
	local Layout = self:CreateInstance("UIListLayout", Content, {
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0, 4)
	})

	-- Window class
	local WindowClass = {
		Window = Window,
		TitleBar = TitleBar,
		Content = Content,
		Title = Title,
		WindowFrame = Window
	}

	function WindowClass:SetTitle(text)
		Title.Text = tostring(text)
		return self
	end

	function WindowClass:SetVisible(visible)
		Window.Visible = visible
		return self
	end

	function WindowClass:Remove()
		Window:Destroy()
		-- Remove from windows list
		local index = table.find(UILibrary.Windows, self)
		if index then
			table.remove(UILibrary.Windows, index)
		end
	end

	function WindowClass:CreateButton(config)
		config = config or {}
		config.Parent = Content
		return UILibrary:CreateButton(config)
	end

	function WindowClass:CreateLabel(config)
		config = config or {}
		config.Parent = Content
		return UILibrary:CreateLabel(config)
	end

	-- Make draggable
	local dragging = false
	local dragStart = nil
	local startPos = nil

	TitleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = Window.Position
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			Window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	-- Close button functionality
	CloseButton.Activated:Connect(function()
		WindowClass:Remove()
	end)

	-- Add to windows list
	table.insert(self.Windows, WindowClass)

	-- Set up hover detection
	WindowClass.HoverConnection = self:DetectHover(Window)

	return WindowClass
end

return UILibrary
