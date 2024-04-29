local addonName = "MythicScoreTracker"
local addon = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceEvent-3.0")

-- Localization
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

-- Data structures
local playerScores = {}
local history = {}
local textures = {
    "Interface\\Icons\\achievement_bg_winner_orc",
    "Interface\\Icons\\ability_mount_camel_gray",
    "Interface\\Icons\\achievement_bg_kill_flag_carrier_horde"
}

-- Event handling
function addon:OnInitialize()
    -- Initialization logic
    self:RegisterChatCommand("mds", "ShowUI")
end

function addon:OnEnable()
    -- Enable logic
    self:RegisterEvent("CHALLENGE_MODE_COMPLETED", "OnChallengeModeCompleted")
end

function addon:OnDisable()
    -- Disable logic
    self:UnregisterAllEvents()
end

function addon:OnChallengeModeCompleted(event, mapID, level, time, onTime, keystoneUpgradeLevels)
    if level < 0 or level > 10 then
        return  -- Ignore dungeons outside the 0-10 level range
    end

    local baseScore = level * 100
    local timeBonus = onTime and (1000 - time) or 0
    local score = baseScore + timeBonus

    local playerName = UnitName("player")
    playerScores[playerName] = playerScores[playerName] or {}
    table.insert(playerScores[playerName], score)

    local dungeonName = C_ChallengeMode.GetMapUIInfo(mapID)
    local runDetails = {
        dungeonName = dungeonName,
        level = level,
        time = time,
        score = score,
        completed = onTime
    }
    table.insert(history, runDetails)

    self:UpdateUI()
end

-- Function to simulate Mythic Dungeon score
local function SimulateMythicDungeonScore(level, time, onTime)
    if level < 0 or level > 10 then
        return 0  -- Return 0 for dungeons outside the 0-10 level range
    end

    local baseScore = level * 100
    local timeBonus = onTime and (1000 - time) or 0
    return baseScore + timeBonus
end

-- Function to update the UI
function addon:UpdateUI()
    if not self.mainFrame then
        self:CreateUI()
    end

    -- Update player scores
    local playerName = UnitName("player")
    local playerScoresText = L["YOUR_SCORES"] .. "\n"
    for i, score in ipairs(playerScores[playerName] or {}) do
        playerScoresText = playerScoresText .. i .. ". " .. score .. "\n"
    end

    self.mainFrame.playerScores:SetText(playerScoresText)
    self.mainFrame:Show()
end

-- Function to create the UI
function addon:CreateUI()
    self.mainFrame = AceGUI:Create("Frame")
    self.mainFrame:SetTitle("Mythic Dungeon Scores")
    self.mainFrame:SetLayout("Flow")

    -- Player scores text
    self.mainFrame.playerScores = AceGUI:Create("Label")
    self.mainFrame.playerScores:SetText("")
    self.mainFrame:AddChild(self.mainFrame.playerScores)

    -- Simulation dropdown
    local simDropdown = AceGUI:Create("Dropdown")
    simDropdown:SetWidth(150)
    simDropdown:SetText(L["SIMULATE_SCORE"])
    simDropdown:SetList({
        ["+1 Level"] = 1,
        ["+2 Levels"] = 2,
        ["+3 Levels"] = 3,
        ["-1 Level"] = -1,
        ["-2 Levels"] = -2,
        ["-3 Levels"] = -3
    })
    simDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        self:SimulateScore(value)
    end)
    self.mainFrame:AddChild(simDropdown)

    -- Set background texture
    local texturePath = textures[1]  -- Choose a texture from the textures table
    self.mainFrame:SetStatusText(texturePath)
    self.mainFrame:SetCallback("OnClose", function(widget)
        widget:Hide()
    end)
end

-- Function to simulate dungeon score
function addon:SimulateScore(levelChange)
    local currentLevel = C_ChallengeMode.GetActiveKeystoneInfo()
    local simulatedLevel = currentLevel + levelChange

    local time = 30   -- Example completion time in minutes (configurable)
    local onTime = true  -- Example completion status (configurable)

    local simulatedScore = SimulateMythicDungeonScore(simulatedLevel, time, onTime)
    local simResultText = L["SIMULATION_RESULTS"] .. "\n"
    simResultText = simResultText .. string.format("Simulated Level: %d\n", simulatedLevel)
    simResultText = simResultText .. string.format("Completion Time: %d minutes\n", time)
    simResultText = simResultText .. "Simulated Score: " .. simulatedScore

    StaticPopupDialogs["MYTHIC_DUNGEON_SIMULATION"] = {
        text = simResultText,
        button1 = OKAY,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3
    }
    StaticPopup_Show("MYTHIC_DUNGEON_SIMULATION")
end
