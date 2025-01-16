.. SPDX-License-Identifier:	CC-BY-NC-SA-4.0

新月杀实用小知识整理
==================

这里整理了一些比较实用的小知识，今后可能会用到。


新月杀标记格式整理
-----------------

.. error::
    
    在设置，增加或移除玩家的标记时，请使用room类中的相关函数，不要使用player类中的set/add/remove。


"mark":普通标记，不会显示在将面上。

"@mark":显示标记，标记名称与标记的值（可以是table,string,int等类型的值）

"@@mark":显示标记，但是不会显示标记值。

"@$mark":显示牌名标记，标记值为Card.name的table

"@&mark":显示武将名标记，标记值为General.name的table

"@!mark":角标标记，标记不会显示在将面上，但是会伴有角标图片与标记数量在将框右下角

.. note::

    @!mark需要自带角标图片，标记图片放在扩展包文件夹的image/mark文件夹中，格式20x20-25x25之间。

    类型为png图片。命名需要与@!mark标记名一致。若对此@！mark赋值，除int以外的类型均不会显示标记值。

"@[mark]":此为qml标记，本标记需要额外定义qml标记函数。

.. code-block:: lua
   :linenos:

   Fk:addQmlMark{
    name="mark",
    qml_path = function(name, value, p){
      return "qml的路径"  -- string
    },
    how_to_show = function(name, value, p){
      return "标记值的显示"  -- string？
    },
   }
   -- 详情请查看类 QmlMarkSpec

"@[private]$mark":仅自己可见的卡牌牌堆标记。本标记里面存放的是卡牌的私人牌堆。

"@[private]&mark":仅自己可见的武将牌堆标记。本标记里面存放的是武将的私人牌堆。

"@[private]:mark":仅自己可见的qml窗口标记

"@[suits]mark":显示花色的标记。其标记值应为存放Card.Suit的table。

"@[chara]mark":显示角色的武将名（若有副将，改为显示位置）。其标记值应为角色的id。

"@[player]mark":记录多名角色，标记值显示数量，点击查看记录的角色信息（若后继以$开头则仅自己可见），传入值为角色id的table

"@[cardtypes]mark":显示卡牌的类型。标记值为Card.type的table。

"@[:]mark":显示标记的详情。这是一个qml标记，标记值为table。

"@[xianfu]mark":显示角色武将名称的标记。标记值为一个类{value,visible}。

.. note::

    标记值中的value属性可为StrIng可为int。若为int则输入角色id，然后该属性返回角色的武将名称。

    visible属性则控制此标记值是否对非标记拥有者可见，为bool类型的属性。
    
    @[xianfu]mark目前为唯一特殊标记，其的标记值是一个类。



新月杀技能名格式整理
-------------------

"skill_name":正常的技能名，作为武将的一般技能名，武将addskill此技能时会正常加入武将的技能栏。

.. note::

    武将addRelatedSkill此技能则作为衍生技加入游戏，在游戏开始时不会获得，例如界吕蒙的攻心，觉醒才可获得。


"#skill_name":衍生技。此技能不会出现在武将的技能栏中，会被隐藏。一般是作为技能的补充效果。

.. note::

    例如，咆哮改：你使用的杀无次数限制。你回合开始可以使用一张杀。

    第一个效果需要我们创建一个CreateTargetModSkill实现，第二个则是CreateTriggerSkill实现。
    
    使用skill1:addRelatedSkill(skill2)将我们创建的第一个技能CreateTargetModSkill挂载上CreateTriggerSkill。

"skill_name$":主公技，其仅会在该角色的身份为主公时会获得。在玩家角色低于5名时不会获得。

"skill_name&":附加技，该技能为额外获得的非武将池技能。在定义主要技时，设置主要技的attach_skill_name参数即可令全场获得本附加技。

.. note::

    例如一将成名的刘封的陷嗣，其会令全场拥有一个附加技【陷嗣】，这个技能是不属于武将的，因此不会受到技能失去和无效的影响。



新月杀其他命名格式整理
--------------------

"&card_name":衍生卡牌名。此卡牌不会出现在牌堆中，需要“特殊召唤”才能出现。例如虎牢关神吕布的装备。

"$card_pile":私人牌堆名。$前缀的牌堆仅能自己看见，即私人牌堆拥有者。

"card_pile&":私人牌堆名。但此牌堆的牌可如手牌搬使用或打出。
