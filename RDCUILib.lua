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
}

--// Universal functions
local NullFunction = function() end
local CloneRef = cloneref or function(_)return _ end
local function GetService(...): ServiceProvider
	return CloneRef(game:GetService(...))
end

function ImGui:Warn(...)
	if self.NoWarnings then return end
	return warn("[IMGUI]", ...)
end

--// Services 
local TweenService: TweenService = GetService("TweenService")
local UserInputService: UserInputService = GetService("UserInputService")
local Players: Players = GetService("Players")
local CoreGui = GetService("CoreGui")
local RunService: RunService = GetService("RunService")

--// LocalPlayer
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local Mouse = LocalPlayer:GetMouse()

--// ImGui Config
local IsStudio = RunService:IsStudio()
ImGui.NoWarnings = not IsStudio

--// Create all prefabs programmatically
function ImGui:CreatePrefabs()
	local UI = Instance.new("ScreenGui")
	UI.Name = "DepsoImGui"
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
	
	local Tickbox = Instance.new("TextButton")
        Tickbox.Name = "Tickbox"
        Tickbox.Size = UDim2.new(0, 16, 0, 16)
        Tickbox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        Tickbox.BorderSizePixel = 0
        Tickbox.Text = ""
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
	
	-- Keybind Prefab
	local Keybind = Instance.new("Frame")
	Keybind.Name = "Keybind"
	Keybind.Size = UDim2.new(1, 0, 0, 25)
	Keybind.BackgroundTransparency = 1
	Keybind.Parent = Prefabs
	
	local KeybindLayout = Instance.new("UIListLayout")
	KeybindLayout.FillDirection = Enum.FillDirection.Horizontal
	KeybindLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	KeybindLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	KeybindLayout.Parent = Keybind
	
	local KeybindLabel = Instance.new("TextLabel")
	KeybindLabel.Name = "Label"
	KeybindLabel.Size = UDim2.new(0.7, 0, 1, 0)
	KeybindLabel.BackgroundTransparency = 1
	KeybindLabel.Text = "Keybind"
	KeybindLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	KeybindLabel.TextSize = 14
	KeybindLabel.Font = Enum.Font.SourceSans
	KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
	KeybindLabel.Parent = Keybind
	
	local KeybindValueText = Instance.new("TextButton")
	KeybindValueText.Name = "ValueText"
	KeybindValueText.Size = UDim2.new(0, 60, 0, 20)
	KeybindValueText.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	KeybindValueText.BorderSizePixel = 0
	KeybindValueText.Text = "None"
	KeybindValueText.TextColor3 = Color3.fromRGB(255, 255, 255)
	KeybindValueText.TextSize = 12
	KeybindValueText.Font = Enum.Font.SourceSans
	KeybindValueText.Parent = Keybind
	
	local KeybindCorner = Instance.new("UICorner")
	KeybindCorner.CornerRadius = UDim.new(0, 3)
	KeybindCorner.Parent = KeybindValueText
	
	-- Console Prefab
	local Console = Instance.new("ScrollingFrame")
	Console.Name = "Console"
	Console.Size = UDim2.new(1, 0, 0, 200)
	Console.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	Console.BorderSizePixel = 0
	Console.ScrollBarThickness = 8
	Console.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
	Console.CanvasSize = UDim2.new(0, 0, 0, 0)
	Console.AutomaticCanvasSize = Enum.AutomaticSize.Y
	Console.Parent = Prefabs
	
	local ConsoleCorner = Instance.new("UICorner")
	ConsoleCorner.CornerRadius = UDim.new(0, 4)
	ConsoleCorner.Parent = Console
	
	local Source = Instance.new("TextBox")
	Source.Name = "Source"
	Source.Size = UDim2.new(1, 0, 1, 0)
	Source.BackgroundTransparency = 1
	Source.Text = ""
	Source.TextColor3 = Color3.fromRGB(255, 255, 255)
	Source.TextSize = 12
	Source.Font = Enum.Font.Code
	Source.TextXAlignment = Enum.TextXAlignment.Left
	Source.TextYAlignment = Enum.TextYAlignment.Top
	Source.ClearTextOnFocus = false
	Source.MultiLine = true
	Source.Parent = Console
	
	local ConsolePadding = Instance.new("UIPadding")
	ConsolePadding.PaddingLeft = UDim.new(0, 5)
	ConsolePadding.PaddingRight = UDim.new(0, 5)
	ConsolePadding.PaddingTop = UDim.new(0, 5)
	ConsolePadding.PaddingBottom = UDim.new(0, 5)
	ConsolePadding.Parent = Console
	
	local Lines = Instance.new("TextLabel")
	Lines.Name = "Lines"
	Lines.Size = UDim2.new(0, 30, 1, 0)
	Lines.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	Lines.BorderSizePixel = 0
	Lines.Text = "1"
	Lines.TextColor3 = Color3.fromRGB(150, 150, 150)
	Lines.TextSize = 12
	Lines.Font = Enum.Font.Code
	Lines.TextXAlignment = Enum.TextXAlignment.Center
	Lines.TextYAlignment = Enum.TextYAlignment.Top
	Lines.Visible = false
	Lines.Parent = Console
	
	-- Table Prefab
	local Table = Instance.new("Frame")
	Table.Name = "Table"
	Table.Size = UDim2.new(1, 0, 0, 200)
	Table.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	Table.BorderSizePixel = 0
	Table.Parent = Prefabs
	
	local TableCorner = Instance.new("UICorner")
	TableCorner.CornerRadius = UDim.new(0, 4)
	TableCorner.Parent = Table
	
	local TableLayout = Instance.new("UIListLayout")
	TableLayout.FillDirection = Enum.FillDirection.Vertical
	TableLayout.Padding = UDim.new(0, 2)
	TableLayout.Parent = Table
	
	local TablePadding = Instance.new("UIPadding")
	TablePadding.PaddingLeft = UDim.new(0, 5)
	TablePadding.PaddingRight = UDim.new(0, 5)
	TablePadding.PaddingTop = UDim.new(0, 5)
	TablePadding.PaddingBottom = UDim.new(0, 5)
	TablePadding.Parent = Table
	
	local RowTemp = Instance.new("Frame")
	RowTemp.Name = "RowTemp"
	RowTemp.Size = UDim2.new(1, 0, 0, 25)
	RowTemp.BackgroundTransparency = 1
	RowTemp.Visible = false
	RowTemp.Parent = Table
	
	local RowLayout = Instance.new("UIListLayout")
	RowLayout.FillDirection = Enum.FillDirection.Horizontal
	RowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	RowLayout.Padding = UDim.new(0, 2)
	RowLayout.Parent = RowTemp
	
	local ColumnTemp = Instance.new("Frame")
	ColumnTemp.Name = "ColumnTemp"
	ColumnTemp.Size = UDim2.new(0.33, 0, 1, 0)
	ColumnTemp.BackgroundTransparency = 1
	ColumnTemp.Visible = false
	ColumnTemp.Parent = RowTemp
	
	local ColumnStroke = Instance.new("UIStroke")
	ColumnStroke.Color = Color3.fromRGB(100, 100, 100)
	ColumnStroke.Thickness = 1
	ColumnStroke.Enabled = false
	ColumnStroke.Parent = ColumnTemp
	
	local ColumnLayout = Instance.new("UIListLayout")
	ColumnLayout.FillDirection = Enum.FillDirection.Vertical
	ColumnLayout.Padding = UDim.new(0, 2)
	ColumnLayout.Parent = ColumnTemp
	
	local ColumnPadding = Instance.new("UIPadding")
	ColumnPadding.PaddingLeft = UDim.new(0, 3)
	ColumnPadding.PaddingRight = UDim.new(0, 3)
	ColumnPadding.PaddingTop = UDim.new(0, 2)
	ColumnPadding.PaddingBottom = UDim.new(0, 2)
	ColumnPadding.Parent = ColumnTemp
	
	-- CollapsingHeader Prefab
	local CollapsingHeader = Instance.new("Frame")
	CollapsingHeader.Name = "CollapsingHeader"
	CollapsingHeader.Size = UDim2.new(1, 0, 0, 25)
	CollapsingHeader.BackgroundTransparency = 1
	CollapsingHeader.Parent = Prefabs
	
	local HeaderLayout = Instance.new("UIListLayout")
	HeaderLayout.FillDirection = Enum.FillDirection.Vertical
	HeaderLayout.Parent = CollapsingHeader
	
	local TitleBar = Instance.new("TextButton")
	TitleBar.Name = "TitleBar"
	TitleBar.Size = UDim2.new(1, 0, 0, 25)
	TitleBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	TitleBar.BorderSizePixel = 0
	TitleBar.Text = ""
	TitleBar.Parent = CollapsingHeader
	
	local TitleBarCorner = Instance.new("UICorner")
	TitleBarCorner.CornerRadius = UDim.new(0, 4)
	TitleBarCorner.Parent = TitleBar
	
	local TitleBarLayout = Instance.new("UIListLayout")
	TitleBarLayout.FillDirection = Enum.FillDirection.Horizontal
	TitleBarLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	TitleBarLayout.Padding = UDim.new(0, 5)
	TitleBarLayout.Parent = TitleBar
	
	local TitleBarPadding = Instance.new("UIPadding")
	TitleBarPadding.PaddingLeft = UDim.new(0, 5)
	TitleBarPadding.PaddingRight = UDim.new(0, 5)
	TitleBarPadding.Parent = TitleBar
	
	local HeaderToggle = Instance.new("Frame")
	HeaderToggle.Name = "Toggle"
	HeaderToggle.Size = UDim2.new(0, 15, 0, 15)
	HeaderToggle.BackgroundTransparency = 1
	HeaderToggle.Parent = TitleBar
	
	local HeaderToggleButton = Instance.new("ImageButton")
	HeaderToggleButton.Name = "ToggleButton"
	HeaderToggleButton.Size = UDim2.new(1, 0, 1, 0)
	HeaderToggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	HeaderToggleButton.BorderSizePixel = 0
	HeaderToggleButton.Image = ""
	HeaderToggleButton.Parent = HeaderToggle
	
	local HeaderTitle = Instance.new("TextLabel")
	HeaderTitle.Name = "Title"
	HeaderTitle.Size = UDim2.new(1, -20, 1, 0)
	HeaderTitle.BackgroundTransparency = 1
	HeaderTitle.Text = "Header"
	HeaderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	HeaderTitle.TextSize = 14
	HeaderTitle.Font = Enum.Font.SourceSans
	HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
	HeaderTitle.Parent = TitleBar
	
	local ChildContainer = Instance.new("Frame")
	ChildContainer.Name = "ChildContainer"
	ChildContainer.Size = UDim2.new(1, -10, 0, 0)
	ChildContainer.Position = UDim2.new(0, 5, 0, 0)
	ChildContainer.BackgroundTransparency = 1
	ChildContainer.AutomaticSize = Enum.AutomaticSize.Y
	ChildContainer.Visible = false
	ChildContainer.Parent = CollapsingHeader
	
	local ContainerLayout = Instance.new("UIListLayout")
	ContainerLayout.FillDirection = Enum.FillDirection.Vertical
	ContainerLayout.Padding = UDim.new(0, 4)
	ContainerLayout.Parent = ChildContainer
	
	local ContainerPadding = Instance.new("UIPadding")
	ContainerPadding.PaddingTop = UDim.new(0, 5)
	ContainerPadding.PaddingBottom = UDim.new(0, 5)
	ContainerPadding.Parent = ChildContainer
	
	-- SeparatorText Prefab
	local SeparatorText = Instance.new("Frame")
	SeparatorText.Name = "SeparatorText"
	SeparatorText.Size = UDim2.new(1, 0, 0, 20)
	SeparatorText.BackgroundTransparency = 1
	SeparatorText.Parent = Prefabs
	
	local SeparatorLine = Instance.new("Frame")
	SeparatorLine.Name = "Line"
	SeparatorLine.Size = UDim2.new(1, 0, 0, 1)
	SeparatorLine.Position = UDim2.new(0, 0, 0.5, 0)
	SeparatorLine.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	SeparatorLine.BorderSizePixel = 0
	SeparatorLine.Parent = SeparatorText
	
	local SeparatorTextLabel = Instance.new("TextLabel")
	SeparatorTextLabel.Name = "TextLabel"
	SeparatorTextLabel.Size = UDim2.new(0, 100, 1, 0)
	SeparatorTextLabel.Position = UDim2.new(0.5, 0, 0, 0)
	SeparatorTextLabel.AnchorPoint = Vector2.new(0.5, 0)
	SeparatorTextLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	SeparatorTextLabel.BorderSizePixel = 0
	SeparatorTextLabel.Text = ""
	SeparatorTextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	SeparatorTextLabel.TextSize = 12
	SeparatorTextLabel.Font = Enum.Font.SourceSans
	SeparatorTextLabel.Parent = SeparatorText
	
	-- Row Prefab
	local Row = Instance.new("Frame")
	Row.Name = "Row"
	Row.Size = UDim2.new(1, 0, 0, 25)
	Row.BackgroundTransparency = 1
	Row.Parent = Prefabs
	
	local RowUILayout = Instance.new("UIListLayout")
	RowUILayout.FillDirection = Enum.FillDirection.Horizontal
	RowUILayout.VerticalAlignment = Enum.VerticalAlignment.Center
	RowUILayout.Padding = UDim.new(0, 5)
	RowUILayout.Parent = Row
	
	local RowUIPadding = Instance.new("UIPadding")
	RowUIPadding.Parent = Row
	
	-- ScrollBox Prefab
	local ScrollBox = Instance.new("ScrollingFrame")
	ScrollBox.Name = "ScrollBox"
	ScrollBox.Size = UDim2.new(1, 0, 0, 150)
	ScrollBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	ScrollBox.BorderSizePixel = 0
	ScrollBox.ScrollBarThickness = 8
	ScrollBox.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
	ScrollBox.CanvasSize = UDim2.new(0, 0, 0, 0)
	ScrollBox.AutomaticCanvasSize = Enum.AutomaticSize.Y
	ScrollBox.Parent = Prefabs
	
	local ScrollBoxCorner = Instance.new("UICorner")
	ScrollBoxCorner.CornerRadius = UDim.new(0, 4)
	ScrollBoxCorner.Parent = ScrollBox
	
	local ScrollBoxLayout = Instance.new("UIListLayout")
	ScrollBoxLayout.FillDirection = Enum.FillDirection.Vertical
	ScrollBoxLayout.Padding = UDim.new(0, 4)
	ScrollBoxLayout.Parent = ScrollBox
	
	local ScrollBoxPadding = Instance.new("UIPadding")
	ScrollBoxPadding.PaddingLeft = UDim.new(0, 5)
	ScrollBoxPadding.PaddingRight = UDim.new(0, 5)
	ScrollBoxPadding.PaddingTop = UDim.new(0, 5)
	ScrollBoxPadding.PaddingBottom = UDim.new(0, 5)
	ScrollBoxPadding.Parent = ScrollBox
	
	-- Image Prefab
	local Image = Instance.new("ImageButton")
	Image.Name = "Image"
	Image.Size = UDim2.new(1, 0, 0, 100)
	Image.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	Image.BorderSizePixel = 0
	Image.Image = ""
	Image.ScaleType = Enum.ScaleType.Fit
	Image.Parent = Prefabs
	
	local ImageCorner = Instance.new("UICorner")
	ImageCorner.CornerRadius = UDim.new(0, 4)
	ImageCorner.Parent = Image
	
	-- Viewport Prefab
	local Viewport = Instance.new("Frame")
	Viewport.Name = "Viewport"
	Viewport.Size = UDim2.new(1, 0, 0, 200)
	Viewport.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	Viewport.BorderSizePixel = 0
	Viewport.Parent = Prefabs
	
	local ViewportCorner = Instance.new("UICorner")
	ViewportCorner.CornerRadius = UDim.new(0, 4)
	ViewportCorner.Parent = Viewport
	
	local ViewportFrame = Instance.new("ViewportFrame")
	ViewportFrame.Name = "Viewport"
	ViewportFrame.Size = UDim2.new(1, 0, 1, 0)
	ViewportFrame.BackgroundTransparency = 1
	ViewportFrame.Parent = Viewport
	
	local ViewportFrameCorner = Instance.new("UICorner")
	ViewportFrameCorner.CornerRadius = UDim.new(0, 4)
	ViewportFrameCorner.Parent = ViewportFrame
	
	local WorldModel = Instance.new("WorldModel")
	WorldModel.Name = "WorldModel"
	WorldModel.Parent = ViewportFrame
	
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
	TitleBarLayout.HorizontalAlignment = Enum.HorizontalAlignment.SpaceBetween
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
	
	-- Selection Prefab (for dropdowns)
	local Selection = Instance.new("ScrollingFrame")
	Selection.Name = "Selection"
	Selection.Size = UDim2.new(0, 150, 0, 100)
	Selection.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	Selection.BorderSizePixel = 0
	Selection.ScrollBarThickness = 6
	Selection.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
	Selection.CanvasSize = UDim2.new(0, 0, 0, 0)
	Selection.AutomaticCanvasSize = Enum.AutomaticSize.Y
	Selection.Parent = Prefabs
	
	local SelectionCorner = Instance.new("UICorner")
	SelectionCorner.CornerRadius = UDim.new(0, 4)
	SelectionCorner.Parent = Selection
	
	local SelectionStroke = Instance.new("UIStroke")
	SelectionStroke.Color = Color3.fromRGB(100, 100, 100)
	SelectionStroke.Thickness = 1
	SelectionStroke.Parent = Selection
	
	local SelectionLayout = Instance.new("UIListLayout")
	SelectionLayout.FillDirection = Enum.FillDirection.Vertical
	SelectionLayout.Parent = Selection
	
	local SelectionTemplate = Instance.new("TextButton")
	SelectionTemplate.Name = "Template"
	SelectionTemplate.Size = UDim2.new(1, 0, 0, 25)
	SelectionTemplate.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	SelectionTemplate.BorderSizePixel = 0
	SelectionTemplate.Text = "Item"
	SelectionTemplate.TextColor3 = Color3.fromRGB(255, 255, 255)
	SelectionTemplate.TextSize = 12
	SelectionTemplate.Font = Enum.Font.SourceSans
	SelectionTemplate.Visible = false
	SelectionTemplate.Parent = Selection
	
	-- ModalEffect Prefab
	local ModalEffect = Instance.new("Frame")
	ModalEffect.Name = "ModalEffect"
	ModalEffect.Size = UDim2.new(1, 0, 1, 0)
	ModalEffect.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	ModalEffect.BackgroundTransparency = 0.6
	ModalEffect.BorderSizePixel = 0
	ModalEffect.Parent = Prefabs
	
	-- Create demo rigs
	local R15Rig = Instance.new("Model")
	R15Rig.Name = "R15 Rig"
	R15Rig.Parent = Prefabs
	
	-- Create a simple R15 rig structure
	local Humanoid = Instance.new("Humanoid")
	Humanoid.Parent = R15Rig
	
	local HumanoidRootPart = Instance.new("Part")
	HumanoidRootPart.Name = "HumanoidRootPart"
	HumanoidRootPart.Size = Vector3.new(2, 2, 1)
	HumanoidRootPart.Material = Enum.Material.Plastic
	HumanoidRootPart.BrickColor = BrickColor.new("Medium stone grey")
	HumanoidRootPart.CanCollide = false
	HumanoidRootPart.Anchored = true
	HumanoidRootPart.Parent = R15Rig
	
	local Head = Instance.new("Part")
	Head.Name = "Head"
	Head.Size = Vector3.new(2, 1, 1)
	Head.Material = Enum.Material.Plastic
	Head.BrickColor = BrickColor.new("Light orange")
	Head.CanCollide = false
	Head.Parent = R15Rig
	
	local HeadWeld = Instance.new("WeldConstraint")
	HeadWeld.Part0 = HumanoidRootPart
	HeadWeld.Part1 = Head
	HeadWeld.Parent = Head
	Head.CFrame = HumanoidRootPart.CFrame * CFrame.new(0, 1.5, 0)
	
	return UI
end

--// Create prefabs
local UI = ImGui:CreatePrefabs()
local Prefabs = UI.Prefabs
ImGui.Prefabs = Prefabs
Prefabs.Visible = false

--// Styles
local AddionalStyles = {
	[{
		Name="Border"
	}] = function(GuiObject: GuiObject, Value, Class)
		local Outline = GuiObject:FindFirstChildOfClass("UIStroke")
		if not Outline then return end

		local BorderThickness = Class.BorderThickness
		if BorderThickness then
			Outline.Thickness = BorderThickness
		end

		Outline.Enabled = Value
	end,

	[{
		Name="Ratio"
	}] = function(GuiObject: GuiObject, Value, Class)
		local RatioAxis = Class.RatioAxis or "Height"
		local AspectRatio = Class.Ratio or 4/3
		local AspectType = Class.AspectType or Enum.AspectType.ScaleWithParentSize

		local Ratio = GuiObject:FindFirstChildOfClass("UIAspectRatioConstraint")
		if not Ratio then
			Ratio = ImGui:CreateInstance("UIAspectRatioConstraint", GuiObject)
		end

		Ratio.DominantAxis = Enum.DominantAxis[RatioAxis]
		Ratio.AspectType = AspectType
		Ratio.AspectRatio = AspectRatio
	end,

	[{
		Name="CornerRadius",
		Recursive=true
	}] = function(GuiObject: GuiObject, Value, Class)
		local UICorner = GuiObject:FindFirstChildOfClass("UICorner")
		if not UICorner then
			UICorner = ImGui:CreateInstance("UICorner", GuiObject)
		end

		UICorner.CornerRadius = Class.CornerRadius
	end,

	[{
		Name="Label"
	}] = function(GuiObject: GuiObject, Value, Class)
		local Label = GuiObject:FindFirstChild("Label")
		if not Label then return end

		Label.Text = Class.Label
		function Class:SetLabel(Text)
			Label.Text = Text
			return Class
		end
	end,

	[{
		Name="NoGradient",
		Aliases = {"NoGradientAll"},
		Recursive=true
	}] = function(GuiObject: GuiObject, Value, Class)
		local UIGradient = GuiObject:FindFirstChildOfClass("UIGradient")
		if not UIGradient then return end
		UIGradient.Enabled = not Value
	end,

	--// Addional functions for classes
	[{
		Name="Callback"
	}] = function(GuiObject: GuiObject, Value, Class)
		function Class:SetCallback(NewCallback)
			Class.Callback = NewCallback
			return Class
		end
		function Class:FireCallback(NewCallback)
			return Class.Callback(GuiObject)
		end
	end,

	[{
		Name="Value"
	}] = function(GuiObject: GuiObject, Value, Class)
		function Class:GetValue()
			return Class.Value
		end
	end,
}

function ImGui:GetName(Name: string)
	local Format = "%s_"
	return Format:format(Name)
end

function ImGui:CreateInstance(Class, Parent, Properties)
	local Instance = Instance.new(Class, Parent)
	for Key, Value in next, Properties or {} do
		Instance[Key] = Value
	end
	return Instance
end

function ImGui:ApplyColors(ColorOverwrites, GuiObject: GuiObject, ElementType: string)
	for Info, Value in next, ColorOverwrites do
		local Key = Info
		local Recursive = false

		if typeof(Info) == "table" then
			Key = Info.Name or ""
			Recursive = Info.Recursive or false
		end

		--// Child object
		if typeof(Value) == "table" then
			local Element = GuiObject:FindFirstChild(Key, Recursive)

			if not Element then 
				if ElementType == "Window" then
					Element = GuiObject.Content:FindFirstChild(Key, Recursive)
					if not Element then continue end
				else 
					warn(Key, "was not found in", GuiObject)
					warn("Table:", Value)

					continue
				end
			end

			ImGui:ApplyColors(Value, Element)
			continue
		end

		--// Set property
		GuiObject[Key] = Value
	end
end

function ImGui:CheckStyles(GuiObject: GuiObject, Class, Colors)
	--// Addional styles
	for Info, Callback in next, AddionalStyles do
		local Value = Class[Info.Name]
		local Aliases = Info.Aliases

		if Aliases and not Value then
			for _, Alias in Info.Aliases do
				Value = Class[Alias]
				if Value then break end
			end
		end
		if Value == nil then continue end

		--// Stylise children
		Callback(GuiObject, Value, Class)
		if Info.Recursive then
			for _, Child in next, GuiObject:GetChildren() do
				Callback(Child, Value, Class)
			end
		end
	end

	--// Label functions/Styliser
	local ElementType = GuiObject.Name
	GuiObject.Name = self:GetName(ElementType)

	--// Apply Colors
	local Colors = Colors or {}
	local ColorOverwrites = Colors[ElementType]

	if ColorOverwrites then
		ImGui:ApplyColors(ColorOverwrites, GuiObject, ElementType)
	end

	--// Set properties
	for Key, Value in next, Class do
		pcall(function() --// If the property does not exist
			GuiObject[Key] = Value
		end)
	end
end

function ImGui:MergeMetatables(Class, Instance: GuiObject)
	local Metadata = {}
	Metadata.__index = function(self, Key)
		local suc, Value = pcall(function()
			local Value = Instance[Key]
			if typeof(Value) == "function" then
				return function(...)
					return Value(Instance, ...)
				end
			end
			return Value
		end)
		return suc and Value or Class[Key]
	end

	Metadata.__newindex = function(self, Key, Value)
		local Key2 = Class[Key]
		if Key2 ~= nil or typeof(Value) == "function" then
			Class[Key] = Value
		else
			Instance[Key] = Value
		end
	end

	return setmetatable({}, Metadata)
end

function ImGui:Concat(Table, Separator: " ") 
	local Concatenated = ""
	for Index, String in next, Table do
		Concatenated ..= tostring(String) .. (Index ~= #Table and Separator or "")
	end
	return Concatenated
end

function ImGui:ContainerClass(Frame: Frame, Class, Window)
	local ContainerClass = Class or {}
	local WindowConfig = ImGui.Windows[Window]

	function ContainerClass:NewInstance(Instance: Frame, Class, Parent)
		--// Config
		Class = Class or {}

		--// Set Parent
		Instance.Parent = Parent or Frame
		Instance.Visible = true

		--// TODO
		if WindowConfig and WindowConfig.NoGradientAll then
			Class.NoGradient = true
		end

		local Colors = WindowConfig and WindowConfig.Colors
		ImGui:CheckStyles(Instance, Class, Colors)

		--// External callback check
		if Class.NewInstanceCallback then
			Class.NewInstanceCallback(Instance)
		end

		--// Merge the class with the properties of the instance
		return ImGui:MergeMetatables(Class, Instance)
	end

	function ContainerClass:Button(Config)
		Config = Config or {}
		local Button = Prefabs.Button:Clone()
		local ObjectClass = self:NewInstance(Button, Config)

		local function Callback(...)
			local func = Config.Callback or NullFunction
			return func(ObjectClass, ...)
		end
		Button.Activated:Connect(Callback)

		--// Apply animations
		ImGui:ApplyAnimations(Button, "Buttons")
		return ObjectClass
	end

	function ContainerClass:Image(Config)
		Config = Config or {}
		local Image = Prefabs.Image:Clone()

		--// Check for rbxassetid
		if tonumber(Config.Image) then
			Config.Image = `rbxassetid://{Config.Image}`
		end

		local ObjectClass = self:NewInstance(Image, Config)
		local function Callback(...)
			local func = Config.Callback or NullFunction
			return func(ObjectClass, ...)
		end
		Image.Activated:Connect(Callback)

		--// Apply animations
		ImGui:ApplyAnimations(Image, "Buttons")
		return ObjectClass
	end

	function ContainerClass:ScrollingBox(Config)
		Config = Config or {}
		local Box = Prefabs.ScrollBox:Clone()
		local ContainClass = ImGui:ContainerClass(Box, Config, Window) 
		return self:NewInstance(Box, ContainClass)
	end

	function ContainerClass:Label(Config)
		Config = Config or {}
		local Label = Prefabs.Label:Clone()
		return self:NewInstance(Label, Config)
	end

	function ContainerClass:Checkbox(Config)
		Config = Config or {}
		local IsRadio = Config.IsRadio

		local CheckBox = Prefabs.CheckBox:Clone()
		local Tickbox: ImageButton = CheckBox.Tickbox
		local Tick: ImageLabel = Tickbox.Tick
		local Label = CheckBox.Label
		local ObjectClass = self:NewInstance(CheckBox, Config)

		--// Stylise to correct type
		if IsRadio then
			Tick.ImageTransparency = 1
			Tick.BackgroundTransparency = 0
		else
			local padding = Tickbox:FindFirstChildOfClass("UIPadding")
			if padding then padding:Remove() end
			local corner = Tickbox:FindFirstChildOfClass("UICorner")
			if corner then corner:Remove() end
		end

		--// Apply animations
		ImGui:ApplyAnimations(CheckBox, "Buttons", Tickbox)

		local Value = Config.Value or false

		--// Callback
		local function Callback(...)
			local func = Config.Callback or NullFunction
			return func(ObjectClass, ...)
		end

		function Config:SetTicked(NewValue: boolean, NoAnimation: false)
			Value = NewValue
			Config.Value = Value

			--// Animations
			local Size = Value and UDim2.fromScale(1,1) or UDim2.fromScale(0,0)
			ImGui:Tween(Tick, {
				Size = Size
			}, nil, NoAnimation)
			ImGui:Tween(Label, {
				TextTransparency = Value and 0 or 0.3
			}, nil, NoAnimation)

			--// Fire callback
			Callback(Value)

			return Config
		end
		Config:SetTicked(Value, true)

		function Config:Toggle()
			Config:SetTicked(not Value)
			return Config
		end

		--// Connect functions
		local function Clicked()
			Value = not Value
			Config:SetTicked(Value)
		end
		CheckBox.Activated:Connect(Clicked)
		Tickbox.Activated:Connect(Clicked)

		return ObjectClass
	end

	function ContainerClass:RadioButton(Config)
		Config = Config or {}
		Config.IsRadio = true
		return self:Checkbox(Config)
	end

	function ContainerClass:Viewport(Config)
		Config = Config or {}
		local Model = Config.Model

		local Holder = Prefabs.Viewport:Clone()
		local Viewport: ViewportFrame = Holder.Viewport
		local WorldModel: WorldModel = Viewport.WorldModel
		Config.WorldModel = WorldModel
		Config.Viewport = Viewport

		function Config:SetCamera(Camera)
			Viewport.CurrentCamera = Camera
			Config.Camera = Camera
			Camera.CFrame = CFrame.new(0,0,0)
			return Config
		end

		local Camera = Config.Camera or ImGui:CreateInstance("Camera", Viewport)
		Config:SetCamera(Camera)

		function Config:SetModel(Model: Model, PivotTo: CFrame)
			WorldModel:ClearAllChildren()

			--// Set new model
			if Config.Clone then
				Model = Model:Clone()
			end
			if PivotTo then
				Model:PivotTo(PivotTo)
			end

			Model.Parent = WorldModel
			Config.Model = Model
			return Model
		end

		--// Set model
		if Model then
			Config:SetModel(Model)
		end

		local ContainClass = ImGui:ContainerClass(Holder, Config, Window) 
		return self:NewInstance(Holder, ContainClass)
	end

	function ContainerClass:InputText(Config)
		Config = Config or {}
		local TextInput = Prefabs.TextInput:Clone()
		local TextBox: TextBox = TextInput.Input
		local ObjectClass = self:NewInstance(TextInput, Config)

		TextBox.Text = Config.Value or ""
		TextBox.PlaceholderText = Config.PlaceHolder or ""
		TextBox.MultiLine = Config.MultiLine == true

		--// Apply animations
		ImGui:ApplyAnimations(TextInput, "Inputs")

		local function Callback(...)
			local func = Config.Callback or NullFunction
			return func(ObjectClass, ...)
		end
		TextBox:GetPropertyChangedSignal("Text"):Connect(function()
			local Value = TextBox.Text
			Config.Value = Value
			return Callback(Value)
		end)

		function Config:SetValue(Text)
			TextBox.Text = tostring(Text)
			Config.Value = Text
			return Config
		end

		function Config:Clear()
			TextBox.Text = ""
			return Config
		end

		return ObjectClass
	end

	function ContainerClass:InputTextMultiline(Config)
		Config = Config or {}
		Config.Label = ""
		Config.Size = UDim2.new(1, 0, 0, 38)
		Config.MultiLine = true
		return ContainerClass:InputText(Config)
	end

	function ContainerClass:GetRemainingHeight()
		local Padding = Frame:FindFirstChildOfClass("UIPadding")
		local UIListLayout = Frame:FindFirstChildOfClass("UIListLayout")

		local LayoutPaddding = UIListLayout.Padding
		local PaddingTop = Padding.PaddingTop
		local PaddingBottom = Padding.PaddingBottom

		local PaddingSizeY = PaddingTop+PaddingBottom+LayoutPaddding
		local OccupiedY = Frame.AbsoluteSize.Y+PaddingSizeY.Offset+3

		return UDim2.new(1, 0, 1, -OccupiedY) 
	end

	function ContainerClass:Console(Config)
		Config = Config or {}
		local Console: ScrollingFrame = Prefabs.Console:Clone()
		local Source: TextBox = Console.Source
		local Lines = Console.Lines

		if Config.Fill then
			Console.Size = ContainerClass:GetRemainingHeight()
		end

		--// Set values from config
		Source.TextEditable = Config.ReadOnly ~= true
		Source.Text = Config.Text or ""
		Source.TextWrapped = Config.TextWrapped == true
		Source.RichText = Config.RichText == true
		Lines.Visible = Config.LineNumbers == true

		function Config:UpdateLineNumbers()
			if not Config.LineNumbers then return end

			local LinesCount = #Source.Text:split("\n")
			local Format = Config.LinesFormat or "%s"

			--// Update lines text
			Lines.Text = ""
			for i = 1, LinesCount do
				Lines.Text ..= `{Format:format(i)}{i ~= LinesCount and '\n' or ''}`
			end

			Source.Size = UDim2.new(1, -Lines.AbsoluteSize.X, 0, 0)
			return Config
		end

		function Config:UpdateScroll()
			local CanvasSizeY = Console.AbsoluteCanvasSize.Y
			Console.CanvasPosition = Vector2.new(0, CanvasSizeY)
			return Config
		end

		function Config:SetText(Text)
			if not Config.Enabled then return end
			Source.Text = Text
			Config:UpdateLineNumbers()
			return Config
		end

		function Config:GetValue()
			return Source.Text
		end

		function Config:Clear(Text)
			Source.Text = ""
			Config:UpdateLineNumbers()
			return Config
		end

		function Config:AppendText(...)
			if not Config.Enabled then return end

			local MaxLines = Config.MaxLines or 100
			local NewString = "\n" .. ImGui:Concat({...}, " ") 

			Source.Text ..= NewString
			Config:UpdateLineNumbers()

			if Config.AutoScroll then
				Config:UpdateScroll()
			end

			local Lines = Source.Text:split("\n")
			if #Lines > MaxLines then
				Source.Text = Source.Text:sub(#Lines[1]+2)
			end
			return Config
		end

		--// Connect events
		Source.Changed:Connect(Config.UpdateLineNumbers)

		return self:NewInstance(Console, Config)
	end

	function ContainerClass:Table(Config)
		Config = Config or {}
		local Table: Frame = Prefabs.Table:Clone()
		local TableChildCount = #Table:GetChildren() --// Performance

		--// Configure Table style
		if Config.Fill then
			Table.Size = ContainerClass:GetRemainingHeight()
		end
		local RowName = "Row"

		local RowsCount = 0
		function Config:CreateRow()
			local RowClass = {}

			local Row: Frame = Table.RowTemp:Clone()
			local UIListLayout = Row:FindFirstChildOfClass("UIListLayout")
			UIListLayout.VerticalAlignment = Enum.VerticalAlignment[Config.Align or "Center"]

			local RowChildCount = #Row:GetChildren() --// Performance
			Row.Name = RowName
			Row.Visible = true

			--// Background colors
			if Config.RowBackground then
				Row.BackgroundTransparency = RowsCount % 2 == 1 and 0.92 or 1
			end

			function RowClass:CreateColumn(CConfig)
				CConfig = CConfig or {}
				local Column: Frame = Row.ColumnTemp:Clone()
				Column.Visible = true
				Column.Name = "Column"

				local Stroke = Column:FindFirstChildOfClass("UIStroke")
				Stroke.Enabled = Config.Border ~= false

				local ContainClass = ImGui:ContainerClass(Column, CConfig, Window) 
				return ContainerClass:NewInstance(Column, ContainClass, Row)
			end

			function RowClass:UpdateColumns()
				if not Row or not Table then return end
				local Columns = Row:GetChildren()
				local RowsCount = #Columns - RowChildCount

				for _, Column: Frame in next, Columns do
					if not Column:IsA("Frame") then continue end
					Column.Size = UDim2.new(1/RowsCount, 0, 0, 0)
				end
				return RowClass
			end
			Row.ChildAdded:Connect(RowClass.UpdateColumns)
			Row.ChildRemoved:Connect(RowClass.UpdateColumns)

			RowsCount += 1
			return ContainerClass:NewInstance(Row, RowClass, Table)
		end

		function Config:UpdateRows()
			local Rows = Table:GetChildren()
			local PaddingY = Table.UIListLayout.Padding.Offset + 2
			local RowsCount = #Rows - TableChildCount

			for _, Row: Frame in next, Rows do
				if not Row:IsA("Frame") then continue end
				Row.Size = UDim2.new(1, 0, 1/RowsCount, -PaddingY)
			end
			return Config
		end

		if Config.RowsFill then
			Table.AutomaticSize = Enum.AutomaticSize.None
			Table.ChildAdded:Connect(Config.UpdateRows)
			Table.ChildRemoved:Connect(Config.UpdateRows)
		end

		function Config:ClearRows()
			RowsCount = 0
			local PostRowName = ImGui:GetName(RowName)
			for _, Row: Frame in next, Table:GetChildren() do
				if not Row:IsA("Frame") then continue end

				if Row.Name == PostRowName then
					Row:Remove()
				end
			end
			return Config
		end

		return self:NewInstance(Table, Config) 
	end

	function ContainerClass:Grid(Config)
		Config = Config or {}
		Config.Grid = true

		return self:Table(Config)
	end

	function ContainerClass:CollapsingHeader(Config)
		Config = Config or {}
		local Title = Config.Title or ""
		Config.Name = Title

		local Header = Prefabs.CollapsingHeader:Clone()
		local Titlebar: TextButton = Header.TitleBar
		local Container: Frame = Header.ChildContainer
		Titlebar.Title.Text = Title

		--// Apply animations
		if Config.IsTree then
			ImGui:ApplyAnimations(Titlebar, "Tabs")
		else
			ImGui:ApplyAnimations(Titlebar, "Buttons")
		end

		--// Open Animations
		function Config:SetOpen(Open)
			local Animate = Config.NoAnimation ~= true
			Config.Open = Open
			ImGui:HeaderAnimate(Header, Animate, Open, Titlebar)
			return self
		end

		--// Toggle
		local ToggleButton = Titlebar.Toggle.ToggleButton
		local function Toggle()
			Config:SetOpen(not Config.Open)
		end
		Titlebar.Activated:Connect(Toggle)
		ToggleButton.Activated:Connect(Toggle)

		--// Custom toggle image
		if Config.Image then
			ToggleButton.Image = Config.Image 
		end

		--// Open
		Config:SetOpen(Config.Open or false)

		local ContainClass = ImGui:ContainerClass(Container, Config, Window) 
		return self:NewInstance(Header, ContainClass)
	end

	function ContainerClass:TreeNode(Config)
		Config = Config or {}
		Config.IsTree = true
		return self:CollapsingHeader(Config)
	end

	function ContainerClass:Separator(Config)
		Config = Config or {}
		local Separator = Prefabs.SeparatorText:Clone()
		local HeaderLabel = Separator.TextLabel
		HeaderLabel.Text = Config.Text or ""

		if not Config.Text then
			HeaderLabel.Visible = false
		end

		return self:NewInstance(Separator, Config)
	end

	function ContainerClass:Row(Config)
		Config = Config or {}
		local Row: Frame = Prefabs.Row:Clone()
		local UIListLayout = Row:FindFirstChildOfClass("UIListLayout")
		local UIPadding = Row:FindFirstChildOfClass("UIPadding")

		if Config.Spacing then
			UIListLayout.Padding = UDim.new(0, Config.Spacing)
		end

		function Config:Fill()
			local Children = Row:GetChildren()
			local Rows = #Children - 2 --// -UIListLayout + UIPadding

			--// Change layout
			local Padding = UIListLayout.Padding.Offset * 2
			UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

			--// Apply correct margins
			UIPadding.PaddingLeft = UIListLayout.Padding
			UIPadding.PaddingRight = UIListLayout.Padding

			for _, Child: Instance in next, Children do
				local YScale = 0
				if Child:IsA("ImageButton") then
					YScale = 1
				end
				pcall(function()
					Child.Size = UDim2.new(1/Rows, -Padding, YScale, 0)
				end)
			end
			return Config
		end

		local ContainClass = ImGui:ContainerClass(Row, Config, Window) 
		return self:NewInstance(Row, ContainClass)
	end

	function ContainerClass:Slider(Config)
		Config = Config or {}
		
		--// Unpack config
		local Value = Config.Value or 0
		local ValueFormat = Config.Format or "%.d"
		local IsProgress = Config.Progress
		Config.Name = Config.Label or ""
		
		--// Slider element
		local Slider: TextButton = Prefabs.Slider:Clone()
		local UIPadding = Slider:FindFirstChildOfClass("UIPadding")
		local Grab: Frame = Slider.Grab
		local ValueText = Slider.ValueText
		local Label = Slider.Label
		
		--// Input data
		local Dragging = false
		local MouseMoveConnection = nil
		local InputType = Enum.UserInputType.MouseButton1
		
		local ObjectClass = self:NewInstance(Slider, Config)

		local function Callback(...)
			local func = Config.Callback or NullFunction
			return func(ObjectClass, ...)
		end

		--// Apply Progress styles
		if IsProgress then
			local UIGradient = Grab:FindFirstChildOfClass("UIGradient")

			local PaddingSides = UDim.new(0,2)
			local Diff = UIPadding.PaddingLeft - PaddingSides

			Grab.AnchorPoint = Vector2.new(0, 0.5)
			if UIGradient then
				UIGradient.Enabled = true
			end

			UIPadding.PaddingLeft = PaddingSides
			UIPadding.PaddingRight = PaddingSides

			Label.Position = UDim2.new(1, 15-Diff.Offset, 0, 0)
		end

		function Config:SetValue(Value: number, Slider: false)
			local MinValue = Config.MinValue or 0
			local MaxValue = Config.MaxValue or 100
			local Difference = MaxValue - MinValue
			local Percentage = (Value - MinValue) / Difference

			if not Slider then
				Value = tonumber(Value)
			else
				Percentage = Value
				Value = MinValue + (Difference * Percentage)
			end

			--// Animate grab
			local Props = {
				Position = UDim2.fromScale(Percentage, 0.5)
			}

			if IsProgress then
				Props = {
					Size = UDim2.fromScale(Percentage, 1)
				}
			end

			--// Animate
			ImGui:Tween(Grab, Props)

			--// Update UI
			Config.Value = Value
			ValueText.Text = ValueFormat:format(Value, MaxValue) 

			--// Fire callback
			Callback(Value)

			return Config
		end

		------// Move events
		local function MouseMove()
			if Config.ReadOnly then return end
			if not Dragging then return end
			
			local MouseX = UserInputService:GetMouseLocation().X
			local LeftPos = Slider.AbsolutePosition.X

			local Percentage = (MouseX-LeftPos)/Slider.AbsoluteSize.X
			Percentage = math.clamp(Percentage, 0, 1)
			Config:SetValue(Percentage, true)
		end

		local function InputEnded(inputObject)
			if not Dragging then return end
			if inputObject.UserInputType ~= InputType then return end

			Dragging = false
			if MouseMoveConnection then
				MouseMoveConnection:Disconnect()
			end
		end

		--// Connect mouse events
		ImGui:ConnectHover({
			Parent = Slider,
			OnInput = function(MouseHovering, Input)
				if not MouseHovering then return end
				if Input.UserInputType ~= InputType then return end

				Dragging = true
				MouseMoveConnection = Mouse.Move:Connect(MouseMove) --// Save heavy performance
			end
		})

		--// Connect events
		Slider.Activated:Connect(MouseMove)
		UserInputService.InputEnded:Connect(InputEnded)

		--// Update UI
		Config:SetValue(Value)

		return ObjectClass
	end

	function ContainerClass:ProgressSlider(Config)
		Config = Config or {}
		Config.Progress = true
		return self:Slider(Config)
	end

	function ContainerClass:ProgressBar(Config)
		Config = Config or {}
		Config.Progress = true
		Config.ReadOnly = true
		Config.MinValue = 0
		Config.MaxValue = 100
		Config.Format = "% i%%"
		Config = self:Slider(Config)

		function Config:SetPercentage(Value: number)
			Config:SetValue(Value)
		end

		return Config
	end

	function ContainerClass:Keybind(Config)
		Config = Config or {}

		local Key = Config.Value
		local TobeNullKey = Config.NullKey or Enum.KeyCode.Backspace

		local Keybind: Frame = Prefabs.Keybind:Clone()
		local ValueText: TextButton = Keybind.ValueText

		local ObjectClass = nil
		local function Callback(...)
			local func = Config.Callback or NullFunction
			return func(ObjectClass, ...)
		end

		function Config:SetValue(NewKey: Enum.KeyCode)
			if not NewKey then return end

			if NewKey == TobeNullKey then
				ValueText.Text = "Not set"
				Config.Value = nil
			else
				ValueText.Text = NewKey.Name
				Config.Value = NewKey
			end
		end

		ValueText.Activated:Connect(function()
			ValueText.Text = "..."

			local NewKey = UserInputService.InputBegan:Wait()
			if not UserInputService.WindowFocused then return end 

			--// Reset back to previous if unknown
			local Previous = Config.Value
			if NewKey.KeyCode.Name == "Unknown" then
				return Config:SetValue(Previous)
			end

			wait(.1) --// 👍
			Config:SetValue(NewKey.KeyCode)
		end)

		Config.Connection = UserInputService.InputBegan:Connect(function(Input, GameProcessed)
			if not Config.IgnoreGameProcessed and GameProcessed then return end
			local KeyCode = Input.KeyCode
			local Match = Config.Value

			if KeyCode == TobeNullKey then return end
			if KeyCode ~= Match then return end 

			return Callback(Input.KeyCode)
		end)

		--// Update UI
		Config:SetValue(Key)

		ObjectClass = self:NewInstance(Keybind, Config)
		return ObjectClass
	end

	function ContainerClass:Combo(Config)
		Config = Config or {}
		Config.Open = false
		Config.Value = ""

		local Combo: TextButton = Prefabs.Combo:Clone()
		local Toggle: ImageButton = Combo.Toggle.ToggleButton
		local ValueText = Combo.ValueText
		ValueText.Text = Config.Placeholder or ""

		local Dropdown = nil
		local ObjectClass = self:NewInstance(Combo, Config)

		local ComboHovering = ImGui:ConnectHover({
			Parent = Combo
		})

		local function Callback(Value, ...)
			local func = Config.Callback or NullFunction
			Config:SetOpen(false)
			return func(ObjectClass, Value, ...)
		end

		function Config:SetValue(Value, ...)
			local Items = Config.Items or {}
			local DictValue = Items[Value]
			ValueText.Text = tostring(Value)
			Config.Value = Value

			return Callback(DictValue or Value) 
		end

		function Config:SetOpen(Open: true)
			local Animate = Config.NoAnimation ~= true
			ImGui:HeaderAnimate(Combo, Animate, Open, Combo, Toggle)
			Config.Open = Open

			if Open then
				Dropdown = ImGui:Dropdown({
					Parent = Combo,
					Items = Config.Items or {},
					SetValue = Config.SetValue,
					Closed = function()
						if not ComboHovering.Hovering then 
							Config:SetOpen(false)
						end
					end,
				})
			end

			return self
		end

		local function ToggleOpen()
			if Dropdown then
				Dropdown:Close()
			end
			Config:SetOpen(not Config.Open)
		end

		--// Connect events
		Combo.Activated:Connect(ToggleOpen)
		Toggle.Activated:Connect(ToggleOpen)
		ImGui:ApplyAnimations(Combo, "Buttons")

		if Config.Selected then
			Config:SetValue(Config.Selected)
		end

		return ObjectClass 
	end

	return ContainerClass
end

function ImGui:Dropdown(Config)
	local Parent: GuiObject = Config.Parent
	if not Parent then return end

	local Selection: ScrollingFrame = Prefabs.Selection:Clone()
	local UIStroke = Selection:FindFirstChildOfClass("UIStroke")

	local Padding = UIStroke.Thickness*2
	local Position = Parent.AbsolutePosition
	local Size = Parent.AbsoluteSize

	Selection.Parent = self.ScreenGui
	Selection.Position = UDim2.fromOffset(Position.X+Padding, Position.Y+Size.Y)

	local Hover = self:ConnectHover({
		Parent = Selection,
		OnInput = function(MouseHovering, Input)
			if not Input.UserInputType.Name:find("Mouse") then return end

			if not MouseHovering then
				Config:Close()
			end
		end,
	})

	function Config:Close()
		local CloseCallback = Config.Closed
		if CloseCallback then
			CloseCallback()
		end

		Hover:Disconnect()
		Selection:Remove()
	end

	local function SetValue(Value)
		Config:Close()
		Config:SetValue(Value)
	end

	--// Append items
	local ItemTemplate: TextButton = Selection.Template
	ItemTemplate.Visible = false

	for Index, Index2 in next, Config.Items do
		local Value = typeof(Index) ~= "number" and Index or Index2

		local NewItem: TextButton = ItemTemplate:Clone()
		NewItem.Text = tostring(Value)
		NewItem.Parent = Selection
		NewItem.Visible = true
		NewItem.Activated:Connect(function()
			return SetValue(Value)
		end)

		self:ApplyAnimations(NewItem, "Tabs")
	end

	--// Configure size of the frame
	-- Roblox does not support UISizeConstraint on a scrolling frame grr

	local MaxSizeY = Config.MaxSizeY or 200
	local YSize = math.clamp(Selection.AbsoluteCanvasSize.Y, Size.Y, MaxSizeY)
	Selection.Size = UDim2.fromOffset(Size.X-Padding, YSize)

	return Config
end

function ImGui:GetAnimation(Animation: boolean?)
	return Animation and self.Animation or TweenInfo.new(0)
end

function ImGui:Tween(Instance: GuiObject, Props: SharedTable, tweenInfo, NoAnimation: false)
	local tweenInfo = tweenInfo or ImGui:GetAnimation(not NoAnimation)
	local Tween = TweenService:Create(Instance, 
		tweenInfo,
		Props
	)
	Tween:Play()
	return Tween
end

function ImGui:ApplyAnimations(Instance: GuiObject, Class: string, Target: GuiObject?)
	local Animatons = ImGui.Animations
	local ColorProps = Animatons[Class]

	if not ColorProps then 
		return warn("No colors for", Class)
	end

	--// Apply tweens for connections
	local Connections = {}
	for Connection, Props in next, ColorProps do
		if typeof(Props) ~= "table" then continue end
		local Target = Target or Instance
		local Callback = function()
			ImGui:Tween(Target, Props)
		end

		--// Connections
		Connections[Connection] = Callback
		Instance[Connection]:Connect(Callback)
	end

	--// Reset colors
	if Connections["MouseLeave"] then
		Connections["MouseLeave"]()
	end

	return Connections 
end

function ImGui:HeaderAnimate(Header: Instance, Animation, Open, TitleBar: Instance, Toggle)
	local ToggleButtion = Toggle or TitleBar.Toggle.ToggleButton

	--// Togle animation
	ImGui:Tween(ToggleButtion, {
		Rotation = Open and 90 or 0,
	}):Play()

	--// Container animation
	local Container: Frame = Header:FindFirstChild("ChildContainer")
	if not Container then return end

	local UIListLayout: UIListLayout = Container.UIListLayout
	local UIPadding: UIPadding = Container:FindFirstChildOfClass("UIPadding")
	local ContentSize = UIListLayout.AbsoluteContentSize

	if UIPadding then
		local Top = UIPadding.PaddingTop.Offset
		local Bottom = UIPadding.PaddingBottom.Offset
		ContentSize = Vector2.new(ContentSize.X, ContentSize.Y+Top+Bottom)
	end

	Container.AutomaticSize = Enum.AutomaticSize.None
	if not Open then
		Container.Size = UDim2.new(1, -10, 0, ContentSize.Y)
	end

	--// Animate
	local Tween = ImGui:Tween(Container, {
		Size = UDim2.new(1, -10, 0, Open and ContentSize.Y or 0),
		Visible = Open
	})
	Tween.Completed:Connect(function()
		if not Open then return end
		Container.AutomaticSize = Enum.AutomaticSize.Y
		Container.Size = UDim2.new(1, -10, 0, 0)
	end)
end

function ImGui:ApplyDraggable(Frame: Frame, Header: Frame)
	local tweenInfo = ImGui:GetAnimation(true)
	local Header = Header or Frame

	local Dragging = false
	local KeyBeganPos = nil
	local BeganPos = Frame.Position

	--// Whitelist
	local UserInputTypes = {
		Enum.UserInputType.MouseButton1,
		Enum.UserInputType.Touch
	}

	local function UserInputTypeAllowed(InputType: Enum.UserInputType)
		return table.find(UserInputTypes, InputType)
	end

	--// Debounce 
	Header.InputBegan:Connect(function(Key)
		if UserInputTypeAllowed(Key.UserInputType) then
			Dragging = true
			KeyBeganPos = Key.Position
			BeganPos = Frame.Position
		end
	end)

	UserInputService.InputEnded:Connect(function(Key)
		if UserInputTypeAllowed(Key.UserInputType) then
			Dragging = false
		end
	end)

	--// Dragging
	local function Movement(Input)
		if not Dragging then return end

		local Delta = Input.Position - KeyBeganPos
		local Position = UDim2.new(
			BeganPos.X.Scale, 
			BeganPos.X.Offset + Delta.X, 
			BeganPos.Y.Scale, 
			BeganPos.Y.Offset + Delta.Y
		)

		ImGui:Tween(Frame, {
			Position = Position
		}):Play()
	end

	--// Connect movement events
	UserInputService.TouchMoved:Connect(Movement)
	UserInputService.InputChanged:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement then 
			return Movement(Input)
		end
	end)
end


function ImGui:ApplyResizable(MinSize, Frame: Frame, Dragger: TextButton, Config)
	local DragStart
	local OrignialSize

	MinSize = MinSize or Vector2.new(160, 90)

	Dragger.MouseButton1Down:Connect(function()
		if DragStart then return end
		OrignialSize = Frame.AbsoluteSize			
		DragStart = Vector2.new(Mouse.X, Mouse.Y)
	end)	

	UserInputService.InputChanged:Connect(function(Input)
		if not DragStart or Input.UserInputType ~= Enum.UserInputType.MouseMovement then 
			return
		end

		local MousePos = Vector2.new(Mouse.X, Mouse.Y)
		local mouseMoved = MousePos - DragStart

		local NewSize = OrignialSize + mouseMoved
		NewSize = UDim2.fromOffset(
			math.max(MinSize.X, NewSize.X), 
			math.max(MinSize.Y, NewSize.Y)
		)

		Frame.Size = NewSize
		if Config then
			Config.Size = NewSize
		end
	end)

	UserInputService.InputEnded:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			DragStart = nil
		end
	end)	
end

function ImGui:ConnectHover(Config)
	local Parent = Config.Parent
	local Connections = {}
	Config.Hovering = false

	--// Connect Events
	table.insert(Connections, Parent.MouseEnter:Connect(function()
		Config.Hovering = true
	end))
	table.insert(Connections, Parent.MouseLeave:Connect(function()
		Config.Hovering = false
	end))

	if Config.OnInput then
		table.insert(Connections, UserInputService.InputBegan:Connect(function(Input)
			return Config.OnInput(Config.Hovering, Input)
		end))
	end

	function Config:Disconnect()
		for _, Connection in next, Connections do
			Connection:Disconnect()
		end
	end

	return Config
end

function ImGui:ApplyWindowSelectEffect(Window: GuiObject, TitleBar)
	local UIStroke = Window:FindFirstChildOfClass("UIStroke")

	local Colors = {
		Selected = {
			BackgroundColor3 = TitleBar.BackgroundColor3
		},
		Deselected = {
			BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		}
	}

	local function SetSelected(Selected)
		local Animations = ImGui.Animations
		local Type = Selected and "Selected" or "Deselected"
		local TweenInfo = ImGui:GetAnimation(true) 

		ImGui:Tween(TitleBar, Colors[Type])
		ImGui:Tween(UIStroke, Animations.WindowBorder[Type])
	end

	self:ConnectHover({
		Parent = Window,
		OnInput = function(MouseHovering, Input)
			if Input.UserInputType.Name:find("Mouse") then
				SetSelected(MouseHovering)
			end
		end,
	})
end

function ImGui:SetWindowProps(Properties, IgnoreWindows)
	local Module = {
		OldProperties = {}
	}

	--// Collect windows & set properties
	for Window in next, ImGui.Windows do
		if table.find(IgnoreWindows or {}, Window) then continue end

		local OldValues = {}
		Module.OldProperties[Window] = OldValues

		for Key, Value in next, Properties do
			OldValues[Key] = Window[Key]
			Window[Key] = Value
		end
	end

	--// Revert to previous values
	function Module:Revert()
		for Window in next, ImGui.Windows do
			local OldValues = Module.OldProperties[Window]
			if not OldValues then continue end

			for Key, Value in next, OldValues do
				Window[Key] = Value
			end
		end
	end

	return Module
end

function ImGui:CreateWindow(WindowConfig)
	--// Create Window frame
	local Window: Frame = Prefabs.Window:Clone()
	Window.Parent = ImGui.ScreenGui
	Window.Visible = true
	WindowConfig.Window = Window

	local Content = Window.Content
	local Body = Content.Body

	--// Window Resize
	local Resize = Window.ResizeGrab
	Resize.Visible = WindowConfig.NoResize ~= true

	local MinSize = WindowConfig.MinSize or Vector2.new(160, 90)
	ImGui:ApplyResizable(
		MinSize, 
		Window, 
		Resize,
		WindowConfig
	)

	--// Title Bar
	local TitleBar: Frame = Content.TitleBar
	TitleBar.Visible = WindowConfig.NoTitleBar ~= true

	local Toggle = TitleBar.Left.Toggle
	Toggle.Visible = WindowConfig.NoCollapse ~= true
	ImGui:ApplyAnimations(Toggle.ToggleButton, "Tabs")

	local ToolBar = Content.ToolBar
	ToolBar.Visible = WindowConfig.TabsBar ~= false

	if not WindowConfig.NoDrag then
		ImGui:ApplyDraggable(Window)
	end

	--// Close Window 
	local CloseButton: TextButton = TitleBar.Close
	CloseButton.Visible = WindowConfig.NoClose ~= true

	function WindowConfig:Close()
		local Callback = WindowConfig.CloseCallback
		WindowConfig:SetVisible(false)
		if Callback then
			Callback(WindowConfig)
		end
		return WindowConfig
	end
	CloseButton.Activated:Connect(WindowConfig.Close)

	function WindowConfig:GetHeaderSizeY(): number
		local ToolbarY = ToolBar.Visible and ToolBar.AbsoluteSize.Y or 0
		local TitlebarY = TitleBar.Visible and TitleBar.AbsoluteSize.Y or 0
		return ToolbarY + TitlebarY
	end

	function WindowConfig:UpdateBody()
		local HeaderSizeY = self:GetHeaderSizeY()
		Body.Size = UDim2.new(1, 0, 1, -HeaderSizeY)
	end
	WindowConfig:UpdateBody()

	--// Open/Close
	WindowConfig.Open = true
	function WindowConfig:SetOpen(Open: true, NoAnimation: false)
		local WindowAbSize = Window.AbsoluteSize 
		local TitleBarSize = TitleBar.AbsoluteSize 

		self.Open = Open

		--// Call animations
		ImGui:HeaderAnimate(TitleBar, true, Open, TitleBar, Toggle.ToggleButton)
		ImGui:Tween(Resize, {
			TextTransparency = Open and 0.6 or 1,
			Interactable = Open
		}, nil, NoAnimation)
		ImGui:Tween(Window, {
			Size = Open and self.Size or UDim2.fromOffset(WindowAbSize.X, TitleBarSize.Y)
		}, nil, NoAnimation)
		ImGui:Tween(Body, {
			Visible = Open
		}, nil, NoAnimation)
		return self
	end

	function WindowConfig:SetVisible(Visible: boolean)
		Window.Visible = Visible 
		return self
	end

	function WindowConfig:SetTitle(Text)
		TitleBar.Left.Title.Text = tostring(Text)
		return self
	end
	function WindowConfig:Remove()
		Window:Remove()
		return self
	end

	Toggle.ToggleButton.Activated:Connect(function()
		local Open = not WindowConfig.Open
		WindowConfig.Open = Open
		return WindowConfig:SetOpen(Open)
	end)	

	function WindowConfig:CreateTab(Config)
		local Name = Config.Name or ""
		local TabButton = ToolBar.TabButton:Clone()
		TabButton.Name = Name
		TabButton.Text = Name
		TabButton.Visible = true
		TabButton.Parent = ToolBar
		Config.Button = TabButton

		local AutoSizeAxis = WindowConfig.AutoSize or "Y"
		local Content: Frame = Body.Template:Clone()
		Content.AutomaticSize = Enum.AutomaticSize[AutoSizeAxis]
		Content.Visible = Config.Visible or false
		Content.Name = Name
		Content.Parent = Body
		Config.Content = Content

		if AutoSizeAxis == "Y" then
			Content.Size = UDim2.fromScale(1, 0)
		elseif AutoSizeAxis == "X" then
			Content.Size = UDim2.fromScale(0, 1)
		end

		TabButton.Activated:Connect(function()
			WindowConfig:ShowTab(Config)
		end)

		function Config:GetContentSize()
			return Content.AbsoluteSize
		end

		--// Apply animations
		Config = ImGui:ContainerClass(Content, Config, Window)
		ImGui:ApplyAnimations(TabButton, "Tabs")

		--// Automatic sizes
		self:UpdateBody()
		if WindowConfig.AutoSize then
			Content:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
				local Size = Config:GetContentSize()
				self:SetSize(Size)
			end)
		end

		return Config
	end

	function WindowConfig:SetPosition(Position)
		Window.Position = Position
		return self
	end

	function WindowConfig:SetSize(Size)
		local HeaderSizeY = self:GetHeaderSizeY()

		if typeof(Size) == "Vector2" then
			Size = UDim2.fromOffset(Size.X, Size.Y)
		end

		--// Apply new size
		local NewSize = UDim2.new(
			Size.X.Scale,
			Size.X.Offset,
			Size.Y.Scale,
			Size.Y.Offset + HeaderSizeY
		)
		self.Size = NewSize
		Window.Size = NewSize

		return self
	end

	--// Tab change system 
	function WindowConfig:ShowTab(TabClass: SharedTable)
		local TargetPage: Frame = TabClass.Content

		--// Page animation
		if not TargetPage.Visible and not TabClass.NoAnimation then
			TargetPage.Position = UDim2.fromOffset(0, 5)
		end

		--// Hide other tabs
		for _, Page in next, Body:GetChildren() do
			Page.Visible = Page == TargetPage
		end

		--// Page animation
		ImGui:Tween(TargetPage, {
			Position = UDim2.fromOffset(0, 0)
		})
		return self
	end

	function WindowConfig:Center() --// Without an Anchor point
		local Size = Window.AbsoluteSize
		local Position = UDim2.new(0.5,-Size.X/2,0.5,-Size.Y/2)
		self:SetPosition(Position)
		return self
	end

	--// Load Style Configs
	WindowConfig:SetTitle(WindowConfig.Title or "Depso UI")

	if not WindowConfig.Open then
		WindowConfig:SetOpen(WindowConfig.Open or true, true)
	end

	ImGui.Windows[Window] = WindowConfig
	ImGui:CheckStyles(Window, WindowConfig, WindowConfig.Colors)

	--// Window section events
	if not WindowConfig.NoSelectEffect then
		ImGui:ApplyWindowSelectEffect(Window, TitleBar)
	end

	return ImGui:MergeMetatables(WindowConfig, Window)
end

function ImGui:CreateModal(Config)
	local ModalEffect = Prefabs.ModalEffect:Clone()
	ModalEffect.BackgroundTransparency = 1
	ModalEffect.Parent = ImGui.FullScreenGui
	ModalEffect.Visible = true

	ImGui:Tween(ModalEffect, {
		BackgroundTransparency = 0.6
	})

	--// Config
	Config = Config or {}
	Config.TabsBar = Config.TabsBar ~= nil and Config.TabsBar or false
	Config.NoCollapse = true
	Config.NoResize = true
	Config.NoClose = true
	Config.NoSelectEffect = true
	Config.Parent = ModalEffect

	--// Center
	Config.AnchorPoint = Vector2.new(0.5, 0.5)
	Config.Position = UDim2.fromScale(0.5, 0.5)

	--// Create Window
	local Window = self:CreateWindow(Config)
	Config = Window:CreateTab({
		Visible = true
	})

	--// Disable other windows
	local WindowManger = ImGui:SetWindowProps({
		Interactable = false
	}, {Window.Window})

	--// Close functions
	local WindowClose = Window.Close
	function Config:Close()
		local Tween = ImGui:Tween(ModalEffect, {
			BackgroundTransparency = 1
		})
		Tween.Completed:Connect(function()
			ModalEffect:Remove()
		end)

		WindowManger:Revert()
		WindowClose()
	end

	return Config
end

local GuiParent = IsStudio and PlayerGui or CoreGui
ImGui.ScreenGui = ImGui:CreateInstance("ScreenGui", GuiParent, {
	DisplayOrder = 9999,
	ResetOnSpawn = false
})
ImGui.FullScreenGui = ImGui:CreateInstance("ScreenGui", GuiParent, {
	DisplayOrder = 99999,
	ResetOnSpawn = false,
	ScreenInsets = Enum.ScreenInsets.None
})

return ImGui
