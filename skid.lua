if getgenv then
    if getgenv().KaitunRunning then
        warn("[Kaitun] Script is already running!")
        return
    end
    getgenv().KaitunRunning = true
end
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local VirtualInputManager = pcall(function() return game:GetService("VirtualInputManager") end) and game:GetService("VirtualInputManager") or nil
local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
local PlaceId = game.PlaceId
local One_World = PlaceId == 2753915549
local Two_World = PlaceId == 4442272183
local Three_World = PlaceId == 7449423635
local Old_World = One_World
local New_World = Two_World
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local CommF_ = Remotes:WaitForChild("CommF_")
local Net = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")
local maxStat = 2800
getgenv().Configs = getgenv().Configs or {
    ["AutoFarm"] = true,
    ["Fast Attack"] = true,
    ["Auto Buso"] = true,
    ["Auto Stats"] = true,
    ["UsePortalTP"] = true,
    ["PortalCooldown"] = 0,
    ["TargetWeapon"] = "Melee",
    ["WebhookUrl"] = "",
    ["WebhookInterval"] = 300,
    ["Quest"] = {
        ["Godhuman"] = true,
        ["CDK"] = true,
        ["Soul Guitar"] = true,
        ["Saber"] = true,
        ["RGB Haki"] = true
    }
}
getgenv()["Fast Attack"] = getgenv()["Fast Attack"] ~= false
getgenv().UsePortalTP = getgenv().UsePortalTP ~= false
getgenv().PortalCooldown = getgenv().PortalCooldown or 0
_G.AimedTarget = _G.AimedTarget or nil
local CurrentQuest = ""
local Stop_Fast_Attack = false
local TargetLimbs = {
    "RightLowerArm", "RightUpperArm",
    "LeftLowerArm", "LeftUpperArm",
    "RightHand", "LeftHand",
    "HumanoidRootPart", "Head"
}
local StatusLabel = nil
local function InitMinimalUI()
    pcall(function()
        local CoreGui = game:GetService("CoreGui")
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local function GetSafeGuiParent()
            local parent = nil
            pcall(function()
                if gethui then parent = gethui() end
            end)
            if not parent then
                pcall(function() parent = CoreGui end)
            end
            if not parent then
                pcall(function()
                    parent = LocalPlayer:WaitForChild("PlayerGui", 5) or LocalPlayer.PlayerGui
                end)
            end
            return parent or CoreGui
        end
        local guiParent = GetSafeGuiParent()
        local oldGui = guiParent:FindFirstChild("TestKaitunUI")
        if oldGui then
            oldGui:Destroy()
        end
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "TestKaitunUI"
        ScreenGui.ResetOnSpawn = false
        ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        ScreenGui.Parent = guiParent
        local MainFrame = Instance.new("Frame")
        MainFrame.Name = "MainFrame"
        MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        MainFrame.Size = UDim2.new(0, 360, 0, 155)
        MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
        MainFrame.BorderSizePixel = 0
        MainFrame.Active = true
        MainFrame.Draggable = true
        MainFrame.Parent = ScreenGui
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 12)
        Corner.Parent = MainFrame
        local Stroke = Instance.new("UIStroke")
        Stroke.Color = Color3.fromRGB(55, 55, 75)
        Stroke.Thickness = 1.5
        Stroke.Parent = MainFrame
        local TitleLabel = Instance.new("TextLabel")
        TitleLabel.Name = "TitleLabel"
        TitleLabel.AnchorPoint = Vector2.new(0.5, 0)
        TitleLabel.Position = UDim2.new(0.5, 0, 0, 16)
        TitleLabel.Size = UDim2.new(1, -20, 0, 30)
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.Font = Enum.Font.GothamBold
        TitleLabel.Text = "test kaitun"
        TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TitleLabel.TextSize = 22
        TitleLabel.Parent = MainFrame
        local DiscordBtn = Instance.new("TextButton")
        DiscordBtn.Name = "DiscordBtn"
        DiscordBtn.AnchorPoint = Vector2.new(0.5, 0)
        DiscordBtn.Position = UDim2.new(0.5, 0, 0, 52)
        DiscordBtn.Size = UDim2.new(0, 240, 0, 28)
        DiscordBtn.BackgroundColor3 = Color3.fromRGB(28, 30, 40)
        DiscordBtn.Font = Enum.Font.GothamSemibold
        DiscordBtn.Text = "dsc.gg/thncommnunity"
        DiscordBtn.TextColor3 = Color3.fromRGB(88, 166, 255)
        DiscordBtn.TextSize = 14
        DiscordBtn.AutoButtonColor = true
        DiscordBtn.Parent = MainFrame
        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 8)
        BtnCorner.Parent = DiscordBtn
        local BtnStroke = Instance.new("UIStroke")
        BtnStroke.Color = Color3.fromRGB(60, 70, 100)
        BtnStroke.Thickness = 1
        BtnStroke.Parent = DiscordBtn
        DiscordBtn.MouseButton1Click:Connect(function()
            pcall(function()
                if setclipboard then
                    setclipboard("dsc.gg/cchubnekkkk")
                    DiscordBtn.Text = "Copied to Clipboard!"
                    task.delay(1.5, function()
                        DiscordBtn.Text = "dsc.gg/hubhuphubp"
                    end)
                end
            end)
        end)
        StatusLabel = Instance.new("TextLabel")
        StatusLabel.Name = "StatusLabel"
        StatusLabel.AnchorPoint = Vector2.new(0.5, 0)
        StatusLabel.Position = UDim2.new(0.5, 0, 0, 92)
        StatusLabel.Size = UDim2.new(1, -24, 0, 45)
        StatusLabel.BackgroundColor3 = Color3.fromRGB(24, 25, 32)
        StatusLabel.Font = Enum.Font.GothamMedium
        StatusLabel.Text = "Status : Initializing Engine..."
        StatusLabel.TextColor3 = Color3.fromRGB(180, 185, 200)
        StatusLabel.TextSize = 13
        StatusLabel.TextWrapped = true
        StatusLabel.Parent = MainFrame
        local StatusCorner = Instance.new("UICorner")
        StatusCorner.CornerRadius = UDim.new(0, 8)
        StatusCorner.Parent = StatusLabel
    end)
end
task.spawn(InitMinimalUI)
local function UpdateStatus(statusText)
    local text = tostring(statusText or " Status : Idle")
    if StatusLabel and StatusLabel.Parent then
        local success = pcall(function()
            StatusLabel.Text = text
        end)
        if not success and sethiddenproperty then
            pcall(sethiddenproperty, StatusLabel, "Text", text)
        end
    end
end
local QuestsDatabase = {
    One_World = {
        {
            Min = 1,
            Max = 9,
            Ms = "Bandit",
            Mon = "Bandit",
            Quest = "BanditQuest1",
            QLv = 1,
            Next = 10,
            CQ = CFrame.new(1059.37, 15.45, 1550.42),
            CMon = CFrame.new(1185.07, 105.77, -1510.87)
        },
        {
            Min = 10,
            Max = 14,
            Ms = "Monkey",
            Mon = "Monkey",
            Quest = "JungleQuest",
            QLv = 1,
            Next = 15,
            CQ = CFrame.new(-1598.09, 35.55, 153.38),
            CMon = CFrame.new(-1498.40, 23.80, 85.90)
        },
        {
            Min = 15,
            Max = 29,
            Ms = "Gorilla",
            Mon = "Gorilla",
            Quest = "JungleQuest",
            QLv = 2,
            Next = 30,
            Fallback = "Monkey",
            CQ = CFrame.new(-1598.09, 35.55, 153.38),
            CMon = CFrame.new(-1245.80, 6.20, -495.20)
        },
        {
            Min = 30,
            Max = 39,
            Ms = "Pirate",
            Mon = "Pirate",
            Quest = "BuggyQuest1",
            QLv = 1,
            Next = 40,
            CQ = CFrame.new(-1141.07, 4.10, 3831.55),
            CMon = CFrame.new(-1215.50, 4.80, 3915.20)
        },
        {
            Min = 40,
            Max = 59,
            Ms = "Brute",
            Mon = "Brute",
            Quest = "BuggyQuest1",
            QLv = 2,
            Next = 60,
            Fallback = "Pirate",
            CQ = CFrame.new(-1141.07, 4.10, 3831.55),
            CMon = CFrame.new(-1352.40, 15.20, 4125.60)
        },
        {
            Min = 60,
            Max = 74,
            Ms = "Desert Bandit",
            Mon = "Desert Bandit",
            Quest = "DesertQuest",
            QLv = 1,
            Next = nil,
            CQ = CFrame.new(894.49, 5.14, 4392.43),
            CMon = CFrame.new(932.79, 6.85, 4488.25)
        },
        {
            Min = 75,
            Max = 89,
            Ms = "Desert Officer",
            Mon = "Desert Officer",
            Quest = "DesertQuest",
            QLv = 2,
            Next = 90,
            Fallback = "Desert Bandit",
            CQ = CFrame.new(894.49, 5.14, 4392.43),
            CMon = CFrame.new(1572.85, 10.37, 4373.58)
        },
        {
            Min = 90,
            Max = 99,
            Ms = "Snow Bandit",
            Mon = "Snow Bandit",
            Quest = "SnowQuest",
            QLv = 1,
            Next = nil,
            CQ = CFrame.new(1389.74, 86.65, -1298.91),
            CMon = CFrame.new(1287.65, 105.77, -1376.10)
        },
        {
            Min = 100,
            Max = 119,
            Ms = "Snowman",
            Mon = "Snowman",
            Quest = "SnowQuest",
            QLv = 2,
            Next = 120,
            Fallback = "Snow Bandit",
            CQ = CFrame.new(1389.74, 86.65, -1298.91),
            CMon = CFrame.new(1185.07, 105.77, -1510.87)
        },
        {
            Min = 120,
            Max = 149,
            Ms = "Chief Petty Officer",
            Mon = "Chief Petty Officer",
            Quest = "MarineQuest2",
            QLv = 1,
            Next = 150,
            CQ = CFrame.new(-4688.98, 5.88, 4226.45),
            CMon = CFrame.new(-4882.86, 22.65, 4255.54)
        },
        {
            Min = 150,
            Max = 174,
            Ms = "Sky Bandit",
            Mon = "Sky Bandit",
            Quest = "SkyQuest",
            QLv = 1,
            Next = 175,
            CQ = CFrame.new(-4839.53, 716.37, -2619.44),
            CMon = CFrame.new(-4981.40, 720.50, -2850.20)
        },
        {
            Min = 175,
            Max = 189,
            Ms = "Dark Master",
            Mon = "Dark Master",
            Quest = "SkyQuest",
            QLv = 2,
            Next = 190,
            Fallback = "Sky Bandit",
            CQ = CFrame.new(-4839.53, 716.37, -2619.44),
            CMon = CFrame.new(-5250.20, 730.10, -2990.80)
        },
        {
            Min = 190,
            Max = 209,
            Ms = "Prisoner",
            Mon = "Prisoner",
            Quest = "PrisonerQuest",
            QLv = 1,
            Next = 210,
            CQ = CFrame.new(5308.93, 1.66, 475.12),
            CMon = CFrame.new(5433.39, 88.68, 514.99)
        },
        {
            Min = 210,
            Max = 249,
            Ms = "Dangerous Prisoner",
            Mon = "Dangerous Prisoner",
            Quest = "PrisonerQuest",
            QLv = 2,
            Next = 250,
            Fallback = "Prisoner",
            CQ = CFrame.new(5308.93, 1.66, 475.12),
            CMon = CFrame.new(5540.20, 1.80, 620.50)
        },
        {
            Min = 250,
            Max = 274,
            Ms = "Toga Warrior",
            Mon = "Toga Warrior",
            Quest = "ColosseumQuest",
            QLv = 1,
            Next = 275,
            CQ = CFrame.new(-1576.12, 7.39, -2983.31),
            CMon = CFrame.new(-1817.97, 209.56, -12288.92)
        },
        {
            Min = 275,
            Max = 299,
            Ms = "Gladiator",
            Mon = "Gladiator",
            Quest = "ColosseumQuest",
            QLv = 2,
            Next = 300,
            Fallback = "Toga Warrior",
            CQ = CFrame.new(-1576.12, 7.39, -2983.31),
            CMon = CFrame.new(-1420.50, 7.40, -3150.20)
        },
        {
            Min = 300,
            Max = 324,
            Ms = "Military Soldier",
            Mon = "Military Soldier",
            Quest = "MagmaQuest",
            QLv = 1,
            Next = 325,
            CQ = CFrame.new(-5315.50, 12.20, 8515.80),
            CMon = CFrame.new(-5410.20, 35.80, 8680.10)
        },
        {
            Min = 325,
            Max = 374,
            Ms = "Military Spy",
            Mon = "Military Spy",
            Quest = "MagmaQuest",
            QLv = 2,
            Next = 375,
            Fallback = "Military Soldier",
            CQ = CFrame.new(-5315.50, 12.20, 8515.80),
            CMon = CFrame.new(-5850.40, 75.20, 8820.60)
        },
        {
            Min = 375,
            Max = 399,
            Ms = "Fishman Warrior",
            Mon = "Fishman Warrior",
            Quest = "FishmanQuest",
            QLv = 1,
            Next = 400,
            CQ = CFrame.new(61122.65, 18.50, 1569.40),
            CMon = CFrame.new(60938.82, 93.64, 1373.08)
        },
        {
            Min = 400,
            Max = 474,
            Ms = "Fishman Commando",
            Mon = "Fishman Commando",
            Quest = "FishmanQuest",
            QLv = 2,
            Next = 475,
            Fallback = "Fishman Warrior",
            CQ = CFrame.new(61122.65, 18.50, 1569.40),
            CMon = CFrame.new(61848.24, 55.50, 1461.36)
        },
        {
            Min = 475,
            Max = 524,
            Ms = "God's Guard",
            Mon = "God's Guard",
            Quest = "SkyExp1Quest",
            QLv = 1,
            Next = 525,
            CQ = CFrame.new(-4720.50, 845.20, -1950.40),
            CMon = CFrame.new(-4650.20, 850.50, -1820.10)
        },
        {
            Min = 525,
            Max = 624,
            Ms = "Shanda",
            Mon = "Shanda",
            Quest = "SkyExp2Quest",
            QLv = 1,
            Next = 625,
            CQ = CFrame.new(-7850.20, 5545.20, -490.50),
            CMon = CFrame.new(-7700.50, 5550.80, -380.20)
        },
        {
            Min = 625,
            Max = 649,
            Ms = "Galley Pirate",
            Mon = "Galley Pirate",
            Quest = "FountainQuest",
            QLv = 1,
            Next = 650,
            CQ = CFrame.new(5259.82, 37.35, 4050.03),
            CMon = CFrame.new(5420.50, 38.20, 4180.50)
        },
        {
            Min = 650,
            Max = 724,
            Ms = "Galley Captain",
            Mon = "Galley Captain",
            Quest = "FountainQuest",
            QLv = 2,
            Next = 725,
            Fallback = "Galley Pirate",
            CQ = CFrame.new(5259.82, 37.35, 4050.03),
            CMon = CFrame.new(5569.81, 38.53, 3849.01)
        }
    },

    Two_World = {
        {
            Min = 725,
            Max = 774,
            Ms = "Raider",
            Mon = "Raider",
            Quest = "Area1Quest",
            QLv = 1,
            Next = 775,
            CQ = CFrame.new(-429.54, 71.77, 1836.18),
            CMon = CFrame.new(-737.03, 10.17, 2392.58)
        },
        {
            Min = 775,
            Max = 799,
            Ms = "Mercenary",
            Mon = "Mercenary",
            Quest = "Area1Quest",
            QLv = 2,
            Next = 800,
            Fallback = "Raider",
            CQ = CFrame.new(-429.54, 71.77, 1836.18),
            CMon = CFrame.new(-920.50, 50.20, 2150.80)
        },
        {
            Min = 800,
            Max = 874,
            Ms = "Swan Pirate",
            Mon = "Swan Pirate",
            Quest = "Area2Quest",
            QLv = 1,
            Next = 875,
            CQ = CFrame.new(638.40, 73.10, 918.50),
            CMon = CFrame.new(850.20, 120.50, 1210.80)
        },
        {
            Min = 875,
            Max = 899,
            Ms = "Factory Staff",
            Mon = "Factory Staff",
            Quest = "Area2Quest",
            QLv = 2,
            Next = 900,
            Fallback = "Swan Pirate",
            CQ = CFrame.new(638.40, 73.10, 918.50),
            CMon = CFrame.new(280.50, 75.80, -120.50)
        },
        {
            Min = 900,
            Max = 949,
            Ms = "Marine Lieutenant",
            Mon = "Marine Lieutenant",
            Quest = "MarineQuest3",
            QLv = 1,
            Next = 950,
            CQ = CFrame.new(-2440.80, 73.20, -3215.50),
            CMon = CFrame.new(-2680.20, 75.10, -3050.40)
        },
        {
            Min = 950,
            Max = 974,
            Ms = "Marine Captain",
            Mon = "Marine Captain",
            Quest = "MarineQuest3",
            QLv = 2,
            Next = 975,
            Fallback = "Marine Lieutenant",
            CQ = CFrame.new(-2440.80, 73.20, -3215.50),
            CMon = CFrame.new(-2920.50, 80.40, -3350.20)
        },
        {
            Min = 975,
            Max = 999,
            Ms = "Zombie",
            Mon = "Zombie",
            Quest = "ZombieQuest",
            QLv = 1,
            Next = 1000,
            CQ = CFrame.new(-5497.06, 47.59, -795.22),
            CMon = CFrame.new(-5649.23, 126.06, -737.77)
        },
        {
            Min = 1000,
            Max = 1099,
            Ms = "Vampire",
            Mon = "Vampire",
            Quest = "ZombieQuest",
            QLv = 2,
            Next = 1100,
            Fallback = "Zombie",
            CQ = CFrame.new(-5497.06, 47.59, -795.22),
            CMon = CFrame.new(-6064.07, 15.24, -4902.98)
        },
        {
            Min = 1100,
            Max = 1124,
            Ms = "Lab Subordinate",
            Mon = "Lab Subordinate",
            Quest = "IceSideQuest",
            QLv = 1,
            Next = 1125,
            CQ = CFrame.new(-6064.07, 15.24, -4902.98),
            CMon = CFrame.new(-5769.20, 37.93, -4468.39)
        },
        {
            Min = 1125,
            Max = 1174,
            Ms = "Horned Warrior",
            Mon = "Horned Warrior",
            Quest = "IceSideQuest",
            QLv = 2,
            Next = 1175,
            Fallback = "Lab Subordinate",
            CQ = CFrame.new(-6064.07, 15.24, -4902.98),
            CMon = CFrame.new(-6423.83, 43.16, -5842.85)
        },
        {
            Min = 1175,
            Max = 1199,
            Ms = "Magma Ninja",
            Mon = "Magma Ninja",
            Quest = "FireSideQuest",
            QLv = 1,
            Next = 1200,
            CQ = CFrame.new(-5428.03, 15.06, -5299.43),
            CMon = CFrame.new(-5433.39, 88.68, 514.99)
        },
        {
            Min = 1200,
            Max = 1249,
            Ms = "Lava Pirate",
            Mon = "Lava Pirate",
            Quest = "FireSideQuest",
            QLv = 2,
            Next = 1250,
            Fallback = "Magma Ninja",
            CQ = CFrame.new(-5428.03, 15.06, -5299.43),
            CMon = CFrame.new(-5210.50, 45.80, -4850.20)
        },
        {
            Min = 1250,
            Max = 1299,
            Ms = "Ship Deckhand",
            Mon = "Ship Deckhand",
            Quest = "ShipQuest1",
            QLv = 1,
            Next = 1300,
            CQ = CFrame.new(968.81, 125.09, 33244.13),
            CMon = CFrame.new(917.96, 136.90, 33343.41)
        },
        {
            Min = 1300,
            Max = 1349,
            Ms = "Ship Engineer",
            Mon = "Ship Engineer",
            Quest = "ShipQuest1",
            QLv = 2,
            Next = 1350,
            Fallback = "Ship Deckhand",
            CQ = CFrame.new(968.81, 125.09, 33244.13),
            CMon = CFrame.new(880.50, 140.20, 32950.40)
        },
        {
            Min = 1350,
            Max = 1374,
            Ms = "Arctic Warrior",
            Mon = "Arctic Warrior",
            Quest = "FrostQuest",
            QLv = 1,
            Next = 1375,
            CQ = CFrame.new(5667.66, 26.80, -6486.09),
            CMon = CFrame.new(5850.20, 35.80, -6210.50)
        },
        {
            Min = 1375,
            Max = 1499,
            Ms = "Snow Lurker",
            Mon = "Snow Lurker",
            Quest = "FrostQuest",
            QLv = 2,
            Next = 1500,
            Fallback = "Arctic Warrior",
            CQ = CFrame.new(5667.66, 26.80, -6486.09),
            CMon = CFrame.new(5569.81, 38.53, 3849.01)
        }
    },

    Three_World = {
        {
            Min = 1500,
            Max = 1524,
            Ms = "Pirate Millionaire",
            Mon = "Pirate Millionaire",
            Quest = "PiratePortQuest",
            QLv = 1,
            Next = 1525,
            CQ = CFrame.new(-290.07, 42.90, 5581.59),
            CMon = CFrame.new(-4839.53, 716.37, -2619.44)
        },
        {
            Min = 1525,
            Max = 1574,
            Ms = "Pistol Billionaire",
            Mon = "Pistol Billionaire",
            Quest = "PiratePortQuest",
            QLv = 2,
            Next = 1575,
            Fallback = "Pirate Millionaire",
            CQ = CFrame.new(-290.07, 42.90, 5581.59),
            CMon = CFrame.new(-3212.00, 263.81, -10551.88)
        },
        {
            Min = 1575,
            Max = 1624,
            Ms = "Dragon Crew Warrior",
            Mon = "Dragon Crew Warrior",
            Quest = "AmazonQuest",
            QLv = 1,
            Next = 1625,
            CQ = CFrame.new(5832.84, 51.68, -1101.52),
            CMon = CFrame.new(6250.40, 55.20, -1350.80)
        },
        {
            Min = 1625,
            Max = 1649,
            Ms = "Female Islander",
            Mon = "Female Islander",
            Quest = "AmazonQuest2",
            QLv = 1,
            Next = 1650,
            CQ = CFrame.new(5832.84, 51.68, -1101.52),
            CMon = CFrame.new(5448.86, 601.52, 751.13)
        },
        {
            Min = 1650,
            Max = 1699,
            Ms = "Giant Islander",
            Mon = "Giant Islander",
            Quest = "AmazonQuest2",
            QLv = 2,
            Next = 1700,
            Fallback = "Female Islander",
            CQ = CFrame.new(5832.84, 51.68, -1101.52),
            CMon = CFrame.new(4770.50, 758.96, 1069.87)
        },
        {
            Min = 1700,
            Max = 1749,
            Ms = "Marine Commodore",
            Mon = "Marine Commodore",
            Quest = "MarineTreeIsland",
            QLv = 1,
            Next = 1750,
            CQ = CFrame.new(-2440.50, 73.50, -3215.20),
            CMon = CFrame.new(-2650.20, 75.80, -3050.40)
        },
        {
            Min = 1750,
            Max = 1824,
            Ms = "Marine Rear Admiral",
            Mon = "Marine Rear Admiral",
            Quest = "MarineTreeIsland",
            QLv = 2,
            Next = 1825,
            Fallback = "Marine Commodore",
            CQ = CFrame.new(-2440.50, 73.50, -3215.20),
            CMon = CFrame.new(-2920.50, 80.40, -3350.20)
        },
        {
            Min = 1825,
            Max = 1899,
            Ms = "Forest Pirate",
            Mon = "Forest Pirate",
            Quest = "DeepForestIsland",
            QLv = 1,
            Next = 1900,
            CQ = CFrame.new(-11194.54, 442.03, -8608.81),
            CMon = CFrame.new(-11194.54, 442.03, -8608.81)
        },
        {
            Min = 1900,
            Max = 1974,
            Ms = "Mythological Pirate",
            Mon = "Mythological Pirate",
            Quest = "DeepForestIsland2",
            QLv = 1,
            Next = 1975,
            CQ = CFrame.new(-12463.60, 386.62, -7566.08),
            CMon = CFrame.new(-13150.20, 410.50, -7820.60)
        },
        {
            Min = 1975,
            Max = 2024,
            Ms = "Jungle Pirate",
            Mon = "Jungle Pirate",
            Quest = "DeepForestIsland2",
            QLv = 2,
            Next = 2025,
            Fallback = "Mythological Pirate",
            CQ = CFrame.new(-12463.60, 386.62, -7566.08),
            CMon = CFrame.new(-13520.40, 420.20, -8150.20)
        },
        {
            Min = 2025,
            Max = 2049,
            Ms = "Demonic Soul",
            Mon = "Demonic Soul",
            Quest = "HauntedQuest2",
            QLv = 1,
            Next = 2050,
            CQ = CFrame.new(-9493.12, 172.17, 6149.69),
            CMon = CFrame.new(-9579.00, 6.00, 6194.00)
        },
        {
            Min = 2050,
            Max = 2099,
            Ms = "Posessed Mummy",
            Mon = "Posessed Mummy",
            Quest = "HauntedQuest2",
            QLv = 2,
            Next = 2100,
            Fallback = "Demonic Soul",
            CQ = CFrame.new(-9493.12, 172.17, 6149.69),
            CMon = CFrame.new(-9712.03, 204.70, 6193.32)
        },
        {
            Min = 2100,
            Max = 2124,
            Ms = "Peanut Scout",
            Mon = "Peanut Scout",
            Quest = "NutsIslandQuest",
            QLv = 1,
            Next = 2125,
            CQ = CFrame.new(-2104.39, 38.10, -10194.22),
            CMon = CFrame.new(-1948.40, 9.74, -9984.92)
        },
        {
            Min = 2125,
            Max = 2199,
            Ms = "Ice Cream Chef",
            Mon = "Ice Cream Chef",
            Quest = "IceCreamIslandQuest",
            QLv = 1,
            Next = 2200,
            CQ = CFrame.new(-820.40, 65.85, -10965.57),
            CMon = CFrame.new(-646.42, 85.85, -10892.42)
        },
        {
            Min = 2200,
            Max = 2249,
            Ms = "Cookie Crafter",
            Mon = "Cookie Crafter",
            Quest = "CakeQuest1",
            QLv = 1,
            Next = 2250,
            CQ = CFrame.new(-1928.32, 37.73, -12840.63),
            CMon = CFrame.new(-2150.20, 45.20, -12650.50)
        },
        {
            Min = 2250,
            Max = 2299,
            Ms = "Baking Staff",
            Mon = "Baking Staff",
            Quest = "CakeQuest2",
            QLv = 1,
            Next = 2300,
            CQ = CFrame.new(-1928.32, 37.73, -12840.63),
            CMon = CFrame.new(-1818.35, 57.07, -12999.04)
        },
        {
            Min = 2300,
            Max = 2349,
            Ms = "Cocoa Warrior",
            Mon = "Cocoa Warrior",
            Quest = "CakeQuest2",
            QLv = 2,
            Next = 2350,
            Fallback = "Baking Staff",
            CQ = CFrame.new(-1928.32, 37.73, -12840.63),
            CMon = CFrame.new(-2022.45, 37.80, -12029.09)
        },
        {
            Min = 2350,
            Max = 2449,
            Ms = "Chocolate Bar Battler",
            Mon = "Chocolate Bar Battler",
            Quest = "ChocQuest1",
            QLv = 2,
            Next = 2450,
            CQ = CFrame.new(151.20, 24.84, -12774.54),
            CMon = CFrame.new(315.43, 76.84, -12411.67)
        },
        {
            Min = 2450,
            Max = 2499,
            Ms = "Candy Rebel",
            Mon = "Candy Rebel",
            Quest = "CandyQuest1",
            QLv = 1,
            Next = 2500,
            CQ = CFrame.new(-1150.20, 15.80, -14250.60),
            CMon = CFrame.new(-1320.50, 25.40, -14520.10)
        },
        {
            Min = 2500,
            Max = 2549,
            Ms = "Island Boy",
            Mon = "Island Boy",
            Quest = "TikiQuest1",
            QLv = 1,
            Next = 2550,
            CQ = CFrame.new(-16800.35, 60.26, 290.22),
            CMon = CFrame.new(-16550.20, 55.40, 450.80)
        },
        {
            Min = 2550,
            Max = 2624,
            Ms = "Sun-kissed Warrior",
            Mon = "Sun-kissed Warrior",
            Quest = "TikiQuest2",
            QLv = 1,
            Next = 2625,
            CQ = CFrame.new(-16800.35, 60.26, 290.22),
            CMon = CFrame.new(-17100.50, 65.20, 180.40)
        },
        {
            Min = 2625,
            Max = 2649,
            Ms = "Coral Pirate",
            Mon = "Coral Pirate",
            Quest = "SubmergedQuest1",
            QLv = 2,
            Next = 2650,
            CQ = CFrame.new(10880.69, -2086.20, 10032.62),
            CMon = CFrame.new(10808.60, -2030.36, 9364.23)
        },
        {
            Min = 2650,
            Max = 2700,
            Ms = "Ocean Prophet",
            Mon = "Ocean Prophet",
            Quest = "SubmergedQuest2",
            QLv = 2,
            Next = nil,
            Fallback = "Coral Pirate",
            CQ = CFrame.new(10880.69, -2086.20, 10032.62),
            CMon = CFrame.new(11019.13, -2146.07, 9342.39)
        }
    }
}
local function GetQuestMob(monName, fullName)
    local lowerMon = monName and string.lower(monName) or ""
    local lowerFull = fullName and string.lower(fullName) or ""
    local function CheckModel(m)
        if not m or not m:IsA("Model") then return false end
        local hum = m:FindFirstChild("Humanoid")
        local hrp = m:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp or hum.Health <= 0 then return false end
        local lowerName = string.lower(m.Name)
        if lowerName == lowerMon or (lowerFull ~= "" and lowerName == lowerFull) then
            return true
        end
        if lowerMon ~= "" and string.find(lowerName, lowerMon, 1, true) then
            return true
        end
        return false
    end
    local enemiesFolder = Workspace:FindFirstChild("Enemies")
    if enemiesFolder then
        for _, mob in ipairs(enemiesFolder:GetChildren()) do
            if CheckModel(mob) then
                return mob
            end
        end
    end
    local charFolder = Workspace:FindFirstChild("Characters")
    if charFolder then
        for _, mob in ipairs(charFolder:GetChildren()) do
            if mob ~= LocalPlayer.Character and CheckModel(mob) then
                return mob
            end
        end
    end
    return nil
end
local function GetOptimalQuest(level)
    local worldTable = One_World and QuestsDatabase.One_World or (Two_World and QuestsDatabase.Two_World or QuestsDatabase.Three_World)
    if not worldTable or #worldTable == 0 then return nil end
    local exactQuest = nil
    local highestEligible = nil
    for _, q in ipairs(worldTable) do
        if level >= q.Min and level <= q.Max then
            exactQuest = q
            break
        end
        if level >= q.Min then
            if not highestEligible or q.Min > highestEligible.Min then
                highestEligible = q
            end
        end
    end
    if exactQuest then
        return exactQuest
    end
    if highestEligible then
        return highestEligible
    end
    return worldTable[1]
end
local BossesDatabase = {
    { Item = "Wardens Sword", Boss = "Chief Warden", Type = "Sword", Sea = 1, MinLevel = 100 },
    { Item = "Pole (1st Form)", Boss = "Thunder God", Type = "Sword", Sea = 1, MinLevel = 200 },
    { Item = "Saber", Boss = "Saber Expert", Type = "Sword", Sea = 1, MinLevel = 200 },
    { Item = "Bisento", Boss = "Greybeard", Type = "Sword", Sea = 1, MinLevel = 750 },
    { Item = "Cursed Dual Katana", Boss = "Cursed Skeleton", Type = "Sword", Sea = 3, MinLevel = 2200 },
    { Item = "Valkyrie Helm", Boss = "rip_indra True Form", Type = "Accessory", Sea = 3, MinLevel = 2000 }
}
local FightingStyles = {
    ["Black Leg"] = {
        Target = 300,
        Teacher = "Mad Scientist",
        BeliCost = 150000,
        FragCost = 0,
        MinSea = 1,
        BuyCommand = "BuyBlackLeg",
        Position = CFrame.new(-1288.38, 7.39, -3252.61)
    },
    ["Electro"] = {
        Target = 300,
        Teacher = "Mad Scientist",
        BeliCost = 500000,
        FragCost = 0,
        MinSea = 1,
        BuyCommand = "BuyElectro",
        Position = CFrame.new(-4957.67, 35.95, -4665.60)
    },
    ["Fishman Karate"] = {
        Target = 300,
        Teacher = "Water Kung Fu Teacher",
        BeliCost = 750000,
        FragCost = 0,
        MinSea = 1,
        BuyCommand = "BuyFishmanKarate",
        Position = CFrame.new(61122.65, 18.50, 1569.40)
    },
    ["Dragon Claw"] = {
        Target = 300,
        Teacher = "Sabi",
        BeliCost = 0,
        FragCost = 1500,
        MinSea = 2,
        BuyCommand = "BlackbeardReward",
        BuyArgs = { "DragonClaw", "2" },
        Position = CFrame.new(-9493.12, 172.17, 6149.69)
    },
    ["Superhuman"] = {
        Target = 300,
        Teacher = "Martial Arts Master",
        BeliCost = 3000000,
        FragCost = 0,
        MinSea = 2,
        BuyCommand = "BuySuperhuman",
        Position = CFrame.new(-4957.67, 35.95, -4665.60)
    },
    ["Death Step"] = {
        Target = 400,
        Teacher = "Phoeyu",
        BeliCost = 2500000,
        FragCost = 5000,
        MinSea = 2,
        BuyCommand = "BuyDeathStep",
        Requires = "Black Leg",
        Position = CFrame.new(5667.66, 26.80, -6486.09)
    },
    ["Sharkman Karate"] = {
        Target = 400,
        Teacher = "Daigrock",
        BeliCost = 2500000,
        FragCost = 5000,
        MinSea = 2,
        BuyCommand = "BuySharkmanKarate",
        Requires = "Fishman Karate",
        Position = CFrame.new(-1288.38, 7.39, -3252.61)
    },
    ["Electric Claw"] = {
        Target = 400,
        Teacher = "Previous Hero",
        BeliCost = 3000000,
        FragCost = 5000,
        MinSea = 3,
        BuyCommand = "BuyElectricClaw",
        Requires = "Electro",
        Position = CFrame.new(-11194.54, 442.03, -8608.81)
    },
    ["Dragon Talon"] = {
        Target = 400,
        Teacher = "Uzoth",
        BeliCost = 3000000,
        FragCost = 5000,
        MinSea = 3,
        BuyCommand = "BuyDragonTalon",
        Requires = "Dragon Claw",
        Position = CFrame.new(-5428.03, 15.06, -5299.43)
    },
    ["Godhuman"] = {
        Target = 600,
        Teacher = "Ancient Monk",
        BeliCost = 5000000,
        FragCost = 5000,
        MinSea = 3,
        BuyCommand = "BuyGodhuman",
        Position = CFrame.new(-5027.03, 326.79, -3206.70)
    }
}
local GodhumanStyleOrder = {
    { Name = "Superhuman",       MinSea = 2, Target = 400, BuyOnly = false },
    { Name = "Death Step",       MinSea = 2, Target = 400, BuyOnly = false },
    { Name = "Sharkman Karate",  MinSea = 2, Target = 400, BuyOnly = false },
    { Name = "Electric Claw",    MinSea = 3, Target = 400, BuyOnly = false },
    { Name = "Dragon Talon",     MinSea = 3, Target = 400, BuyOnly = false }
}
local function GetInventory(forceRefresh)
    local genv = getgenv()
    local cache = genv.KaitunInventoryCache
    local isCacheValid = not forceRefresh and type(cache) == "table" and cache.Ready == true
        and type(cache.Items) == "table" and type(cache.ByName) == "table"
        and type(cache.ByType) == "table" and type(cache.Materials) == "table"
    if isCacheValid and tick() - (cache.Time or 0) < 3 then
        return cache.Items
    end
    local success, inventoryData = pcall(function()
        local modules = genv.KaitunInventoryModules
        if type(modules) ~= "table" then
            local rs = game:GetService("ReplicatedStorage")
            modules = {
                Service = require(rs.ItemReplicationService),
                Config = require(rs.ItemConfig),
                Keys = require(rs.ItemReplicationService.KEYS)
            }
            genv.KaitunInventoryModules = modules
        end
        local service = modules.Service
        local config = modules.Config
        local keys = modules.Keys
        local rawItems = service:GetItems(keys.IS_OWNED)
        local itemsList = {}
        local byName = {}
        local byType = {}
        local materials = {}
        local metaCache = genv.KaitunItemMetaCache or {}
        genv.KaitunItemMetaCache = metaCache
        local function ReadItemProperty(propKey, itemEntry)
            if not propKey then return nil end
            local ok, val = pcall(service.ReadItem, service, propKey, itemEntry.ItemId, itemEntry.NetworkedUID)
            return ok and val or nil
        end
        local validItemCount = 0
        local iterSource = type(rawItems) == "table" and rawItems or {}
        for _, itemEntry in pairs(iterSource) do
            if itemEntry.Value then
                validItemCount = validItemCount + 1
                local itemMeta = metaCache[itemEntry.ItemId]
                if not itemMeta then
                    pcall(function()
                        local matchResult = config.match(itemEntry.ItemId):unwrap()
                        local indexInfo = matchResult.Index or {}
                        local idType = indexInfo.IdType or "Unknown"
                        local resolvedType = idType
                        if idType == "Moveset" then
                            resolvedType = (matchResult.Moveset and matchResult.Moveset.Type)
                                or (matchResult.Display and matchResult.Display.Category)
                                or idType
                        elseif idType == "PhysicalMoveset" then
                            resolvedType = "Blox Fruit"
                        end
                        local price = nil
                        if resolvedType == "Blox Fruit" and matchResult.Quality then
                            price = tonumber(matchResult.Quality.MoneyPrice)
                        end
                        local rarity = matchResult.Quality and (matchResult.Quality.Rarity or matchResult.Quality.RarityValue) or nil
                        itemMeta = {
                            Name = indexInfo.StorageKey or indexInfo.DebugLabel,
                            Type = resolvedType,
                            HasMastery = (idType == "Moveset"),
                            Price = price,
                            Rarity = rarity
                        }
                        metaCache[itemEntry.ItemId] = itemMeta
                    end)
                end
                if itemMeta and itemMeta.Name then
                    local count = 1
                    local mastery = 0
                    if itemMeta.Type == "Material" then
                        count = tonumber(ReadItemProperty(keys.QUANTITY, itemEntry)) or 1
                    else
                        if itemMeta.HasMastery or itemMeta.Type == "Sword" or itemMeta.Type == "Melee" or itemMeta.Type == "Gun" or itemMeta.Type == "Moveset" then
                            mastery = tonumber(ReadItemProperty(keys.MASTERY, itemEntry)) or 0
                        end
                    end
                    local itemRecord = {
                        Name = itemMeta.Name,
                        Type = itemMeta.Type,
                        Count = count,
                        Mastery = mastery,
                        Price = itemMeta.Price,
                        Value = itemMeta.Price,
                        Rarity = itemMeta.Rarity,
                        ItemId = itemEntry.ItemId,
                        NetworkedUID = itemEntry.NetworkedUID
                    }
                    table.insert(itemsList, itemRecord)
                    byName[itemMeta.Name] = itemRecord
                    if not byType[itemMeta.Type] then
                        byType[itemMeta.Type] = {}
                    end
                    table.insert(byType[itemMeta.Type], itemRecord)
                    if itemMeta.Type == "Material" then
                        materials[itemMeta.Name] = (materials[itemMeta.Name] or 0) + count
                    end
                end
            end
        end
        if validItemCount == 0 or #itemsList == 0 then
            error("inventory replication is not ready")
        end
        return {
            Items = itemsList,
            ByName = byName,
            ByType = byType,
            Materials = materials,
            Time = tick(),
            Ready = true
        }
    end)
    if not success or type(inventoryData) ~= "table" then
        return (type(cache) == "table" and type(cache.Items) == "table") and cache.Items or {}
    end
    genv.KaitunInventoryCache = inventoryData
    return inventoryData.Items
end
local function GetMaterialCount(materialName)
    GetInventory()
    local cache = getgenv().KaitunInventoryCache
    return type(cache) == "table" and type(cache.Materials) == "table" and tonumber(cache.Materials[materialName]) or 0
end
local function GetItemsByType(categoryName)
    GetInventory()
    local cache = getgenv().KaitunInventoryCache
    return type(cache) == "table" and type(cache.ByType) == "table" and cache.ByType[categoryName] or {}
end
local function HasItem(itemName)
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp and bp:FindFirstChild(itemName) then
        return true
    end
    local char = LocalPlayer.Character
    if char and char:FindFirstChild(itemName) then
        return true
    end
    GetInventory()
    local cache = getgenv().KaitunInventoryCache
    return type(cache) == "table" and type(cache.ByName) == "table" and cache.ByName[itemName] ~= nil
end
local MasteryCache = {
    Masteries = {},
    NextRefreshAt = 0
}
local function GetMasteries(force)
    if not force and tick() < MasteryCache.NextRefreshAt then
        return MasteryCache.Masteries
    end
    local success, result = pcall(function()
        return CommF_:InvokeServer("getFightingStyles")
    end)
    if success and type(result) == "table" then
        MasteryCache.Masteries = result
        MasteryCache.NextRefreshAt = tick() + 0.75
        return result
    end
    MasteryCache.NextRefreshAt = tick() + 0.5
    return nil
end
local function GetGodhumanNextStep(force)
    if HasItem("Godhuman") then
        return nil
    end
    local masteries = GetMasteries(force)
    if type(masteries) ~= "table" then
        return nil
    end
    for _, style in ipairs(GodhumanStyleOrder) do
        local name = style.Name
        local level = masteries[name]
        if level == nil then
            return {
                Mode = "BUY",
                Name = name,
                MinSea = style.MinSea
            }
        end
        if not style.BuyOnly and level < style.Target then
            return {
                Mode = "MASTERY",
                Name = name,
                Target = style.Target,
                MinSea = style.MinSea
            }
        end
    end
    return {
        Mode = "BUY",
        Name = "Godhuman"
    }
end
local function GetGodhumanMasteryTarget()
    local step = GetGodhumanNextStep(false)
    return step and step.Mode == "MASTERY" and step.Name or nil
end
local AnchorPart = workspace:FindFirstChild("Rip_Indra")
if not AnchorPart then
    AnchorPart = Instance.new("Part", workspace)
    AnchorPart.Size = Vector3.new(1, 1, 1)
    AnchorPart.Name = "Rip_Indra"
    AnchorPart.Anchored = true
    AnchorPart.CanCollide = false
    AnchorPart.CanTouch = false
    AnchorPart.Transparency = 1
end
getgenv().OnFarm = true
local PosMon = nil
local _B = true
local function BringEnemy()
    if not _B or not PosMon then return end
    pcall(function()
        local enemies = Workspace:FindFirstChild("Enemies")
        if not enemies then return end
        for _, enemy in pairs(enemies:GetChildren()) do
            local hum = enemy:FindFirstChild("Humanoid")
            local root = enemy.PrimaryPart or enemy:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and root then
                if (root.Position - PosMon).Magnitude <= 300 then
                    root.CFrame = CFrame.new(PosMon)
                    root.CanCollide = true
                    hum.WalkSpeed = 0
                    hum.JumpPower = 0
                    if hum:FindFirstChild("Animator") then
                        hum.Animator:Destroy()
                    end
                    pcall(function()
                        sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
                    end)
                end
            end
        end
    end)
end
task.spawn(function()
    repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character.PrimaryPart
    AnchorPart.CFrame = LocalPlayer.Character.PrimaryPart.CFrame
    while task.wait() do
        pcall(function()
            local char = LocalPlayer.Character
            local root = char and (char.PrimaryPart or char:FindFirstChild("HumanoidRootPart"))
            if getgenv().OnFarm then
                if root and AnchorPart and AnchorPart.Parent == workspace then
                    if (root.Position - AnchorPart.Position).Magnitude <= 200 then
                        root.CFrame = AnchorPart.CFrame
                    else
                        AnchorPart.CFrame = root.CFrame
                    end
                end
                if char then
                    for _, p in pairs(char:GetChildren()) do
                        if p:IsA("BasePart") then
                            p.CanCollide = false
                        end
                    end
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp and not hrp:FindFirstChild("BodyClip") then
                        local bv = Instance.new("BodyVelocity")
                        bv.Name = "BodyClip"
                        bv.Parent = hrp
                        bv.MaxForce = Vector3.new(100000, 100000, 100000)
                        bv.Velocity = Vector3.new(0, 0, 0)
                    end
                end
            else
                if char then
                    for _, p in pairs(char:GetChildren()) do
                        if p:IsA("BasePart") then
                            p.CanCollide = true
                        end
                    end
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp and hrp:FindFirstChild("BodyClip") then
                        hrp.BodyClip:Destroy()
                    end
                end
            end
        end)
    end
end)
local function HoldPosition(targetCF)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        if targetCF then
            hrp.CFrame = targetCF
            if AnchorPart then AnchorPart.CFrame = targetCF end
        end
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        local clip = hrp:FindFirstChild("BodyClip")
        if not clip then
            clip = Instance.new("BodyVelocity")
            clip.Name = "BodyClip"
            clip.MaxForce = Vector3.new(100000, 100000, 100000)
            clip.Velocity = Vector3.zero
            clip.Parent = hrp
        end
    end
end
local function EnableNoclip()
    getgenv().OnFarm = true
end
local function DisableNoclip()
    getgenv().OnFarm = false
end
local WorldGates = {}
if Old_World then
    WorldGates = {
        { name = "Sea1Pair1AToB", gate = CFrame.new(-6024.18, 5471.35, 2218.09), remote = Vector3.new(-4166.60986328125, 1093.697998046875, -347.1622619628906) },
        { name = "Sea1Pair2AToB", gate = CFrame.new(4041.83, -3.07, -1810.55),  remote = Vector3.new(61167.36, -2.93, 1950.91), next = 3 },
        { name = "Sea1Pair2BToA", gate = CFrame.new(61167.36, -2.93, 1950.91),  remote = Vector3.new(4041.83, -3.07, -1810.55), next = 2 }
    }
elseif New_World then
    WorldGates = {
        { name = "Sea2PairAToB", gate = CFrame.new(-6501.28, 83.46, -124.42),   remote = Vector3.new(922.89, 125.36, 32843.34), next = 2 },
        { name = "Sea2PairBToA", gate = CFrame.new(922.89, 125.36, 32843.34),   remote = Vector3.new(-6501.28, 83.46, -124.42), next = 1 }
    }
elseif Three_World then
    WorldGates = {
        { name = "CastleToHydra",   gate = CFrame.new(-5027.03, 326.79, -3206.70), remote = Vector3.new(5650.95, 1025.57, -350.38),   next = 2 },
        { name = "HydraToCastle",   gate = CFrame.new(5650.95, 1025.57, -350.38),  remote = Vector3.new(-5027.03, 326.79, -3206.70),  next = 1 },
        { name = "CastleToMansion", gate = CFrame.new(-5059.82, 326.79, -3192.29), remote = Vector3.new(-12463.60, 386.62, -7566.08), next = 4 },
        { name = "MansionToCastle", gate = CFrame.new(-12463.60, 386.62, -7566.08), remote = Vector3.new(-5059.82, 326.79, -3192.29), next = 3 }
    }
    pcall(function()
        table.insert(WorldGates, { name = "CastleToTiki", gate = CFrame.new(-5095.44, 316.79, -3175.76), remote = Vector3.new(-16800.35, 60.26, 290.22), next = 6 })
        table.insert(WorldGates, { name = "TikiToCastle", gate = CFrame.new(-16800.35, 60.26, 290.22), remote = Vector3.new(-5095.44, 316.79, -3175.76), next = 5 })
    end)
end
local function FindBestGateRoute(startPos, endPos, gates)
    local bestDistance = (endPos - startPos).Magnitude
    local bestGate = nil
    local function SearchRoutes(currentPos, accumulatedDist, visitedIndices)
        if #visitedIndices > 0 then
            local directRemaining = (endPos - currentPos).Magnitude
            local totalRoute = accumulatedDist + directRemaining
            if totalRoute < bestDistance then
                bestDistance = totalRoute
                bestGate = gates[visitedIndices[1]]
            end
        end
        if #visitedIndices >= #gates then return end
        for idx, gate in ipairs(gates) do
            local alreadyVisited = false
            for _, v in ipairs(visitedIndices) do
                if v == idx then alreadyVisited = true; break end
            end
            if not alreadyVisited then
                local distToGate = (currentPos - gate.gate.Position).Magnitude
                table.insert(visitedIndices, idx)
                local nextGate = gate.next and gates[gate.next]
                local arrivalPos = nextGate and nextGate.gate.Position or gate.remote
                SearchRoutes(arrivalPos, accumulatedDist + distToGate, visitedIndices)
                table.remove(visitedIndices)
            end
        end
    end
    SearchRoutes(startPos, 0, {})
    return bestGate, bestDistance
end
local function HoldInPortal(targetRemote)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local holdVelocity = hrp:FindFirstChild("_KaitunPortalHold")
    if holdVelocity and not holdVelocity:IsA("BodyVelocity") then
        holdVelocity:Destroy()
        holdVelocity = nil
    end
    if not holdVelocity then
        holdVelocity = Instance.new("BodyVelocity")
        holdVelocity.Name = "_KaitunPortalHold"
        holdVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
        holdVelocity.P = 100000
        holdVelocity.Velocity = Vector3.new(0, 0, 0)
        holdVelocity.Parent = hrp
    end
    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    local startPos = hrp.Position
    pcall(function()
        CommF_:InvokeServer("requestEntrance", targetRemote)
    end)
    local step = 0
    while task.wait(0.1) do
        step = step + 1
        local c = LocalPlayer.Character
        local root = c and c:FindFirstChild("HumanoidRootPart")
        if (root and (root.Position - startPos).Magnitude > 150) or step > 30 then
            break
        end
    end
    getgenv().PortalCooldown = tick() + 10
    if holdVelocity then
        holdVelocity:Destroy()
    end
end
local CurrentTween = nil
local CurrentTweenGoal = nil
local TweenSpeed = 210
local function ToTarget(targetDestination)
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root or hum.Health <= 0 then return end
    if hum.Sit then
        hum.Sit = false
        hum.Jump = true
        task.wait(0.1)
        if not hum.SeatPart then
            root.CFrame = root.CFrame * CFrame.new(0, 10, 0)
        end
        return
    end
    local targetCF = typeof(targetDestination) == "CFrame" and targetDestination or CFrame.new(targetDestination)
    local destPos = targetCF.Position
    local currentPos = root.Position
    local isSubmergedCrossing = (destPos.Y < -1000 and currentPos.Y > -1000) or (destPos.Y > -1000 and currentPos.Y < -1000)
    if isSubmergedCrossing then
        if destPos.Y < -1000 then
            local subWorkerCFrame = CFrame.new(-16270, 25, 1379)
            if (root.Position - subWorkerCFrame.Position).Magnitude > 50 then
                ToTarget(subWorkerCFrame)
                return
            end
            pcall(function()
                Net["RF/SubmarineWorkerSpeak"]:InvokeServer("TravelToSubmergedIsland")
            end)
            local timeout = tick() + 8
            while task.wait(0.1) do
                local c = LocalPlayer.Character
                local r = c and c:FindFirstChild("HumanoidRootPart")
                if (r and r.Position.Y < -1000) or tick() >= timeout then break end
            end
            return
        else
            local subTeleportCFrame = CFrame.new(11427, -2155, 9730)
            if (root.Position - subTeleportCFrame.Position).Magnitude > 50 then
                ToTarget(subTeleportCFrame)
                return
            end
            pcall(function()
                Net["RF/SubmarineTransportation"]:InvokeServer("InitiateTeleport", "Tiki Outpost")
            end)
            local timeout = tick() + 8
            while task.wait(0.1) do
                local c = LocalPlayer.Character
                local r = c and c:FindFirstChild("HumanoidRootPart")
                if (r and r.Position.Y > -1000) or tick() >= timeout then break end
            end
            return
        end
    end
    local totalDist = (destPos - currentPos).Magnitude
    if getgenv().UsePortalTP and totalDist > 2000 and tick() >= (getgenv().PortalCooldown or 0) then
        local bestGate, bestDist = FindBestGateRoute(currentPos, destPos, WorldGates)
        if bestGate and bestDist < totalDist - 1000 then
            if (currentPos - bestGate.gate.Position).Magnitude > 5 then
                ToTarget(bestGate.gate)
                return
            end
            HoldInPortal(bestGate.remote)
            return
        end
    end
    getgenv().OnFarm = true
    local dist = (targetCF.Position - root.Position).Magnitude
    if dist <= 12 then
        if CurrentTween then
            pcall(function() CurrentTween:Cancel() end)
            CurrentTween = nil
        end
        CurrentTweenGoal = targetCF
        AnchorPart.CFrame = targetCF
        root.CFrame = targetCF
        return
    end
    if CurrentTween and CurrentTweenGoal
        and CurrentTween.PlaybackState == Enum.PlaybackState.Playing
        and (CurrentTweenGoal.Position - targetCF.Position).Magnitude <= 15 then
        return CurrentTween
    end
    if CurrentTween then
        pcall(function() CurrentTween:Cancel() end)
        CurrentTween = nil
    end
    CurrentTweenGoal = targetCF
    local speed = tonumber(getgenv().TweenSpeed) or tonumber(TweenSpeed) or 210
    if speed > 220 then speed = 220 end
    if speed < 50 then speed = 200 end
    local tweenInfo = TweenInfo.new(dist / speed, Enum.EasingStyle.Linear)
    CurrentTween = TweenService:Create(AnchorPart, tweenInfo, { CFrame = targetCF })
    if hum.Sit == true then
        AnchorPart.CFrame = CFrame.new(AnchorPart.Position.X, targetCF.Y, AnchorPart.Position.Z)
    end
    CurrentTween.Completed:Connect(function()
        CurrentTween = nil
        CurrentTweenGoal = nil
    end)
    CurrentTween:Play()
end
local _tp = ToTarget
local function EquipBestWeapon()
    pcall(function()
        local char = LocalPlayer.Character
        local bp = LocalPlayer:FindFirstChild("Backpack")
        if not char or not bp then return end
        local targetType = getgenv().Configs and getgenv().Configs.TargetWeapon or "Melee"
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") and (tool:GetAttribute("WeaponType") == targetType or tool.ToolTip == targetType) then
                return tool
            end
        end
        for _, tool in ipairs(bp:GetChildren()) do
            if tool:IsA("Tool") and (tool:GetAttribute("WeaponType") == targetType or tool.ToolTip == targetType) then
                char.Humanoid:EquipTool(tool)
                return tool
            end
        end
        for _, tool in ipairs(bp:GetChildren()) do
            if tool:IsA("Tool") and (tool.ToolTip == "Melee" or tool.ToolTip == "Sword") then
                char.Humanoid:EquipTool(tool)
                return tool
            end
        end
    end)
end
local function GetEnemiesInRadius(char, isLocal)
    local root = isLocal and char:FindFirstChild("HumanoidRootPart")
    local origin = root and root.Position or char:GetPivot().Position
    local enemies = {}
    local searchFolders = {
        Workspace:FindFirstChild("Characters"),
        Workspace:FindFirstChild("Enemies")
    }
    for _, folder in ipairs(searchFolders) do
        if folder then
            for _, model in ipairs(folder:GetChildren()) do
                local hum = model:FindFirstChild("Humanoid")
                local hrp = model:FindFirstChild("HumanoidRootPart")
                if hum and hrp and hum.Health > 0 and (not isLocal or model ~= char) then
                    if (hrp.Position - origin).Magnitude <= 60 then
                        table.insert(enemies, model)
                    end
                end
            end
        end
    end
    return enemies
end
task.spawn(function()
    while task.wait(0.05) do
        if getgenv()["Fast Attack"] and not Stop_Fast_Attack and CurrentQuest ~= "Electro" and CurrentQuest ~= "Fishman Karate" then
            local char = LocalPlayer.Character
            local tool = char and char:FindFirstChildOfClass("Tool")
            if tool then
                local hitBatch = {}
                for _, enemy in ipairs(GetEnemiesInRadius(char, false)) do
                    local hitPart = enemy:FindFirstChild(TargetLimbs[math.random(1, #TargetLimbs)]) or enemy.PrimaryPart
                    if hitPart then
                        table.insert(hitBatch, { enemy, hitPart })
                    end
                end
                if #hitBatch > 0 then
                    pcall(function()
                        Net["RE/RegisterAttack"]:FireServer(0.05)
                        Net["RE/RegisterHit"]:FireServer(hitBatch[1][2], hitBatch)
                    end)
                end
            end
        end
    end
end)
RunService.Heartbeat:Connect(function()
    if not getgenv()["Fast Attack"] or Stop_Fast_Attack or CurrentQuest == "Electro" or CurrentQuest == "Fishman Karate" then
        return
    end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local tool = char and char:FindFirstChildOfClass("Tool")
    if not hrp or not tool then return end
    local enemies = GetEnemiesInRadius(char, true)
    if #enemies > 0 then
        local firstEnemy = enemies[1]
        local hitPart = firstEnemy:FindFirstChild(TargetLimbs[math.random(1, #TargetLimbs)]) or firstEnemy.PrimaryPart
        if hitPart then
            pcall(function()
                Net["RE/RegisterHit"]:FireServer(hitPart, { { firstEnemy, hitPart } })
            end)
        end
    end
end)
local FollowerConnection = nil
local function SyncFollower(targetInstance)
    if FollowerConnection then
        FollowerConnection:Disconnect()
        FollowerConnection = nil
    end
    if not targetInstance or not targetInstance.Parent then return end
    local initialRotation = targetInstance:GetPivot().Rotation
    FollowerConnection = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not targetInstance or not targetInstance.Parent or not hrp then
            if FollowerConnection then
                FollowerConnection:Disconnect()
                FollowerConnection = nil
            end
            return
        end
        targetInstance:PivotTo(CFrame.new(hrp.Position) * initialRotation)
    end)
end
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if getgenv().Configs and getgenv().Configs["Auto Buso"] then
                local char = LocalPlayer.Character
                if char and not char:FindFirstChild("HasBuso") then
                    CommF_:InvokeServer("Buso")
                end
            end
            if getgenv().Configs and getgenv().Configs["Auto Stats"] then
                local data = LocalPlayer:FindFirstChild("Data")
                if data and data:FindFirstChild("Points") and data.Points.Value > 0 then
                    local points = data.Points.Value
                    local melee = data.Stats.Melee.Level.Value
                    local defense = data.Stats.Defense.Level.Value
                    local sword = data.Stats.Sword.Level.Value
                    if melee < maxStat then
                        CommF_:InvokeServer("AddPoint", "Melee", points)
                    elseif defense < maxStat then
                        CommF_:InvokeServer("AddPoint", "Defense", points)
                    elseif sword < maxStat then
                        CommF_:InvokeServer("AddPoint", "Sword", points)
                    end
                end
            end
        end)
    end
end)
task.spawn(function()
    while task.wait(2) do
        pcall(function()
            local bp = LocalPlayer:FindFirstChild("Backpack")
            local char = LocalPlayer.Character
            if bp then
                for _, item in pairs(bp:GetChildren()) do
                    if item:IsA("Tool") and (item:FindFirstChild("EatRemote") or item:GetAttribute("FruitName")) then
                        CommF_:InvokeServer("StoreFruit", item:GetAttribute("FruitName") or item.Name, item)
                    end
                end
            end
            if char then
                for _, item in pairs(char:GetChildren()) do
                    if item:IsA("Tool") and (item:FindFirstChild("EatRemote") or item:GetAttribute("FruitName")) then
                        CommF_:InvokeServer("StoreFruit", item:GetAttribute("FruitName") or item.Name, item)
                    end
                end
            end
            if getgenv().Configs and getgenv().Configs["Snipe Fruit"] then
                for _, obj in pairs(Workspace:GetChildren()) do
                    if obj:IsA("Tool") and (obj:FindFirstChild("Handle") or obj:FindFirstChild("EatRemote")) then
                        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if hrp and obj:FindFirstChild("Handle") then
                            UpdateStatus(" Status : Sniping Dropped Fruit [" .. obj.Name .. "]")
                            hrp.CFrame = obj.Handle.CFrame * CFrame.new(0, 2, 0)
                            task.wait(0.5)
                        end
                    end
                end
            end
        end)
    end
end)
local lastFruitSpin = 0
local function AutoRandomFruit()
    if not (getgenv().Configs and getgenv().Configs["Auto Random Fruit"]) then return end
    if tick() - lastFruitSpin < 120 then return end
    pcall(function()
        local data = LocalPlayer:FindFirstChild("Data")
        local beli = data and data:FindFirstChild("Beli") and data.Beli.Value or 0
        local level = data and data:FindFirstChild("Level") and data.Level.Value or 1
        if level >= 50 and beli >= 100000 then
            CommF_:InvokeServer("Cousin", "Buy")
            lastFruitSpin = tick()
        end
    end)
end
local function AutoCollectChests()
    if not (getgenv().Configs and getgenv().Configs["Auto Chest"]) then return false end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local targetChest = nil
    local nearestDist = math.huge
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Part") and obj.Name:find("Chest") and obj:FindFirstChild("TouchInterest") then
            local dist = (hrp.Position - obj.Position).Magnitude
            if dist < nearestDist then
                nearestDist = dist
                targetChest = obj
            end
        end
    end
    if targetChest then
        UpdateStatus(" Status : Collecting Chest [" .. targetChest.Name .. "]")
        ToTarget(targetChest.CFrame * CFrame.new(0, 2, 0))
        return true
    end
    return false
end
local function PrioritizeRipIndra()
    if not Three_World then return false end
    local enemiesFolder = Workspace:FindFirstChild("Enemies")
    local ripIndra = Workspace:FindFirstChild("rip_indra True Form") or (enemiesFolder and enemiesFolder:FindFirstChild("rip_indra True Form"))
    if not ripIndra then return false end
    local hum = ripIndra:FindFirstChild("Humanoid")
    local root = ripIndra:FindFirstChild("HumanoidRootPart")
    if not hum or not root or hum.Health <= 0 then return false end
    UpdateStatus(" Status : Farming rip_indra True Form")
    _G.AimedTarget = ripIndra
    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = root.CFrame * CFrame.new(0, 30, 0)
            EquipBestWeapon()
        end
    end)
    return true
end
local function PrioritizeFactory()
    if not Two_World then return false end
    if not (getgenv().Configs and getgenv().Configs["Auto Factory"]) then return false end
    local enemiesFolder = Workspace:FindFirstChild("Enemies")
    local core = enemiesFolder and enemiesFolder:FindFirstChild("Core")
    if not core then return false end
    local hum = core:FindFirstChild("Humanoid")
    local root = core:FindFirstChild("HumanoidRootPart") or core:FindFirstChild("Head") or core:FindFirstChildWhichIsA("BasePart")
    if not hum or not root or hum.Health <= 0 then return false end
    UpdateStatus(" Status : Attacking Factory Core")
    _G.AimedTarget = core
    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = root.CFrame * CFrame.new(0, 25, 0)
            EquipBestWeapon()
        end
    end)
    return true
end
local function PrioritizePirateRaid()
    if not Three_World then return false end
    if not (getgenv().Configs and getgenv().Configs["Auto Pirate Raid"]) then return false end
    local enemiesFolder = Workspace:FindFirstChild("Enemies")
    if not enemiesFolder then return false end
    local raidPirate = nil
    for _, mob in pairs(enemiesFolder:GetChildren()) do
        if mob.Name:find("Pirate") and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 and mob:FindFirstChild("HumanoidRootPart") then
            local dist = (mob.HumanoidRootPart.Position - Vector3.new(-5543.5, 313.8, -2964.2)).Magnitude
            if dist < 600 then
                raidPirate = mob
                break
            end
        end
    end
    if raidPirate then
        UpdateStatus(" Status : Defending Castle Pirate Raid (" .. raidPirate.Name .. ")")
        _G.AimedTarget = raidPirate
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and raidPirate:FindFirstChild("HumanoidRootPart") then
            hrp.CFrame = raidPirate.HumanoidRootPart.CFrame * CFrame.new(0, 25, 0)
            EquipBestWeapon()
        end
        return true
    end
    return false
end
local eliteHunterPos = CFrame.new(-5418.89, 313.78, -2826.99)
local function PrioritizeEliteHunter()
    if not Three_World then return false end
    if not (getgenv().Configs and getgenv().Configs["Auto Elite Hunter"]) then return false end
    local enemiesFolder = Workspace:FindFirstChild("Enemies")
    local eliteNames = {["Deandre"] = true, ["Diablo"] = true, ["Urban"] = true}
    local eliteBoss = nil
    if enemiesFolder then
        for _, mob in pairs(enemiesFolder:GetChildren()) do
            if eliteNames[mob.Name] and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 and mob:FindFirstChild("HumanoidRootPart") then
                eliteBoss = mob
                break
            end
        end
    end
    if eliteBoss then
        UpdateStatus(" Status : Hunting Elite Boss (" .. eliteBoss.Name .. ")")
        _G.AimedTarget = eliteBoss
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and eliteBoss:FindFirstChild("HumanoidRootPart") then
            hrp.CFrame = eliteBoss.HumanoidRootPart.CFrame * CFrame.new(0, 25, 0)
            EquipBestWeapon()
        end
        return true
    end
    local status = CommF_:InvokeServer("EliteHunter", "Progress")
    if status and status:find("spotted") then
        CommF_:InvokeServer("EliteHunter")
    end
    return false
end
local deathKingPos = CFrame.new(-9515.6, 172.1, 6078.5)
local soulReaperAltarPos = CFrame.new(-8933.17, 146.83, 6067.89)
local function PrioritizeBones()
    if not Three_World then return false end
    if not (getgenv().Configs and getgenv().Configs["Auto Bones"]) then return false end
    local enemiesFolder = Workspace:FindFirstChild("Enemies")
    local soulReaper = enemiesFolder and enemiesFolder:FindFirstChild("Soul Reaper")
    if soulReaper and soulReaper:FindFirstChild("Humanoid") and soulReaper.Humanoid.Health > 0 and soulReaper:FindFirstChild("HumanoidRootPart") then
        UpdateStatus(" Status : Slaying Soul Reaper (Hallow Scythe Hunt)")
        _G.AimedTarget = soulReaper
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = soulReaper.HumanoidRootPart.CFrame * CFrame.new(0, 25, 0)
            EquipBestWeapon()
        end
        return true
    end
    if HasItem("Hallow Essence") then
        UpdateStatus(" Status : Placing Hallow Essence on Altar")
        ToTarget(soulReaperAltarPos)
        return true
    end
    local boneCount = GetMaterialCount("Bones")
    if boneCount >= 50 then
        UpdateStatus(" Status : Rolling Death King Random Surprise")
        CommF_:InvokeServer("Bones", "Buy", 1, 1)
    end
    local boneMobNames = {["Reborn Skeleton"] = true, ["Living Zombie"] = true, ["Demonic Soul"] = true, ["Posessed Mummy"] = true}
    local targetMob = nil
    if enemiesFolder then
        for _, mob in pairs(enemiesFolder:GetChildren()) do
            if boneMobNames[mob.Name] and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 and mob:FindFirstChild("HumanoidRootPart") then
                targetMob = mob
                break
            end
        end
    end
    if targetMob then
        UpdateStatus(" Status : Farming Bones (" .. targetMob.Name .. ")")
        _G.AimedTarget = targetMob
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and targetMob:FindFirstChild("HumanoidRootPart") then
            hrp.CFrame = targetMob.HumanoidRootPart.CFrame * CFrame.new(0, 25, 0)
            EquipBestWeapon()
        end
        return true
    else
        ToTarget(CFrame.new(-9516.99, 172.01, 6078.46))
        return true
    end
end
local cakeLandPortalPos = CFrame.new(-2103.7, 70.0, -12165.7)
local function PrioritizeCakePrince()
    if not Three_World then return false end
    if not (getgenv().Configs and getgenv().Configs["Auto Cake Prince"]) then return false end
    local enemiesFolder = Workspace:FindFirstChild("Enemies")
    local doughKing = enemiesFolder and (enemiesFolder:FindFirstChild("Dough King") or enemiesFolder:FindFirstChild("Cake Prince"))
    if doughKing and doughKing:FindFirstChild("Humanoid") and doughKing.Humanoid.Health > 0 and doughKing:FindFirstChild("HumanoidRootPart") then
        UpdateStatus(" Status : Slaying " .. doughKing.Name .. " (Mirror Fractal Hunt)")
        _G.AimedTarget = doughKing
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = doughKing.HumanoidRootPart.CFrame * CFrame.new(0, 25, 0)
            EquipBestWeapon()
        end
        return true
    end
    if HasItem("God's Chalice") and GetMaterialCount("Conjured Cocoa") >= 10 then
        UpdateStatus(" Status : Crafting Sweet Chalice for Dough King")
        CommF_:InvokeServer("CakePrinceSpawner", true)
    end
    local cakeMobNames = {["Peanut Scout"] = true, ["Peanut President"] = true, ["Ice Cream Chef"] = true, ["Ice Cream Commander"] = true, ["Cookie Crafter"] = true, ["Cake Guard"] = true}
    local cakeMob = nil
    if enemiesFolder then
        for _, mob in pairs(enemiesFolder:GetChildren()) do
            if cakeMobNames[mob.Name] and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 and mob:FindFirstChild("HumanoidRootPart") then
                cakeMob = mob
                break
            end
        end
    end
    if cakeMob then
        UpdateStatus(" Status : Farming Cake Land Mobs (" .. cakeMob.Name .. ")")
        _G.AimedTarget = cakeMob
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and cakeMob:FindFirstChild("HumanoidRootPart") then
            hrp.CFrame = cakeMob.HumanoidRootPart.CFrame * CFrame.new(0, 25, 0)
            EquipBestWeapon()
        end
        return true
    end
    return false
end
local ttkDealerLocations = {
    CFrame.new(-1580.9, 7.3, -2982.5),  
    CFrame.new(-2608.2, 73.1, -1960.3), 
    CFrame.new(-6508.6, 89.0, -132.8),  
    CFrame.new(638.4, 73.2, 918.5)      
}
local ttkCraftPos = CFrame.new(-1022.4, 1148.7, -3424.2) 
local function PrioritizeTTK()
    if not Two_World then return false end
    if not (getgenv().Configs and getgenv().Configs["Auto TTK"]) then return false end
    if HasItem("True Triple Katana") then return false end
    local hasShisui = HasItem("Shisui")
    local hasSaddi = HasItem("Saddi")
    local hasWando = HasItem("Wando")
    if hasShisui and hasSaddi and hasWando then
        local masteries = getFightingStyles()
        local sM = masteries and masteries["Shisui"] or 300
        local saM = masteries and masteries["Saddi"] or 300
        local wM = masteries and masteries["Wando"] or 300
        if sM >= 300 and saM >= 300 and wM >= 300 then
            UpdateStatus(" Status : Crafting True Triple Katana with Mysterious Man")
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                if (hrp.Position - ttkCraftPos.Position).Magnitude > 20 then
                    ToTarget(ttkCraftPos)
                    return true
                else
                    CommF_:InvokeServer("MysteriousMan")
                    return true
                end
            end
        end
    end
    local managerStatus = CommF_:InvokeServer("CheckHunt")
    if managerStatus and managerStatus:find("here") then
        for _, loc in ipairs(ttkDealerLocations) do
            ToTarget(loc)
            task.wait(1)
            if not hasShisui then CommF_:InvokeServer("BuyItem", "Shisui") end
            if not hasSaddi then CommF_:InvokeServer("BuyItem", "Saddi") end
            if not hasWando then CommF_:InvokeServer("BuyItem", "Wando") end
        end
        return true
    end
    return false
end
local function PrioritizeMirageIsland()
    if not Three_World then return false end
    if not (getgenv().Configs and getgenv().Configs["Auto Mirage Island"]) then return false end
    local locationsFolder = Workspace:FindFirstChild("_WorldOrigin") and Workspace._WorldOrigin:FindFirstChild("Locations")
    local mirage = (locationsFolder and locationsFolder:FindFirstChild("Mirage Island")) or Workspace:FindFirstChild("Mirage Island")
    if mirage then
        UpdateStatus(" Status : Mirage Island Detected!")
        local lighting = game:GetService("Lighting")
        local sky = lighting:FindFirstChildWhichIsA("Sky")
        local isFullMoon = lighting:GetAttribute("MoonPhase") == 5 or (sky and sky.MoonTextureId:find("9709149431"))
        if isFullMoon then
            UpdateStatus(" Status : Full Moon on Mirage Island - Resonating Gear")
            local char = LocalPlayer.Character
            if char and not char:FindFirstChild("RaceEnergy") then
                CommF_:InvokeServer("ActivateAbility")
            end
        end
        return true
    end
    return false
end
local function PrioritizeSeaEvents()
    if not (getgenv().Configs and getgenv().Configs["Auto Sea Events"]) then return false end
    if not (Two_World or Three_World) then return false end
    local enemiesFolder = Workspace:FindFirstChild("Enemies")
    if not enemiesFolder then return false end
    local seaBeast = enemiesFolder:FindFirstChild("SeaBeast") or enemiesFolder:FindFirstChild("SeaBeast1")
    if seaBeast and seaBeast:FindFirstChild("Humanoid") and seaBeast.Humanoid.Health > 0 and seaBeast:FindFirstChild("HumanoidRootPart") then
        UpdateStatus(" Status : Slaying Sea Beast")
        _G.AimedTarget = seaBeast
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = seaBeast.HumanoidRootPart.CFrame * CFrame.new(0, 35, 0)
            EquipBestWeapon()
        end
        return true
    end
    local terrorShark = enemiesFolder:FindFirstChild("Terrorshark")
    if terrorShark and terrorShark:FindFirstChild("Humanoid") and terrorShark.Humanoid.Health > 0 and terrorShark:FindFirstChild("HumanoidRootPart") then
        UpdateStatus(" Status : Slaying Terrorshark")
        _G.AimedTarget = terrorShark
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = terrorShark.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0)
            EquipBestWeapon()
        end
        return true
    end
    for _, mob in pairs(enemiesFolder:GetChildren()) do
        if (mob.Name == "Shark" or mob.Name == "Piranha" or mob.Name:find("Crew")) and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 and mob:FindFirstChild("HumanoidRootPart") then
            UpdateStatus(" Status : Defending Ship (" .. mob.Name .. ")")
            _G.AimedTarget = mob
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, 25, 0)
                EquipBestWeapon()
            end
            return true
        end
    end
    local kitsuneIsland = Workspace:FindFirstChild("Kitsune Island") or (Workspace:FindFirstChild("_WorldOrigin") and Workspace._WorldOrigin.Locations:FindFirstChild("Kitsune Island"))
    if kitsuneIsland then
        UpdateStatus(" Status : Kitsune Island Active - Collecting Azure Embers")
        for _, obj in pairs(Workspace:GetChildren()) do
            if obj.Name:find("Ember") and obj:FindFirstChildWhichIsA("BasePart") then
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = obj:FindFirstChildWhichIsA("BasePart").CFrame
                    task.wait(0.2)
                    CommF_:InvokeServer("KitsuneShrine")
                    return true
                end
            end
        end
    end
    if getgenv().Configs["Auto Shark Anchor"] and not HasItem("Shark Anchor") then
        if not HasItem("Monster Magnet") then
            if not HasItem("Shark Tooth Necklace") then
                if GetMaterialCount("Mutant Tooth") >= 1 and GetMaterialCount("Shark Tooth") >= 5 then
                    CommF_:InvokeServer("CraftItem", "ToothNecklace")
                end
            elseif not HasItem("Terror Jaw") then
                if GetMaterialCount("Terror Eyes") >= 1 and GetMaterialCount("Mutant Tooth") >= 2 then
                    CommF_:InvokeServer("CraftItem", "TerrorJaw")
                end
            else
                if GetMaterialCount("Terror Eyes") >= 2 and GetMaterialCount("Electric Wings") >= 8 and GetMaterialCount("Shark Tooth") >= 20 and GetMaterialCount("Mutant Tooth") >= 10 then
                    CommF_:InvokeServer("CraftItem", "MonsterMagnet")
                end
            end
        end
    end
    return false
end
local templeOfTimePos = CFrame.new(28310.02, 14895.11, 109.46)
local raceTrialDoors = {
    ["Human"]   = CFrame.new(29221.7, 14890.3, -24.3),
    ["Mink"]    = CFrame.new(29020.8, 14890.3, -380.2),
    ["Skypiea"] = CFrame.new(28642.4, 14890.3, -438.2),
    ["Fishman"] = CFrame.new(28231.2, 14890.3, -209.1),
    ["Ghoul"]   = CFrame.new(28678.9, 14890.3, 185.4),
    ["Cyborg"]  = CFrame.new(28503.2, 14890.3, 420.1)
}
local function PrioritizeRaceV4()
    if not Three_World then return false end
    if not (getgenv().Configs and getgenv().Configs["Auto Race V4"]) then return false end
    if not (HasItem("Valkyrie Helm") and HasItem("Mirror Fractal")) then return false end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local distToTemple = (hrp.Position - templeOfTimePos.Position).Magnitude
    if distToTemple > 3000 then
        UpdateStatus(" Status : Teleporting to Temple of Time")
        ToTarget(templeOfTimePos)
        return true
    end
    CommF_:InvokeServer("PullLever")
    local data = LocalPlayer:FindFirstChild("Data")
    local myRace = data and data:FindFirstChild("Race") and data.Race.Value or "Human"
    local trialDoor = raceTrialDoors[myRace]
    if trialDoor then
        local distToDoor = (hrp.Position - trialDoor.Position).Magnitude
        if distToDoor > 10 then
            UpdateStatus(" Status : Entering " .. myRace .. " Trial Door")
            ToTarget(trialDoor)
            return true
        else
            UpdateStatus(" Status : Activating Race V3 for Trial Entrance")
            CommF_:InvokeServer("ActivateAbility")
            task.wait(1)
        end
    end
    local enemiesFolder = Workspace:FindFirstChild("Enemies")
    if enemiesFolder then
        for _, mob in pairs(enemiesFolder:GetChildren()) do
            if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 and mob:FindFirstChild("HumanoidRootPart") then
                UpdateStatus(" Status : Slaying Trial Opponent (" .. mob.Name .. ")")
                _G.AimedTarget = mob
                hrp.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, 25, 0)
                EquipBestWeapon()
                return true
            end
        end
    end
    CommF_:InvokeServer("UpgradeRaceV4")
    return false
end
local raidLabPosSea2 = CFrame.new(-6460.7, 249.9, -4508.8)
local raidLabPosSea3 = CFrame.new(-5012.3, 314.5, -2824.7)
local function PrioritizeRaids()
    if not (getgenv().Configs and getgenv().Configs["Auto Raid"]) then return false end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local raidIslands = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("RaidIslands")
    local enemiesFolder = Workspace:FindFirstChild("Enemies")
    if raidIslands or (enemiesFolder and enemiesFolder:FindFirstChildWhichIsA("Model") and enemiesFolder:FindFirstChildWhichIsA("Model").Name:find("Raid")) then
        for _, mob in pairs(enemiesFolder:GetChildren()) do
            if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 and mob:FindFirstChild("HumanoidRootPart") then
                UpdateStatus(" Status : Clearing Raid Mob (" .. mob.Name .. ")")
                _G.AimedTarget = mob
                hrp.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, 25, 0)
                EquipBestWeapon()
                return true
            end
        end
        CommF_:InvokeServer("Awakener", "Awaken")
        return true
    end
    local selectedChip = getgenv().Configs.SelectedRaid or "Flame"
    local data = LocalPlayer:FindFirstChild("Data")
    local frags = data and data:FindFirstChild("Fragments") and data.Fragments.Value or 0
    if not HasItem("Special Microchip") then
        UpdateStatus(" Status : Purchasing " .. selectedChip .. " Raid Microchip")
        CommF_:InvokeServer("RaidsNpc", "Select", selectedChip)
        task.wait(1)
    end
    if HasItem("Special Microchip") then
        local labPos = Three_World and raidLabPosSea3 or raidLabPosSea2
        UpdateStatus(" Status : Entering Raid Chamber")
        ToTarget(labPos)
        return true
    end
    return false
end
local hornedManPos = CFrame.new(-11892.07, 930.58, -8760.16)
local rainbowBossOrder = {"Stone", "Island Empress", "Kilo Admiral", "Captain Elephant", "Beautiful Pirate"}
local function PrioritizeRainbowHaki()
    if not Three_World then return false end
    if not (getgenv().Configs and getgenv().Configs["Auto Rainbow Haki"]) then return false end
    local questGui = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("Main") and LocalPlayer.PlayerGui.Main:FindFirstChild("Quest")
    local hasQuest = questGui and questGui.Visible == true
    if not hasQuest then
        UpdateStatus(" Status : Taking Rainbow Haki Quest from Horned Man")
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            if (hrp.Position - hornedManPos.Position).Magnitude > 20 then
                ToTarget(hornedManPos)
                return true
            else
                CommF_:InvokeServer("HornedMan", "Bet")
                return true
            end
        end
    else
        local enemiesFolder = Workspace:FindFirstChild("Enemies")
        if enemiesFolder then
            for _, bossName in ipairs(rainbowBossOrder) do
                local boss = enemiesFolder:FindFirstChild(bossName)
                if boss and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 and boss:FindFirstChild("HumanoidRootPart") then
                    UpdateStatus(" Status : Defeating Rainbow Haki Boss (" .. bossName .. ")")
                    _G.AimedTarget = boss
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.CFrame = boss.HumanoidRootPart.CFrame * CFrame.new(0, 25, 0)
                        EquipBestWeapon()
                    end
                    return true
                end
            end
        end
    end
    return false
end
local function RunSaberPuzzle()
    if not One_World then return false end
    if HasItem("Saber") then return false end
    local data = LocalPlayer:FindFirstChild("Data")
    local level = data and data:FindFirstChild("Level") and data.Level.Value or 1
    if level < 200 then return false end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local map = Workspace:FindFirstChild("Map")
    local jungle = map and map:FindFirstChild("Jungle")
    if not jungle then return false end
    local plates = jungle:FindFirstChild("QuestPlates")
    if plates and plates:FindFirstChild("Door") and plates.Door.Transparency == 0 then
        UpdateStatus(" Status : Pressing Jungle Plates")
        for i = 1, 5 do
            local plate = plates:FindFirstChild("Plate" .. i)
            local btn = plate and plate:FindFirstChild("Button")
            if btn and btn.BrickColor.Name ~= "Lime green" then
                ToTarget(btn.CFrame * CFrame.new(0, 2, 0))
                task.wait(0.5)
                return true
            end
        end
    end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    local hasTorch = (bp and bp:FindFirstChild("Torch")) or (char and char:FindFirstChild("Torch"))
    local hasCup = (bp and bp:FindFirstChild("Cup")) or (char and char:FindFirstChild("Cup"))
    local hasRelic = (bp and bp:FindFirstChild("Relic")) or (char and char:FindFirstChild("Relic"))
    if not hasTorch and not hasCup and not hasRelic then
        local cellarPart = jungle:FindFirstChild("Final") and jungle.Final:FindFirstChild("Part")
        if cellarPart and cellarPart.Transparency == 0 then
            UpdateStatus(" Status : Grabbing Jungle Torch")
            ToTarget(CFrame.new(-1610.2, 12.2, 162.8))
            task.wait(0.5)
            return true
        end
    end
    if hasTorch then
        UpdateStatus(" Status : Burning Desert Door")
        ToTarget(CFrame.new(1114.6, 5.1, 4350.2))
        task.wait(0.5)
        return true
    end
    if hasCup then
        local cupTool = (char and char:FindFirstChild("Cup")) or (bp and bp:FindFirstChild("Cup"))
        if cupTool and not cupTool:GetAttribute("Filled") then
            UpdateStatus(" Status : Filling Cup with Water")
            ToTarget(CFrame.new(1398.2, 37.4, -1320.5))
            task.wait(0.5)
            return true
        else
            UpdateStatus(" Status : Speaking to Sick Man")
            pcall(function()
                CommF_:InvokeServer("SickMan")
            end)
            task.wait(0.5)
            UpdateStatus(" Status : Speaking to Rich Son")
            pcall(function()
                CommF_:InvokeServer("RichSon")
            end)
            task.wait(0.5)
            return true
        end
    end
    if not hasRelic then
        local enemies = Workspace:FindFirstChild("Enemies")
        local mobLeader = enemies and enemies:FindFirstChild("Mob Leader")
        if mobLeader and mobLeader:FindFirstChild("Humanoid") and mobLeader.Humanoid.Health > 0 then
            UpdateStatus(" Status : Slaying Mob Leader")
            _G.AimedTarget = mobLeader
            hrp.CFrame = mobLeader.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0)
            EquipBestWeapon()
            return true
        else
            UpdateStatus(" Status : Slaying Mob Leader (Moving)")
            ToTarget(CFrame.new(-2850.2, 7.4, 5320.5))
            pcall(function()
                CommF_:InvokeServer("RichSon")
            end)
            return true
        end
    end
    if hasRelic then
        local relicDoor = jungle:FindFirstChild("RelicDoor") or (jungle:FindFirstChild("Final") and jungle.Final:FindFirstChild("RelicDoor"))
        if relicDoor and relicDoor.Transparency == 0 then
            UpdateStatus(" Status : Inserting Relic into Door")
            ToTarget(CFrame.new(-1450.2, 29.8, -50.6))
            task.wait(0.5)
            return true
        end
        local enemies = Workspace:FindFirstChild("Enemies")
        local saberBoss = enemies and enemies:FindFirstChild("Saber Expert")
        if saberBoss and saberBoss:FindFirstChild("Humanoid") and saberBoss.Humanoid.Health > 0 then
            UpdateStatus(" Status : Defeating Saber Expert")
            _G.AimedTarget = saberBoss
            hrp.CFrame = saberBoss.HumanoidRootPart.CFrame * CFrame.new(0, 25, 0)
            EquipBestWeapon()
            return true
        else
            ToTarget(CFrame.new(-1458.9, 29.9, -50.6))
            return true
        end
    end
    return false
end
local function RunCDKProgression()
    if not Three_World then return false end
    if HasItem("Cursed Dual Katana") then return false end
    if not HasItem("Tushita") or not HasItem("Yama") then return false end
    local masteries = GetMasteries(false)
    if not masteries or (masteries["Tushita"] or 0) < 350 or (masteries["Yama"] or 0) < 350 then
        return false
    end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local cdkStatus = tostring(pcall(function() return CommF_:InvokeServer("CDKQuest", "OpenDoor") end))
    if cdkStatus ~= "opened" then
        pcall(function()
            CommF_:InvokeServer("CDKQuest", "OpenDoor", true)
        end)
    end
    local altarCFrame = CFrame.new(-12318.19, 601.95, -6538.66)
    local cdkProgress = nil
    pcall(function()
        cdkProgress = CommF_:InvokeServer("CDKQuest", "Progress")
    end)
    local alucardFragments = GetMaterialCount("Alucard Fragment")
    if alucardFragments >= 6 or (type(cdkProgress) == "table" and cdkProgress["Finished"]) then
        local enemies = Workspace:FindFirstChild("Enemies")
        local cursedBoss = enemies and (enemies:FindFirstChild("Cursed Skeleton Boss") or enemies:FindFirstChild("Cursed Skeleton"))
        if cursedBoss and cursedBoss:FindFirstChild("Humanoid") and cursedBoss.Humanoid.Health > 0 then
            UpdateStatus(" Status : Slaying Cursed Skeleton Boss (CDK)")
            _G.AimedTarget = cursedBoss
            hrp.CFrame = cursedBoss.HumanoidRootPart.CFrame * CFrame.new(0, 25, 0)
            if HasItem("Tushita") then
                getgenv().Configs.TargetWeapon = "Sword"
            end
            EquipBestWeapon()
            return true
        else
            UpdateStatus(" Status : Spawning CDK Boss Altar")
            ToTarget(altarCFrame)
            pcall(function()
                CommF_:InvokeServer("CDKQuest", "StartTrial", "Boss")
            end)
            return true
        end
    end
    pcall(function()
        CommF_:InvokeServer("CDKQuest", "Progress", "Good")
        CommF_:InvokeServer("CDKQuest", "StartTrial", "Good")
    end)
    pcall(function()
        CommF_:InvokeServer("CDKQuest", "Progress", "Evil")
        CommF_:InvokeServer("CDKQuest", "StartTrial", "Evil")
    end)
    return false
end
local function RunSoulGuitarPuzzle()
    if not Three_World then return false end
    if HasItem("Soul Guitar") then return false end
    local data = LocalPlayer:FindFirstChild("Data")
    local level = data and data:FindFirstChild("Level") and data.Level.Value or 1
    if level < 2300 then return false end
    local bones = GetMaterialCount("Bones")
    local ectoplasm = GetMaterialCount("Ectoplasm")
    local darkFrag = GetMaterialCount("Dark Fragment")
    local fragments = data and data:FindFirstChild("Fragments") and data.Fragments.Value or 0
    if bones < 500 or ectoplasm < 250 or darkFrag < 1 or fragments < 5000 then
        return false
    end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local isFullMoon = false
    pcall(function()
        local sky = Lighting:FindFirstChildOfClass("Sky")
        local moonId = sky and sky.MoonTextureId or ""
        isFullMoon = (string.find(moonId, "9709149431") ~= nil) or (Lighting.ClockTime >= 18 or Lighting.ClockTime <= 5)
    end)
    local hauntedGraveyard = CFrame.new(-9493.12, 172.17, 6149.69)
    local distToHaunted = (hrp.Position - hauntedGraveyard.Position).Magnitude
    if isFullMoon and distToHaunted > 100 then
        UpdateStatus(" Status : Traveling to Haunted Castle for Soul Guitar")
        ToTarget(hauntedGraveyard)
        return true
    end
    UpdateStatus(" Status : Praying at Gravestone (Soul Guitar)")
    pcall(function()
        CommF_:InvokeServer("gravestone", 1)
    end)
    pcall(function()
        CommF_:InvokeServer("soulGuitarBuy", true)
    end)
    return false
end
local function HopServer(targetMinPlayers, maxPing)
    UpdateStatus(" Status : Finding Low-Ping Server...")
    local api = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    local blacklistFile = "Kaitun_VisitedServers.json"
    local visited = {}
    if readfile and isfile and isfile(blacklistFile) then
        pcall(function()
            visited = HttpService:JSONDecode(readfile(blacklistFile))
        end)
    end
    if type(visited) ~= "table" then
        visited = {}
    end
    local response = nil
    pcall(function()
        response = game:HttpGet(api)
    end)
    if not response then return false end
    local data = nil
    pcall(function()
        data = HttpService:JSONDecode(response)
    end)
    if not data or not data.data then return false end
    for _, s in ipairs(data.data) do
        if type(s) == "table" and s.id and s.id ~= game.JobId and not visited[s.id] then
            local playersCount = s.playing or 0
            local maxSlots = s.maxPlayers or 12
            if playersCount < maxSlots - 1 and (not targetMinPlayers or playersCount >= targetMinPlayers) then
                visited[s.id] = tick()
                if writefile then
                    pcall(function()
                        writefile(blacklistFile, HttpService:JSONEncode(visited))
                    end)
                end
                UpdateStatus(" Status : Teleporting to Server [" .. s.id:sub(1, 8) .. "]")
                TeleportService:TeleportToPlaceInstance(PlaceId, s.id, LocalPlayer)
                task.wait(5)
                return true
            end
        end
    end
    return false
end
local lastWebhookReport = 0
local function SendKaitunWebhook()
    local url = getgenv().Configs and getgenv().Configs.WebhookUrl
    if not url or url == "" or not string.find(url, "https://discord") then
        return
    end
    local interval = getgenv().Configs.WebhookInterval or 300
    if tick() - lastWebhookReport < interval then
        return
    end
    lastWebhookReport = tick()
    pcall(function()
        local data = LocalPlayer:FindFirstChild("Data")
        local level = data and data:FindFirstChild("Level") and data.Level.Value or 1
        local beli = data and data:FindFirstChild("Beli") and data.Beli.Value or 0
        local frags = data and data:FindFirstChild("Fragments") and data.Fragments.Value or 0
        local masteries = GetMasteries(false) or {}
        local godhumanStep = GetGodhumanNextStep(false)
        local hasGodhuman = HasItem("Godhuman")
        local hasCDK = HasItem("Cursed Dual Katana")
        local hasSoulGuitar = HasItem("Soul Guitar")
        local currentSea = One_World and "Sea 1" or (Two_World and "Sea 2" or "Sea 3")
        local embed = {
            ["title"] = "Blox Fruits Kaitun Bot - Status Report",
            ["color"] = 3447003,
            ["fields"] = {
                { ["name"] = "Account", ["value"] = "||" .. LocalPlayer.Name .. "||", ["inline"] = true },
                { ["name"] = "World / Sea", ["value"] = currentSea, ["inline"] = true },
                { ["name"] = "Level", ["value"] = tostring(level) .. " / 2700", ["inline"] = true },
                { ["name"] = "Beli", ["value"] = string.format("%d", beli), ["inline"] = true },
                { ["name"] = "Fragments", ["value"] = string.format("%d", frags), ["inline"] = true },
                { ["name"] = "Current Quest", ["value"] = CurrentQuest ~= "" and CurrentQuest or "None", ["inline"] = true },
                { ["name"] = "Godhuman Status", ["value"] = hasGodhuman and "Unlocked" or (godhumanStep and (godhumanStep.Mode .. ": " .. godhumanStep.Name) or "In Progress"), ["inline"] = false },
                { ["name"] = "Weapons Tracker", ["value"] = string.format("CDK: %s | Soul Guitar: %s | Saber: %s", hasCDK and "Yes" or "No", hasSoulGuitar and "Yes" or "No", HasItem("Saber") and "Yes" or "No"), ["inline"] = false }
            },
            ["footer"] = { ["text"] = "CYBR-MAHI Kaitun Engine | " .. os.date("%X") }
        }
        local payload = HttpService:JSONEncode({ ["embeds"] = { embed } })
        local requestFn = (syn and syn.request) or (http and http.request) or http_request or request
        if requestFn then
            requestFn({
                Url = url,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = payload
            })
        end
    end)
end
local lastSeaTravelAttempt = 0
local function CheckSeaTransition(level)
    if tick() - lastSeaTravelAttempt < 5 then return false end
    if One_World and level >= 700 then
        UpdateStatus(" Status : Level 700 Reached - Traveling to Second Sea")
        lastSeaTravelAttempt = tick()
        pcall(function()
            CommF_:InvokeServer("TravelDressrosa")
        end)
        local detectivePos = CFrame.new(4854.6, 5.7, 742.6)
        ToTarget(detectivePos)
        task.wait(0.5)
        pcall(function()
            CommF_:InvokeServer("TravelDressrosa")
        end)
        return true
    end
    if Two_World and level >= 1500 then
        UpdateStatus(" Status : Level 1500 Reached - Traveling to Third Sea")
        lastSeaTravelAttempt = tick()
        pcall(function()
            CommF_:InvokeServer("TravelZou")
        end)
        local captainPos = CFrame.new(-26.3, 24.3, 2854.2)
        ToTarget(captainPos)
        task.wait(0.5)
        pcall(function()
            CommF_:InvokeServer("TravelZou")
        end)
        return true
    end
    return false
end
local function GetQuestUI()
    local pg = nil
    pcall(function()
        pg = LocalPlayer.PlayerGui or LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:FindFirstChild("PlayerGui")
    end)
    if not pg then return nil end
    local q = nil
    pcall(function()
        if pg:FindFirstChild("Main") and pg.Main:FindFirstChild("Quest") then
            q = pg.Main.Quest
        elseif pg:FindFirstChild("Quest") then
            q = pg.Quest
        else
            for _, child in ipairs(pg:GetChildren()) do
                if child.Name ~= "TestKaitunGui" and child:FindFirstChild("Quest") then
                    q = child.Quest
                    break
                end
            end
        end
    end)
    return q
end
local LastQuestAcceptTime = 0
local function CheckActiveQuest(targetMobName)
    local hasQuest = false
    local questText = ""
    pcall(function()
        local q = GetQuestUI()
        if q then
            if q.Visible == true then
                hasQuest = true
            end
            local container = q:FindFirstChild("Container")
            if container and container.Visible == true then
                hasQuest = true
            end
            local titleObj = q:FindFirstChild("QuestTitle", true)
            if titleObj then
                local label = titleObj:FindFirstChild("Title") or (titleObj:IsA("TextLabel") and titleObj)
                if label and type(label.Text) == "string" and #label.Text > 0 and label.Text ~= "Quest" then
                    questText = label.Text
                    hasQuest = true
                end
            end
        end
    end)
    if not hasQuest and (tick() - LastQuestAcceptTime) < 4 then
        hasQuest = true
    end
    if hasQuest and targetMobName and #questText > 0 then
        local lowerText = string.lower(questText)
        local lowerMob = string.lower(targetMobName)
        if not string.find(lowerText, lowerMob, 1, true) then
            pcall(function()
                CommF_:InvokeServer("AbandonQuest")
            end)
            task.wait(0.3)
            return false, ""
        end
    end
    return hasQuest, questText
end
task.spawn(function()
    while task.wait(0.2) do
        pcall(function()
            if not getgenv().Configs or not getgenv().Configs.AutoFarm then
                UpdateStatus(" Status : Idle")
                return
            end
            SendKaitunWebhook()
            AutoRandomFruit()
            local data = LocalPlayer:FindFirstChild("Data")
            local level = data and data:FindFirstChild("Level") and data.Level.Value or 1
            if Three_World and level >= 1500 and PrioritizeRipIndra() then
                return
            end
            if Two_World and level >= 750 and PrioritizeFactory() then
                return
            end
            if Three_World and level >= 1500 and PrioritizePirateRaid() then
                return
            end
            if CheckSeaTransition(level) then
                return
            end
            if One_World and level >= 200 and not HasItem("Saber") then
                if getgenv().Configs.Quest and getgenv().Configs.Quest.Saber then
                    if RunSaberPuzzle() then
                        return
                    end
                end
            end
            if Two_World and level >= 1000 and not HasItem("True Triple Katana") then
                if PrioritizeTTK() then
                    return
                end
            end
            if Three_World and level >= 1500 then
                if PrioritizeEliteHunter() then
                    return
                end
            end
            if Three_World and level >= 2200 and not HasItem("Cursed Dual Katana") then
                if getgenv().Configs.Quest and getgenv().Configs.Quest.CDK then
                    if RunCDKProgression() then
                        return
                    end
                end
            end
            if Three_World and level >= 2300 and not HasItem("Soul Guitar") then
                if getgenv().Configs.Quest and getgenv().Configs.Quest.SoulGuitar then
                    if RunSoulGuitarPuzzle() then
                        return
                    end
                end
            end
            if Three_World and level >= 2200 then
                if PrioritizeCakePrince() then
                    return
                end
            end
            if level < 2700 then
                local quest = GetOptimalQuest(level)
                if quest then
                    CurrentQuest = quest.Quest
                    local hasActiveQuest, currentQuestTitle = CheckActiveQuest(quest.Mon or quest.Ms)
                    if not hasActiveQuest then
                        UpdateStatus(" Status : Getting Quest [" .. quest.Quest .. "] (Lv " .. level .. ")")
                        local char = LocalPlayer.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        if hrp and quest.CQ then
                            local dist = (hrp.Position - quest.CQ.Position).Magnitude
                            if dist > 20 then
                                ToTarget(quest.CQ * CFrame.new(0, 5, 0))
                            else
                                if CurrentTween then
                                    pcall(function() CurrentTween:Cancel() end)
                                    CurrentTween = nil
                                end
                                hrp.CFrame = quest.CQ * CFrame.new(0, 5, 0)
                                hrp.AssemblyLinearVelocity = Vector3.zero
                                hrp.AssemblyAngularVelocity = Vector3.zero
                                pcall(function()
                                    CommF_:InvokeServer("StartQuest", quest.Quest, quest.QLv)
                                end)
                                LastQuestAcceptTime = tick()
                                task.wait(0.5)
                            end
                        end
                        return
                    else
                        UpdateStatus(" Status : Farming [" .. (quest.Mon or quest.FullName or quest.Ms or "Enemies") .. "] (Lv " .. level .. ")")
                        local char = LocalPlayer.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local targetMob = GetQuestMob(quest.Mon, quest.FullName or quest.Ms)
                            if targetMob and targetMob:FindFirstChild("HumanoidRootPart") and targetMob:FindFirstChild("Humanoid") and targetMob.Humanoid.Health > 0 then
                                _G.AimedTarget = targetMob
                                local mobRoot = targetMob.HumanoidRootPart
                                if not targetMob:GetAttribute("Locked") then
                                    targetMob:SetAttribute("Locked", mobRoot.CFrame)
                                end
                                PosMon = (targetMob:GetAttribute("Locked")).Position
                                BringEnemy()
                                local tool = EquipBestWeapon()
                                local toolTip = tool and tool.ToolTip or ""
                                local hoverCF = nil
                                if toolTip == "Blox Fruit" then
                                    hoverCF = (mobRoot.CFrame * CFrame.new(0, 8, 0)) * CFrame.Angles(0, math.rad(90), 0)
                                else
                                    hoverCF = (mobRoot.CFrame * CFrame.new(0, 15, 0)) * CFrame.Angles(0, math.rad(180), 0)
                                end
                                ToTarget(hoverCF)
                                pcall(function()
                                    local vu = game:GetService("VirtualUser")
                                    vu:CaptureController()
                                    vu:Button1Down(Vector2.new(0, 0))
                                end)
                                pcall(function()
                                    if Net and Net:FindFirstChild("RE/RegisterAttack") and Net:FindFirstChild("RE/RegisterHit") then
                                        Net["RE/RegisterAttack"]:FireServer(0)
                                        Net["RE/RegisterHit"]:FireServer(mobRoot, { { targetMob, mobRoot } })
                                    end
                                end)
                            else
                                _G.AimedTarget = nil
                                PosMon = nil
                                if quest.CMon then
                                    ToTarget(quest.CMon * CFrame.new(0, 25, 0))
                                end
                            end
                        end
                        return
                    end
                end
            end
            if getgenv().Configs.Quest and getgenv().Configs.Quest.Godhuman then
                local nextStep = GetGodhumanNextStep()
                if nextStep then
                    if nextStep.Mode == "BUY" then
                        local styleData = FightingStyles[nextStep.Name]
                        if styleData and styleData.Position then
                            UpdateStatus(" Status : Buying " .. nextStep.Name)
                            local char = LocalPlayer.Character
                            local hrp = char and char:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                if (hrp.Position - styleData.Position.Position).Magnitude > 20 then
                                    ToTarget(styleData.Position)
                                    return
                                else
                                    if styleData.BuyArgs then
                                        CommF_:InvokeServer(styleData.BuyCommand, table.unpack(styleData.BuyArgs))
                                    else
                                        CommF_:InvokeServer(styleData.BuyCommand)
                                    end
                                    return
                                end
                            end
                        end
                    elseif nextStep.Mode == "MASTERY" then
                        getgenv().Configs.TargetWeapon = "Melee"
                    end
                end
            end
            if Three_World and level >= 1900 and PrioritizeBones() then
                return
            end
            if Three_World and level >= 2000 and PrioritizeRaceV4() then
                return
            end
            if level >= 1100 and PrioritizeRaids() then
                return
            end
            if Three_World and level >= 1950 and PrioritizeRainbowHaki() then
                return
            end
            if (Two_World or Three_World) and level >= 1500 and PrioritizeSeaEvents() then
                return
            end
            if Three_World and PrioritizeMirageIsland() then
                return
            end
            if AutoCollectChests() then
                return
            end
            UpdateStatus(" Status : Idle (Max Level)")
        end)
    end
end)
