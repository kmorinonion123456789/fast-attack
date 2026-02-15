local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local remote = ReplicatedStorage.Modules.Net["RE/RegisterHit"]

_G.AttackEnabled = false
local MAX_DIST = 100
local ATTACK_SPEED = 0.1
local lastAttack = 0

local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "ShiunFastAttack"

local button = Instance.new("TextButton", screenGui)
button.Size = UDim2.new(0, 160, 0, 45)
button.Position = UDim2.new(0.5, -80, 0.05, 0)
button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
button.Text = "FAST ATTACK: OFF"
button.TextColor3 = Color3.fromRGB(255, 60, 60)
button.Font = Enum.Font.SourceSansBold
button.TextSize = 18
button.Draggable = true

local corner = Instance.new("UICorner", button)
corner.CornerRadius = UDim.new(0, 8)

button.MouseButton1Click:Connect(function()
    _G.AttackEnabled = not _G.AttackEnabled
    if _G.AttackEnabled then
        button.Text = "FAST ATTACK: ON"
        button.TextColor3 = Color3.fromRGB(60, 255, 60)
    else
        button.Text = "FAST ATTACK: OFF"
        button.TextColor3 = Color3.fromRGB(255, 60, 60)
    end
end)

local function getClosestTarget()
    local closest = nil
    local dist = MAX_DIST
    
    local folders = {workspace:FindFirstChild("Enemies"), workspace:FindFirstChild("Characters"), workspace}
    
    for _, folder in pairs(folders) do
        if folder then
            for _, obj in pairs(folder:GetChildren()) do
                if obj:IsA("Model") and obj ~= player.Character then
                    local hum = obj:FindFirstChildOfClass("Humanoid")
                    local root = obj:FindFirstChild("HumanoidRootPart")
                    
                    if hum and root and hum.Health > 0 then
                        local d = (player.Character.HumanoidRootPart.Position - root.Position).Magnitude
                        if d < dist then
                            dist = d
                            closest = root
                        end
                    end
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if _G.AttackEnabled then
        local now = tick()
        if now - lastAttack >= ATTACK_SPEED then
            local target = getClosestTarget()
            
            if target then
                remote:FireServer(target)
                lastAttack = now
            end
        end
    end
end)

print("Fast Attack Loaded for shiun4545")
