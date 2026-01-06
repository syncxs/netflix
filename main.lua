-- Seven Menu - Main Loader
-- Substitua YOUR_USERNAME e YOUR_REPO pelos seus dados do GitHub

local GITHUB_BASE = "https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/"

-- Sistema de carregamento de módulos
local ModuleLoader = {
    modules = {},
    baseUrl = GITHUB_BASE .. "modules/"
}

function ModuleLoader:Load(moduleName)
    if self.modules[moduleName] then
        return self.modules[moduleName]
    end
    
    local url = self.baseUrl .. moduleName .. ".lua"
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    
    if success then
        self.modules[moduleName] = result
        return result
    else
        warn("Erro ao carregar módulo " .. moduleName .. ": " .. tostring(result))
        return nil
    end
end

-- Carregar WindUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Carregar todos os módulos
local ESP = ModuleLoader:Load("esp")
local Vehicle = ModuleLoader:Load("vehicle")
local Farm = ModuleLoader:Load("farm")
local Lockpick = ModuleLoader:Load("lockpick")
local Movement = ModuleLoader:Load("movement")
local Troll = ModuleLoader:Load("troll")

-- Verificar se os módulos carregaram
if not (ESP and Vehicle and Farm and Lockpick and Movement and Troll) then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Erro",
        Text = "Falha ao carregar alguns módulos!",
        Duration = 5
    })
    return
end

-- Criar Window
local Window = WindUI:CreateWindow({
    Title = "Seven Menu",
    Author = "by Sultan",
    Folder = "SevenMenu",
    NewElements = true,
    HideSearchBar = false,
    OpenButton = {
        Title = "Open Seven Menu",
        CornerRadius = UDim.new(1, 0),
        StrokeThickness = 3,
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        Color = ColorSequence.new(
            Color3.fromHex("#8A2BE2"),
            Color3.fromHex("#DA70D6")
        )
    }
})

Window:SetToggleKey(Enum.KeyCode.T)

-- ==================== MAIN SECTION ====================
local MainSection = Window:Section({
    Title = "Main",
    Icon = "home"
})

-- Vehicle Tab
local MainTab = MainSection:Tab({
    Title = "Veículo",
    Icon = "car"
})

MainTab:Toggle({
    Title = "Puxar Carro",
    Desc = "Abre menu para puxar veículos",
    Flag = "CarPull",
    Default = false,
    Callback = function(value)
        Vehicle.ToggleCarPullGui(value)
    end
})

MainTab:Space()

MainTab:Button({
    Title = "Invadir Veículo",
    Desc = "Entre em qualquer veículo trancado",
    Icon = "key",
    Callback = function()
        local success = Vehicle.BreakIntoVehicle()
        if success then
            WindUI:Notify({
                Title = "Sucesso",
                Content = "Veículo invadido!",
                Icon = "check"
            })
        else
            WindUI:Notify({
                Title = "Erro",
                Content = "Nenhum veículo próximo encontrado.",
                Icon = "x"
            })
        end
    end
})

-- Lockpick Tab
local LockpickTab = MainSection:Tab({
    Title = "Lockpick",
    Icon = "lock"
})

LockpickTab:Toggle({
    Title = "Auto Lockpick & Micha",
    Desc = "Completa automaticamente o mini game",
    Flag = "AutoLockpick",
    Default = false,
    Callback = function(value)
        Lockpick.Toggle(value)
        if value then
            WindUI:Notify({
                Title = "Auto Lockpick",
                Content = "Ativado!",
                Icon = "unlock"
            })
        end
    end
})

-- ==================== TELEPORT SECTION ====================
local TeleportSection = Window:Section({
    Title = "Teleportes",
    Icon = "map-pin"
})

local TeleportTab = TeleportSection:Tab({
    Title = "Locais",
    Icon = "navigation"
})

local teleportLocations = {
    {name = "Porta Mecânica", pos = Vector3.new(316.79, 30.13, -444.86)},
    {name = "Mercado Negro", pos = Vector3.new(-253.96, 30.13, -237.30)}
}

for _, location in ipairs(teleportLocations) do
    TeleportTab:Button({
        Title = location.name,
        Desc = "Teleporta para " .. location.name,
        Icon = "door-open",
        Callback = function()
            local player = game.Players.LocalPlayer
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = CFrame.new(location.pos)
                WindUI:Notify({
                    Title = "Teleporte",
                    Content = "Teleportado para " .. location.name .. "!",
                    Icon = "check"
                })
            end
        end
    })
end

TeleportTab:Space()

TeleportTab:Button({
    Title = "Copiar Posição Atual",
    Desc = "Copia suas coordenadas atuais",
    Icon = "copy",
    Color = Color3.fromHex("#30a0ff"),
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local pos = character.HumanoidRootPart.Position
            local coordString = string.format("Vector3.new(%.2f, %.2f, %.2f)", pos.X, pos.Y, pos.Z)
            setclipboard(coordString)
            WindUI:Notify({
                Title = "Posição Copiada",
                Content = "Coordenadas copiadas!",
                Icon = "check"
            })
        end
    end
})

-- ==================== FARM SECTION ====================
local FarmSection = Window:Section({
    Title = "Farm",
    Icon = "coins"
})

local FarmTab = FarmSection:Tab({
    Title = "Lixeiro",
    Icon = "trash-2"
})

FarmTab:Toggle({
    Title = "Farm Lixeiro",
    Desc = "Coleta lixos automaticamente",
    Flag = "TrashFarm",
    Default = false,
    Callback = function(value)
        Farm.ToggleTrashFarm(value)
        if value then
            WindUI:Notify({
                Title = "Farm Lixeiro",
                Content = "Ativado!",
                Icon = "trash-2"
            })
        end
    end
})

-- ==================== MISC SECTION ====================
local MiscSection = Window:Section({
    Title = "Misc",
    Icon = "settings"
})

-- Movement Tab
local MovementTab = MiscSection:Tab({
    Title = "Movimento",
    Icon = "zap"
})

MovementTab:Toggle({
    Title = "Fly",
    Desc = "Voe livremente (Pressione F)",
    Flag = "Fly",
    Default = false,
    Callback = function(value)
        Movement.ToggleFly(value)
        if value then
            WindUI:Notify({
                Title = "Fly",
                Content = "Ativado! Pressione F para desativar",
                Icon = "plane"
            })
        end
    end
})

MovementTab:Space()

MovementTab:Slider({
    Title = "Velocidade do Fly",
    Desc = "Ajuste a velocidade do fly",
    Flag = "FlySpeed",
    Step = 5,
    Value = {
        Min = 10,
        Max = 100,
        Default = 30
    },
    Callback = function(value)
        Movement.SetFlySpeed(value)
    end
})

-- Detection Tab
local DetectionTab = MiscSection:Tab({
    Title = "Detecção",
    Icon = "eye"
})

DetectionTab:Toggle({
    Title = "ESP Staff",
    Desc = "ESP STAFF",
    Flag = "ESPStaff",
    Default = false,
    Callback = function(value)
        ESP.ToggleESP(value)
        if value then
            WindUI:Notify({
                Title = "ESP Staff",
                Content = "Ativado!",
                Icon = "eye"
            })
        end
    end
})

DetectionTab:Space()

DetectionTab:Toggle({
    Title = "Lista de Staffs",
    Desc = "Mostra lista de staffs online",
    Flag = "StaffList",
    Default = false,
    Callback = function(value)
        ESP.ToggleStaffList(value)
    end
})

-- ==================== TROLL SECTION ====================
local TrollSection = Window:Section({
    Title = "Troll",
    Icon = "laugh"
})

local TrollTab = TrollSection:Tab({
    Title = "Ações de Troll",
    Icon = "smile"
})

TrollTab:Toggle({
    Title = "Menu Troll",
    Desc = "Abre menu para trollar players",
    Flag = "TrollMenu",
    Default = false,
    Callback = function(value)
        Troll.ToggleGui(value)
        if value then
            WindUI:Notify({
                Title = "Menu Troll",
                Content = "Aberto!",
                Icon = "smile"
            })
        end
    end
})

-- ==================== SETTINGS SECTION ====================
local SettingsSection = Window:Section({
    Title = "Settings",
    Icon = "settings"
})

local ConfigTab = SettingsSection:Tab({
    Title = "Configurações",
    Icon = "sliders"
})

ConfigTab:Button({
    Title = "Destruir Menu",
    Desc = "Fecha o menu completamente",
    Icon = "x",
    Color = Color3.fromHex("#ff4830"),
    Justify = "Center",
    Callback = function()
        Window:Destroy()
    end
})

-- ==================== CREDITS SECTION ====================
local CreditsSection = Window:Section({
    Title = "Créditos",
    Icon = "heart"
})

local CreditsTab = CreditsSection:Tab({
    Title = "Sobre",
    Icon = "info"
})

CreditsTab:Section({
    Title = "Seven Menu",
    TextSize = 24,
    FontWeight = Enum.FontWeight.Bold
})

CreditsTab:Space()

CreditsTab:Section({
    Title = "Desenvolvido por Sultan",
    TextSize = 18,
    TextTransparency = 0.35
})

-- Keybind para Fly
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F then
        Movement.ToggleFlyKeybind()
    end
end)

-- Notificação de Inicialização
WindUI:Notify({
    Title = "Seven Menu",
    Content = "Carregado com sucesso!",
    Icon = "check",
    Duration = 5
})
