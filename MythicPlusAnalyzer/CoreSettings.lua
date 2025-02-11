-- Mythic Plus Analyzer Addon
-- Author: alvy023
-- File: CoreSettings.lua
-- Description: Core settings functionality for the Mythic Plus Analyzer addon.
-- License:
-- For more information, visit the project repository.

local AceGUI = LibStub("AceGUI-3.0")

CoreSettings = {}
CoreSettings.settingsWindow = nil
CoreSettings.trackingTabsOrder = {}

--- Description: Show the Settings Window
--- @param:
--- @return:
function CoreSettings:Show()
    if not self.settingsWindow then
        self:CreateSettingsWindow()
    end
    self.settingsWindow:Show()
end

--- Description: Hide the Settings Window
--- @param:
--- @return:
function CoreSettings:Hide()
    if self.settingsWindow then
        self.settingsWindow:Hide()
    end
end

--- Description: Create the Settings Window
--- @param:
--- @return:
function CoreSettings:CreateSettingsWindow()
    self.settingsWindow = AceGUI:Create("Window-MPA")
    self.settingsWindow:SetLayout("Flow")
    self.settingsWindow:SetWidth(450)
    self.settingsWindow:SetHeight(300)

    self.settingsWindow:SetTitle("|cffffcc00M+ Analyzer Settings|r")
    self.settingsWindow:SetTitleFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
    self.settingsWindow:SetTitleAlignment("CENTER")

    -- Create Tabs Group
    local settingsTabs = AceGUI:Create("TabGroup")
    settingsTabs:SetLayout("Flow")
    settingsTabs:SetFullWidth(true)
    settingsTabs:SetFullHeight(true)
    settingsTabs:SetTabs({
        { text = "General", value = "General" },
        { text = "Tracking", value = "Tracking" }
    })

    -- Create a container for tab content
    local tabContainer = AceGUI:Create("SimpleGroup")
    tabContainer:SetFullWidth(true)
    tabContainer:SetLayout("Flow")

    -- Handle tab selection
    settingsTabs:SetCallback("OnGroupSelected", function(container, event, group)
        tabContainer:ReleaseChildren()
        if group == "General" then
            CoreSettings:CreateGeneralTab(tabContainer)
        elseif group == "Tracking" then
            CoreSettings:CreateTrackingTab(tabContainer)
        end
    end)

    -- Add components in the correct order
    settingsTabs:AddChild(tabContainer)
    self.settingsWindow:AddChild(settingsTabs)

    -- Set default tab
    settingsTabs:SelectTab("General")
end

--- Description: Create the General Tab
--- @param: container - The container to add the tab content to.
--- @return:
function CoreSettings:CreateGeneralTab(container)
    local label = AceGUI:Create("Label")
    label:SetText("General Settings go here.")
    label:SetFullWidth(true)
    container:AddChild(label)
end

--- Description: Create the Tracking Tab
--- @param: container - The container to add the tab content to.
--- @return:
function CoreSettings:CreateTrackingTab(container)
    local plugins = MythicPlusAnalyzer.plugins
    if #self.trackingTabsOrder == 0 then
        for _, plugin in ipairs(plugins) do
            table.insert(self.trackingTabsOrder, { text = plugin.name, value = plugin.name })
        end
    end

    for index, tab in ipairs(self.trackingTabsOrder) do
        local group = AceGUI:Create("SimpleGroup")
        group:SetFullWidth(true)
        group:SetLayout("Flow")

        local pluginLabel = AceGUI:Create("Label")
        pluginLabel:SetText(tab.value)
        pluginLabel:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
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

        -- Create Up Button
        local upButton = AceGUI:Create("IconButton-MPA")
        upButton:SetImage("Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Up")
        upButton:SetTooltip("Move Up")
        upButton:SetWidth(36)
        upButton:SetHeight(36)
        upButton:SetCallback("OnClick", function()
            if index > 1 then
                self.trackingTabsOrder[index], self.trackingTabsOrder[index - 1] =
                    self.trackingTabsOrder[index - 1], self.trackingTabsOrder[index]
                container:ReleaseChildren()
                self:CreateTrackingTab(container)
            end
        end)
        group:AddChild(upButton)

        -- Create Down Button
        local downButton = AceGUI:Create("IconButton-MPA")
        downButton:SetImage("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Up")
        downButton:SetTooltip("Move Down")
        downButton:SetWidth(36)
        downButton:SetHeight(36)
        downButton:SetCallback("OnClick", function()
            if index < #self.trackingTabsOrder then
                self.trackingTabsOrder[index], self.trackingTabsOrder[index + 1] =
                    self.trackingTabsOrder[index + 1], self.trackingTabsOrder[index]
                container:ReleaseChildren()
                self:CreateTrackingTab(container)
            end
        end)
        group:AddChild(downButton)

        container:AddChild(group)
    end
end

--- Description: Reset Settings
--- @param:
--- @return:
function CoreSettings:ResetSettings()
    CoreSettings:Hide()
    self.settingsWindow = nil
    self.trackingTabsOrder = {}
end

-- Register slash commands directly via MythicPlusAnalyzer
MythicPlusAnalyzer:RegisterChatCommand("mpa-settings", function()
    CoreSettings:Show()
end)

MythicPlusAnalyzer:RegisterChatCommand("mpa-settings-reset", function()
    CoreSettings:ResetSettings()
end)
