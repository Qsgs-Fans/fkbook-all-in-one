local extension = Package:new("xuexi")
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
    data.n = data.n + 10
  end,
}

sunwukong:addSkill("wushuang")
sunwukong:addSkill(st__meiwang)

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
}

return extension