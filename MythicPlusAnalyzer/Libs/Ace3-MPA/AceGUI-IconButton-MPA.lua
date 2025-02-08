-- MPA Custom Icon Button
local AceGUI = LibStub("AceGUI-3.0")

local Type, Version = "IconButton-MPA", 1

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]
local function Control_OnEnter(frame)
    frame.obj:Fire("OnEnter")
end

local function Control_OnLeave(frame)
    frame.obj:Fire("OnLeave")
end

local function Button_OnClick(frame, button)
    frame.obj:Fire("OnClick", button)
    AceGUI:ClearFocus()
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
    ["OnAcquire"] = function(self)
        self:SetHeight(24)
        self:SetWidth(24)
        self:SetImage(nil)
        self:SetTooltip(nil)
        self:SetDisabled(false)
    end,

    ["OnRelease"] = function(self)
        self.icon:Hide()
    end,

    ["SetImage"] = function(self, icon)
        self.icon:SetTexture(icon)
        self.icon:Show()
    end,

    ["SetImageSize"] = function(self, width, height)
        self.icon:SetSize(width, height)
    end,

    ["SetTooltip"] = function(self, tooltipText)
        self.tooltipText = tooltipText
    end,

    ["SetSize"] = function(self, width, height)
        self.frame:SetSize(width, height)
    end,

    ["SetCallback"] = function(self, event, callback)
        if event == "OnClick" then
            self.frame:SetScript("OnMouseUp", callback)
        else
            self.frame:SetScript(event, callback)
        end
    end,

    ["SetDisabled"] = function(self, disabled)
        self.disabled = disabled
        if disabled then
            self.frame:Disable()
            self.icon:SetVertexColor(0.5, 0.5, 0.5, 0.5)
        else
            self.frame:Enable()
            self.icon:SetVertexColor(1, 1, 1, 1)
        end
    end,

    ["Hide"] = function(self)
        self.frame:Hide()
    end,

    ["Show"] = function(self)
        self.frame:Show()
    end
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
    local frame = CreateFrame("Button", nil, UIParent)
    frame:Hide()

    frame:EnableMouse(true)
    frame:SetScript("OnEnter", Control_OnEnter)
    frame:SetScript("OnLeave", Control_OnLeave)
    frame:SetScript("OnMouseUp", Button_OnClick)

    local icon = frame:CreateTexture(nil, "BACKGROUND")
    icon:SetAllPoints(frame)

    local widget = {
        frame = frame,
        icon = icon,
        type = Type
    }
    for method, func in pairs(methods) do
        widget[method] = func
    end

    frame:SetScript("OnEnter", function()
        if widget.tooltipText then
            GameTooltip:SetOwner(widget.frame, "ANCHOR_TOPRIGHT")
            GameTooltip:SetText(widget.tooltipText, 1, 1, 1, 1, true)
            GameTooltip:Show()
        end
    end)

    frame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)