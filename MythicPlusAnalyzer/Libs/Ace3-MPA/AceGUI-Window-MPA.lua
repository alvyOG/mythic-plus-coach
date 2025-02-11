-- Mythic Plus Analyzer Addon
-- Author: alvy023
-- File: AceGUI-Window-MPA.lua
-- Description: Custom Window for the Mythic Plus Analyzer addon.
-- License:
-- For more information, visit the project repository.

-- Load Libraries
local AceGUI = LibStub("AceGUI-3.0")

-- Constants
local Type, Version = "Window-MPA", 3

-- Methods
--- Description: Hides the window.
--- @param:
--- @return:
local function Hide(self)
    self.frame:Hide()
end

--- Description: Shows the window.
--- @param:
--- @return:
local function Show(self)
    self.frame:Show()
end

--- Description: Called when the widget is acquired.
--- @param:
--- @return:
local function OnAcquire(self)
    self:SetWidth(400)
    self:SetHeight(300)
    self.frame:Show()
end

--- Description: Called when the widget is released.
--- @param:
--- @return:
local function OnRelease(self)
    self.frame:Hide()
end

--- Description: Sets the title of the window.
--- @param: title - The title text.
--- @return:
local function SetTitle(self, title)
    self.titleLabel:SetText(title)
end

--- Description: Sets the font of the title.
--- @param: font - The font path.
--- @param: size - The font size.
--- @param: flags - The font flags.
--- @return:
local function SetTitleFont(self, font, size, flags)
    self.titleLabel:SetFont(font, size, flags)
end

--- Description: Sets the alignment of the title.
--- @param: align - The alignment ("LEFT", "CENTER", "RIGHT").
--- @return:
local function SetTitleAlignment(self, align)
    self.titleLabel:ClearAllPoints()
    if align == "LEFT" then
        self.titleLabel:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 10, -10)
    elseif align == "CENTER" then
        self.titleLabel:SetPoint("TOP", self.frame, "TOP", 0, -10)
    elseif align == "RIGHT" then
        self.titleLabel:SetPoint("TOPRIGHT", self.frame, "TOPRIGHT", -10, -10)
    end
end

--- Description: Adds a button to the button bar.
--- @param: button - The button to add.
--- @return:
local function AddButtonToBar(self, button)
    local numButtons = #self.buttonBar.buttons
    button.frame:SetParent(self.buttonBar)
    button.frame:SetPoint("RIGHT", self.buttonBar, "RIGHT", -numButtons * 26, 0)  -- Adjust spacing as needed
    button.frame:Show()
    table.insert(self.buttonBar.buttons, button)
end

-- Constructor
--- Description: Creates a new instance of the Window-MPA widget.
--- @param:
--- @return: The created widget.
local function Constructor()
    local frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    frame:SetSize(400, 300)
    frame:SetPoint("CENTER")
    frame:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background" })
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    -- Create the 'content' frame that AceGUI expects
    local content = CreateFrame("Frame", nil, frame)
    content:SetPoint("TOPLEFT", 10, -40)  -- Adjust the Y offset to add more space
    content:SetPoint("BOTTOMRIGHT", -10, 10)

    -- Create the title label
    local titleLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    titleLabel:SetPoint("TOP", frame, "TOP", 0, -10)
    titleLabel:SetText("Default Title")

    -- Create the button bar container
    local buttonBar = CreateFrame("Frame", nil, frame)
    buttonBar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
    buttonBar:SetSize(100, 24)  -- Adjust the width as needed

    -- Create the close button using IconButton-MPA
    local closeButton = AceGUI:Create("IconButton-MPA")
    closeButton:SetImage("Interface\\AddOns\\MythicPlusAnalyzer\\Assets\\CustomIcon-White-X.tga")
    closeButton:SetTooltip("Close")
    closeButton:SetSize(16, 16)
    closeButton:SetCallback("OnClick", function()
        frame:Hide()
    end)
    closeButton.frame:SetParent(buttonBar)
    closeButton.frame:SetPoint("RIGHT", buttonBar, "RIGHT")
    closeButton.frame:Show()

    buttonBar.buttons = {}
    table.insert(buttonBar.buttons, closeButton)  -- Insert the close button into the buttonBar table

    local widget = {
        frame = frame,
        content = content,  -- Important: AceGUI expects this field
        titleLabel = titleLabel,
        buttonBar = buttonBar,
        type = Type,
        Close = CloseWindow,
        SetTitle = SetTitle,
        SetTitleFont = SetTitleFont,
        SetTitleAlignment = SetTitleAlignment,
        OnAcquire = OnAcquire,
        OnRelease = OnRelease,
        Hide = Hide,
        Show = Show,
        AddButton = AddButtonToBar,  -- Add the AddButton method
    }

    -- Ensure the widget properly inherits from AceGUI.WidgetContainerBase
    AceGUI:RegisterAsContainer(widget)
    return widget
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)