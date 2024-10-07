-- Name: SilentServer
-- License: LGPL v2.1

-- not starting with ^ because these could be color coded
local patterns = {
  '^Delete your WDB folder regularly',
  '^If you want to help our project',
  '^Keep up to date with',
  '^We encourage everyone to',
  '^All gold transactions are',
  '^Tune in to Everlook Broadcasting',
  '^Follow us on X',
  '^If you enjoy Mysteries of Azeroth',
  '^/join world to connect',
  '^Welcome to Turtle',
  '^Six years of',
  ".- %[%d+-%d+%] started!", -- battleground
}

local SilentServer = CreateFrame("Frame","SilentServer")
SilentServer:SetScript("OnEvent", function ()
  SilentServer[event](this,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10)
end)
SilentServer:RegisterEvent("RAID_ROSTER_UPDATE")

local raid_roster = {}
local raid_roster_count = 0

-- update raid members, but only if there's an actual change
function SilentServer:RosterUpdate()
  local rnum = GetNumRaidMembers()
  if rnum == raid_roster_count then return end
  raid_roster = {}
  raid_roster_count = rnum
  for i=1,raid_roster_count do
    local name, _, _, _, class = GetRaidRosterInfo(i)
    raid_roster[name] = { name = name, class = class }
  end
end

function  SilentServer:RAID_ROSTER_UPDATE()
  self:RosterUpdate()
end

function  SilentServer:PLAYER_ENTERING_WORLD()
  self:RosterUpdate()
end

local orig_ChatFrame_OnEvent = ChatFrame_OnEvent
ChatFrame_OnEvent = function (event,a2,a3,a4,a5,a6,a7,a8,a9,a10)
  local msg = arg1
  local from = arg2

  if event == "CHAT_MSG_SYSTEM" then
    for _,pattern in patterns do
      if string.find(msg,pattern) then
        return false
      end
    end
    orig_ChatFrame_OnEvent(event,a2,a3,a4,a5,a6,a7,a8,a9,a10)
  elseif event == "CHAT_MSG_YELL" and SilentServerDB.hellfire then
    if from and and UnitName("player") ~= from and
        raid_roster[from] and raid_roster[from].class == "Warlock" then
      return false
    end
    orig_ChatFrame_OnEvent(event,a2,a3,a4,a5,a6,a7,a8,a9,a10)
  else
    orig_ChatFrame_OnEvent(event,a2,a3,a4,a5,a6,a7,a8,a9,a10)
  end
end
