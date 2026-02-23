-- [[ 1. SERVICES ]]
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- [[ 2. INTRO UI ]]
local IntroGui = Instance.new("ScreenGui", CoreGui)
IntroGui.Name = "OceaHubIntro"
IntroGui.IgnoreGuiInset = true

local Main = Instance.new("Frame", IntroGui)
Main.Size = UDim2.fromOffset(420, 280)
Main.Position = UDim2.fromScale(0.5, 0.5)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
Main.BorderSizePixel = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 18)

-- Glow efekti (isteğe bağlı)
local UIStroke = Instance.new("UIStroke", Main)
UIStroke.Color = Color3.fromRGB(45, 45, 50)
UIStroke.Thickness = 2

local Welcome = Instance.new("TextLabel", Main)
Welcome.Size = UDim2.new(1, 0, 0, 160)
Welcome.Position = UDim2.fromOffset(0, 20)
Welcome.BackgroundTransparency = 1
Welcome.Font = Enum.Font.GothamBold
Welcome.TextColor3 = Color3.new(1, 1, 1)
Welcome.TextSize = 16
Welcome.Text = "WELCOME " .. LocalPlayer.Name .. "\n\nOceaHub: XLS Edition\n• Reach & MS Boost Added\n• " .. os.date("%d.%m.%y")

local OK = Instance.new("TextButton", Main)
OK.Size = UDim2.fromOffset(160, 45)
OK.Position = UDim2.new(0.5, -80, 1, -65)
OK.Text = "OK / PROCEED"
OK.Font = Enum.Font.GothamBold
OK.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
OK.TextColor3 = Color3.new(1, 1, 1)
OK.AutoButtonColor = true
Instance.new("UICorner", OK).CornerRadius = UDim.new(0, 12)

-- Intro Logic
local Proceed = false
OK.MouseButton1Click:Connect(function() 
    Proceed = true 
end)

-- Menü gelmeden önce bekleme
repeat task.wait() until Proceed 

-- Kapanış Animasyonu
TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(0,0), BackgroundTransparency = 1}):Play()
task.wait(0.55)
IntroGui:Destroy()

-- [[ 3. MACLIB UI SETUP (Intro'dan sonra başlar) ]]
local MacLib = loadstring(game:HttpGet("https://github.com/biggaboy212/Maclib/releases/latest/download/maclib.txt"))()
local Window = MacLib:Window({
    Title = "OceaHub", Subtitle = "XLS: Edition",
    Size = UDim2.fromOffset(850, 600), Keybind = Enum.KeyCode.RightControl, 
    AcrylicBlur = true, ShowUserInfo = true,
})

local tabGroup = Window:TabGroup()
local tabs = {
    Reach = tabGroup:Tab({ Name = "Hitbox Expander", Image = "rbxassetid://18821914323" }),
    MS    = tabGroup:Tab({ Name = "MS Engine", Image = "rbxassetid://11419717444" }),
}

-- [[ 4. GLOBALS ]]
_G.ReachSize = 0
_G.ReachTransparency = 0
_G.ArmReachSize = 0
_G.ArmReachTransparency = 0
_G.FakeMSActive = false
_G.MinPing = 145
_G.MaxPing = 160

-- [[ 5. SECTIONS ]]
local LegSec = tabs.Reach:Section({ Side = "Left" })
local ArmSec = tabs.Reach:Section({ Side = "Right" })
local MSLeft = tabs.MS:Section({ Side = "Left" })
local MSRight = tabs.MS:Section({ Side = "Right" })

-- Reach Ayarları
LegSec:Header({ Name = "Leg Reach (Bacak)" })
LegSec:Slider({ Name = "Size", Default = 0, Minimum = 0, Maximum = 10, Callback = function(v) _G.ReachSize = v end })
LegSec:Slider({ Name = "Transparency", Default = 0, Minimum = 0, Maximum = 1, Callback = function(v) _G.ReachTransparency = v end })

ArmSec:Header({ Name = "Arm Reach (Kol)" })
ArmSec:Slider({ Name = "Size", Default = 0, Minimum = 0, Maximum = 10, Callback = function(v) _G.ArmReachSize = v end })
ArmSec:Slider({ Name = "Transparency", Default = 0, Minimum = 0, Maximum = 1, Callback = function(v) _G.ArmReachTransparency = v end })

-- MS Ayarları
MSLeft:Header({ Name = "MS Boost (Clumsy)" })
MSLeft:Input({
    Name = "Lag Value (Sec)", Placeholder = "0.1", AcceptedCharacters = "NumbersAndDecimal",
    Callback = function(v)
        local num = tonumber(v)
        if num then settings().Network.IncomingReplicationLag = num end
    end
})

MSRight:Header({ Name = "Fake Tab MS" })
MSRight:Toggle({ Name = "Enable", Default = false, Callback = function(v) _G.FakeMSActive = v end })
MSRight:Slider({ Name = "Min", Default = 145, Minimum = 0, Maximum = 1000, Callback = function(v) _G.MinPing = v end })
MSRight:Slider({ Name = "Max", Default = 160, Minimum = 0, Maximum = 1000, Callback = function(v) _G.MaxPing = v end })

-- [[ 6. ENGINES ]]
local function CreateFakeLimb(original, name)
    if original and not original:FindFirstChild(name) then
        local fake = original:Clone()
        fake.Name = name; fake.Parent = original; fake.CanCollide = false; fake.Massless = true
        Instance.new("WeldConstraint", fake).Part0 = fake; fake.WeldConstraint.Part1 = original
        for _, v in pairs(original:GetChildren()) do
            if v:IsA("CharacterMesh") or v:IsA("SpecialMesh") or v:IsA("Texture") then v:Clone().Parent = fake end
        end
    end
end

RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if char then
        -- Legs
        for _, lName in pairs({"Right Leg", "Left Leg", "RightFoot", "LeftFoot"}) do
            local l = char:FindFirstChild(lName)
            if l and l:IsA("BasePart") then
                CreateFakeLimb(l, "LVisual")
                l.Size = Vector3.new(_G.ReachSize, 2, _G.ReachSize)
                l.Transparency = _G.ReachTransparency
            end
        end
        -- Arms
        for _, aName in pairs({"Right Arm", "Left Arm", "RightHand", "LeftHand"}) do
            local a = char:FindFirstChild(aName)
            if a and a:IsA("BasePart") then
                CreateFakeLimb(a, "AVisual")
                a.Size = Vector3.new(_G.ArmReachSize, _G.ArmReachSize, _G.ArmReachSize)
                a.Transparency = _G.ArmReachTransparency
            end
        end
    end
end)

local function HookPingLabels()
    for _, v in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
        if v.Name == "PlayerPing" and v:IsA("TextLabel") then
            if v:FindFirstAncestor(tostring(LocalPlayer.UserId)) or v.Parent.Name == tostring(LocalPlayer.UserId) then
                v:GetPropertyChangedSignal("Text"):Connect(function()
                    if _G.FakeMSActive then
                        local fakeMS = tostring(math.random(_G.MinPing, _G.MaxPing)) .. "ms"
                        if v.Text ~= fakeMS then v.Text = fakeMS end
                    end
                end)
            end
        end
    end
end
HookPingLabels()
