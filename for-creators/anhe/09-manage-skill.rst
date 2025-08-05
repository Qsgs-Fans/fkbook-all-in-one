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
  
  hasSkill("skill_name") / hasSkill(skill.name)

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

⑥ 攻击范围技

⑦ 失效技

⑧ 目标选择技

⑨ 可见技

⑩ 卡牌技

视为技
~~~~~~~

☆ 视为技，就是指那种允许把一张或者几张卡牌当作其它卡牌使用或打出的技能。\

比如倾国（把一张黑牌当作闪）、乱击（把两张同花色的牌当作万箭齐发）之类的。\

在视为技中，被视作为的卡牌不一定是实际存在的卡牌。\

比如鬼才，是把一张手牌当作一张虚拟的卡牌打出，而虚拟的卡牌具有更改判定的作用效果。\
这样的被视作为的、可以完成一定技能效果的虚拟卡牌，称作技能卡。

视为技有一门远房亲戚，被大家称为锁定视为技。指将一张卡牌永久视为其它卡牌的技能。\
目前已有的锁定视为技有：红颜、武神、禁酒等。

创建一个视为技用到的关键词为 ``addEffect("viewas",{})`` ，它的原型是：

.. code:: lua

  ---@class ViewAsSkillSpec: UsableSkillSpec
  ---@field public card_filter? fun(self: ViewAsSkill, player: Player, to_select: integer, selected: integer[]): any @ 判断卡牌能否选择
  ---@field public view_as fun(self: ViewAsSkill, player: Player, cards: integer[]): Card? @ 判断转化为什么牌
  ---@field public pattern? string
  ---@field public enabled_at_play? fun(self: ViewAsSkill, player: Player): any
  ---@field public enabled_at_response? fun(self: ViewAsSkill, player: Player, response: boolean): any
  ---@field public before_use? fun(self: ViewAsSkill, player: ServerPlayer, use: UseCardDataSpec): string? @ 使用/打出前执行的内容，返回字符串则取消此次使用，返回技能名则在本次询问中禁止使用此技能
  ---@field public after_use? fun(self: ViewAsSkill, player: ServerPlayer, use: UseCardData | RespondCardData): string? @ 使用/打出此牌后执行的内容
  ---@field public prompt? string|fun(self: ViewAsSkill, player: Player, selected_cards: integer[], selected: Player[]): string


这个函数内部有多个参数，我们先在这里仅挑选列举的几个关键字参数做介绍。

- ``pattern``: 表示这个视为技在回合外可转化牌的限制规定。在回合外询问你打出或者使用某张牌时会以本参数作为使用规则；
- ``card_filter``: 是一个规定选择玩家手里那些牌被视为的函数，返回false代表此次视为牌的操作为虚拟牌。\
    这个函数的原型是: ``function(self, player, to_select, selected)``, 它需要四个参数，分别是self,player, to_select和selected, 
    分别代表函数本体，使用本技能的玩家，下一张要选择的牌和已经选择的牌。
- ``view_as``: 是一个规定选择玩家手里那些牌被视为的函数，返回false代表此次视为牌的操作为虚拟牌。\
    这个函数的原型是: ``function(self,player, cards)``, 它需要三个参数，分别是self,player和cards。
- ``enabled_at_play`` 表示约定是否允许主动使用视为的卡牌。\
    这个函数的原型是: ``function(self, player)``, 它需要两个参数，分别是self, player。
- ``enabled_at_response`` 表示约定是否允许使用视为的卡牌进行响应。
    这个函数的原型是: ``function(self, player, response)`` 。第三个参数response判断是否为打出卡牌。

值得一提的是，锁定视为技的创建方法，是 ``addEffect("filter",{})`` 关键字 ，原型是：

.. code:: lua
  
  ---@class FilterSpec: StatusSkillSpec
  ---@field public card_filter? fun(self: FilterSkill, card: Card, player: Player, isJudgeEvent: boolean?): any
  ---@field public view_as? fun(self: FilterSkill, player: Player, card: Card): Card?
  ---@field public equip_skill_filter? fun(self: FilterSkill, skill: Skill, player: Player): string?
  ---@field public handly_cards? fun(self: FilterSkill, player: Player): integer[]? @ 视为拥有可以如手牌般使用或打出的牌

这些参数和创建视为技的CreateViewAsSkill的同名参数的含义是一样的。但是多了equip_skill_filter和handly_cards两个参数。

equip_skill_filter是用来判技能是否视为某装备的函数，skill是本技能，返回值string是装备的代码名称

handly_cards是用来返回可以视为拥有可以如手牌般使用或打出的牌的牌的函数，返回值integer[]是牌的id数组。


触发技
~~~~~~~

☆ 触发技，就是指那种一旦遇到某个条件，就可以发动产生某种效果的技能。

比如放逐（受到伤害时可让某角色摸牌翻面）、闭月（回合结束阶段时可摸一张牌）之类的。

触发技中有一部分技能是在受到伤害时发动的，就是著名的卖血触发技了；也有一些是遇到回合中的某个阶段被触发的，被称作阶段触发技。

PS：我们之前设计的美王技能也是一个触发技哦～

创建一个视为技用到的方法为 ``addEffect(fk.时机,{})`` ，它的原型是：

.. code:: lua

    {
      --- name = "xxx",
      --- can_trigger?: T,
      --- on_cost?: T,
      --- on_use?: T,
      --- can_wake?: T,
      --- global?: boolean,
      --- anim_type?: AnimationType,
      --- frequency?: string,
      --- priority? : number,
    }

这个方法有多个参数，我们这里仅挑选几个重要的：

- ``name``: 表示这个触发技的名字。
- ``frequency``: 表示这个触发技的类型，例如锁定技、限定技、觉醒技等。
- ``priority``: 表示这个触发技的优先级，数字越大优先级越高。
- ``global``: 表示这个触发技是否全局触发，如果是，则所有角色满足条件均会触发。
- ``anim_type``: 表示这个触发技的动画类型。
- ``can_wake``: 表示这个触发技的觉醒条件。\ 
- ``can_trigger``: 是一个规定这个触发技在触发时机下满足何等条件可被触发的函数。\
    这个函数的原型是: ``function(self, player, event, target, data)`` , 它需要五个参数，分别是self, player, event, target, data。
- ``on_cost`` 是一个规定这个触发技触发时需要执行对应消耗的函数。\
    这个函数的原型是同can_trigger保持一致。
- ``on_use`` 是一个规定这个触发技触发后执行对应效果的函数。
    这个函数的原型是同can_trigger保持一致。

举例来说，如果一个触发技能是：当你受到伤害后，你可以弃置一张牌，摸一张牌。\

这里这个触发技能的can_trigger便是“受伤角色为拥有这个技能的角色”，触发时机是fk.Damaged，\
而这个触发技能的on_cost和on_use也就分别是“弃置一张牌”和“摸一张牌”啦。

唔……好像一口气看了太多了……有点心虚……
不过其实我们现在已经把最主要的两类技能了解得差不多了。剩下的那三类占的比重已经不是很大了，都是一些特殊技能而已。


禁止技
~~~~~~~

☆ 禁止技，就是具有禁止使用效果的技能啦。具体到游戏里面，就是那些不能成为目标的技能了。

比如空城（没手牌时不能成为杀和决斗的目标）、谦逊（不能成为顺手牵羊和乐不思蜀的目标）之类的。

创建一个视为技用到的关键词为 ``addEffect("prohibit",{})`` ，它的原型是：

.. code:: lua

  ---@class ProhibitSpec: StatusSkillSpec
  ---@field public is_prohibited? fun(self: ProhibitSkill, from: Player, to: Player, card: Card): any
  ---@field public prohibit_use? fun(self: ProhibitSkill, player: Player, card: Card): any
  ---@field public prohibit_response? fun(self: ProhibitSkill, player: Player, card: Card): any
  ---@field public prohibit_discard? fun(self: ProhibitSkill, player: Player, card: Card): any
  ---@field public prohibit_pindian? fun(self: ProhibitSkill, from: Player, to: Player): any

这个方法有五个参数，is_prohibited, prohibit_use, prohibit_response, prohibit_discard和prohibit_pindian，后四个参数都是可选参数，分别对应不同的禁止情况。

- ``name``: 表示这个禁止技的名字。
- ``is_prohibited``: 是一个规定这个禁止技是否禁止"某名玩家对某名玩家使用某张牌"的函数。\
    这个函数的原型是: ``function(self, from, to, card)``, 它需要四个参数，分别是self, from, to, card。
- ``prohibit_pindian``: 是一个规定这个禁止技对“拼点”这一操作的禁止要求。\
    这个函数的原型是: ``function(self, player, to)``, 它需要三个参数，分别是self, player, to。
- ``prohibit_use``: 是一个规定这个禁止技对“使用”这一操作的禁止要求。\
    这个函数的原型是: ``function(self, player, card)``, 它需要三个参数，分别是self, player, card。
- ``prohibit_response`` 是一个规定这个禁止技对“打出”这一操作的禁止要求。\
    这个函数的原型是同prohibit_use保持一致。
- ``prohibit_discard`` 是一个规定这个禁止技对“弃置”这一操作的禁止要求。
    这个函数的原型是同prohibit_use保持一致。


距离修改技
~~~~~~~~~~


☆ 距离修改技，就是跟计算距离相关的技能了，之前我们设计过那个腾云技能就属于这一类，应该是很熟悉了。

创建方法我们也已经使用过了，就是： ``addEffect("distance",{})``

.. code:: lua

  ---@class DistanceSpec: StatusSkillSpec
  ---@field public correct_func? fun(self: DistanceSkill, from: Player, to: Player): integer?
  ---@field public fixed_func? fun(self: DistanceSkill, from: Player, to: Player): integer?


- ``correct_func``: 是一个规定距离修正的函数。\
    这个函数的原型是: ``function(self, from, to)``, 它需要两个参数，分别是self, from和to。
- ``fixed_func``: 是一个规定距离固定值的函数。\
    这个函数的原型是同correct_func保持一致。

距离修改技的correct_func和fixed_func都是用来修正距离的，返回值integer代表修正的距离。


手牌上限技
~~~~~~~~~~

☆ 手牌上限技，就是用来修改手牌上限的技能嘛，很好理解。像血裔、宗室之类的都算的。

创建手牌上限技用到的方法是 ``addEffect("max_cards",{})`` ，它的原型是：

.. code:: lua

  ---@class MaxCardsSpec: StatusSkillSpec
  ---@field public correct_func? fun(self: MaxCardsSkill, player: Player): number?
  ---@field public fixed_func? fun(self: MaxCardsSkill, player: Player): number?
  ---@field public exclude_from? fun(self: MaxCardsSkill, player: Player, card: Card): any @ 判定某牌是否不计入手牌上限


- ``correct_func``: 是一个规定手牌上限修正的函数。\
    这个函数的原型是: ``function(self, player)``, 它需要两个参数，分别是self和player。
- ``fixed_func``: 是一个规定手牌上限固定值的函数。\
    这个函数的原型是同correct_func保持一致。
- ``exclude_from``: 是一个判定某张牌是否不计入手牌上限的函数。\
    这个函数的原型是: ``function(self, player, card)``, 它需要三个参数，分别是self, player和card。


攻击范围技
~~~~~~~~~~

☆ 攻击范围技，就是用来修改攻击范围的技能。比如阑干、伏匿之类的。

创建攻击范围技用到的方法是 ``addEffect("atkrange",{})`` ，它的原型是：

.. code:: lua

  ---@class AttackRangeSpec: StatusSkillSpec
  ---@field public correct_func? fun(self: AttackRangeSkill, from: Player, to: Player): number?
  ---@field public fixed_func? fun(self: AttackRangeSkill, player: Player): number?  @ 判定角色的锁定攻击范围初值
  ---@field public final_func? fun(self: AttackRangeSkill, player: Player): number?  @ 判定角色的锁定攻击范围终值
  ---@field public within_func? fun(self: AttackRangeSkill, from: Player, to: Player): any @ 判定to角色是否锁定在角色from攻击范围内
  ---@field public without_func? fun(self: AttackRangeSkill, from: Player, to: Player): any @ 判定to角色是否锁定在角色from攻击范围外


- ``within_func``: 是一个判定某个角色是否锁定在某个角色的攻击范围内的函数。\
    这个函数的原型是: ``function(self, from, to)``, 它需要两个参数，分别是self, from和to。
- ``without_func``: 是一个判定某个角色是否锁定在某个角色的攻击范围外的函数。\
    这个函数的原型是同within_func保持一致。
- ``final_func``: 是一个判定某个角色的锁定攻击范围终值的函数。\
    这个函数的原型是同correct_func保持一致。

攻击范围技的correct_func和fixed_func都是用来修正攻击范围的，返回值number代表修正的距离。


失效技
~~~~~~~

☆ 失效技，就是那些不能发动的技能。比如谋曹丕的放逐、界马超的铁骑之类的。

创建失效技用到的方法是 ``addEffect("invalidity",{})`` ，它的原型是：

.. code:: lua

  ---@class InvaliditySpec: StatusSkillSpec
  ---@field public invalidity_func? fun(self: InvaliditySkill, from: Player, skill: Skill): any @ 判定角色的技能是否无效
  ---@field public invalidity_attackrange? fun(self: InvaliditySkill, player: Player, card: Weapon): any @ 判定武器的攻击范围是否无效


- ``invalidity_func``: 是一个判定某个技能是否无效的函数。\
    这个函数的原型是: ``function(self, from, skill)``, 它需要两个参数，分别是self, from和skill。
- ``invalidity_attackrange``: 是一个判定某个武器的攻击范围是否无效的函数。\
    这个函数的原型是同invalidity_func保持一致。


目标选择技
~~~~~~~~~~

☆ 目标选择技，可以选择额外目标或者卡牌次数上限的多功能技能。比如咆哮之类的。

创建目标选择技用到的方法是 ``addEffect("targetmod",{})`` ，它的原型是：

.. code:: lua

  ---@class TargetModSpec: StatusSkillSpec
  ---@field public bypass_times? fun(self: TargetModSkill, player: Player, skill: ActiveSkill, scope: integer, card?: Card, to?: Player): any
  ---@field public residue_func? fun(self: TargetModSkill, player: Player, skill: ActiveSkill, scope: integer, card?: Card, to?: Player): number?
  ---@field public fix_times_func? fun(self: TargetModSkill, player: Player, skill: ActiveSkill, scope: integer, card?: Card, to?: Player): number?
  ---@field public bypass_distances? fun(self: TargetModSkill, player: Player, skill: ActiveSkill, card?: Card, to?: Player): any
  ---@field public distance_limit_func? fun(self: TargetModSkill, player: Player, skill: ActiveSkill, card?: Card, to?: Player): number?
  ---@field public extra_target_func? fun(self: TargetModSkill, player: Player, skill: ActiveSkill, card?: Card): number?
  ---@field public target_tip_func? fun(self: TargetModSkill, player: Player, to_select: Player, selected: Player[], selected_cards: integer[], card?: Card, selectable: boolean, extra_data: any): string|TargetTipDataSpec?

这个函数内部有多个参数，我们先在这里仅挑选列举的几个关键字参数做介绍。

- ``bypass_times``: 是一个判定某个主动技能或某张牌是否无次数限制的函数。\
    这个函数的原型是同is_prohibited保持一致。
- ``residue_func``: 是一个修正卡牌的次数上限的函数。\
    这个函数的原型是同correct_func保持一致。
- ``fix_times_func``: 是一个固定卡牌的次数上限的函数。\
    这个函数的原型是同correct_func保持一致。
- ``bypass_distances``: 是一个判定某个主动技能或某张牌是否无距离限制的函数。\
    这个函数的原型是同is_prohibited保持一致。
- ``distance_limit_func``: 是一个修正距离限制的函数。\
    这个函数的原型是同correct_func保持一致。
- ``extra_target_func``: 是一个修正额外目标的数量的函数。\
    这个函数的原型是同correct_func保持一致。
- ``target_tip_func``: 是一个自定义目标选择提示的函数。\
    这个函数的原型是: ``function(self, to_select, selected, selected_cards, card, selectable, extra_data)``,
    它需要七个参数，分别是self, to_select, selected_cards, card, selectable, extra_data。



可见技
~~~~~~~~

☆ 可见技，令某个角色的身份，卡牌变成可见的技能。比如捷悟之类的。

创建可见技用到的方法是 ``addEffect("visibility",{})`` ，它的原型是：
.. code:: lua

  ---@class VisibilitySpec: StatusSkillSpec
  ---@field public card_visible? fun(self: VisibilitySkill, player: Player, card: Card): any
  ---@field public role_visible? fun(self: VisibilitySkill, player: Player, target: Player): any


- ``card_visible``: 是一个判定某个卡牌是否对某个角色可见的函数。\
    这个函数的原型是: ``function(self, player, card)``, 它需要两个参数，分别是self, player和card。
- ``role_visible``: 是一个判定某个角色的身份是否对某个玩家可见的函数。\
    这个函数的原型是同card_visible保持一致。


卡牌技
~~~~~~~~~~

☆ 卡牌技，就是那些可以对卡牌进行操作的技能。比如狂战士之类的。

创建卡牌技用到的方法是 ``addEffect("cardmod",{})`` ，它的原型是：

.. code:: lua

  ---@class CardSkillSpec: UsableSkillSpec
  ---@field public mod_target_filter? fun(self: ActiveSkill, player: Player, to_select: Player, selected: Player[], card: Card, extra_data: any): any @ 判定目标是否合法（例如不能杀自己，火攻无手牌目标）
  ---@field public target_filter? fun(self: CardSkill, player: Player?, to_select: Player, selected: Player[], selected_cards: integer[], card?: Card, extra_data: any): any @ 判定目标能否选择
  ---@field public feasible? fun(self: CardSkill, player: Player, selected: Player[], selected_cards: integer[]): any @ 判断卡牌和目标是否符合技能限制
  ---@field public can_use? fun(self: CardSkill, player: Player, card: Card, extra_data: any): any @ 判断主动技能否发动
  ---@field public on_use? fun(self: CardSkill, room: Room, cardUseEvent: UseCardData): any
  ---@field public fix_targets? fun(self: CardSkill, player: Player, card: Card, extra_data: any): Player[]? @ 设置固定目标
  ---@field public on_action? fun(self: CardSkill, room: Room, cardUseEvent: UseCardData, finished: boolean): any
  ---@field public about_to_effect? fun(self: CardSkill, room: Room, effect: CardEffectData): boolean? @ 生效前判断，返回true则取消效果
  ---@field public on_effect? fun(self: CardSkill, room: Room, effect: CardEffectData): any
  ---@field public on_nullified? fun(self: CardSkill, room: Room, effect: CardEffectData): any @ (仅用于延时锦囊)被抵消时执行内容


这个方法有很多参数，我们这里挑选几个重要的：

- ``mod_target_filter``: 是一个规定目标是否合法的函数。\
    这个函数的原型是: ``function(self, player, to_select, selected, card, extra_data)``, 它需要六个参数，分别是self, player, to_select, selected, card, extra_data。
- ``target_filter``: 是一个规定目标能否选择的函数。\
    这个函数的原型是同mod_target_filter保持一致。
- ``feasible``: 是一个判断卡牌和目标是否符合技能限制的函数。\
    这个函数的原型是: ``function(self, player, selected, selected_cards)``, 它需要三个参数，分别是self, player, selected_cards。
- ``can_use``: 是一个判断主动技能是否发动的函数。\
    这个函数的原型是同feasible保持一致。
- ``on_use``: 是一个规定主动技能发动后执行的函数。\
    这个函数的原型是: ``function(self, room, cardUseEvent)``, 它需要两个参数，分别是self, room, cardUseEvent。
- ``fix_targets``: 是一个设置固定目标的函数。\
    这个函数的原型是: ``function(self, player, card, extra_data)``, 它需要三个参数，分别是self, player, card, extra_data。
- ``on_action``: 是一个规定主动技能效果执行前或者执行完毕后的函数，区别执行前或者后依靠参数finished来区分。\
    这个函数的原型是同on_use保持一致。
- ``about_to_effect``: 是一个规定主动技能生效前的判断函数。如果返回true则取消效果。\
    这个函数的原型是: ``function(self, room, effect)``, 它需要两个参数，分别是self, room, effect。
- ``on_effect``: 是一个规定主动技能生效时执行的函数。\
    这个函数的原型是同on_use保持一致。
- ``on_nullified``: 是一个规定延时锦囊被抵消时的函数。\
    这个函数的原型是同on_use保持一致。

cardskill仅用于绑定卡牌，是作为卡牌的主动使用技。



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

1. player表示获得技能的角色。

2. skill_names表示待获得技能的名字，传入的就是我们上面所提到了name啦。

   特别地，如果要失去某些技能的话，只需要在技能的名字前面加上一个 ``-`` 字符就可以啦，非常方便！
   举例来说，我想要获得那个男人的技能激昂，那么传入的字符串应该就是"jiang"，而如果要失去激昂，那么应该传入“-jiang”。

3. source_skill表示待获得技能的技能来源，就是通过那个技能使角色获得了这个技能，日常可以设为nil，则为空。

4. sendLog表示是否在对局中要发送获得或失去技能的报告。

5. no_trigger表示是否在对局中要触发获得或失去技能的对应时机。

