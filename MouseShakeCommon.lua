--
-- MouseShake
-- 
-- Copyright (c) 2019-2026 Dana Basken
--

function GetScaledMousePosition(frame)
  local scale, x, y = frame:GetEffectiveScale(), GetCursorPosition();
  return x / scale, y / scale;
end
