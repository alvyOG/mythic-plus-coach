-- MPA Custom Window
local AceGUI = LibStub("AceGUI-3.0")

local Type, Version = "Window-MPA", 1

local function Hide(self)
    self.frame:Hide()
end

local function Show(self)
    self.frame:Show()
end

local function OnAcquire(self)
    self:SetWidth(400)
    self:SetHeight(300)
    self.frame:Show()
end

local function OnRelease(self)
    self.frame:Hide()
end

local function SetTitle(self, title)
    -- Do nothing (prevents default title bar)
end

local function CloseWindow(self)
    self.frame:Hide()
end

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
    content:SetPoint("TOPLEFT", 10, -10)
    content:SetPoint("BOTTOMRIGHT", -10, 10)

    local widget = {
        frame = frame,
        content = content,  -- Important: AceGUI expects this field
        type = Type,
        Close = CloseWindow,
        SetTitle = SetTitle,
        OnAcquire = OnAcquire,
        OnRelease = OnRelease,
        Hide = Hide,
        Show = Show,
    }

    -- Ensure the widget properly inherits from AceGUI.WidgetContainerBase
    AceGUI:RegisterAsContainer(widget)
    return widget
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
