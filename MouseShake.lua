--
-- MouseShake
-- 
-- Copyright (c) 2019-2026 Dana Basken
--

print("MouseShake 12.0.1.0");

local lastX, lastY = GetCursorPosition();

local currentGesture = "none";
local gestureSeconds = 0;
local gestureTimeoutSeconds = 0.25;

local minShakeCount = 3;
local shakeCount = 0;
local shakeDistance = 500;

local frame = CreateFrame("FRAME");
frame:SetFrameStrata("HIGH");

local function Shake()
  shakeCount = shakeCount + 1;
  if (shakeCount > minShakeCount) then
    Finder_Show();
  end
end

local function OnUpdateGesture()
  gestureSeconds = 0;
  if (currentGesture == "left" or currentGesture == "right") then
    Shake();
  end
end

local function SetGesture(gesture)
  if (currentGesture ~= gesture) then
    -- print("switch gesture from " .. currentGesture .. " to " .. gesture);
    currentGesture = gesture;
    OnUpdateGesture();
  end
end

local function ClearShake()
  shakeCount = 0;
end

local function ClearGesture()
  if (currentGesture == "left" or currentGesture == "right") then
    ClearShake();
    Finder_Hide();
  end
  SetGesture("none");
end

local function CheckGestureTimeout(elapsedSeconds)
  gestureSeconds = gestureSeconds + elapsedSeconds;
  if (gestureSeconds > gestureTimeoutSeconds) then
    ClearGesture();
  end
end

local function CheckGesture(elapsedSeconds)
  local cursorX, cursorY = GetScaledMousePosition(frame);
  if (cursorX ~= lastX or cursorY ~= lastY) then
    local deltaX = (cursorX - lastX) / elapsedSeconds;
    -- local deltaY = (cursorY - lastY) / elapsedSeconds;
    if (deltaX < -shakeDistance) then
      SetGesture("left");
    end
    if (deltaX > shakeDistance) then
      SetGesture("right");
    end
    lastX, lastY = cursorX, cursorY
  end
end

local function PositionMouseFinder()
  if (mouseFinderState == "visible") then
    local cursorX, cursorY = GetScaledMousePosition(frame);
    frame:SetPoint(mouseFinderPoint, nil, "CENTER", cursorX, cursorY);
  end
end

local function UpdateHandler(self, elapsedSeconds, ...)
  PositionMouseFinder();
  CheckGestureTimeout(elapsedSeconds);
  CheckGesture(elapsedSeconds);
  Finder_Run(elapsedSeconds);
end

-- frame:SetScript("OnEvent", MerchantEventHandler);
frame:SetScript("OnUpdate", UpdateHandler);
