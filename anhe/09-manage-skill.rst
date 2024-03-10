技能管理
==========

技能判定
--------------

在前一章节创建修改距离技能时，我们遇到了 ``hasSkill`` 函数方法\
体会到这一方式对设计思路的影响，本章节针对此函数方法做具体介绍。

``hasSkill`` 函数方法的核心控制因素在于操控角色的玩家 ``player`` \
可以在游戏源代码 ``lua/core/player.lua`` 中看到对此参数的详细说明。\
``hasSkill`` 函数方法是 ``player`` 的一个成员函数，\
技能开发过程中我们主要通过 ``player`` 调用这个成员函数。

``hasSkill`` 函数方法的原型是这样的

.. code:: lua
  
  hasSkill(skill_name)

翻译过来，就是：hasSkill(技能名)

这个函数主要用于判断一个玩家对象是否拥有指定的技能，返回true和false分别代表拥有和没有。

创建技能
--------------

技能需要代码编写者在编写完成后主动创建，以便正常在游戏中使用。

然而，不同的技能有不同的创建方法。之前我们已经成功创建了一个关于距离修改的技能，\
但是显然同样的方法面对那些与距离无关的技能的创建工作就无能为力了。

新月杀的技能体系很庞大，有各式各样的技能。但是大体上看，这些技能可以依照它们的特点划分成一些相对好理解的类别：
① 视为技（包括锁定视为技等）
② 触发技（包括卖血触发技、启动触发技、阶段触发技等）
③ 禁止技
④ 距离修改技
⑤ 手牌上限技

☆ 视为技，就是指那种允许把一张或者几张卡牌当作其它卡牌使用或打出的技能。\
比如倾国（把一张黑牌当作闪）、乱击（把两张同花色的牌当作万箭齐发）之类的。\
在视为技中，被视作为的卡牌不一定是实际存在的卡牌。\
比如鬼才，是把一张手牌当作一张虚拟的卡牌打出，而虚拟的卡牌具有更改判定的作用效果。\
这样的被视作为的、可以完成一定技能效果的虚拟卡牌，称作技能卡。

视为技有一门远房亲戚，被大家称为锁定视为技。指将一张卡牌永久视为其它卡牌的技能。\
目前已有的锁定视为技有：红颜、武神、禁酒等。

创建一个视为技用到的方法为 ``fk.CreateViewAsSkill`` ，它的原型是：

.. code:: lua

  fk.CreateViewAsSkill{
    name = "xxx",
    interaction = xxx,
    card_filter = xxx,
    view_as = xxx,
    enabled_at_play = xxx, 
    enabled_at_response = xxx,
  }

这个方法有六个参数，name, interaction, card_filter, view_as, enabled_at_play和enabled_at_response，我们先在这里忽略掉interaction，对其他五个参数做介绍。

- ``name``: 表示这个视为技的名字；
- ``card_filter``: 是一个规定选择玩家手里那些牌被视为的函数，返回false代表此次视为牌的操作为虚拟牌。\
    这个函数的原型是: ``function(self, selected, to_select)``, 它需要三个参数，分别是self, selected和to_select, 分别代表函数本体，已经被选的牌和下一张要选择的牌。
- ``view_as``: 是一个规定选择玩家手里那些牌被视为的函数，返回false代表此次视为牌的操作为虚拟牌。\
    这个函数的原型是: ``function(self, cards)``, 它需要两个参数，分别是self, cards。
- ``enabled_at_play`` 表示约定是否允许主动使用视为的卡牌。\
    这个函数的原型是: ``function(self, player)``, 它需要两个参数，分别是self, player。
- ``enabled_at_response``表示约定是否允许使用视为的卡牌进行响应。
    这个函数的原型是: ``function(self, player, pattern)``。第三个参数pattern用于对特定响应方式做筛选。

值得一提的是，锁定视为技的创建方法，是 ``fk.CreateFilterSkill``，原型是：

.. code:: lua
  
  fk.CreateFilterSkill{
    name = "xxx", 
    view_filter = xxx, 
    view_as = xxx
  }

这些参数和创建视为技的CreateViewAsSkill的同名参数的含义是一样的。

☆ 触发技，就是指那种一旦遇到某个条件，就可以发动产生某种效果的技能。比如放逐（受到伤害时可让某角色摸牌翻面）、闭月（回合结束阶段时可摸一张牌）之类的。
触发技中有一部分技能是在受到伤害时发动的，就是著名的卖血触发技了；也有一些是遇到回合中的某个阶段被触发的，被称作阶段触发技。
PS：我们之前设计的美王技能也是一个触发技哦～

创建一个视为技用到的方法为 ``fk.CreateTriggerSkill`` ，它的原型是：

.. code:: lua

  fk.CreateTriggerSkill{
    name = "xxx",
    frequency = xxx,
    events = xxx,
    can_trigger = xxx,
    on_cost = xxx, 
    on_use = xxx,
  }

这个方法有六个参数，name, frequency, events, can_trigger, on_cost和on_use.

- ``name``: 表示这个触发技的名字。
- ``frequency``: 表示这个触发技的类型，例如锁定技、限定技、觉醒技等。
- ``events``: 表示这个触发技的触发时机，例如受到伤害后等，需要用lua的表形式提供参数，如events = {fk.Damaged}，表示受到伤害后这个时机。  
- ``can_trigger``: 是一个规定这个触发技在触发时机下满足何等条件可被触发的函数。\
    这个函数的原型是: ``function(self, player, event, target, data)``, 它需要五个参数，分别是self, player, event, target, data。
- ``on_cost`` 是一个规定这个触发技触发时需要执行对应消耗的函数。\
    这个函数的原型是同can_trigger保持一致。
- ``on_use``是一个规定这个触发技触发后执行对应效果的函数。
    这个函数的原型是同can_trigger保持一致。

举例来说，如果一个触发技能是：当你受到伤害后，你可以弃置一张牌，摸一张牌。\
这里这个触发技能的can_trigger便是“受伤角色为拥有这个技能的角色”，\
而这个触发技能的on_cost和on_use也就分别是“弃置一张牌”和“摸一张牌”啦。

唔……好像一口气看了太多了……有点心虚……
不过其实我们现在已经把最主要的两类技能了解得差不多了。剩下的那三类占的比重已经不是很大了，都是一些特殊技能而已。

☆ 禁止技，就是具有禁止使用效果的技能啦。具体到游戏里面，就是那些不能成为目标的技能了。比如空城（没手牌时不能成为杀和决斗的目标）、谦逊（不能成为顺手牵羊和乐不思蜀的目标）之类的。

创建一个视为技用到的方法为 ``fk.CreateProhibitSkill`` ，它的原型是：

.. code:: lua

  fk.CreateProhibitSkill{
    name = "xxx",
    prohibit_use = xxx,
    prohibit_use = xxx,
    prohibit_discard = xxx,
  }

这个方法有四个参数，name, prohibit_use, prohibit_response和prohibit_discard，后三个参数都是可选参数，分别对应不同的禁止情况。

- ``name``: 表示这个禁止技的名字。
- ``prohibit_use``: 是一个规定这个禁止技对“使用”这一操作的禁止要求。\
    这个函数的原型是: ``function(self, player, card)``, 它需要三个参数，分别是self, player, card。
- ``prohibit_response`` 是一个规定这个禁止技对“打出”这一操作的禁止要求。\
    这个函数的原型是同prohibit_use保持一致。
- ``prohibit_discard`` 是一个规定这个禁止技对“弃置”这一操作的禁止要求。
    这个函数的原型是同prohibit_use保持一致。

☆ 距离修改技，就是跟计算距离相关的技能了，之前我们设计过那个腾云技能就属于这一类，应该是很熟悉了。

创建方法我们也已经使用过了，就是： ``fk.CreateDistanceSkill{name, correct_func}``。

所以这部分就忽略掉吧……

☆ 手牌上限技，就是用来修改手牌上限的技能嘛，很好理解。像血裔、宗室之类的都算的。

创建手牌上限技用到的方法是 ``fk.CreateMaxCardsSkill``，它的原型是：

.. code:: lua

  fk.CreateMaxCardsSkill{
    name = "xxx",
    correct_func = xxx,
  }

不用说，name肯定又是来表示技能名字的了，而correct_func则是用来指导手牌上限修正的了。
和距离修改技中的correct_func一样，手牌上线技能的correct_func也是一个返回修正数值的函数，它的函数原型是：function(self, player)。

就这样，我们基本上知道了应该如何去创建一个我们需要的技能了。\
不过是采用对应的创建方法，通过不同的参数传递和处理来表达我们的意愿，达到特定的效果而已。No confusion, now!

获得或失去技能
--------------

有些时候我们会需要在游戏中获得或失去某些技能。比如父魂，在发动成功后将会获得咆哮和武圣。听上去真是帅得不得了……

其实也不过就是一句话就能搞定的事情了。真的，没有看错，只需要一句话、或者更具体的、一个函数就OK了。这个函数就是：handleAddLoseSkills!
还记得Room老兄吧？没错，handleAddLoseSkills依然是它的一个成员函数（早就说过我们会经常拜托Room兄办事的……）

.. code:: lua
  room:handleAddLoseSkills(player, skill_names, source_skill, sendlog, no_trigger)

其中：
① player表示获得技能的角色。
② skill_names表示待获得技能的名字，传入的就是我们上面所提到了name啦。\
特别地，如果要失去某些技能的话，只需要在技能的名字前面加上一个 ``-`` 字符就可以啦，非常方便！\
举例来说，我想要获得那个男人的技能激昂，那么传入的字符串应该就是"jiang"，而如果要失去激昂，那么应该传入“-jiang”。
③ source_skill表示待获得技能的技能来源，就是通过那个技能使角色获得了这个技能，日常可以设为nil，则为空。
④ sendLog表示是否在对局中要发送获得或失去技能的报告。
⑤ no_trigger表示是否在对局中要触发获得或失去技能的对应时机。

