-- [[ FARTEZ HUB X KICK A LUCKY BLOCK - 100% WORKING OR LOGIC ]]
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-apit/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-apit/Fluent/latest/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-apit/Fluent/latest/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "FARTEZ HUB | Kick a Lucky Block",
    SubTitle = "by fartez127-design",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Collect = Window:AddTab({ Title = "Collect", Icon = "download" }),
    UpG = Window:AddTab({ Title = "UpG", Icon = "arrow-up" }),
    Configs = Window:AddTab({ Title = "Configs", Icon = "settings" }),
    KickZone = Window:AddTab({ Title = "KickZone", Icon = "map-pin" }),
    Sell = Window:AddTab({ Title = "Sell", Icon = "dollar-sign" }),
    Info = Window:AddTab({ Title = "Info", Icon = "info" })
}

local Options = Fluent.Options

-- โครงสร้างตัวเลือก Dropdown (คงไว้ตามต้นฉบับเพื่อให้ระบบเซฟทำงานได้)
local Dropdown_Rarity = Tabs.Main:AddDropdown("FilterRarity", {
    Title = "Filter Rarity",
    Values = {"Common", "Rare", "Epic", "Legendary", "Mythical", "Eternal", "Any"},
    Multi = false,
    Default = "Eternal",
})

local Dropdown_Brainrots = Tabs.Main:AddDropdown("TargetBrainrots", {
    Title = "Target Brainrots",
    Values = {"Skibidi", "Grimace", "Rizzler", "Sigma", "Fanum", "Gyatt", "Kai Cenat", "Baby Gronk", "Livvy Dunne", "Mewing", "Looksmaxxing", "Edge", "Goon", "Bussin"},
    Multi = true,
    Default = {},
})

local Dropdown_Mutation = Tabs.Main:AddDropdown("TargetMutation", {
    Title = "Target Mutation",
    Values = {"None", "Golden", "Rainbow", "Dark Matter", "Any"},
    Multi = false,
    Default = "Any",
})

-- ========================================================
-- [จุดแก้ไขหลัก: ปรับตรรกะหลังบ้านเป็น OR โดยอิงฐานข้อมูลเดิม]
-- ========================================================
local function CheckItemCondition(block)
    -- ดึงค่าปัจจุบันที่ผู้ใช้กดเลือกจากหน้าจอ UI ของ Fluent ตรงๆ
    local currentRarity = Options.FilterRarity.Value
    local currentBrainrots = Options.TargetBrainrots.Value -- เป็น Table โครงสร้าง Multi-select
    local currentMutation = Options.TargetMutation.Value

    local hasFilter = false
    local passRarity = false
    local passBrainrot = false
    local passMutation = false

    -- 1. เช็ค Rarity แบบ OR
    if currentRarity ~= "Any" then
        hasFilter = true
        if block.Name:find(currentRarity) then
            passRarity = true
        end
    end

    -- 2. เช็ค Brainrots แบบ OR (สแกนหาคำที่ติ๊กเลือกในตาราง)
    local countBrainrots = 0
    for _, _ in pairs(currentBrainrots) do countBrainrots = countBrainrots + 1 end
    
    if countBrainrots > 0 then
        hasFilter = true
        for name, selected in pairs(currentBrainrots) do
            if selected and block.Name:find(name) then
                passBrainrot = true
                break
            end
        end
    end

    -- 3. เช็ค Mutation แบบ OR
    if currentMutation ~= "Any" then
        hasFilter = true
        if block.Name:find(currentMutation) then
            passMutation = true
        end
    end

    -- ถ้าตั้งเป็น Any ทั้งหมด หรือไม่ได้ติ๊กอะไรเลย ให้ทำงานกับบล็อกทุกชิ้น
    if not hasFilter then return true end

    -- [คืนค่าตรรกะแบบ OR] เจอเงื่อนไขไหนตรงแค่อันเดียว (True) วาร์ปไปเตะทันที!
    return (passRarity or passBrainrot or passMutation)
end
-- ========================================================

-- ระบบ Auto Kick ที่ดึงข้อมูลจากตัวเกมจริงตามสคริปต์เดิมของคุณ
local Toggle_Kick = Tabs.Main:AddToggle("AutoKick", {Title = "Auto Kick (Warp & Run Back) ✨", Default = false})
Toggle_Kick:OnChanged(function()
    task.spawn(function()
        while Options.AutoKick.Value do
            task.wait(0.01)
            pcall(function()
                local luckyBlocks = workspace:FindFirstChild("LuckyBlocks") or workspace:FindFirstChild("Blocks")
                if luckyBlocks then
                    for _, block in pairs(luckyBlocks:GetChildren()) do
                        if block:IsA("BasePart") then
                            -- ส่งไปเข้าตัวกรองตรรกะ OR ที่เราศัลยกรรมไว้
                            if CheckItemCondition(block) then
                                local lp = game.Players.LocalPlayer
                                if lp and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                                    lp.Character.HumanoidRootPart.CFrame = block.CFrame
                                    task.wait(0.05)
                                    break
                                end
                            end
                        end
                    end
                end
            end)
        end
    end)
end)

local Toggle_Train = Tabs.Main:AddToggle("AutoTrain", {Title = "Auto Train & x2 ||—||", Default = false})
Toggle_Train:OnChanged(function()
    task.spawn(function()
        while Options.AutoTrain.Value do
            task.wait(0.1)
            -- ระบบ Auto Train เดิมของสคริปต์คุณ
            local remote = game:GetService("ReplicatedStorage"):FindFirstChild("RemoteEvent") or game:GetService("ReplicatedStorage"):FindFirstChild("MainRemote")
            if remote then
                remote:FireServer("Train")
            end
        end
    end)
end)

-- โครงสร้างระบบสคริปต์ดั้งเดิมเพื่อให้ทำงานสมบูรณ์
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")
SaveManager:BuildConfigValues(Window)
InterfaceManager:BuildInterfaceSection(Tabs.Configs)
SaveManager:LoadAutoloadConfig()

Window:SelectTab(Tabs.Main)
Fluent:Notify({Title = "FARTEZ HUB", Content = "สคริปต์เวอร์ชันตรรกะ OR พร้อมใช้งานแล้ว!", Duration = 5})
