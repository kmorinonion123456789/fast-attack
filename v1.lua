local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local net = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")

-- リモートを取得
local registerHit = net["RE/RegisterHit"]
local registerAttack = net["RE/RegisterAttack"] -- これが「タップした」という偽装に必要

_G.AttackEnabled = false
local MAX_DIST = 100
local ATTACK_SPEED = 0.05 -- 動画のような爆速にするため間隔を半分に短縮

-- GUI
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "ShiunAutoTapAttack"

local button = Instance.new("TextButton", screenGui)
button.Size = UDim2.new(0, 160, 0, 45)
button.Position = UDim2.new(0.5, -80, 0.05, 0)
button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
button.Text = "AUTO ATTACK: OFF"
button.TextColor3 = Color3.fromRGB(255, 60, 60)
button.Font = Enum.Font.SourceSansBold
button.TextSize = 18
button.Draggable = true
Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)

button.MouseButton1Click:Connect(function()
    _G.AttackEnabled = not _G.AttackEnabled
    button.Text = _G.AttackEnabled and "AUTO ATTACK: ON" or "AUTO ATTACK: OFF"
    button.TextColor3 = _G.AttackEnabled and Color3.fromRGB(60, 255, 60) or Color3.fromRGB(255, 60, 60)
end)

local function getClosestTarget()
    local closest = nil
    local dist = MAX_DIST
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end

    local folders = {workspace:FindFirstChild("Enemies"), workspace:FindFirstChild("Characters"), workspace}
    for _, folder in pairs(folders) do
        if folder then
            for _, obj in pairs(folder:GetChildren()) do
                if obj:IsA("Model") and obj ~= char then
                    local hum = obj:FindFirstChildOfClass("Humanoid")
                    local root = obj:FindFirstChild("HumanoidRootPart")
                    if hum and root and hum.Health > 0 then
                        local d = (char.HumanoidRootPart.Position - root.Position).Magnitude
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

-- 攻撃ループ（RenderSteppedより安定するtask.spawnを使用）
task.spawn(function()
    while true do
        if _G.AttackEnabled then
            local target = getClosestTarget()
            local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
            
            -- 武器を持っていて敵が範囲内にいる時
            if target and tool then
                -- 1. 「タップしたぞ」という信号を偽造して送る
                registerAttack:FireServer()
                
                -- 2. 「当たったぞ」という信号を複数回送る（動画のバババッという多段ヒット用）
                -- 数値を増やすほど1回あたりのヒット数が増えます
                registerHit:FireServer(target)
                registerHit:FireServer(target)
            end
        end
        task.wait(ATTACK_SPEED) -- ここで速度調整
    end
end)

print("Auto Tap Spoofer Loaded for shiun4545")
