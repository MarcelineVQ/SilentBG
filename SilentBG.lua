-- Name: SilentBG
-- License: LGPL v2.1

local bg_pattern = ".- %[%d+-%d+%] started!"
local SilentBG = CreateFrame("Frame","SilentBG")

-- message add hook
local add_message = DEFAULT_CHAT_FRAME.AddMessage
function FilteredAddMessage(self,msg,a1,a2,a3,a4,a5,a6,a7,a8,a9)
  if string.find(msg,bg_pattern) then return end
  add_message(self,msg,a1,a2,a3,a4,a5,a6,a7,a8,a9)
end

SilentBG:RegisterEvent("CHAT_MSG_SYSTEM")
SilentBG:SetScript("OnEvent", function ()
  if event == "CHAT_MSG_SYSTEM" and string.find(arg1,bg_pattern) then
    -- a system message for bg's has fired, temporary disallow printing of it
    DEFAULT_CHAT_FRAME.AddMessage = FilteredAddMessage

    local elapsed = 0
    SilentBG:SetScript("OnUpdate", function ()
      elapsed = elapsed + arg1
      if elapsed > 0.2 then
        DEFAULT_CHAT_FRAME.AddMessage = add_message
        SilentBG:SetScript("OnUpdate", nil)
      end
    end)
  end
end)
