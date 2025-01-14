.. SPDX-License-Identifier:	CC-BY-NC-SA-4.0

解析:触发技的除事件以外的其他时机
=================

这里解析的是lua/server/event.lua文件

-- 列出所有触发事件以外的时机

-- 关于每个时机的详情请从文档中检索。


此为获得与失去技能时的时机
-------------------------

fk.EventLoseSkill = 22   @失去技能时

fk.EventAcquireSkill = 23   @获得技能时

.. note::

   fk.EventLoseSkill，fk.EventAcquireSkill的时机承担者者均为（获得/失去）的技能时的角色，

   data=skill。skill为本次（获得/失去）的技能


此为横置与翻面的时机
-----------------------

fk.BeforeTurnOver = 79  @翻面前

fk.TurnedOver = 30      @翻面时

fk.BeforeChainStateChange = 80   @改变横置状态前

fk.ChainStateChanged = 31    @改变横置状态后

.. note::

   fk.BeforeTurnOver，fk.TurnedOver的承担者均为翻面角色，无data。

   fk.BeforeChainStateChange，fk.ChainStateChanged的承担者均为横置角色，无data。

   （若在触发fk.BeforeTurnOver技能的on_use函数中return true则导致翻面中止）

   （若在触发fk.BeforeChainStateChange技能的on_use函数中return true则导致横置状态改变时机被取消）


此为游戏完成后的时机
-----------------------

fk.GameFinished = 66  @游戏完成后

.. note::

   fk.GameFinished为游戏完成后，执行当前阶段的角色为承担者，data=winner，
   winner  string @ 获胜的身份，空字符串表示平局



此类为询问卡牌时机。
----------------------

fk.AskForCardUse = 67   @询问卡牌使用时

fk.AskForCardResponse = 68  @询问卡牌打出时

fk.HandleAskForPlayCard = 97 @即将使用或打出卡牌时

fk.AfterAskForCardUse = 98  @询问卡牌使用后

fk.AfterAskForCardResponse = 99  @询问卡牌打出后

fk.AfterAskForNullification = 100  @询问无懈可击响应决胜后


.. note::

   fk.AskForCardUse的data参考解析:TriggerData中的AskForUse类。

   fk.AskForCardResponse的data详情参考解析:TriggerData中的AskForCardResponse

   fk.HandleAskForPlayCard是对即将使用或打出的卡牌进行限制的时机，其data是根据需求变化。

   在询问使用卡牌后也就是时机fk.AskForCardUse后会执行时机fk.HandleAskForPlayCard，

   此时fk.HandleAskForPlayCard里面的data和fk.AskForCardUse里面的data是一样的，无承担者target。

   而在时机fk.AskForCardResponse后，fk.HandleAskForPlayCard的data又会与fk.AskForCardResponse一致，同样无承担者。

   时机fk.AfterAskForCardUse在执行完fk.HandleAskForPlayCard后，会将本次卡牌使用事件作为data.result传入data，其余与fk.AskForCardUse一致。

   时机fk.AfterAskForCardResponse在执行完fk.HandleAskForPlayCard后，会将本次卡牌询问打出事件作为data.result传入data，其余与fk.AskForCardResponse一致。

   时机fk.AfterAskForNullification无承担者，并且分为可无懈时，和无或者不可无懈时。

   当没有人拥有视为使用或者无懈可击卡牌时，本时机的data={ eventData = effectData }，会直接执行卡牌效果。

   当有人拥有无懈可击打出并且在最终获胜时，
   
   data={

    result   CardUseStruct? @ 最终决胜出的卡牌使用信息,

    eventData? CardEffectEvent @ 关联的卡牌生效流程，可为空。

   }




此为牌堆洗牌时机
---------------

fk.AfterDrawPileShuffle = 74  @在牌堆洗牌后

.. note::

    本时机无承担者，data={}，data是一个空表。



此为触发技使用前时机
---------------

fk.BeforeTriggerSkillUse = 75  @在触发技使用之前

.. note::

    data详情参考解析:TriggerData中的SkillUseStruct



此为卡牌展示/亮出时机
---------------

fk.CardShown = 77  @卡牌展示/亮出时

.. note::

    本时机的data={ cardIds = cards }。

    cards 为本次展示的牌，类型可为integer|integer[]|Card|Card[]



此为卡牌区域废除与恢复时机
------------------------

fk.AreaAborted = 87  @区域废除时

fk.AreaResumed = 88  @区域恢复时

.. note::

   fk.AreaAborted的data={slots={}}。data里面只有一个slots属性，里面存放的是一个键值对。

   当废除判定区时，slots是空数组；当废除装备副区时索引为本次废除的副区字符串，

   例如卡牌的武器栏值为3 ，slots["3"]就代表了废除的区域为武器栏。而值为int，其是一个计数编号，

   本次废除事件中，第一个废除的装备栏记入1，第二个废除的则是2。

   因此如果第一个废除的是武器栏，slots["3"]==1。

   fk.AreaResumed的data与fk.AreaAborted的一样，都是数组，但是索引是不同的。   

   fk.AreaResumed的索引是1，2等int，而不是fk.AreaAborted的string作为索引。

   同时，它里面存放的是恢复的区域，

   此区域必须先是废除状态才可记入。而索引对应的值为string，

    Player.WeaponSlot = 'WeaponSlot' @武器栏

    Player.ArmorSlot = 'ArmorSlot' @防具栏

    Player.OffensiveRideSlot = 'OffensiveRideSlot' @进攻马

    Player.DefensiveRideSlot = 'DefensiveRideSlot' @防御马

    Player.TreasureSlot = 'TreasureSlot' @宝物栏

    Player.JudgeSlot = 'JudgeSlot'  @判定区




此为角色的明置暗置时机
------------------------

fk.GeneralShown = 95   @角色展示时

fk.GeneralRevealed = 89  @角色明置时

fk.GeneralHidden = 90   @角色暗置时

.. note::

   时机fk.GeneralShown的data= {[isDeputy and "d" or "m"] = generalName}。

   意思是如果本次展示的是副将，则索引值（键值，key值）为"d"，若变主将则是"m"。

   值均为本次展示的武将名。

   时机fk.GeneralRevealed的data会根据你的明置数量发生变化，若你一次性明置的仅是一个将，

   其data内容与时机fk.GeneralShown一样。

   若你一次性明置两个将， data = {["m"] = player:getMark("__heg_general"),
   ["d"] = player:getMark("__heg_deputy")}

   player代表了一次性明置双将的玩家，getmark是获取对应主副将的武将名称，

   所以data["m"]＝明置的主将名称，data["d"]＝明置的副将名称。

   时机fk.GeneralHidden的data为暗置的武将名称，data=generalName。




此为角色出牌开始时时机
---------------------

fk.StartPlayCard = 91  @角色出牌开始时

.. note::

    本时机与该角色的出牌阶段开始时有所不同，这里是在出牌阶段开始之后的出牌开始时。

    其时机在出牌阶段的fk.EventPhaseProceeding之后。

    而本时机的应用场景则主要是作为refresh_events触发，为某些技能的使用提前预设，

    例如提前将要用的卡放在某些区域方便在使用时及时移动，提前增加或清除标记等。




此为角色属性改变时机
-------------------

fk.BeforePropertyChange = 92  @角色属性改变前

fk.PropertyChange = 93  @角色属性改变时

fk.AfterPropertyChange = 94 @角色属性改变后

.. note::

    属性相关时机对应的data数据详情参考杂项文档中的解析:TriggerData中ChangePropertyData数据。

    fk.PropertyChange，若在触发本时机技能的on_use函数中return true则导致本事件与后续此事件流程终止


.. caution::

    data.result属性会在时机fk.AfterPropertyChange后重新赋值。

    如果你的fk.BeforePropertyChange，fk.PropertyChange，fk.AfterPropertyChange是在一个技能里，请注意仔细查看Data数据。
