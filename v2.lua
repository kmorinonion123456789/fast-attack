local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local net = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")

-- 設定
_G.AttackEnabled = false
_G.AimbotEnabled = false
local MAX_DIST = 250 -- エイム範囲を少し広げました
local ATTACK_SPEED = 0.05 

-- --- GUI (動画のデザインに近い形に修正) ---
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "ShiunHub_V4"

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 200, 0, 120)
frame.Position = UDim2.new(0.5, -100, 0.1, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.2
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame)

local function createButton(text, pos)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 180, 0, 45)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 60, 60)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16
    Instance.new("UICorner", btn)
    return btn
end

local atkBtn = createButton("AUTO ATTACK: OFF", UDim2.new(0, 10, 0, 10))
local aimBtn = createButton("SKILL AIMBOT: OFF", UDim2.new(0, 10, 0, 65))

-- --- ターゲット取得 ---
local function getClosestTarget()
    local closest = nil
    local dist = MAX_DIST
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end

    -- workspace内の全NPC/プレイヤーをスキャン
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Humanoid") and obj.Parent ~= char and obj.Health > 0 then
            local root = obj.Parent:FindFirstChild("HumanoidRootPart")
            if root then
                local d = (char.HumanoidRootPart.Position - root.Position).Magnitude
                if d < dist then
                    dist = d
                    closest = root
                end
            end
        end
    end
    return closest
end

-- ボタンイベント
atkBtn.MouseButton1Click:Connect(function()
    _G.AttackEnabled = not _G.AttackEnabled
    atkBtn.Text = _G.AttackEnabled and "AUTO ATTACK: ON" or "AUTO ATTACK: OFF"
    atkBtn.TextColor3 = _G.AttackEnabled and Color3.fromRGB(60, 255, 60) or Color3.fromRGB(255, 60, 60)
end)

aimBtn.MouseButton1Click:Connect(function()
    _G.AimbotEnabled = not _G.AimbotEnabled
    aimBtn.Text = _G.AimbotEnabled and "SKILL AIMBOT: ON" or "SKILL AIMBOT: OFF"
    aimBtn.TextColor3 = _G.AimbotEnabled and Color3.fromRGB(60, 255, 60) or Color3.fromRGB(255, 60, 60)
end)

-- --- メインループ ---
RunService.Stepped:Connect(function()
    if not (_G.AttackEnabled or _G.AimbotEnabled) then return end
    
    local target = getClosestTarget()
    local char = player.Character
    if not target or not char then return end

    -- 1. 通常攻撃 (RegisterHit系)
    if _G.AttackEnabled then
        net["RE/RegisterAttack"]:FireServer()
        net["RE/RegisterHit"]:FireServer(target.Parent)
    end

    -- 2. スキルエイムボット (動画の「ライト」用)
    if _G.AimbotEnabled then
        -- キャラクター内のスキルフォルダにあるリモートを強制書き換え
        local fruit = char:FindFirstChild("Light-Light")
        if fruit then
            local remote = fruit:FindFirstChild("RemoteEvent")
            if remote then
                -- 座標(Vector3)をサーバーに送り続けて誘導する
                remote:FireServer(target.Position)
            end
        end
        
        -- 手持ちツール内のリモートも同様に処理
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            for _, r in pairs(tool:GetDescendants()) do
                if r:IsA("RemoteEvent") then
                    r:FireServer(target.Position)
                end
            end
        end
    end
end)

print("Shiun4545: Skill Tracking Aimbot Loaded.")
