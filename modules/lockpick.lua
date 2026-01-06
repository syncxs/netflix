-- Lockpick Module
local Lockpick = {}

-- Variáveis privadas
local autoLockpickEnabled = false
local lockpickConnection = nil
local visibilityConnection = nil

-- Função privada para setup
local function setupAutoLockpick()
    if lockpickConnection then
        lockpickConnection:Disconnect()
        lockpickConnection = nil
    end
    if visibilityConnection then
        visibilityConnection:Disconnect()
        visibilityConnection = nil
    end
    
    if not autoLockpickEnabled then return end
    
    local player = game.Players.LocalPlayer
    
    lockpickConnection = game.ReplicatedStorage.InGameRemotes:WaitForChild("Lockpick").OnClientEvent:Connect(function()
        if not autoLockpickEnabled then return end
        
        task.wait(0.05)
        task.spawn(function()
            for i = 1, 5 do
                if not autoLockpickEnabled then break end
                task.wait(0.5)
                
                local LockpickVenceu = game.ReplicatedStorage.InGameRemotes:FindFirstChild("LockpickVenceu")
                if LockpickVenceu then
                    LockpickVenceu:FireServer()
                end
                task.wait(0.3)
            end
        end)
    end)
end

-- Ocultar GUI do lockpick
task.spawn(function()
    local player = game.Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    
    while true do
        local lockpickGui = playerGui:FindFirstChild("Lockpick")
        if lockpickGui then
            local lockpickFrame = lockpickGui:FindFirstChild("Lockpick")
            if lockpickFrame then
                lockpickFrame.Visible = false
            end
        end
        task.wait(0.05)
    end
end)

-- Função pública
function Lockpick.Toggle(enabled)
    autoLockpickEnabled = enabled
    if enabled then
        setupAutoLockpick()
    else
        if lockpickConnection then
            lockpickConnection:Disconnect()
            lockpickConnection = nil
        end
        if visibilityConnection then
            visibilityConnection:Disconnect()
            visibilityConnection = nil
        end
    end
end

function Lockpick.IsEnabled()
    return autoLockpickEnabled
end

return Lockpick
