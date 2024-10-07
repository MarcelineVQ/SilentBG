-- Name: SilentServer
-- License: LGPL v2.1

-- not starting with ^ because these could be color coded
local patterns = {
  '^Delete your WDB',
  '^If you want',
  '^Keep up to',
  '^We encourage everyone',
  '^All gold transactions',
  '^Tune in to',
  '^Follow us on',
  '^If you enjoy',
  '^/join world to',
  '^Welcome to Turtle',
  '^Six years of',
  '^Download the anniversary',
  ".- %[%d+-%d+%] started!", -- battleground
}

local SilentServer = CreateFrame("Frame","SilentServer")
SilentServer:SetScript("OnEvent", function ()
  SilentServer[event](this,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10)
end)
SilentServer:RegisterEvent("ADDON_LOADED")
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

function SilentServer:ADDON_LOADED(addon)
  if addon ~= "SilentServer" then return end
  SilentServerDB = SilentServerDB or {}
  if SilentServerDB.hellfire == nil then SilentServerDB.hellfire = true end
end

function SilentServer:RAID_ROSTER_UPDATE()
  self:RosterUpdate()
end

function SilentServer:PLAYER_ENTERING_WORLD()
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
    if from and UnitName("player") ~= from and
        raid_roster[from] and raid_roster[from].class == "Warlock" then
      return false
    end
    orig_ChatFrame_OnEvent(event,a2,a3,a4,a5,a6,a7,a8,a9,a10)
  else
    orig_ChatFrame_OnEvent(event,a2,a3,a4,a5,a6,a7,a8,a9,a10)
  end
end
