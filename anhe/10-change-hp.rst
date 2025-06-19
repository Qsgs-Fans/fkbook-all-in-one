体力变更
==========

在修改手牌上限的时候，我们初次接触到了获得体力值的方法player.hp。其实，体力作为三国杀武将的绝对重要的属性，在我们的扩展武将活动中占有着不可替代的地位，很多技能都是围绕体力所展开的。接下来我们就了解一下有关体力变化的方法。

体力流失
--------------

完成流失体力的任务其实很简单，只需要一个函数即可。那便是：loseHp。
loseHp是Room的一个成员函数，它的原型是这样的: ``loseHp(player, lose)`` 。

其中player是流失体力的受害者，而lose是一个数值，表示流失体力的数量。

现在我们就到代码中实验一下这个函数吧。
比如我们设计一个类似于崩坏的技能：

“自满：锁定技，回合开始阶段开始时，你须流失1点体力。”

这是一个触发技，触发频率为锁定技，触发的时机是回合开始阶段，效果就是流失一点体力了。

所以代码是这样写的：

.. code:: lua
  local Luaziman=fk.CreateSkill{
    name = "lua_ziman",
    tags={Skill.Compulsory}
  }

  Luaziman:addEffect(fk.TurnStart,{
    can_trigger = function(self, player, event, target, data)
      return player:hasSkill(Luaziman.name) and target == player
    end,
    on_cost = Util.TrueFunc, 
    on_use = function(self, player, event, target, data)
      local room = player.room
      room:loseHp(player, 1)
    end,
  })


请注意：流失体力是不会触发武将的那些卖血触发技的！什么奸雄啊刚烈啊反馈啊遗计啊在体力流失面前都是浮云！

从代码中也能明白，对吧？流失体力只有这么一句话，哪有心思管你是否发动技能啊。

所以要想触发那些卖血触发技，还是要先造成伤害才好……

制造伤害
--------------

在新月杀中，制造一次伤害可比流失一次体力要更复杂了。首先我们应该先认识一下新月杀中专门负责管理伤害信息的一个伤害结构damage：

.. code:: lua

   room:damage{
    from = player,
    to = target,
    damage = 1,
    damageType = fk.FireDamage,
    skillName = "yeyan",
   }

可以看到damage信息包含如下一些成员变量：

1. from：表示伤害来源（无来源伤害的值为nil）。
2. to：表示伤害对象。  
3. damage：表示伤害的点数。
4. nature：表示伤害的属性，有三个取值：

   fk.NormalDamage：无属性伤害，或者说普通伤害；

   fk.FireDamage：火焰属性伤害，如业炎造成的伤害；

   fk.ThunderDamage：雷电属性伤害，如雷击造成的伤害。

5. skillName：表示造成伤害的技能来源。

上述例子便是玩家player对目标target造成了1点火属性伤害，效果来自于技能“业炎”。

现在我们就把技能"自满"中的体力流失改成伤害：

“自满：锁定技：回合开始阶段，你须对自己造成的一点伤害。”

首先定义一个伤害结构吧：

这个伤害的来源是自己，所以from = player；

而伤害目标也是自己，所以to = player；

造成了一点伤害，所以damage = 1；

没说伤害是什么属性的，所以就认为nature = sgs.DamageStruct_Normal；

伤害的技能来源当然是自满这个技能啦，但是由于这个效果处于自满技能内，我们可以用self.name代替字符串。

然后，代码就是……

.. code:: lua

  local Luaziman=fk.CreateSkill{
    name = "lua_ziman",
    tags={Skill.Compulsory}
  }

  Luaziman:addEffect(fk.TurnStart,{
    can_trigger = function(self, player, event, target, data)
      return player:hasSkill(self) and target == player
    end,
    on_cost = Util.TrueFunc, 
    on_use = function(self, player, event, target, data)
      local room = player.room
      room:damage{
          from = player,
          to = player,
          damage = 1,
          damageType = fk.NormalDamage,
          skillName = self.name,
        }
    end,
  })

回复体力
--------------

现在我们来研究一下体力恢复的事情

与造成伤害需要用伤害结构来保存伤害信息一样，恢复体力也有一些信息需要保存，

所以也是通过一个结构来保存这些信息的。这个用来保存恢复体力的各方面信息的结构，就是恢复结构recover了。

.. code:: lua

   room:recover{
      who = player,
      num = 1,
      recoverBy = player,
      skillName = "qingnang"
    }

可以看到damage信息包含如下一些成员变量：

1. who：表示要回复体力的角色。
2. num：表示回复体力的数值。  
3. recoverBy：表示回复体力的事件来源角色。
4. skillName：表示回复体力的技能来源。

上述例子便是玩家player令自己player回复了1点体力，效果来自于技能“青囊”。

现在我们把技能改成：

“自满：锁定技：回合开始时，你须对自己造成的一点伤害，然后恢复一点体力。”

然后，代码就是……

.. code:: lua

  local Luaziman=fk.CreateSkill{
    name = "lua_ziman",
    tags={Skill.Compulsory}
  }

  Luaziman:addEffect(fk.TurnStart,{
    can_trigger = function(self, player, event, target, data)
      return player:hasSkill(self) and target == player
    end,
    on_cost = Util.TrueFunc, 
    on_use = function(self, player, event, target, data)
      local room = player.room
      room:damage{
          from = player,
          to = player,
          damage = 1,
          damageType = fk.NormalDamage,
          skillName = self.name,
        }
      room:recover{
          who = player,
          num = 1,
          recoverBy = player,
          skillName = self.name,
        }
    end,
  })
  
体力上限修改
--------------

下面要谈一个很严肃的问题了。嗯，就是体力上限的问题。这是关乎到武将们的切身利益的严重问题。

流失体力上限，这是一种几乎不可逆的行为，使用前请务必三思啊……（☆SP刘备：不要学我玩嗓子！）

不过在代码中，修改体力上限和修改体力一样简单，都是可以一行代码解决的小问题。

room麾下一员大将changeMaxHp正等待着我们的召唤！那么我们就来考察考察这个成员函数吧: ``loseMaxHp(player, num)`` 。

其中player是要修改体力上限的橘色，而num是一个数值，表示修改体力上限的数量，正数代表增加体力上限，负数代表减少体力上限。

创建一个新技能：

“自满：锁定技，当你造成伤害后，你减少一点体力上限，然后你增加一点体力上限。”

这也是个触发技，触发时机是造成伤害后，应该是fk.Damage，代码就是……

.. code:: lua

  local Luaziman=fk.CreateSkill{
    name = "lua_ziman",
    tags={Skill.Compulsory}
  }

  Luaziman:addEffect(fk.TurnStart,{
    can_trigger = function(self, player, event, target, data)
      return player:hasSkill(self) and target == player
    end,
    on_cost = Util.TrueFunc, 
    on_use = function(self, player, event, target, data)
      local room = player.room
      room:changeMaxHp(player, -1)
      room:changeMaxHp(player, 1)
    end,
  })
