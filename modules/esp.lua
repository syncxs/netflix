-- ESP Module
local ESP = {}

-- Variáveis locais (privadas ao módulo)
local espEnabled = false
local staffListGui = nil
local staffListFrame = nil
local isDragging = false
local dragStart = nil
local startPos = nil
local staffDetectionActive = false
local staffUpdateLoop = nil
local lastStaffList = {}

local ESPSettings = {
    Box_Color = Color3.fromRGB(255, 0, 0),
    Box_Thickness = 2,
    Team_Check = false,
    Team_Color = false,
    Autothickness = true
}

-- Funções auxiliares privadas
local Space = game:GetService("Workspace")
local Player = game:GetService("Players").LocalPlayer
local Camera = Space.CurrentCamera

local function NewLine(color, thickness)
    local line = Drawing.new("Line")
    line.Visible = false
    line.From = Vector2.new(0, 0)
    line.To = Vector2.new(0, 0)
    line.Color = color
    line.Thickness = thickness
    line.Transparency = 1
    return line
end

local function Vis(lib, state)
    for i, v in pairs(lib) do
        v.Visible = state
    end
end

local function Colorize(lib, color)
    for i, v in pairs(lib) do
        v.Color = color
    end
end

local function Rainbow(lib, delay)
    task.spawn(function()
        while espEnabled do
            for hue = 0, 1, 1/30 do
                if not espEnabled then break end
                local color = Color3.fromHSV(hue, 0.6, 1)
                Colorize(lib, color)
                task.wait(delay)
            end
        end
    end)
end

local function CreateAdvancedESP(plr)
    repeat task.wait() until plr.Character ~= nil and plr.Character:FindFirstChild("Humanoid") ~= nil
    
    local R15 = plr.Character.Humanoid.RigType == Enum.HumanoidRigType.R15
    
    local Library = {
        TL1 = NewLine(ESPSettings.Box_Color, ESPSettings.Box_Thickness),
        TL2 = NewLine(ESPSettings.Box_Color, ESPSettings.Box_Thickness),
        TR1 = NewLine(ESPSettings.Box_Color, ESPSettings.Box_Thickness),
        TR2 = NewLine(ESPSettings.Box_Color, ESPSettings.Box_Thickness),
        BL1 = NewLine(ESPSettings.Box_Color, ESPSettings.Box_Thickness),
        BL2 = NewLine(ESPSettings.Box_Color, ESPSettings.Box_Thickness),
        BR1 = NewLine(ESPSettings.Box_Color, ESPSettings.Box_Thickness),
        BR2 = NewLine(ESPSettings.Box_Color, ESPSettings.Box_Thickness)
    }
    
    Rainbow(Library, 0.15)
    
    local oripart = Instance.new("Part")
    oripart.Parent = Space
    oripart.Transparency = 1
    oripart.CanCollide = false
    oripart.Size = Vector3.new(1, 1, 1)
    oripart.Position = Vector3.new(0, 0, 0)
    
    local function Updater()
        local c 
        c = game:GetService("RunService").RenderStepped:Connect(function()
            if not espEnabled then
                Vis(Library, false)
                for i, v in pairs(Library) do
                    pcall(function() v:Remove() end)
                end
                pcall(function() oripart:Destroy() end)
                c:Disconnect()
                return
            end
            
            if plr.Character ~= nil and plr.Character:FindFirstChild("Humanoid") ~= nil and 
               plr.Character:FindFirstChild("HumanoidRootPart") ~= nil and 
               plr.Character.Humanoid.Health > 0 and plr.Character:FindFirstChild("Head") ~= nil then
                
                local Hum = plr.Character
                local HumPos, vis = Camera:WorldToViewportPoint(Hum.HumanoidRootPart.Position)
                
                if vis then
                    oripart.Size = Vector3.new(Hum.HumanoidRootPart.Size.X, Hum.HumanoidRootPart.Size.Y*1.5, Hum.HumanoidRootPart.Size.Z)
                    oripart.CFrame = CFrame.new(Hum.HumanoidRootPart.CFrame.Position, Camera.CFrame.Position)
                    
                    local SizeX = oripart.Size.X
                    local SizeY = oripart.Size.Y
                    local TL = Camera:WorldToViewportPoint((oripart.CFrame * CFrame.new(SizeX, SizeY, 0)).p)
                    local TR = Camera:WorldToViewportPoint((oripart.CFrame * CFrame.new(-SizeX, SizeY, 0)).p)
                    local BL = Camera:WorldToViewportPoint((oripart.CFrame * CFrame.new(SizeX, -SizeY, 0)).p)
                    local BR = Camera:WorldToViewportPoint((oripart.CFrame * CFrame.new(-SizeX, -SizeY, 0)).p)

                    local ratio = (Camera.CFrame.p - Hum.HumanoidRootPart.Position).magnitude
                    local offset = math.clamp(1/ratio*750, 2, 300)

                    Library.TL1.From = Vector2.new(TL.X, TL.Y)
                    Library.TL1.To = Vector2.new(TL.X + offset, TL.Y)
                    Library.TL2.From = Vector2.new(TL.X, TL.Y)
                    Library.TL2.To = Vector2.new(TL.X, TL.Y + offset)

                    Library.TR1.From = Vector2.new(TR.X, TR.Y)
                    Library.TR1.To = Vector2.new(TR.X - offset, TR.Y)
                    Library.TR2.From = Vector2.new(TR.X, TR.Y)
                    Library.TR2.To = Vector2.new(TR.X, TR.Y + offset)

                    Library.BL1.From = Vector2.new(BL.X, BL.Y)
                    Library.BL1.To = Vector2.new(BL.X + offset, BL.Y)
                    Library.BL2.From = Vector2.new(BL.X, BL.Y)
                    Library.BL2.To = Vector2.new(BL.X, BL.Y - offset)

                    Library.BR1.From = Vector2.new(BR.X, BR.Y)
                    Library.BR1.To = Vector2.new(BR.X - offset, BR.Y)
                    Library.BR2.From = Vector2.new(BR.X, BR.Y)
                    Library.BR2.To = Vector2.new(BR.X, BR.Y - offset)

                    Vis(Library, true)

                    if ESPSettings.Autothickness then
                        local distance = (Player.Character.HumanoidRootPart.Position - oripart.Position).magnitude
                        local value = math.clamp(1/distance*100, 1, 4)
                        for u, x in pairs(Library) do
                            x.Thickness = value
                        end
                    end
                else 
                    Vis(Library, false)
                end
            else 
                Vis(Library, false)
                if game:GetService("Players"):FindFirstChild(plr.Name) == nil then
                    for i, v in pairs(Library) do
                        pcall(function() v:Remove() end)
                    end
                    pcall(function() oripart:Destroy() end)
                    c:Disconnect()
                end
            end
        end)
    end
    coroutine.wrap(Updater)()
end

local function updateESP()
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= Player then
            if player.Team and tostring(player.Team.Name):upper() == "STAFF" then
                task.spawn(function()
                    CreateAdvancedESP(player)
                end)
            end
        end
    end
end

local function getStaffList()
    local staffList = {}
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= Player then
            if player.Team and tostring(player.Team.Name):upper() == "STAFF" then
                table.insert(staffList, player.Name)
            end
        end
    end
    table.sort(staffList)
    return staffList
end

local function staffListChanged(newList)
    if #lastStaffList ~= #newList then return true end
    for i, name in ipairs(newList) do
        if lastStaffList[i] ~= name then return true end
    end
    return false
end

local function createStaffList()
    local Players = game:GetService("Players")
    local playerGui = Player:WaitForChild("PlayerGui")
    
    if staffListGui then staffListGui:Destroy() end
    
    staffListGui = Instance.new("ScreenGui")
    staffListGui.Name = "StaffListGui"
    staffListGui.ResetOnSpawn = false
    staffListGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    staffListFrame = Instance.new("Frame")
    staffListFrame.Size = UDim2.new(0, 220, 0, 280)
    staffListFrame.Position = UDim2.new(0.5, -110, 0.5, -140)
    staffListFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    staffListFrame.BorderSizePixel = 0
    staffListFrame.Active = true
    staffListFrame.Parent = staffListGui
    
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 12)
    uiCorner.Parent = staffListFrame
    
    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = Color3.fromRGB(138, 43, 226)
    uiStroke.Thickness = 3
    uiStroke.Parent = staffListFrame
    
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    header.BorderSizePixel = 0
    header.Parent = staffListFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 12)
    headerCorner.Parent = header
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Staffs Online"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = header
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "StaffScroll"
    scrollFrame.Size = UDim2.new(1, -20, 1, -70)
    scrollFrame.Position = UDim2.new(0, 10, 0, 60)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(138, 43, 226)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.Parent = staffListFrame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 8)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = scrollFrame
    
    staffListGui.Parent = playerGui
end

local function updateStaffList(staffList)
    if not staffListFrame then return end
    local scrollFrame = staffListFrame:FindFirstChild("StaffScroll")
    if not scrollFrame then return end
    
    for _, child in pairs(scrollFrame:GetChildren()) do
        if child:IsA("TextLabel") then child:Destroy() end
    end
    
    for i, staffName in ipairs(staffList) do
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0, 30)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = staffName
        nameLabel.TextColor3 = Color3.fromRGB(138, 43, 226)
        nameLabel.TextSize = 15
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.LayoutOrder = i
        nameLabel.Parent = scrollFrame
    end
end

-- Funções públicas do módulo
function ESP.ToggleESP(enabled)
    espEnabled = enabled
    if enabled then
        updateESP()
        
        game.Players.PlayerAdded:Connect(function(player)
            if not espEnabled then return end
            player:GetPropertyChangedSignal("Team"):Connect(function()
                if espEnabled and player.Team and tostring(player.Team.Name):upper() == "STAFF" then
                    task.wait(0.5)
                    CreateAdvancedESP(player)
                end
            end)
        end)
    else
        task.wait(0.3)
    end
end

function ESP.ToggleStaffList(enabled)
    staffDetectionActive = enabled
    if enabled then
        createStaffList()
        lastStaffList = getStaffList()
        updateStaffList(lastStaffList)
        
        staffUpdateLoop = task.spawn(function()
            while staffDetectionActive do
                task.wait(2)
                local currentStaffList = getStaffList()
                if staffListChanged(currentStaffList) then
                    lastStaffList = currentStaffList
                    updateStaffList(currentStaffList)
                end
            end
        end)
    else
        if staffListGui then staffListGui:Destroy() staffListGui = nil staffListFrame = nil end
        if staffUpdateLoop then task.cancel(staffUpdateLoop) staffUpdateLoop = nil end
        lastStaffList = {}
    end
end

-- Retornar módulo
return ESP
