-- Core Settings Window for Mythic Plus Analyzer
local AceGUI = LibStub("AceGUI-3.0")

CoreSettings = {}
CoreSettings.settingsWindow = nil
CoreSettings.trackingTabsOrder = {}

-- Show the Settings Window
function CoreSettings:Show()
    if not self.settingsWindow then
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

    -- Create Tabs Group
    local settingsTabs = AceGUI:Create("TabGroup")
    settingsTabs:SetLayout("Flow")
    settingsTabs:SetFullWidth(true)
    settingsTabs:SetTabs({
        { text = "General", value = "General" },
        { text = "Tracking", value = "Tracking" }
    })

    -- Create a container for tab content
    local tabContainer = AceGUI:Create("SimpleGroup")
    tabContainer:SetFullWidth(true)
    tabContainer:SetFullHeight(true)
    tabContainer:SetLayout("Flow")

    -- Handle tab selection
    settingsTabs:SetCallback("OnGroupSelected", function(container, event, group)
        tabContainer:ReleaseChildren() -- Clear previous tab content
        if group == "General" then
            CoreSettings:CreateGeneralTab(tabContainer)
        elseif group == "Tracking" then
            CoreSettings:CreateTrackingTab(tabContainer)
        end
    end)

    -- Add components in the correct order
    self.settingsWindow:AddChild(settingsTabs)
    self.settingsWindow:AddChild(tabContainer)

    -- Set default tab
    settingsTabs:SelectTab("General")
end

-- Create the General Tab
function CoreSettings:CreateGeneralTab(container)
    local label = AceGUI:Create("Label")
    label:SetText("General Settings go here.")
    label:SetFullWidth(true)
    container:AddChild(label)
end

-- Create the Tracking Tab
function CoreSettings:CreateTrackingTab(container)
    local plugins = MythicPlusAnalyzer.plugins
    if #self.trackingTabsOrder == 0 then
        for _, plugin in ipairs(plugins) do
            table.insert(self.trackingTabsOrder, { text = plugin.name, value = plugin.name })
        end
    end

    for index, tab in ipairs(self.trackingTabsOrder) do
        local pluginLabel = AceGUI:Create("Label")
        pluginLabel:SetText(tab.value)
        pluginLabel:SetWidth(120)
        container:AddChild(pluginLabel)

        local enableButton = AceGUI:Create("Button")
        enableButton:SetText("Enable")
        enableButton:SetWidth(80)
        enableButton:SetCallback("OnClick", function()
            MythicPlusAnalyzer:SetPluginEnable(tab.value, true)
        end)
        container:AddChild(enableButton)

        local disableButton = AceGUI:Create("Button")
        disableButton:SetText("Disable")
        disableButton:SetWidth(80)
        disableButton:SetCallback("OnClick", function()
            MythicPlusAnalyzer:SetPluginEnable(tab.value, false)
        end)
        container:AddChild(disableButton)

        local upButton = AceGUI:Create("Button")
        upButton:SetText("+")
        upButton:SetWidth(30)
        upButton:SetCallback("OnClick", function()
            if index > 1 then
                self.trackingTabsOrder[index], self.trackingTabsOrder[index - 1] = self.trackingTabsOrder[index - 1], self.trackingTabsOrder[index]
                self:CreateTrackingTab(container)
            end
        end)
        container:AddChild(upButton)

        local downButton = AceGUI:Create("Button")
        downButton:SetText("-")
        downButton:SetWidth(30)
        downButton:SetCallback("OnClick", function()
            if index < #self.trackingTabsOrder then
                self.trackingTabsOrder[index], self.trackingTabsOrder[index + 1] = self.trackingTabsOrder[index + 1], self.trackingTabsOrder[index]
                self:CreateTrackingTab(container)
            end
        end)
        container:AddChild(downButton)
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
