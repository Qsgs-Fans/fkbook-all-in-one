--[[
  拓展包名称：学习包（xuexi）
  说明：这个拓展包是我学习武将拓展用的
  作者：notify
  武将数目：总共1名武将，已完成1名武将
  武将列表：
    孙悟空（st__sunwukong）
  尚需完善的内容：好多好多……
  备注：
    百度新月杀吧欢迎您！
--]]
local extension = Package:new("xuexi")
-- 我是单行注释 ^_^
extension.extensionName = "study"

Fk:loadTranslationTable{
  ["xuexi"] = "学习",
  ["st"] = "学",
}

local sunwukong = General:new(extension, "st__sunwukong", "god", 5)

local st__meiwang = fk.CreateTriggerSkill{
  name = "st__meiwang",
  anim_type = "drawcard",
  events = {fk.DrawNCards},
  on_use = function(self, event, target, player, data)
    local msg = {} -- 创建一个LogMessage
    msg.type = "#hello"
    msg.to = { player.id }
    player.room:sendLog(msg)

    data.n = data.n + 10
  end,
}

local tengyun = fk.CreateDistanceSkill{
  name = "st__tengyun",
  correct_func = function(self, from, to)
    if from:hasSkill(self) then
      return -5
    end
    if to:hasSkill(self) then
      return 5
    end
  end,
}

sunwukong:addSkill("wushuang")
sunwukong:addSkill(st__meiwang)
sunwukong:addSkill(tengyun)

Fk:loadTranslationTable{
  ["st__sunwukong"] = "孙悟空",
  ["#st__sunwukong"] = "齐天大圣",
  ["designer:st__sunwukong"] = "设计者",
  ["cv:st__sunwukong"] = "配音演员",
  ["illustrator:st__sunwukong"] = "画师",

  ["st__meiwang"] = "美王",
  [":st__meiwang"] = "摸牌阶段，你可以多摸十张牌。",
  ["$st__meiwang"] = "技能 美王 的台词哦。",
  ["~st__sunwukong"] = "孙悟空的阵亡语音……",

  ["#hello"] = "Hello！新月杀向你 %to 问好！",
}

return extension
