创建一个新技能
===============

重头戏来了！

前面我们就知道了，武将的游戏体验和TA的技能如何有着好大好大的关系。\
怎么样？五体力上限带无双的孙悟空是不是比五体力上限的白板孙悟空玩起来带劲儿多了？

现在我们要继续强化这种体验感了！打造真正拥有自己个性的新技能！

听说周瑜因为长得帅所以能多摸牌？我们美猴王孙悟空怎么样？摸死你！

现在打开刚刚遗忘在角落里的xuexi/skills文件夹吧，要写代码了～

先把一份英姿的代码拷贝到我们的扩展包文件里面去吧。

首先我们要创建一个技能lua，这个lua文件是专门用来存放本技能的各种效果的。

在skills里面新建文件，st__meiwang.lua。这里命名文件是没有讲究的，你可以完全按照自己喜好来定义，重复也没关系。

.. code:: lua

  local skill = fk.CreateSkill({
    name = "st__meiwang", ---技能内部名称，要求唯一性
    tags = {}, -- 技能标签，Skill.Compulsory代表锁定技，支持存放多个标签
  })


  --添加技能效果
  skill:addEffect(fk.DrawNCards, { --时机为摸牌阶段摸牌时
    anim_type = "drawcard", --动画效果为  摸牌动画
    on_use = function(self, event, target, player, data)
      data.n = data.n + 1 --摸牌数+1
    end
  })

  Fk:loadTranslationTable { --[[ 翻译表 ]] ) 

  return skill  --不要忘记返回做好的技能对象哦

注意定义孙悟空的那句话一开始就有了，只是演示该粘贴的位置哦。

什么？哪里搞到的？当然是全局搜索咯。新月杀已有的技能也全都是用Lua语言写的，\
我们稍微搜搜技能内部名称自然就找到它们的Lua代码了。

切记，如果遇到不知道怎么实现的效果，就去主力服或者私服下载一遍扩展包，然后在诸多大佬们做好的技能里面找找看吧！

言归正传，孙悟空那头都快上火了。

周瑜英姿多摸了一张牌，看到代码里面那个数字"+1"了吧？

.. code:: lua

   data.n = data.n + 1

孙大圣那可是"美"猴"王"啊，才多摸一张牌哪儿说得过去啊？在后面加个零，多摸十张！

.. code:: lua

   data.n = data.n + 10

行了，满意了。

核心代码已经完成，不过还有点需要修饰的工作要做。


翻译不要忘记咯（还记得那个Fk:loadTranslationTable吧？）：

.. code:: lua

  ["st__meiwang"] = "美王",
  [":st__meiwang"] = "摸牌阶段，你可以多摸十张牌。",

翻译一个技能是有一些要注意的地方的。

翻译技能的通式是这样的：

.. code:: lua

  ["技能名字"] = "技能名字的译文",
  [":技能名字"] = "技能的描述",

如果你需要设定技能的语音文件，我们在下一节audio篇会讲解哦~

技能名字的译文不要超过两个汉字，否则在游戏界面里面会显示的很奇怪……

技能名字前面加冒号，表示的是技能的描述。这个描述文本中可以加上HTML标签\
以制造某些文字效果，就跟网页代码一样。比如用<b>和</b>将一段文本夹起来，\
这段文本就被加粗了，要知道字体加粗是可以来显示锁定技、限定技、\
觉醒技之类的提示语的。

.. hint::

   不过在实操中，我们不要对锁定技之类的提示语手动加粗。

现在技能已经写好了，剩下的只需要把这个技能添加到武将身上就行了。\
没错，还是用我们已经熟悉的 ``addSkill`` 函数，不过这次不用addSkill形式了。\
这是因为我们要一口气添加多个技能，现在我们回到xuexi/init.lua文件\
找到我们的美猴王！添加属于我们自己的技能！不用引用别人的恩赐了！

.. code:: lua

   sunwukong:addSkills{"wushuang","st__meiwang"}

技能就添加完成了！赶快到游戏里面体验这个拥有强力摸牌技能的齐天大圣孙悟空吧！


进阶小知识：
.. code:: lua

   local skill = fk.CreateSkill({
     name = "技能内部名",
     tags = {Skill.Compulsory}, -- 技能标签
     dynamic_desc = ..., -- 动态描述函数
     dynamic_name = ..., -- 动态名称函数
   })

   -- 添加技能实际效果
   skill:addEffect( --[[ 每段效果的实际代码 ]] )

   -- 主动技例子
   skill:addEffect("active", { -- 关键词
     anim_type = "动画类型",
     card_filter = ...,
     target_filter = ...,
     on_use = ...,
   })
   -- 触发技例子
   skill:addEffect(fk.触发时机, {
     anim_type = ...,
     can_trigger = ...,
     on_cost = function(self, event, target, player, data)
       if ... then
         event:setCostData(self, {tos = {target}, cards = {1, 2}) --存储信息的函数，这里的信息在on_cost/on_use中可以获取
         return true
       end
     end,
     on_use = function(self, event, target, player, data)
       local to = event:getCostData(self).tos[1] --获取存储的信息
       ...
     end
   })

   -- 添加技能AI
   skill:addAI( --[[ ... ]] )
   -- 添加技能测试用例
   skill:addTest( --[[ 技能的测试用例 ]] )

   Fk:loadTranslationTable { --[[ 翻译表 ]] )
   return skill
