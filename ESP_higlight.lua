-- LocalScript: Place this in StarterPlayerScripts
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

-- Variable to control ESP state
local isESPEnabled = true

-- Function to create and apply a Highlight and Username display to a player's character
local function applyHighlight(character, player)
    -- Skip the LocalPlayer
    if player == Players.LocalPlayer then return end
    if not character or not character:IsA("Model") then return end

    -- Determine the player's team color
    local teamColor = player.TeamColor.Color

    -- Create a Highlight object (if not already created)
    local highlight = character:FindFirstChild("PlayerHighlight") or Instance.new("Highlight")
    highlight.Name = "PlayerHighlight"
    highlight.Adornee = character
    highlight.FillColor = teamColor -- Use team color for highlight fill
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255) -- White outline
    highlight.Enabled = isESPEnabled -- Sync highlight visibility with ESP state
    highlight.Parent = character

    -- Create a BillboardGui for the username (if not already created)
    local billboardGui = character:FindFirstChild("UsernameDisplay") or Instance.new("BillboardGui")
    billboardGui.Name = "UsernameDisplay"
    billboardGui.Size = UDim2.new(0, 150, 0, 25) -- Smaller text size
    billboardGui.StudsOffset = Vector3.new(0, 3, 0) -- Offset above the player's head
    billboardGui.Adornee = character:FindFirstChild("Head") or character.PrimaryPart
    billboardGui.AlwaysOnTop = true
    billboardGui.Enabled = isESPEnabled -- Sync visibility with ESP state
    billboardGui.Parent = character

    -- Create a TextLabel for the username (if not already created)
    local textLabel = billboardGui:FindFirstChild("TextLabel") or Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0) -- Fill the BillboardGui
    textLabel.BackgroundTransparency = 1 -- Transparent background
    textLabel.Text = player.Name -- Display the player's username
    textLabel.TextColor3 = teamColor -- Use team color for username text
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextScaled = true
    textLabel.TextStrokeTransparency = 0 -- Fully opaque stroke
    textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0) -- Black stroke for better readability
    textLabel.Parent = billboardGui
end

-- Function to toggle ESP on or off
local function toggleESP()
    isESPEnabled = not isESPEnabled

    -- Update existing highlights and username displays
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and player ~= Players.LocalPlayer then
            -- Update Highlight
            local highlight = player.Character:FindFirstChild("PlayerHighlight")
            if highlight then
                highlight.Enabled = isESPEnabled
            end

            -- Update Username Display
            local billboardGui = player.Character:FindFirstChild("UsernameDisplay")
            if billboardGui then
                billboardGui.Enabled = isESPEnabled
            end
        end
    end
end

-- Function to monitor a single player
local function monitorPlayer(player)
    -- Skip the LocalPlayer
    if player == Players.LocalPlayer then return end

    -- Apply ESP when the player's character is added
    player.CharacterAdded:Connect(function(character)
        character:WaitForChild("HumanoidRootPart") -- Ensure the character is fully loaded
        applyHighlight(character, player)

        -- Explicitly sync ESP visibility state with the toggle
        local highlight = character:FindFirstChild("PlayerHighlight")
        if highlight then
            highlight.Enabled = isESPEnabled
        end

        local billboardGui = character:FindFirstChild("UsernameDisplay")
        if billboardGui then
            billboardGui.Enabled = isESPEnabled
        end
    end)

    -- Apply ESP if the player's character already exists
    if player.Character then
        applyHighlight(player.Character, player)
    end
end

-- Monitor all players in the game
for _, player in pairs(Players:GetPlayers()) do
    monitorPlayer(player)
end

-- Monitor new players joining the game
Players.PlayerAdded:Connect(function(player)
    monitorPlayer(player)
end)

-- Create GUI for toggling ESP
local function createToggleGUI()
    -- Prevent duplicate GUIs
    if Players.LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("ESPToggleGUI") then
        return
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ESPToggleGUI"
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.new(0, 200, 0, 50)
    toggleButton.Position = UDim2.new(0.5, -100, 0.9, 0) -- Bottom-center position
    toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.Font = Enum.Font.SourceSans
    toggleButton.TextSize = 20
    toggleButton.Text = "Toggle ESP: ON"
    toggleButton.Parent = screenGui

    -- Update button color and text based on ESP state
    local function updateButton()
        toggleButton.Text = isESPEnabled and "Toggle ESP: ON" or "Toggle ESP: OFF"
        toggleButton.BackgroundColor3 = isESPEnabled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
    end

    -- Connect the toggle button click
    toggleButton.MouseButton1Click:Connect(function()
        toggleESP()
        updateButton()
    end)

    -- Initialize button state
    updateButton()
end

-- Ensure GUI persists across resets
StarterGui.ResetPlayerGuiOnSpawn = false
createToggleGUI()
