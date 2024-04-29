-- Libraries
local AceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

-- Data structures
local playerScores = {}
local textures = {
    "Interface\\Icons\\ability_mount_camel_gray",
    "Interface\\Icons\\achievement_bg_winner_orc",
    "Interface\\Icons\\achievement_bg_kill_flag_carrier_horde"
}

-- Localization
L["YOUR_SCORES"] = "Your Mythic Dungeon Scores"
L["SIMULATE"] = "Simulate Dungeon Run"

-- Create the main frame
function addon:CreateMainFrame()
    local frame = AceGUI:Create("Frame")
    frame:SetTitle("Mythic Dungeon Score Tracker")
    frame:SetLayout("Flow")
    frame:SetWidth(400)
    frame:SetHeight(300)

    -- Player scores label
    local playerScoresLabel = AceGUI:Create("Label")
    playerScoresLabel:SetText(L["YOUR_SCORES"])
    frame:AddChild(playerScoresLabel)

    -- Score list
    local scoreList = AceGUI:Create("ScrollFrame")
    scoreList:SetLayout("List")
    scoreList:SetFullWidth(true)
    scoreList:SetFullHeight(true)
    frame:AddChild(scoreList)

    -- Store the frame reference
    self.mainFrame = frame
end

-- Update the main frame with current scores
function addon:UpdateMainFrame()
    local scoreList = self.mainFrame.children[2]  -- Get the score list widget
    scoreList:ReleaseChildren()  -- Clear existing entries

    local playerName = UnitName("player")
    local playerHistory = playerScores[playerName] or {}

    for _, entry in ipairs(playerHistory) do
        local levelText = string.format("%d", entry.level)
        local timeText = string.format("%d minutes", entry.time)
        local scoreText = string.format("Score: %d", entry.score)

        local itemLabel = AceGUI:Create("Label")
        itemLabel:SetText(string.format("%s - %s - %s", levelText, timeText, scoreText))
        scoreList:AddChild(itemLabel)
    end
end

-- Simulate a dungeon run
function addon:SimulateDungeonRun(level, time, onTime)
    local playerName = UnitName("player")
    local score = self:CalculateScore(level, time, onTime)

    -- Store the simulated run in history
    playerScores[playerName] = playerScores[playerName] or {}
    table.insert(playerScores[playerName], { level = level, time = time, score = score })

    -- Update the UI
    self:UpdateMainFrame()
end

-- Calculate the dungeon score
function addon:CalculateScore(level, time, onTime)
    if level < 0 or level > 10 then
        return 0  -- Ignore dungeons outside the 0-10 level range
    end

    local baseScore = level * 100
    local timeBonus = onTime and (1000 - time) or 0
    return baseScore + timeBonus
end

-- Initialize the addon
function addon:OnInitialize()
    -- Create the main frame
    self:CreateMainFrame()

    -- Create a minimap button
    local icon = textures[1]  -- Choose an icon from the textures table
    local minimapButton = LibStub("LibDBIcon-1.0")
    minimapButton:Register(addonName, {
        icon = icon,
        OnClick = function(button, buttonPressed)
            if buttonPressed == "LeftButton" then
                self.mainFrame:SetShown(not self.mainFrame:IsShown())
            end
        end,
        OnTooltipShow = function(tooltip)
            tooltip:SetText("Mythic Dungeon Score Tracker")
            tooltip:AddLine("Click to toggle the score tracker.")
        end,
    })
end

-- Enable the addon
function addon:OnEnable()
    -- Enable logic
end

-- Disable the addon
function addon:OnDisable()
    -- Disable logic
end

-- Register the addon and enable it
addon:SetDefaultModuleState(false)
addon:EnableModule(addonName)