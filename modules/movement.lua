-- Movement Module
local Movement = {}

-- Variáveis privadas
local flying = false
local flySpeed = 30
local bodyVelocity = nil
local bodyGyro = nil

-- Funções privadas
local function startFly()
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoidRootPart or not humanoid then return end
    
    if bodyGyro then pcall(function() bodyGyro:Destroy() end) end
    if bodyVelocity then pcall(function() bodyVelocity:Destroy() end) end
    
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(0, 0, 0)
    bodyGyro.P = 9000
    bodyGyro.Parent = humanoidRootPart
    
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(0, 0, 0)
    bodyVelocity.P = 1250
    bodyVelocity.Parent = humanoidRootPart
    
    task.spawn(function()
        while flying do
            pcall(function()
                if not humanoidRootPart or not humanoidRootPart.Parent then
                    flying = false
                    return
                end
                
                local camera = workspace.CurrentCamera
                local userInputService = game:GetService("UserInputService")
                local moveDirection = Vector3.new(0, 0, 0)
                
                if userInputService:IsKeyDown(Enum.KeyCode.W) then 
                    moveDirection = moveDirection + (camera.CFrame.LookVector * Vector3.new(1, 0, 1)).Unit
                end
                if userInputService:IsKeyDown(Enum.KeyCode.S) then 
                    moveDirection = moveDirection - (camera.CFrame.LookVector * Vector3.new(1, 0, 1)).Unit
                end
                if userInputService:IsKeyDown(Enum.KeyCode.A) then 
                    moveDirection = moveDirection - camera.CFrame.RightVector
                end
                if userInputService:IsKeyDown(Enum.KeyCode.D) then 
                    moveDirection = moveDirection + camera.CFrame.RightVector
                end
                
                local verticalSpeed = 0
                if userInputService:IsKeyDown(Enum.KeyCode.Space) then 
                    verticalSpeed = 1
                end
                if userInputService:IsKeyDown(Enum.KeyCode.LeftShift) then 
                    verticalSpeed = -1
                end
                
                if moveDirection.Magnitude > 0 then
                    moveDirection = moveDirection.Unit
                end
                
                moveDirection = moveDirection + Vector3.new(0, verticalSpeed, 0)
                
                if moveDirection.Magnitude > 0 then
                    bodyGyro.MaxTorque = Vector3.new(9000, 9000, 9000)
                    bodyGyro.CFrame = camera.CFrame
                    bodyVelocity.MaxForce = Vector3.new(9000, 9000, 9000)
                    bodyVelocity.Velocity = moveDirection * flySpeed
                else
                    bodyGyro.MaxTorque = Vector3.new(0, 0, 0)
                    bodyVelocity.MaxForce = Vector3.new(9000, 9000, 9000)
                    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                end
            end)
            task.wait(0.1)
        end
        
        if bodyGyro then 
            pcall(function() bodyGyro:Destroy() end)
            bodyGyro = nil
        end
        if bodyVelocity then 
            pcall(function() bodyVelocity:Destroy() end)
            bodyVelocity = nil
        end
    end)
end

local function stopFly()
    flying = false
    task.wait(0.2)
    
    if bodyGyro then 
        pcall(function() bodyGyro:Destroy() end)
        bodyGyro = nil
    end
    if bodyVelocity then 
        pcall(function() bodyVelocity:Destroy() end)
        bodyVelocity = nil
    end
    
    local player = game.Players.LocalPlayer
    local character = player.Character
    if character then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")
        
        if humanoidRootPart then
            pcall(function()
                humanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                humanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end)
        end
        
        if humanoid then
            pcall(function()
                humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
                task.wait(0.1)
                humanoid:ChangeState(Enum.HumanoidStateType.Landing)
            end)
        end
    end
end

-- Funções públicas
function Movement.ToggleFly(enabled)
    flying = enabled
    if flying then 
        startFly()
    else 
        stopFly()
    end
end

function Movement.ToggleFlyKeybind()
    flying = not flying
    if flying then 
        startFly()
    else 
        stopFly()
    end
end

function Movement.SetFlySpeed(speed)
    flySpeed = speed
end

function Movement.IsFlyEnabled()
    return flying
end

return Movement
