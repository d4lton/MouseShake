--
-- MouseShake
-- 
-- Copyright (c) 2019-2026 Dana Basken
--

local Finder_state = "idle";
local Finder_cursorOffset = "CENTER";
local Finder_size = 0;
local Finder_minSize = 1.0;
local Finder_maxSize = 64.0;
local Finder_sizePerSecond = 0.1;

local Finder_frame = CreateFrame("FRAME");
Finder_frame:SetFrameStrata("HIGH");

local Finder_texture = Finder_frame:CreateTexture(nil, "BACKGROUND");
Finder_texture:SetAllPoints(Finder_frame);
Finder_frame.texture = Finder_texture;

local function Finder_Size()
  local size = Finder_size / Finder_frame:GetEffectiveScale();
  Finder_frame:SetSize(size, size);
end

local function Finder_Position()
  local x, y = GetScaledMousePosition(Finder_frame);
  Finder_frame:SetPoint(Finder_cursorOffset, nil, "BOTTOMLEFT", x, y);
  Finder_Size();
end

function Finder_OnUpdateState(previousState)
  -- print("FinderOnUpdateState(" .. previousState .. "): " .. Finder_state);
  if (Finder_state == "grow") then
    Finder_size = Finder_minSize;
    Finder_texture:SetTexture("Interface\\Addons\\MouseShake\\images\\pointer2.blp");
  end
  if (Finder_state == "idle") then
    Finder_texture:SetColorTexture(0.0, 0.0, 0.0, 0.0);
  end
end

function Finder_SetState(state)
  if (Finder_state ~= state) then
    local previousState = Finder_state;
    Finder_state = state;
    Finder_OnUpdateState(previousState);
  end
end

function Finder_Run(elapsedSeconds)
  if (Finder_state == "grow") then
    Finder_size = Finder_size + (Finder_sizePerSecond / elapsedSeconds);
    if (Finder_size > Finder_maxSize) then
      Finder_SetState("grown");
    end
    Finder_Position();
  end
  if (Finder_state == "shrink") then
    Finder_size = Finder_size - (Finder_sizePerSecond / elapsedSeconds);
    if (Finder_size <= Finder_minSize) then
      Finder_SetState("idle");
    end
    Finder_Position();
  end
  if (Finder_state == "grown") then
    Finder_Position();
  end
end

function Finder_Show()
  if (Finder_state ~= "grown") then
    Finder_SetState("grow");
  end
end

function Finder_Hide(force)
  if (force) then
    Finder_SetState("idle");
  else
    Finder_SetState("shrink");
  end
end
