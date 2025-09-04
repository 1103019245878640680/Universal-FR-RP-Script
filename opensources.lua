-- Rayfield Interface Library
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Create Rayfield Window
local Window =
    Rayfield:CreateWindow(
    {
        Name = "Nhjw",
        LoadingTitle = "Loading...",
        LoadingSubtitle = "by Nhjw",
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "Nhjw",
            FileName = "Config"
        }
    }
)

-- Fly Variables
local FlyEnabled = false
local FlySpeed = 50
local Player = game.Players.LocalPlayer
local Humanoid = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
local RootPart = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
local BodyVelocity = nil
local BodyGyro = nil

-- Hookfunction for Fly (Inspired by HD Admin)
local function SetupFly()
    if not Humanoid or not RootPart then
        Humanoid = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        RootPart = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if not Humanoid or not RootPart then
            return
        end
    end

    -- Clean up existing fly instances
    if BodyVelocity then
        BodyVelocity:Destroy()
    end
    if BodyGyro then
        BodyGyro:Destroy()
    end

    BodyVelocity = Instance.new("BodyVelocity")
    BodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    BodyVelocity.Velocity = Vector3.new(0, 0, 0)
    BodyVelocity.Parent = RootPart

    BodyGyro = Instance.new("BodyGyro")
    BodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    BodyGyro.CFrame = RootPart.CFrame
    BodyGyro.Parent = RootPart

    -- Hook movement
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local Camera = workspace.CurrentCamera

    local function UpdateFly()
        if not FlyEnabled then
            return
        end
        local MoveDirection = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            MoveDirection = MoveDirection + Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            MoveDirection = MoveDirection - Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            MoveDirection = MoveDirection - Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            MoveDirection = MoveDirection + Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            MoveDirection = MoveDirection + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            MoveDirection = MoveDirection - Vector3.new(0, 1, 0)
        end

        BodyVelocity.Velocity = MoveDirection * FlySpeed
        BodyGyro.CFrame = Camera.CFrame
    end

    RunService:BindToRenderStep("FlyUpdate", Enum.RenderPriority.Input.Value + 1, UpdateFly)
end

-- Hookfunction for WalkSpeed
local OldWalkSpeed
local function HookWalkSpeed(speed)
    if not Humanoid then
        Humanoid = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if not Humanoid then
            return
        end
    end
    OldWalkSpeed = OldWalkSpeed or Humanoid.WalkSpeed
    local mt = getrawmetatable(game)
    local old_index = mt.__index
    setreadonly(mt, false)
    mt.__index =
        newcclosure(
        function(self, key)
            if key == "WalkSpeed" and self == Humanoid then
                return OldWalkSpeed
            end
            return old_index(self, key)
        end
    )
    setreadonly(mt, true)
    Humanoid.WalkSpeed = speed
end

-- Give VIP Card Function
local function GiveVIPCard()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local remote = ReplicatedStorage:FindFirstChild("GiveItem")
    if remote and remote:IsA("RemoteEvent") then
        remote:FireServer("CardsVip.VIP1M")
        print("Carte VIP demandée via " .. remote.Name)
    else
        local cardsVip = ReplicatedStorage:FindFirstChild("CardsVip")
        local vipItem = cardsVip and cardsVip:FindFirstChild("VIP1M")
        if vipItem then
            local clone = vipItem:Clone()
            clone.Parent = Player.Backpack
            print("Carte VIP clonée dans Backpack (client-side)")
        else
            warn("Erreur: VIP1M pas trouvé ou pas de remote!")
        end
    end
end

-- Bypass Adonis Function
local function BypassAdonis()
    local g = getinfo or debug.getinfo
    local d = false
    local h = {}
    local x, y

    setthreadidentity(2)

    -- Hook Adonis Detection and Kill
    for i, v in getgc(true) do
        if typeof(v) == "table" then
            local a = rawget(v, "Detected")
            local b = rawget(v, "Kill")

            if typeof(a) == "function" and not x then
                x = a
                local o
                o =
                    hookfunction(
                    x,
                    function(c, f, n)
                        if c ~= "_" then
                            if d then
                            end
                        end
                        return true
                    end
                )
                table.insert(h, x)
            end

            if rawget(v, "Variables") and rawget(v, "Process") and typeof(b) == "function" and not y then
                y = b
                local o
                o =
                    hookfunction(
                    y,
                    function(f)
                        if d then
                        end
                    end
                )
                table.insert(h, y)
            end
        end
    end

    -- Bypass Namecall for kicks and detections
    local mt = getrawmetatable(game)
    setreadonly(mt, false)

    local oldNamecall = mt.__namecall
    mt.__namecall =
        newcclosure(
        function(self, ...)
            local args = {...}
            local method = getnamecallmethod()

            if method == "Kick" or method == "kick" then
                if tostring(self) == "Players" then
                    return -- Ignore the kick
                end
            end

            if method == "FireServer" or method == "InvokeServer" then
                return oldNamecall(self, ...) -- Pass through remotes without detection
            end

            return oldNamecall(self, ...)
        end
    )

    setreadonly(mt, true)

    -- Patch debug.info to avoid bad yields
    local o
    o =
        hookfunction(
        getrenv().debug.info,
        newcclosure(
            function(...)
                local a, f = ...
                if x and a == x then
                    if d then
                        warn("ez bypass")
                    end
                    return coroutine.yield(coroutine.running())
                end
                return o(...)
            end
        )
    )

    setthreadidentity(7)

    warn("[BYPASS] Bypass Adonis + Namecall")
    print("By Nhjw")
    Rayfield:Notify(
        {
            Title = "Anticheat Bypassed",
            Content = "Ez Anticheat Bypass",
            Duration = 3,
            Image = 0
        }
    )
end

-- Rayfield Tabs and Controls
local MainTab = Window:CreateTab("Main Cheats", nil)

-- Fly Section
local FlySection = MainTab:CreateSection("Fly Controls")
MainTab:CreateToggle(
    {
        Name = "Enable Fly",
        CurrentValue = false,
        Callback = function(Value)
            FlyEnabled = Value
            if FlyEnabled then
                SetupFly()
            else
                if BodyVelocity then
                    BodyVelocity:Destroy()
                end
                if BodyGyro then
                    BodyGyro:Destroy()
                end
                game:GetService("RunService"):UnbindFromRenderStep("FlyUpdate")
            end
        end
    }
)

MainTab:CreateSlider(
    {
        Name = "Fly Speed",
        Range = {10, 200},
        Increment = 10,
        CurrentValue = 50,
        Callback = function(Value)
            FlySpeed = Value
        end
    }
)

-- WalkSpeed Section
local WalkSpeedSection = MainTab:CreateSection("WalkSpeed Controls")
MainTab:CreateSlider(
    {
        Name = "Walk Speed",
        Range = {16, 500},
        Increment = 10,
        CurrentValue = 16,
        Callback = function(Value)
            HookWalkSpeed(Value)
        end
    }
)

-- Give VIP Card Section
local VIPSection = MainTab:CreateSection("VIP Card")
MainTab:CreateButton(
    {
        Name = "Give VIP Card",
        Callback = function()
            GiveVIPCard()
        end
    }
)

-- Bypass Adonis Section
local AdonisSection = MainTab:CreateSection("Adonis Bypass")
MainTab:CreateButton(
    {
        Name = "Bypass Adonis",
        Callback = function()
            BypassAdonis()
        end
    }
)

-- Initialize Player Character
Player.CharacterAdded:Connect(
    function()
        Humanoid = Player.Character:WaitForChild("Humanoid")
        RootPart = Player.Character:WaitForChild("HumanoidRootPart")
        if FlyEnabled then
            SetupFly()
        end
    end
)

print("Rayfield UI Loaded!")
