游戏进程
==========

变身：游戏开始时，变身为孙权；

英姿：摸牌阶段，多摸1张牌；

美王：摸牌阶段，多摸10张牌；

崩坏：回合开始时，流失1点体力，或流失1点体力上限；

自满：回合开始时，受到1点伤害，再恢复1点体力；

……

事实表明，三国杀中有许多技能，都和游戏进程有关；特别是阶段触发技，

更是直接以阶段作为触发时机。这类技能我们已经见识不少了，现在终于有时间有机会有精力有能耐细细品味一番了。

阶段触发技能
--------------
在三国杀中，一个回合里面总共有六大阶段，分别是：

准备阶段；判定阶段；摸牌阶段；出牌阶段；弃牌阶段；结束阶段。

很多技能都在这六个阶段上做文章。

比如英魂（准备阶段）、涉猎（摸牌阶段）、琴音（弃牌阶段）、闭月（结束阶段）之类的。

这种以阶段作为发动时机的技能，大多属于触发技，称作阶段触发技。

跟所有触发技一样，阶段触发技也是通过套用CreateTriggerSkill创建技能的模板创造的。只是它的触发时机是具体的阶段时机了。

跟阶段有关的触发时机有：

① fk.TurnStart（回合开始时）

② fk.EventPhaseChanging  （阶段转换时，两个阶段之间的时间点）---仅在本阶段没有被跳过的情况下才会执行

③ fk.EventPhaseSkipping  （阶段跳过时） ---仅在本阶段将要被跳过的情况下才会执行

④ fk.EventPhaseSkipped   （阶段跳过后） ---仅在本阶段将要被跳过的情况下才会执行

**如果没有跳过阶段的话呢，就会执行下面的⑤⑥⑦时机**

⑤ fk.EventPhaseStart     （阶段开始时）

⑥ fk.EventPhaseProceeding（阶段进行时）

⑦ fk.EventPhaseEnd       （阶段结束时）

⑧ fk.TurnEnd              (回合结束时)

可以看到，回合开始结束时和摸牌阶段有自己专用的触发时机，英姿等技能就是将摸牌阶段摸牌时的fk.DrawNCards作为自己的触发时机的。

然而另外的阶段该怎么办呢？

原来，一个阶段内又包扩两个更细小的触发时机，分别是刚进入这个阶段的阶段开始时机fk.EventPhaseStart，

以及即将离开这个阶段的阶段结束时机fk.EventPhaseEnd。

所以，如果我们说“XX阶段开始时……”，所用的触发时机就是fk.EventPhaseStart；

而如果我们说“XX阶段结束时……”，就该使用fk.EventPhaseEnd作为触发时机了。

那么怎么区分具体是哪个阶段呢？

不要紧，那个Player为我们提供了一个查看当前阶段的成员，那就是phase，写法就是player.phase。

这个函数的返回结果，列在下面了：

- 准备阶段：Player.Start（观星、英魂等可以发动）

- 判定阶段：Player.Judge（延时性锦囊判定；鬼才、鬼道等可以发动）

- 摸牌阶段：Player.Draw（英姿、神威等可以发动）

- 出牌阶段：Player.Play（大多数主动技能可以发动）

- 弃牌阶段：Player.Discard（琴音等可以发动）

- 结束阶段：sgs.Player_Finish（闭月、据守等可以发动）

- 回合外：Player.NotActive（大多数被动技能可以发动）

所以如果说“弃牌阶段……”，所用的触发时机为sgs.EventPhaseStart，并且在触发效果on_trigger中进行判断，

查看 Player.phase == Player.Discard 是否满足就行啦。

跳过阶段
--------------
然而阶段触发技能并不一定是“进入”某个阶段才可以触发的，有时我们会考虑“跳过”某个阶段以达到某些效果。

比如巧变（可以选择跳过判定、摸牌、出牌、弃牌四个阶段）。

为了实现跳过某个阶段，首先要先给自己灌输一个叫做“阶段变更”的概念。

在前一个阶段刚刚结束、后一个阶段刚要开始的这个时间点，就是阶段变更时机了。

所以说，fk.EventPhaseChanging也是和阶段有关的一个触发时机哦。

至于说具体的实现跳过阶段的工作，就要交给Player对象的一个成员函数skip了。下面是它的函数原型：

.. code:: lua
  
  player:skip(phase)

这个函数原型有一个参数phase，就是具体要跳过的那个阶段了。

所以，如果我们要创造这样的一个技能：“自满：锁定技，你跳过判定阶段。”

代码就是这样的：

.. code:: lua
  
  
  local Luaziman=fk.CreateSkill{
    name = "lua_ziman",
    tags={Skill.Compulsory}
  }

  Luaziman:addEffect(fk.EventPhaseChanging,{
    can_trigger = function(self, player, event, target, data)
      return player:hasSkill(self) and target == player
    end,
    on_cost = Util.TrueFunc, 
    on_use = function(self, player, event, target, data)
      local phase = Player.Judge
      player:skip(phase)
    end,
  })


启用翻面
--------------

关于阶段的扰乱方法我们已经掌握了，于是不满足的我们把目光又投向了更大的一个进程单位：回合。

扰乱回合的行为主要有两个，跳过回合和获得额外的回合。现在我们先来解决跳过回合的问题，做法嘛……那就是：启用翻面！

被翻面的角色将直接跳过下一个回合，这个机制是林扩展包引入的，但其实最早在风包曹仁的身上就体现了出来。

据守这个技能可以说开创了跳过阶段行为的先河，先不说究竟在游戏中的价值如何吧，单凭它对游戏进程扰乱的历史贡献就已经足够值得我们膜拜了～

然而，启动翻面的方法其实很简单，没错，又是一个只需要一个函数一条代码就能解决的事情。

完成这个创举的函数就是ServerPlayer中的成员函数: ``turnOver()``, 这个函数甚至简单到连参数都没有……

当然了，这个函数只管把当前角色翻面，至于处于什么状态，是正面朝上还是背面朝上，turnOver函数才不理会呢！

比如这个弱化版的据守技能：

“自满：锁定技，结束阶段，你翻面。”

.. code:: lua
  
  local Luaziman=fk.CreateSkill{
    name = "lua_ziman",
    tags={Skill.Compulsory}
  }

  Luaziman:addEffect(fk.EventPhaseStart,{
    can_trigger = function(self, player, event, target, data)
      return player:hasSkill(self) and target == player
    end,
    on_cost = Util.TrueFunc, 
    on_use = function(self, player, event, target, data)
      player:turnOver()
    end,
  })

额外回合
--------------
能够跳过一个回合，从理论上讲自然也应该有能获得一个额外的回合的方法。

三国杀中含有获得额外回合的技能有连破和放权等。赶紧找源代码来看一下。

看看我们找到了什么？

gainAnExtraTurn，看来就是这个家伙在背后推波助澜了。

没错。可以帮助我们实现获得一个额外的回合功能的方法正是它了。

特别要注意的是，这个函数目前被设置在新月杀的常用函数库内，需要先调用对应的库才可以使用哦！

调用这个库的方法是 ``local U = require "packages/utility/utility"`` 。

而对于这个函数本身，有三个参数to, sendLog, skillName，

分别对应要获得额外回合的角色，是否发动记录信息，和通过什么技能获得了这个额外回合。

好了，下面我们把技能休息改成这个样子：

  “自满：锁定技，结束阶段开始时，你于此回合后执行一个额外的回合。”（好像有点无限循环了呢，不过无所谓！）

.. code:: lua

  local U = require "packages/utility/utility"
  
  local Luaziman=fk.CreateSkill{
    name = "lua_ziman",
    tags={Skill.Compulsory}
  }

  Luaziman:addEffect(fk.EventPhaseStart,{
    can_trigger = function(self, player, event, target, data)
      return player:hasSkill(self) and target == player
    end,
    on_cost = Util.TrueFunc, 
    on_use = function(self, player, event, target, data)
      U.gainAnExtraTurn(player, true, self.name)
    end,
  })

这样只要就永远都是我的回合了。（我的回合，抽卡！）

那么赶紧到游戏中体验一下吧！



