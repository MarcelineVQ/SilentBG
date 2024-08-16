-- Name: SilentBG
-- License: LGPL v2.1

local bg_pattern = ".- %[%d+-%d+%] started!"
local SilentBG = CreateFrame("Frame","SilentBG")

local lock = false
SilentBG:RegisterEvent("CHAT_MSG_SYSTEM")
SilentBG:SetScript("OnEvent", function ()
  if event == "CHAT_MSG_SYSTEM" and string.find(arg1,bg_pattern) and not lock then
    lock = true

    for i=1,NUM_CHAT_WINDOWS do
      getglobal("ChatFrame"..i).OrigAddMessage = getglobal("ChatFrame"..i).AddMessage
      getglobal("ChatFrame"..i).AddMessage = function (frame,msg,a1,a2,a3,a4,a5)
        if string.find(msg,bg_pattern) then return end
        getglobal("ChatFrame"..i).OrigAddMessage(frame,msg,a1,a2,a3,a4,a5)
      end
    end

    local elapsed = 0
    SilentBG:SetScript("OnUpdate", function ()
      elapsed = elapsed + arg1
      if elapsed > 0.2 then
        for i=1,NUM_CHAT_WINDOWS do
          getglobal("ChatFrame"..i).AddMessage = getglobal("ChatFrame"..i).OrigAddMessage
        end
        SilentBG:SetScript("OnUpdate", nil)
        lock = false
      end
    end)
  end
end)
