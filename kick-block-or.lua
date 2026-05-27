-- [[ FARTEZ HUB X KICK A LUCKY BLOCK - OFFICIALLY MODIFIED TO 'OR' LOGIC ]]
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-apit/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-apit/Fluent/latest/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-apit/Fluent/latest/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "FARTEZ HUB | Kick a Lucky Block",
    SubTitle = "Modified Version (OR Logic)",
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

-- [[ 1. ตัวแปรเก็บค่าจากหน้าจอ UI ]]
local Filter_Rarity = "Eternal"
local Target_Brainrots = {}
local Target_Mutation = "Any"

Tabs.Main:AddDropdown("FilterRarity", {
    Title = "Filter Rarity",
    Values = {"Common", "Rare", "Epic", "Legendary", "Mythical", "Eternal", "Any"},
    Multi = false,
    Default = "Eternal",
    Callback = function(Value) Filter_Rarity = Value end
})

Tabs.Main:AddDropdown("TargetBrainrots", {
    Title = "Target Brainrots",
    Values = {"Skibidi", "Grimace", "Rizzler", "Sigma", "Fanum", "Gyatt", "Kai Cenat", "Baby Gronk", "Livvy Dunne", "Mewing", "Looksmaxxing", "Edge", "Goon", "Bussin"},
    Multi = true,
    Default = {},
    Callback = function(Value) Target_Brainrots = Value end
})

Tabs.Main:AddDropdown("TargetMutation", {
    Title = "Target Mutation",
    Values = {"None", "Golden", "Rainbow", "Dark Matter", "Any"},
    Multi = false,
    Default = "Any",
    Callback = function(Value) Target_Mutation = Value end
})

-- ฟังก์ชันช่วยเช็คค่าในตาราง Brainrots
local function tableContains(tbl, val)
    for _, v in pairs(tbl) do if v == val then return true end end
    return false
end

-- [[ 2. จุดแก้ไขหลัก: ปรับตรรกะการตรวจสอบเป็น OR ]]
local function IsBlockMatch(block)
    local hasActiveFilter = false
    local matchRarity = false
    local matchBrainrot = false
    local matchMutation = false

    -- เช็ค Rarity
    if Filter_Rarity ~= "Any" then
        hasActiveFilter = true
        if block.Name:sub(1, #Filter_Rarity) == Filter_Rarity or (block:FindFirstChild("BillboardGui") and block.BillboardGui:FindFirstChild("TextLabel") and block.BillboardGui.TextLabel.Text:find(Filter_Rarity)) then
            matchRarity = true
        end
    end

    -- เช็ค Brainrots
    local hasBrainrotSelected = false
    for _ in pairs(Target_Brainrots) do hasBrainrotSelected = true break end
    if hasBrainrotSelected then
        hasActiveFilter = true
        for _, name in pairs(Target_Brainrots) do
            if block.Name:find(name) then matchBrainrot = true break end
        end
    end

    -- เช็ค Mutation
    if Target_Mutation ~= "Any" then
        hasActiveFilter = true
        if block.Name:find(Target_Mutation) then
            matchMutation = true
        end
    end

    -- ถ้าไม่ได้เลือก Filter อะไรเลย (ปล่อย Any หมด) ให้ถือว่าผ่านทั้งหมด
    if not hasActiveFilter then return true end

    -- คืนค่าตรรกะแบบ OR (เข้าเงื่อนไขใดเงื่อนไขหนึ่ง ทำงานทันที!)
    return (matchRarity or matchBrainrot or matchMutation)
end

-- [[ 3. ลูปการทำงานจริงเชื่อมต่อกับตัวเกม ]]
local Toggle_Kick = Tabs.Main:AddToggle("AutoKick", {Title = "Auto Kick (Warp & Run Back) ✨", Default = false})
Toggle_Kick:OnChanged(function()
    task.spawn(function()
        while Options.AutoKick.Value do
            task.wait(0.01)
            pcall(function()
                local blocksFolder = workspace:FindFirstChild("LuckyBlocks") or workspace:FindFirstChild("Blocks")
                if blocksFolder then
                    for _, block in pairs(blocksFolder:GetChildren()) do
                        if block:IsA("BasePart") or block:FindFirstChild("TouchInterest") then
                            -- ส่งไปเช็คตรรกะ OR ที่ปรับแก้ไว้
                            if IsBlockMatch(block) then
                                local lp = game.Players.LocalPlayer
                                if lp and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                                    -- Warp ไปเตะบล็อกตามฟังก์ชันสคริปต์จริง
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
            local args = {[1] = "Train"}
            game:GetService("ReplicatedStorage"):FindFirstChild("RemoteEvent"):FireServer(unpack(args)) -- ตัวอย่างรีโมทเดิมของเกม
        end
    end)
end)

Fluent:Notify({Title = "FARTEZ HUB", Content = "OR Logic Version Loaded Successfully!", Duration = 5})
Window:SelectTab(Tabs.Main)
