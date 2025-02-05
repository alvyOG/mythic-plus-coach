-- Core Settings Window for Mythic Plus Analyzer
local AceGUI = LibStub("AceGUI-3.0")

CoreSettings = {}
CoreSettings.settingsWindow = nil
CoreSettings.trackingTabsOrder = {}

-- Show the Settings Window
function CoreSettings:Show()
    if not settingsWindow then
        self:CreateSettingsWindow()
    end
    self.settingsWindow:Show()
end

-- Hide the Settings Window
function CoreSettings:Hide()
    if self.settingsWindow then
        self.settingsWindow:Hide()
    end
end

-- Create the Settings Window
function CoreSettings:CreateSettingsWindow()
    self.settingsWindow = AceGUI:Create("Frame")
    self.settingsWindow:SetTitle("M+ Analyzer Settings")
    self.settingsWindow:SetLayout("Flow")
    self.settingsWindow:SetWidth(400)
    self.settingsWindow:SetHeight(300)
    
    local settingsTabs = AceGUI:Create("TabGroup")
    settingsTabs:SetLayout("Flow")
    settingsTabs:SetFullWidth("True")
    settingsTabs:SetTabs({
        { text = "General", value = "General" },
        { text = "Tracking", value = "Tracking" }
    })
    self.settingsWindow:AddChild(settingsTabs)
    
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
    if #self.trackingTabsOrder  == 0 then
        for _, plugin in ipairs(plugins) do
            table.insert(self.trackingTabsOrder, {text = plugin.name, value = plugin.name})
        end
    end
    
    for index, tab in ipairs(self.trackingTabsOrder) do
        local group = AceGUI:Create("SimpleGroup")
        group:SetFullWidth(true)
        group:SetLayout("Flow")

        local pluginLabel = AceGUI:Create("Label")
        pluginLabel:SetText(tab.value)
        pluginLabel:SetWidth(120)
        group:AddChild(pluginLabel)

        local enableButton = AceGUI:Create("Button")
        enableButton:SetText("Enable")
        enableButton:SetWidth(80)
        enableButton:SetCallback("OnClick", function()
            MythicPlusAnalyzer:SetPluginEnable(tab.value, true)
        end)
        group:AddChild(enableButton)

        local disableButton = AceGUI:Create("Button")
        disableButton:SetText("Disable")
        disableButton:SetWidth(80)
        disableButton:SetCallback("OnClick", function()
            MythicPlusAnalyzer:SetPluginEnable(tab.value, false)
        end)
        group:AddChild(disableButton)

        local upButton = AceGUI:Create("Button")
        upButton:SetText("↑")
        upButton:SetWidth(30)
        upButton:SetCallback("OnClick", function()
            if index > 1 then
                self.trackingTabsOrder[index], self.trackingTabsOrder[index - 1] = self.trackingTabsOrder[index - 1], self.trackingTabsOrder[index]
                CoreWindow:UpdateTabs(self.trackingTabsOrder)
                self:CreateTrackingTab(container)
            end
        end)
        group:AddChild(upButton)

        local downButton = AceGUI:Create("Button")
        downButton:SetText("↓")
        downButton:SetWidth(30)
        downButton:SetCallback("OnClick", function()
            if index < #self.trackingTabsOrder then
                self.trackingTabsOrder[index], self.trackingTabsOrder[index + 1] = self.trackingTabsOrder[index + 1], self.trackingTabsOrder[index]
                CoreWindow:UpdateTabs(self.trackingTabsOrder)
                self:CreateTrackingTab(container)
            end
        end)
        group:AddChild(downButton)

        container:AddChild(group)
    end
end

function CoreSettings:ResetSettings()
    CoreSettings:Hide()
    self.settingsWindow = nil
    self.trackingTabsOrder = {}
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
