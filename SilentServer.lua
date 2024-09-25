-- Name: SilentServer
-- License: LGPL v2.1

-- not starting with ^ because these could be color coded
local patterns = {
  ".- %[%d+-%d+%] started!", -- battleground
  'Delete your WDB folder regularly',
  'If you want to help our project',
  'Keep up to date with',
  'We encourage everyone to',
  'All gold transactions are',
  'Tune in to Everlook Broadcasting',
  'Follow us on X',
  'If you enjoy Mysteries of Azeroth',
  '/join world to connect',
  'Welcome to Turtle',
}

local SilentServer = CreateFrame("Frame","SilentServer")

SilentServer:SetScript("OnEvent", function ()
  SilentServer[event](this,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10)
end)
SilentServer:RegisterEvent("ADDON_LOADED")

local lock = false
local raid_roster = {}
local raid_roster_count = 0

function SilentServer:Shush(msg,type,from)
  if lock then return end
  local pat = nil
  if type == "system" then
    for _,pattern in patterns do
      if string.find(msg,pattern) then
        pat = pattern
        break
      end
    end
  elseif type == "yell" then
    if from and UnitName("player") ~= from and
       raid_roster[from] and (SilentServerDB.hellfire and raid_roster[from].class == "Warlock") then
      pat = msg
    end
  end
  if not pat then return end -- no pattern
  lock = true

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
    if elapsed > 0.1 then
      for i=1,NUM_CHAT_WINDOWS do
        getglobal("ChatFrame"..i).AddMessage = getglobal("ChatFrame"..i).OrigAddMessage
      end
      SilentServer:SetScript("OnUpdate", nil)
      lock = false
    end
  end)
end

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

function  SilentServer:ADDON_LOADED(addon)
  if addon ~= "SilentServer" then return end

  SilentServerDB = SilentServerDB or {}
  SilentServerDB.hellfire = SilentServerDB.hellfire or true

  self:RegisterEvent("CHAT_MSG_SYSTEM")
  self:RegisterEvent("CHAT_MSG_YELL")
  self:RegisterEvent("RAID_ROSTER_UPDATE")
  self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function  SilentServer:RAID_ROSTER_UPDATE()
  self:RosterUpdate()
end

function  SilentServer:PLAYER_ENTERING_WORLD()
  self:RosterUpdate()
end

function  SilentServer:CHAT_MSG_SYSTEM(msg)
  self:Shush(msg,"system")
end

function  SilentServer:CHAT_MSG_YELL(msg,from)
  self:Shush(msg,"yell",from)
end
