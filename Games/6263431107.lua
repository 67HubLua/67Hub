local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 300)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleBar

local titleFix = Instance.new("Frame")
titleFix.Size = UDim2.new(1, 0, 0, 10)
titleFix.Position = UDim2.new(0, 0, 1, -10)
titleFix.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
titleFix.BorderSizePixel = 0
titleFix.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -60, 1, 0)
titleText.Position = UDim2.new(0, 10, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "Auto Imposter Scanner"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.TextScaled = true
titleText.Font = Enum.Font.GothamBold
titleText.Parent = titleBar

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 25, 0, 25)
closeButton.Position = UDim2.new(1, -30, 0, 2.5)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
closeButton.BorderSizePixel = 0
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextScaled = true
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 5)
closeCorner.Parent = closeButton

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 20)
statusLabel.Position = UDim2.new(0, 10, 0, 40)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "🔍 Scanning players..."
statusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = mainFrame

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 1, -80)
scrollFrame.Position = UDim2.new(0, 10, 0, 70)
scrollFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 8
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
scrollFrame.Parent = mainFrame

local scrollCorner = Instance.new("UICorner")
scrollCorner.CornerRadius = UDim.new(0, 5)
scrollCorner.Parent = scrollFrame

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.Name
listLayout.Padding = UDim.new(0, 2)
listLayout.Parent = scrollFrame

local playerConnections = {}
local imposterCount = 0

local function createPlayerEntry(targetPlayer)
    local playerFrame = Instance.new("Frame")
    playerFrame.Size = UDim2.new(1, -8, 0, 25)
    playerFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    playerFrame.BorderSizePixel = 0
    playerFrame.Parent = scrollFrame
    
    local entryCorner = Instance.new("UICorner")
    entryCorner.CornerRadius = UDim.new(0, 3)
    entryCorner.Parent = playerFrame
    
    local playerLabel = Instance.new("TextLabel")
    playerLabel.Size = UDim2.new(1, -10, 1, 0)
    playerLabel.Position = UDim2.new(0, 5, 0, 0)
    playerLabel.BackgroundTransparency = 1
    playerLabel.Text = targetPlayer.Name .. " - Unknown"
    playerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    playerLabel.TextScaled = true
    playerLabel.Font = Enum.Font.Gotham
    playerLabel.TextXAlignment = Enum.TextXAlignment.Left
    playerLabel.Parent = playerFrame
    
    return playerFrame, playerLabel
end

local function updatePlayerRole(targetPlayer, playerLabel, playerFrame)
    local roleValue = nil
    local subRoleValue = nil
    
    if targetPlayer.Parent and targetPlayer:FindFirstChild("PublicStates") then
        local publicStates = targetPlayer.PublicStates
        if publicStates:FindFirstChild("Role") and publicStates.Role:IsA("StringValue") then
            roleValue = publicStates.Role.Value
        end
        if publicStates:FindFirstChild("SubRole") and publicStates.SubRole:IsA("StringValue") then
            subRoleValue = publicStates.SubRole.Value
        end
    end
    
    if roleValue then
        local displayText = targetPlayer.Name .. " - " .. roleValue
        if subRoleValue and subRoleValue ~= "" then
            displayText = displayText .. " (" .. subRoleValue .. ")"
        end
        
        if roleValue:lower() == "imposter" then
            playerLabel.Text = "🔴 " .. displayText
            playerLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            playerFrame.BackgroundColor3 = Color3.fromRGB(80, 40, 40)
        else
            playerLabel.Text = "✅ " .. displayText
            playerLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            playerFrame.BackgroundColor3 = Color3.fromRGB(40, 60, 40)
        end
    else
        playerLabel.Text = "❓ " .. targetPlayer.Name .. " - No Role Data"
        playerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        playerFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end
end

local function updateImposterCount()
    imposterCount = 0
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        local roleValue = nil
        if targetPlayer:FindFirstChild("PublicStates") and targetPlayer.PublicStates:FindFirstChild("Role") then
            roleValue = targetPlayer.PublicStates.Role.Value
        end
        if roleValue and roleValue:lower() == "imposter" then
            imposterCount = imposterCount + 1
        end
    end
    
    if imposterCount > 0 then
        statusLabel.Text = "🚨 " .. imposterCount .. " IMPOSTER(S) FOUND!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    else
        statusLabel.Text = "🔍 No imposters detected"
        statusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    end
end

local function setupPlayerMonitoring(targetPlayer)
    if playerConnections[targetPlayer.Name] then return end
    
    local playerFrame, playerLabel = createPlayerEntry(targetPlayer)
    updatePlayerRole(targetPlayer, playerLabel, playerFrame)
    
    playerConnections[targetPlayer.Name] = {}
    
    if targetPlayer:FindFirstChild("PublicStates") then
        local publicStates = targetPlayer.PublicStates
        if publicStates:FindFirstChild("Role") then
            playerConnections[targetPlayer.Name].roleConnection = publicStates.Role.Changed:Connect(function()
                updatePlayerRole(targetPlayer, playerLabel, playerFrame)
                updateImposterCount()
            end)
        end
        if publicStates:FindFirstChild("SubRole") then
            playerConnections[targetPlayer.Name].subRoleConnection = publicStates.SubRole.Changed:Connect(function()
                updatePlayerRole(targetPlayer, playerLabel, playerFrame)
                updateImposterCount()
            end)
        end
        
        playerConnections[targetPlayer.Name].childAddedConnection = publicStates.ChildAdded:Connect(function(child)
            if (child.Name == "Role" or child.Name == "SubRole") and child:IsA("StringValue") then
                updatePlayerRole(targetPlayer, playerLabel, playerFrame)
                updateImposterCount()
            end
        end)
    end
end

local function cleanupPlayerMonitoring(playerName)
    if playerConnections[playerName] then
        for _, connection in pairs(playerConnections[playerName]) do
            if connection then connection:Disconnect() end
        end
        playerConnections[playerName] = nil
    end
    
    local playerFrame = scrollFrame:FindFirstChild(playerName)
    if playerFrame then playerFrame:Destroy() end
end

local function destroyGui()
    for playerName, _ in pairs(playerConnections) do
        cleanupPlayerMonitoring(playerName)
    end
    screenGui:Destroy()
end

closeButton.MouseButton1Click:Connect(destroyGui)

Players.PlayerAdded:Connect(function(newPlayer)
    setupPlayerMonitoring(newPlayer)
    updateImposterCount()
end)

Players.PlayerRemoving:Connect(function(leavingPlayer)
    cleanupPlayerMonitoring(leavingPlayer.Name)
    updateImposterCount()
end)

listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 5)
end)

for _, targetPlayer in pairs(Players:GetPlayers()) do
    setupPlayerMonitoring(targetPlayer)
end
updateImposterCount()
