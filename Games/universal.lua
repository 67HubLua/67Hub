local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local Toggles = Library.Toggles
local Options = Library.Options

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Window = Library:CreateWindow({
	Title = "mspaint",
	Footer = "Walkspeed & ESP v3",
	AutoShow = true,
})

local MainTab = Window:AddTab("Main", "user")

local PlayerBox = MainTab:AddLeftGroupbox("Player")
PlayerBox:AddSlider("WalkSpeed", { Text = "WalkSpeed", Default = 16, Min = 0, Max = 100, Rounding = 0 })
PlayerBox:AddSlider("WalkMultiplier", { Text = "Walk Multiplier", Default = 5, Min = 0.1, Max = 10, Rounding = 1 })
PlayerBox:AddToggle("ToggleWalkspeed", { Text = "Toggle WalkSpeed", Default = false })

local ESPBox = MainTab:AddRightGroupbox("ESP Settings")

ESPBox:AddToggle("ToggleESP", { Text = "Enable Player ESP", Default = false })
ESPBox:AddDropdown("ESP_Type", { Text = "ESP Type", Values = {"Highlight", "SelectionBox", "Text", "SphereAdornment", "CylinderAdornment"}, Default = "Highlight" })
ESPBox:AddSlider("ESP_MaxDistance", { Text = "Max Distance", Default = 1000, Min = 100, Max = 5000 })
ESPBox:AddDivider()

ESPBox:AddLabel("Color Settings")
ESPBox:AddDropdown("ESP_ColorMode", { Text = "Color Mode", Values = {"Team Color", "Default Color"}, Default = "Team Color" })
ESPBox:AddLabel("Default Color"):AddColorPicker("ESP_DefaultColor", { Default = Color3.new(1, 0.2, 0.2) })
ESPBox:AddLabel("SelectionBox Surface"):AddColorPicker("ESP_SurfaceColor", { Default = Color3.new(0, 0.2, 1) })
ESPBox:AddDivider()

ESPBox:AddLabel("Appearance Settings")
ESPBox:AddSlider("ESP_TextSize", { Text = "Text Size", Default = 16, Min = 8, Max = 48, Rounding = 0 })
ESPBox:AddDropdown("ESP_Font", { Text = "Font", Values = {"RobotoCondensed", "SourceSans", "Roboto", "Arial"}, Default = "RobotoCondensed"})
ESPBox:AddLabel("For Highlight Type:")
ESPBox:AddSlider("ESP_FillTransparency", { Text = "Fill Trans", Default = 0.5, Min = 0, Max = 1, Rounding = 2 })
ESPBox:AddSlider("ESP_OutlineTransparency", { Text = "Outline Trans", Default = 0, Min = 0, Max = 1, Rounding = 2 })
ESPBox:AddLabel("For Other Adornments:")
ESPBox:AddSlider("ESP_Thickness", { Text = "Thickness", Default = 0.1, Min = 0, Max = 5, Rounding = 2 })
ESPBox:AddSlider("ESP_Transparency", { Text = "Transparency", Default = 0.65, Min = 0, Max = 1, Rounding = 2 })
ESPBox:AddDivider()

ESPBox:AddLabel("Position Offset")
ESPBox:AddSlider("ESP_OffsetX", { Text = "Offset X", Default = 0, Min = -50, Max = 50, Rounding = 1})
ESPBox:AddSlider("ESP_OffsetY", { Text = "Offset Y", Default = 0, Min = -50, Max = 50, Rounding = 1})
ESPBox:AddSlider("ESP_OffsetZ", { Text = "Offset Z", Default = 0, Min = -50, Max = 50, Rounding = 1})
ESPBox:AddDivider()

ESPBox:AddLabel("Components")
ESPBox:AddToggle("ESP_Tracer",  { Text = "Enable Tracer", Default = true })
ESPBox:AddDropdown("ESP_TracerFrom", {Text = "Tracer Origin", Values = {"Bottom", "Top", "Center", "Mouse"}, Default = "Mouse"})
ESPBox:AddSlider("ESP_TracerThickness", {Text = "Tracer Thickness", Default = 2, Min = 1, Max = 10, Rounding = 0})
ESPBox:AddSlider("ESP_TracerTransparency", {Text = "Tracer Transparency", Default = 0, Min = 0, Max = 1, Rounding = 2})
ESPBox:AddToggle("ESP_Arrow",   { Text = "Enable Arrow", Default = true })
ESPBox:AddSlider("ESP_ArrowCenterOffset", {Text = "Arrow Center Offset", Default = 20, Min = 0, Max = 100, Rounding = 0})
ESPBox:AddDivider()

ESPBox:AddLabel("Global Library Settings")
ESPBox:AddToggle("ESP_Global_Rainbow", {Text = "Enable Rainbow Effect", Default = false})
ESPBox:AddToggle("ESP_Global_Distance", {Text = "Show Distance Text", Default = true})
ESPBox:AddToggle("ESP_Global_IgnoreCharacter", {Text = "Use Camera instead of Character", Default = false})

local Character, Humanoid
local function BindCharacter(char)
    Character = char
    Humanoid = char and char:WaitForChild("Humanoid", 10)
end

if LocalPlayer.Character then BindCharacter(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(BindCharacter)

Toggles.ToggleWalkspeed:OnChanged(function(Value)
	if Value then
		task.spawn(function()
			while Toggles.ToggleWalkspeed.Value do
				local DeltaTime = RunService.Heartbeat:Wait()
				if Character and Humanoid and Humanoid.MoveDirection.Magnitude > 0 then
					Character:TranslateBy(Humanoid.MoveDirection * Options.WalkSpeed.Value * Options.WalkMultiplier.Value * DeltaTime)
				end
			end
		end)
	end
end)

local ESPLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/MSESP/refs/heads/main/source.luau"))()
local espElements = {}
local playerConnections = {}
local espPlayerAdded, espPlayerRemoving

local function GetColor(player)
    if Options.ESP_ColorMode.Value == "Team Color" and player.Team and player.Team.TeamColor then
        return player.Team.TeamColor.Color
    end
    return Options.ESP_DefaultColor.Value
end

local function ClearESP(player)
    if playerConnections[player] then
        for _, conn in ipairs(playerConnections[player]) do conn:Disconnect() end
        playerConnections[player] = nil
    end
    if espElements[player] and typeof(espElements[player].Remove) == "function" then
        pcall(espElements[player].Remove, espElements[player])
    end
    espElements[player] = nil
end

local function UpdateESP(player)
    local espObject = espElements[player]
    if not espObject or not typeof(espObject.CurrentSettings) == "table" then return end
    
    local color = GetColor(player)
    local settings = espObject.CurrentSettings

    settings.Name = player.Name
    settings.Color = color
    settings.MaxDistance = Options.ESP_MaxDistance.Value
    settings.TextSize = Options.ESP_TextSize.Value
    settings.StudsOffset = Vector3.new(Options.ESP_OffsetX.Value, Options.ESP_OffsetY.Value, Options.ESP_OffsetZ.Value)
    settings.Thickness = Options.ESP_Thickness.Value
    settings.Transparency = Options.ESP_Transparency.Value

    if settings.ESPType == "Highlight" then
        settings.FillColor = color
        settings.OutlineColor = color
        settings.FillTransparency = Options.ESP_FillTransparency.Value
        settings.OutlineTransparency = Options.ESP_OutlineTransparency.Value
    end
    if settings.ESPType == "SelectionBox" then
        settings.SurfaceColor = Options.ESP_SurfaceColor.Value
    end

    if not settings.Tracer then settings.Tracer = {} end
    settings.Tracer.Enabled = Toggles.ESP_Tracer.Value
    if Toggles.ESP_Tracer.Value then
        settings.Tracer.Color = color
        settings.Tracer.From = Options.ESP_TracerFrom.Value
        settings.Tracer.Thickness = Options.ESP_TracerThickness.Value
        settings.Tracer.Transparency = Options.ESP_TracerTransparency.Value
    end

    if not settings.Arrow then settings.Arrow = {} end
    settings.Arrow.Enabled = Toggles.ESP_Arrow.Value
    if Toggles.ESP_Arrow.Value then
        settings.Arrow.Color = color
        settings.Arrow.CenterOffset = Options.ESP_ArrowCenterOffset.Value
    end
end

local function AddESP(player)
    if player == LocalPlayer or not ESPLib or not player.Character then return end
    ClearESP(player)
    
    local color = GetColor(player)
    local espSettings = {
        Name = player.Name,
        Model = player.Character,
        Color = color,
        MaxDistance = Options.ESP_MaxDistance.Value,
        ESPType = Options.ESP_Type.Value,
        TextSize = Options.ESP_TextSize.Value,
        StudsOffset = Vector3.new(Options.ESP_OffsetX.Value, Options.ESP_OffsetY.Value, Options.ESP_OffsetZ.Value),
        Thickness = Options.ESP_Thickness.Value,
        Transparency = Options.ESP_Transparency.Value,
        Tracer = { Enabled = Toggles.ESP_Tracer.Value },
        Arrow = { Enabled = Toggles.ESP_Arrow.Value },
    }
    
    local espObject = ESPLib:Add(espSettings)
    if espObject then
        espElements[player] = espObject
        UpdateESP(player)
    end

    playerConnections[player] = { player.CharacterAdded:Connect(function(char)
        task.wait()
        if Toggles.ToggleESP.Value then AddESP(player) end
    end) }
end

local function UpdateEveryone(recreate)
    if not Toggles.ToggleESP.Value then return end
    for player, _ in pairs(espElements) do
        if recreate then AddESP(player) else UpdateESP(player) end
    end
end

local function SetGlobal(setting, value)
    if ESPLib and ESPLib.GlobalConfig then ESPLib.GlobalConfig[setting] = value end
end

Toggles.ESP_Global_Rainbow:OnChanged(function(val) SetGlobal("Rainbow", val) end)
Toggles.ESP_Global_Distance:OnChanged(function(val) SetGlobal("Distance", val) end)
Toggles.ESP_Global_IgnoreCharacter:OnChanged(function(val) SetGlobal("IgnoreCharacter", val) end)
Options.ESP_Font:OnChanged(function(val) SetGlobal("Font", Enum.Font[val]) end)
SetGlobal("Font", Enum.Font[Options.ESP_Font.Value])

local settingsToRecreate = { "ESP_Type" }
local settingsToUpdate = {
    "ESP_MaxDistance", "ESP_ColorMode", "ESP_DefaultColor", "ESP_SurfaceColor", "ESP_TextSize",
    "ESP_FillTransparency", "ESP_OutlineTransparency", "ESP_Thickness", "ESP_Transparency",
    "ESP_OffsetX", "ESP_OffsetY", "ESP_OffsetZ", "ESP_Tracer", "ESP_TracerFrom",
    "ESP_TracerThickness", "ESP_TracerTransparency", "ESP_Arrow", "ESP_ArrowCenterOffset"
}
for _, name in ipairs(settingsToRecreate) do
    local element = Options[name] or Toggles[name]
    if element then element:OnChanged(function() UpdateEveryone(true) end) end
end
for _, name in ipairs(settingsToUpdate) do
    local element = Options[name] or Toggles[name]
    if element then element:OnChanged(function() UpdateEveryone(false) end) end
end

Toggles.ToggleESP:OnChanged(function(Value)
    if not ESPLib then return end
    if Value then
        for _, player in ipairs(Players:GetPlayers()) do AddESP(player) end
        espPlayerAdded = Players.PlayerAdded:Connect(AddESP)
        espPlayerRemoving = Players.PlayerRemoving:Connect(ClearESP)
    else
        if espPlayerAdded then espPlayerAdded:Disconnect(); espPlayerAdded = nil end
        if espPlayerRemoving then espPlayerRemoving:Disconnect(); espPlayerRemoving = nil end
        local playersToClear = {}
        for player, _ in pairs(espElements) do table.insert(playersToClear, player) end
        for _, player in ipairs(playersToClear) do ClearESP(player) end
    end
end)
