-- Core Settings Window for Mythic Plus Analyzer
local AceGUI = LibStub("AceGUI-3.0")

local CoreSettings = {}
local settingsWindow = nil
local trackingTabsOrder = {}

-- Show the Settings Window
function CoreSettings:Show()
    if not settingsWindow then
        self:CreateSettingsWindow()
    end
    settingsWindow:Show()
end

-- Hide the Settings Window
function CoreSettings:Hide()
    if settingsWindow then
        settingsWindow:Hide()
    end
end

-- Create the Settings Window
function CoreSettings:CreateSettingsWindow()
    settingsWindow = AceGUI:Create("Frame")
    settingsWindow:SetTitle("M+ Analyzer Settings")
    settingsWindow:SetLayout("Flow")
    settingsWindow:SetWidth(400)
    settingsWindow:SetHeight(300)
    
    local settingsTabs = AceGUI:Create("TabGroup")
    settingsTabs:SetLayout("Flow")
    settingsTabs:SetTabs({
        { text = "General", value = "General" },
        { text = "Tracking", value = "Tracking" }
    })
    settingsWindow:AddChild(settingsTabs)
    
    local generalContainer = AceGUI:Create("SimpleGroup")
    generalContainer:SetFullWidth(true)
    generalContainer:SetLayout("Flow")
    settingsTabs:AddChild(generalContainer)
    
    local trackingContainer = AceGUI:Create("SimpleGroup")
    trackingContainer:SetFullWidth(true)
    trackingContainer:SetLayout("Flow")
    settingsTabs:AddChild(trackingContainer)
    
    self:CreateTrackingTab(trackingContainer)
    settingsTabs:SelectTab("General")
end

-- Create the Tracking Tab
function CoreSettings:CreateTrackingTab(container)
    container:ReleaseChildren()
    local plugins = MythicPlusAnalyzer.plugins
    if #trackingTabsOrder  == 0 then
        for _, plugin in ipairs(plugins) do
            table.insert(trackingTabsOrder, {text = plugin.name, value = plugin.name})
        end
    end
    
    for index, tab in ipairs(trackingTabsOrder) do
        local group = AceGUI:Create("SimpleGroup")
        group:SetFullWidth(true)
        group:SetLayout("Flow")

        local pluginLabel = AceGUI:Create("Label")
        pluginLabel:SetText(tab.value)
        pluginLabel:SetWidth(150)
        group:AddChild(pluginLabel)

        local enableButton = AceGUI:Create("Button")
        enableButton:SetText("Enable")
        enableButton:SetWidth(60)
        enableButton:SetCallback("OnClick", function()
            MythicPlusAnalyzer:SetPluginEnable(tab.value, true)
        end)
        group:AddChild(enableButton)

        local disableButton = AceGUI:Create("Button")
        disableButton:SetText("Disable")
        disableButton:SetWidth(60)
        disableButton:SetCallback("OnClick", function()
            MythicPlusAnalyzer:SetPluginEnable(tab.value, false)
        end)
        group:AddChild(disableButton)

        local upButton = AceGUI:Create("Button")
        upButton:SetText("↑")
        upButton:SetWidth(30)
        upButton:SetCallback("OnClick", function()
            if index > 1 then
                trackingTabsOrder[index], trackingTabsOrder[index - 1] = trackingTabsOrder[index - 1], trackingTabsOrder[index]
                CoreWindow:UpdateTabs(trackingTabsOrder)
                self:CreateTrackingTab(container)
            end
        end)
        group:AddChild(upButton)

        local downButton = AceGUI:Create("Button")
        downButton:SetText("↓")
        downButton:SetWidth(30)
        downButton:SetCallback("OnClick", function()
            if index < #trackingTabsOrder then
                trackingTabsOrder[index], trackingTabsOrder[index + 1] = trackingTabsOrder[index + 1], trackingTabsOrder[index]
                CoreWindow:UpdateTabs(trackingTabsOrder)
                self:CreateTrackingTab(container)
            end
        end)
        group:AddChild(downButton)

        container:AddChild(group)
    end
end

function CoreSettings:ResetSettings()
    CoreSettings:Hide()
    settingsWindow = nil
    trackingTabsOrder = {}
end

-- Open Settings Command
SLASH_MPASETTINGS1 = "/mpas"
SlashCmdList["MPASETTINGS"] = function()
    CoreSettings:Show()
end

-- Reset Settings Command
SLASH_MPARESETSETTINGS1 = "/mpasreset"
SlashCmdList["MPASETTINGSRESET"] = function()
    CoreSettings:ResetSettings()
end

print("MPA-CoreSettings: Loaded successfully")
