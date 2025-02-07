-- MPA Custom Icon
local AceGUI = LibStub("AceGUI-3.0")

local Type, Version = "IconButton-MPA", 1

local function SetImage(self, icon)
    self.icon:SetTexture(icon)
end

local function SetImageSize(self, width, height)
    self.icon:SetSize(width, height)
end

local function SetTooltip(self, tooltipText)
    self.tooltipText = tooltipText
end

local function OnAcquire(self)
    self:SetWidth(36)
    self:SetHeight(36)
end

local function OnRelease(self)
    self.icon:Hide()
end

local function Hide(self)
    self.frame:Hide()
end

local function Show(self)
    self.frame:Show()
end

local function Constructor()
    -- Create the icon frame (using "Icon" for static image display)
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:SetSize(36, 36)
    
    -- Create the icon texture
    local icon = frame:CreateTexture(nil, "BACKGROUND")
    icon:SetAllPoints(frame)

    -- Set up the widget structure
    local widget = {
        frame = frame,
        icon = icon,  -- Icon texture
        type = Type,
        SetImage = SetImage,
        SetImageSize = SetImageSize,
        SetTooltip = SetTooltip,
        OnAcquire = OnAcquire,
        OnRelease = OnRelease,
        Hide = Hide,
        Show = Show,
    }

    -- Tooltip functionality
    frame:SetScript("OnEnter", function(widget)
        if widget.tooltipText then
            GameTooltip:SetOwner(widget.frame, "ANCHOR_TOPRIGHT")
            GameTooltip:SetText(widget.tooltipText, 1, 1, 1, 1, true)
            GameTooltip:Show()
        end
    end)

    frame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    -- Register the widget as an AceGUI widget
    AceGUI:RegisterWidgetType(Type, Constructor, Version)
    return widget
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
