-- Mythic Plus Analyzer Addon
-- Author: alvy023
-- File: LocationPlugin.lua
-- Description: Location tracking functionality for the Mythic Plus Analyzer addon.
-- License:
-- For more information, visit the project repository.

-- Load Libraries
local AceGUI = LibStub("AceGUI-3.0")

-- Load Libraries
local LocationPlugin = CreateFrame("Frame")
LocationPlugin.name = "LocationPlugin"
LocationPlugin.arrowColor = {1, 1, 1} -- Default white color
LocationPlugin.locationSegments = {}  -- List to store location segments

-- Register the plugin with the Core module
MythicPlusAnalyzer:RegisterPlugin(LocationPlugin)
print("LocationPlugin registered with MythicPlusAnalyzer")

local WorldMapFrame = WorldMapFrame
local mapPins = {}

-- Define the pin template (single texture with arrow and dot combined)
local LocationPinMixin = {}

--- Description: Initializes the pin.
--- @param:
--- @return:
function LocationPinMixin:OnLoad()
    self:SetSize(14, 14)  -- Adjust pin size as needed

    -- Create combined icon (dot + arrow)
    self.texture = self:CreateTexture(nil, "OVERLAY")
    self.texture:SetAllPoints()
    self.texture:SetTexture("Interface\\AddOns\\MythicPlusAnalyzer\\Assets\\CustomIcon-White-Play.tga") -- Custom combined texture
    self.texture:SetVertexColor(unpack(LocationPlugin.arrowColor)) -- Apply default color
end

--- Description: Updates the pin position and rotation.
--- @param: mapID - The map ID.
--- @param: x - The x-coordinate.
--- @param: y - The y-coordinate.
--- @param: facing - The facing direction in radians.
--- @return:
function LocationPinMixin:UpdatePin(mapID, x, y, facing)
    self.mapID = mapID
    self.x = x
    self.y = y
    self.facing = facing

    self:ClearAllPoints()
    self:SetPoint("CENTER", WorldMapFrame.ScrollContainer, "BOTTOMLEFT",
            x * WorldMapFrame.ScrollContainer:GetWidth(),
            y * WorldMapFrame.ScrollContainer:GetHeight())

    -- Rotate the combined texture based on player facing direction
    if self.facing then
        self.texture:SetRotation(self.facing) -- Rotate to match player direction
    end
end

--- Description: Sets the arrow color for all pins.
--- @param: r - Red component.
--- @param: g - Green component.
--- @param: b - Blue component.
--- @return:
function LocationPlugin:SetArrowColor(r, g, b)
    self.arrowColor = {r, g, b}
    for _, pin in ipairs(mapPins) do
        if pin.texture then
            pin.texture:SetVertexColor(r, g, b)
        end
    end
end

--- Description: Registers the pin template with the World Map.
--- @param:
--- @return:
local function RegisterMapPins()
    if not WorldMapFrame.pinPool then
        WorldMapFrame.pinPool = CreateFramePool("FRAME", WorldMapFrame, "BackdropTemplate", function(pool, pin)
            pin:Hide()
            pin:ClearAllPoints()
            if pin.texture then
                pin.texture:SetTexture(nil)
            end
        end, nil, function(pin)
            if not pin.texture then
                Mixin(pin, LocationPinMixin)
                pin:OnLoad()
            end
        end)
    end
end

RegisterMapPins()

--- Description: Adds a custom map pin.
--- @param: mapID - The map ID.
--- @param: x - The x-coordinate.
--- @param: y - The y-coordinate.
--- @param: facing - The facing direction in radians.
--- @return:
function LocationPlugin:AddCustomMapPin(mapID, x, y, facing)
    if not WorldMapFrame.pinPool then return end

    local pin = WorldMapFrame.pinPool:Acquire()
    if not pin.UpdatePin then
        Mixin(pin, LocationPinMixin)
        pin:OnLoad()
    end
    pin:UpdatePin(mapID, x, y, facing)
    pin:Show()
    pin.texture:SetVertexColor(unpack(LocationPlugin.arrowColor)) -- Apply current color

    table.insert(mapPins, pin)
end

--- Description: Stores the player's location every 0.5 seconds.
--- @param:
--- @return:
local function StoreLocation()
    local mapID = C_Map.GetBestMapForUnit("player")
    local position = C_Map.GetPlayerMapPosition(mapID, "player")
    local facing = GetPlayerFacing() -- Get the player's direction in radians

    if not mapID or not position then return end

    local x, y = position:GetXY()
    if not x or not y or not facing then return end

    local segment = {
        mapID = mapID,
        x = x,
        y = y,
        facing = facing, -- Store facing direction
        time = GetTime()
    }

    table.insert(LocationPlugin.locationSegments, segment)

    -- Add to world or dungeon map
    LocationPlugin:AddCustomMapPin(mapID, x, y, facing)
end

-- Timer to track movement every 0.5 seconds
local movementTracker = CreateFrame("Frame")
local lastUpdate = 0
movementTracker:SetScript("OnUpdate", function(self, elapsed)
    local currentTime = GetTime()
    if MythicPlusAnalyzer.isTracking and currentTime > lastUpdate + 1.0 then
        StoreLocation()
        lastUpdate = currentTime
    end
end)

--- Description: Clears old pins from the map.
--- @param:
--- @return:
function LocationPlugin:ClearOldPins()
    for _, pin in ipairs(mapPins) do
        pin:Hide()
        WorldMapFrame.pinPool:Release(pin)
    end
    wipe(mapPins)
end

--- Description: Opens Blizzard's ColorPickerFrame to select arrow color.
--- @param:
--- @return:
function LocationPlugin:OpenColorPicker()
    local function UpdateColor()
        local r, g, b = ColorPickerFrame:GetColorRGB()
        LocationPlugin:SetArrowColor(r, g, b)
    end

    local function CancelColor(previousValues)
        LocationPlugin:SetArrowColor(unpack(previousValues))
    end

    local options = {
        swatchFunc = UpdateColor,
        cancelFunc = CancelColor,
        hasOpacity = false,
        r = LocationPlugin.arrowColor[1],
        g = LocationPlugin.arrowColor[2],
        b = LocationPlugin.arrowColor[3],
    }

    ColorPickerFrame:SetupColorPickerAndShow(options)
end

--- Description: Prints stored map pins.
--- @param:
--- @return:
function LocationPlugin:PrintStoredPins()
    print("Stored Map Pins:")
    for i, pin in ipairs(mapPins) do
        print(string.format("Pin %d: MapID = %d, X = %.4f, Y = %.4f, Facing = %.4f", i, pin.mapID, pin.x, pin.y, pin.facing))
    end
end

--- Description: Resets tracking metrics.
--- @param:
--- @return:
function LocationPlugin:ResetTrackingMetrics()
    self.locationSegments = {}
    self:ClearOldPins()
    print("MPA-Location: Location tracking reset!")
end

-- Register chat commands
MythicPlusAnalyzer:RegisterChatCommand("mpa-map-color", function()
    LocationPlugin:OpenColorPicker()
end)
print("Chat command 'mpa-map-color' registered")

MythicPlusAnalyzer:RegisterChatCommand("mpa-map-print", function()
    LocationPlugin:PrintStoredPins()
end)
print("Chat command 'mpa-map-print' registered")

MythicPlusAnalyzer:RegisterChatCommand("mpa-map-reset", function()
    LocationPlugin:ResetTrackingMetrics()
end)
print("Chat command 'mpa-map-reset' registered")