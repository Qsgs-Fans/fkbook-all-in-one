local extension = Package:new("xuexi")
extension.extensionName = "study"

Fk:loadTranslationTable{
  ["xuexi"] = "学习",
  ["st"] = "学",
}

local sunwukong = General:new(extension, "st__sunwukong", "god", 5)
sunwukong:addSkill("wushuang")
Fk:loadTranslationTable{
  ["st__sunwukong"] = "孙悟空",
  ["#st__sunwukong"] = "齐天大圣",
}

return extension
