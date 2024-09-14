-- Name: SilentServer
-- License: LGPL v2.1

-- not starting with ^ because these could be color coded
local patterns = {
  ".- %[%d+-%d+%] started!", -- battleground
  'Delete your WDB folder regularly',
  'If you want to help our project',
  'Keep up to date with',
  'We encourage everyone to change their password regularly',
  'All gold transactions are',
  'Tune in to Everlook Broadcasting',
  'Follow us on X',
  'If you enjoy Mysteries of Azeroth',
}

local SilentServer = CreateFrame("Frame","SilentServer")

local lock = false
SilentServer:RegisterEvent("CHAT_MSG_SYSTEM")
SilentServer:SetScript("OnEvent", function ()
  if event == "CHAT_MSG_SYSTEM" and not lock then
    local pat = nil
    for _,pattern in patterns do
      if string.find(arg1,pattern) then
        lock = true
        pat = pattern
        break
      end
    end
    if not pat then return end -- no pattern

    for i=1,NUM_CHAT_WINDOWS do
      getglobal("ChatFrame"..i).OrigAddMessage = getglobal("ChatFrame"..i).AddMessage
      getglobal("ChatFrame"..i).AddMessage = function (frame,msg,a1,a2,a3,a4,a5)
        if string.find(msg,pat) then return end
        getglobal("ChatFrame"..i).OrigAddMessage(frame,msg,a1,a2,a3,a4,a5)
      end
    end

    local elapsed = 0
    SilentServer:SetScript("OnUpdate", function ()
      elapsed = elapsed + arg1
      if elapsed > 0.2 then
        for i=1,NUM_CHAT_WINDOWS do
          getglobal("ChatFrame"..i).AddMessage = getglobal("ChatFrame"..i).OrigAddMessage
        end
        SilentServer:SetScript("OnUpdate", nil)
        lock = false
      end
    end)
  end
end)
