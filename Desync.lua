local Players = game:GetService("Players")
local player = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- GUI
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
local button = Instance.new("TextButton")
button.Size = UDim2.new(0,150,0,50)
button.Position = UDim2.new(0,20,0,20)
button.Text = "Desync: OFF"
button.BackgroundColor3 = Color3.fromRGB(255,0,0)
button.TextColor3 = Color3.fromRGB(255,255,255)
button.TextScaled = true
button.Parent = screenGui

-- Variables
local desyncEnabled = false
local clone = nil
local hitbox = nil
local moveConnection = nil
local updateConnection = nil

-- Función para mover el botón
local dragging = false
local dragInput, mousePos, framePos

button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        mousePos = input.Position
        framePos = button.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

button.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

RunService.RenderStepped:Connect(function()
    if dragging and dragInput then
        local delta = dragInput.Position - mousePos
        button.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
    end
end)

-- Función Desync
button.MouseButton1Click:Connect(function()
    desyncEnabled = not desyncEnabled
    button.Text = desyncEnabled and "Desync: ON" or "Desync: OFF"
    button.BackgroundColor3 = desyncEnabled and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
    
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = character.HumanoidRootPart

    if desyncEnabled then
        -- Crear copia
        clone = hrp:Clone()
        clone.Anchored = true
        clone.CanCollide = false
        clone.Transparency = 0
        clone.Parent = workspace

        -- Crear hitbox
        hitbox = Instance.new("Part")
        hitbox.Size = Vector3.new(2,3,1)
        hitbox.Color = Color3.fromRGB(0,255,255)
        hitbox.Transparency = 0.5
        hitbox.Anchored = true
        hitbox.CanCollide = false
        hitbox.CFrame = clone.CFrame
        hitbox.Parent = workspace

        -- Movimiento errático
        moveConnection = RunService.RenderStepped:Connect(function()
            if clone and hitbox then
                local offset = Vector3.new(
                    math.random(-3,3)/2,
                    0,
                    math.random(-3,3)/2
                )
                clone.CFrame = clone.CFrame + offset
                hitbox.CFrame = clone.CFrame
            end
        end)

        -- Actualizar cada 7 segundos a tu posición
        updateConnection = RunService.Heartbeat:Connect(function(deltaTime)
            if not clone.lastUpdate then clone.lastUpdate = 0 end
            clone.lastUpdate = clone.lastUpdate + deltaTime
            if clone.lastUpdate >= 7 then
                clone.CFrame = hrp.CFrame
                hitbox.CFrame = clone.CFrame
                clone.lastUpdate = 0
            end
        end)

    else
        -- Desactivar desync
        if clone then
            clone:Destroy()
            clone = nil
        end
        if hitbox then
            hitbox:Destroy()
            hitbox = nil
        end
        if moveConnection then
            moveConnection:Disconnect()
            moveConnection = nil
        end
        if updateConnection then
            updateConnection:Disconnect()
            updateConnection = nil
        end
    end
end)
