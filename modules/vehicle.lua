-- Vehicle Module
local Vehicle = {}

-- Variáveis privadas
local carPullGui = nil
local carPullFrame = nil
local selectedVehicle = nil
local carPullUpdateLoop = nil

-- Funções auxiliares privadas
local function getAvailableVehicles()
    local vehicles = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "DriveSeat" and (obj:IsA("VehicleSeat") or obj:IsA("Seat")) then
            if not obj.Occupant then
                local vehicleModel = obj.Parent
                table.insert(vehicles, {
                    seat = obj,
                    model = vehicleModel,
                    name = vehicleModel.Name,
                    position = obj.Position
                })
            end
        end
    end
    return vehicles
end

local function pullVehicle(vehicleData)
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character then return false, "Personagem não encontrado!" end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoidRootPart or not humanoid then 
        return false, "HumanoidRootPart ou Humanoid não encontrado!" 
    end
    
    local originalPosition = humanoidRootPart.CFrame
    local driveSeat = vehicleData.seat
    
    if not driveSeat or not driveSeat.Parent then 
        return false, "Veículo não está mais disponível!" 
    end
    
    local vehicleModel = vehicleData.model
    if not vehicleModel.PrimaryPart then
        vehicleModel.PrimaryPart = driveSeat
    end
    
    -- Salvar propriedades originais das partes
    local vehicleParts = {}
    for _, part in pairs(vehicleModel:GetDescendants()) do
        if part:IsA("BasePart") then
            table.insert(vehicleParts, {
                part = part,
                anchored = part.Anchored,
                canCollide = part.CanCollide
            })
            part.Anchored = true
            part.CanCollide = false
        end
    end
    
    driveSeat.Disabled = false
    driveSeat.Locked = false
    
    humanoidRootPart.CFrame = driveSeat.CFrame + Vector3.new(0, 2, 0)
    task.wait(0.15)
    driveSeat:Sit(humanoid)
    task.wait(0.25)
    
    if not humanoid.Sit then
        for _, data in pairs(vehicleParts) do
            if data.part and data.part.Parent then
                data.part.Anchored = data.anchored
                data.part.CanCollide = data.canCollide
            end
        end
        return false, "Não foi possível entrar no veículo!"
    end
    
    -- Calcular posição final
    local rayOrigin = Vector3.new(originalPosition.Position.X, originalPosition.Position.Y + 50, originalPosition.Position.Z)
    local rayDirection = Vector3.new(0, -200, 0)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {character, vehicleModel}
    
    local rayResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    local finalY = rayResult and (rayResult.Position.Y + driveSeat.Size.Y / 2 + 3) or (originalPosition.Position.Y + 3)
    
    -- Animar puxada do veículo
    local pullDuration = 2
    local startTime = tick()
    local startModelCFrame = vehicleModel.PrimaryPart.CFrame
    local targetPosition = Vector3.new(originalPosition.Position.X, finalY, originalPosition.Position.Z)
    local finalModelCFrame = CFrame.new(targetPosition) * CFrame.Angles(0, startModelCFrame:ToEulerAnglesYXZ(), 0)
    
    while tick() - startTime < pullDuration do
        if not driveSeat or not driveSeat.Parent or not humanoid.Sit then break end
        
        local alpha = (tick() - startTime) / pullDuration
        alpha = math.min(alpha, 1)
        local smoothAlpha = alpha < 0.5 and 2 * alpha * alpha or 1 - math.pow(-2 * alpha + 2, 2) / 2
        
        local newCFrame = startModelCFrame:Lerp(finalModelCFrame, smoothAlpha)
        vehicleModel:PivotTo(newCFrame)
        task.wait()
    end
    
    if vehicleModel and vehicleModel.Parent then
        vehicleModel:PivotTo(finalModelCFrame)
    end
    
    task.wait(0.3)
    
    -- Restaurar propriedades
    for _, data in pairs(vehicleParts) do
        if data.part and data.part.Parent then
            data.part.Anchored = data.anchored
            data.part.CanCollide = data.canCollide
        end
    end
    
    task.wait(0.1)
    return true, "Veículo puxado com sucesso!"
end

local function createCarPullGui()
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    
    if carPullGui then carPullGui:Destroy() end
    if carPullUpdateLoop then task.cancel(carPullUpdateLoop) carPullUpdateLoop = nil end
    
    carPullGui = Instance.new("ScreenGui")
    carPullGui.Name = "CarPullGui"
    carPullGui.ResetOnSpawn = false
    carPullGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    carPullFrame = Instance.new("Frame")
    carPullFrame.Size = UDim2.new(0, 350, 0, 450)
    carPullFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
    carPullFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    carPullFrame.BorderSizePixel = 0
    carPullFrame.Active = true
    carPullFrame.Parent = carPullGui
    
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 12)
    uiCorner.Parent = carPullFrame
    
    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = Color3.fromRGB(138, 43, 226)
    uiStroke.Thickness = 3
    uiStroke.Parent = carPullFrame
    
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    header.BorderSizePixel = 0
    header.Parent = carPullFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Puxar Veículo"
    titleLabel.TextColor3 = Color3.fromRGB(138, 43, 226)
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = header
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "VehicleScroll"
    scrollFrame.Size = UDim2.new(1, -20, 1, -120)
    scrollFrame.Position = UDim2.new(0, 10, 0, 60)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(138, 43, 226)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.Parent = carPullFrame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 10)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = scrollFrame
    
    local function updateVehicleList()
        for _, child in pairs(scrollFrame:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextLabel") then 
                child:Destroy() 
            end
        end
        
        selectedVehicle = nil
        local vehicles = getAvailableVehicles()
        
        if #vehicles == 0 then
            local noVehicleLabel = Instance.new("TextLabel")
            noVehicleLabel.Size = UDim2.new(1, 0, 0, 40)
            noVehicleLabel.BackgroundTransparency = 1
            noVehicleLabel.Text = "Nenhum veículo disponível"
            noVehicleLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
            noVehicleLabel.TextSize = 14
            noVehicleLabel.Font = Enum.Font.Gotham
            noVehicleLabel.Parent = scrollFrame
            return
        end
        
        for i, vehicleData in ipairs(vehicles) do
            local vehicleFrame = Instance.new("Frame")
            vehicleFrame.Size = UDim2.new(1, 0, 0, 70)
            vehicleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            vehicleFrame.BorderSizePixel = 0
            vehicleFrame.Parent = scrollFrame
            
            local selectButton = Instance.new("TextButton")
            selectButton.Size = UDim2.new(0, 80, 0, 25)
            selectButton.Position = UDim2.new(1, -90, 1, -32)
            selectButton.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
            selectButton.BorderSizePixel = 0
            selectButton.Text = "Selecionar"
            selectButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            selectButton.TextSize = 12
            selectButton.Font = Enum.Font.GothamBold
            selectButton.Parent = vehicleFrame
            
            selectButton.MouseButton1Click:Connect(function()
                selectedVehicle = vehicleData
                selectButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
                selectButton.Text = "✓ Selecionado"
                task.wait(0.5)
                selectButton.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
                selectButton.Text = "Selecionar"
            end)
        end
    end
    
    local pullButton = Instance.new("TextButton")
    pullButton.Size = UDim2.new(1, -30, 0, 45)
    pullButton.Position = UDim2.new(0, 15, 1, -55)
    pullButton.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    pullButton.BorderSizePixel = 0
    pullButton.Text = "Puxar Veículo Selecionado"
    pullButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    pullButton.TextSize = 16
    pullButton.Font = Enum.Font.GothamBold
    pullButton.Parent = carPullFrame
    
    pullButton.MouseButton1Click:Connect(function()
        if not selectedVehicle then
            pullButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            pullButton.Text = "Selecione um veículo primeiro!"
            task.wait(1.5)
            pullButton.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
            pullButton.Text = "Puxar Veículo Selecionado"
            return
        end
        
        pullButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        pullButton.Text = "Puxando veículo..."
        
        local success, message = pullVehicle(selectedVehicle)
        
        if success then
            pullButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            pullButton.Text = "✓ " .. message
            selectedVehicle = nil
            task.wait(2)
            updateVehicleList()
        else
            pullButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            pullButton.Text = "X " .. message
            task.wait(2)
        end
        
        pullButton.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
        pullButton.Text = "Puxar Veículo Selecionado"
    end)
    
    carPullGui.Parent = playerGui
    updateVehicleList()
    
    carPullUpdateLoop = task.spawn(function()
        while carPullGui and carPullGui.Parent do
            task.wait(10)
            if carPullGui and carPullGui.Parent then
                updateVehicleList()
            end
        end
    end)
end

-- Funções públicas
function Vehicle.ToggleCarPullGui(enabled)
    if enabled then
        createCarPullGui()
    else
        if carPullUpdateLoop then task.cancel(carPullUpdateLoop) carPullUpdateLoop = nil end
        if carPullGui then carPullGui:Destroy() carPullGui = nil carPullFrame = nil selectedVehicle = nil end
    end
end

function Vehicle.BreakIntoVehicle()
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character then return false end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoidRootPart or not humanoid then return false end
    
    local nearestSeat = nil
    local shortestDistance = math.huge
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "DriveSeat" and (obj:IsA("VehicleSeat") or obj:IsA("Seat")) then
            local distance = (obj.Position - humanoidRootPart.Position).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                nearestSeat = obj
            end
        end
    end
    
    if nearestSeat and shortestDistance < 100 then
        nearestSeat.Disabled = false
        nearestSeat.Locked = false
        humanoidRootPart.CFrame = nearestSeat.CFrame + Vector3.new(0, 2, 0)
        task.wait(0.05)
        nearestSeat:Sit(humanoid)
        return true
    end
    
    return false
end

return Vehicle
