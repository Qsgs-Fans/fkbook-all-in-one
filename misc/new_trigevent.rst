开发草稿：触发技重构
=========================

系重要重构内容，影响范围广泛

触发时机重构流程
------------------------

就目前而言，triggerEvent是数字（ ``fk.Damage = 12`` ），data是一个表（并且插件识别为any）
以下是重构方案

首先，将触发时机改为TriggerEvent类的子类

.. code:: lua

   ---@class fk.Damage : TriggerEvent
   fk.Damage = TriggerEvent:subclass("fk.Damage")

然后，考虑到多种触发时机使用同一种data，因此更好的办法是，在基类TriggerEvent和
最终触发时机类之间加入一层父类，即：

.. code:: lua

   ---@class DamageEvent: TriggerEvent
   ---@field data DamageStruct
   local DamageEvent = TriggerEvent:subclass("DamageEvent")

   -- 以及其他使用DamageStruct作为data的触发时机...
   ---@class fk.Damage: DamageEvent
   fk.Damage = DamageEvent:subclass("fk.Damage")

最后，还需要让插件知道这类时机对应的是这个data。

.. code:: lua

   ---@alias DamageTrigFunc fun(self: TriggerSkill, event: DamageEvent,
   ---  target: ServerPlayer, player: ServerPlayer, data: DamageStruct): any

   ---@class SkillSkeleton
   ---@field public addEffect fun(self: SkillSkeleton, key: DamageEvent,
   ---  attr: TrigSkelAttribute?, data: TrigSkelSpec<DamageTrigFunc>): SkillSkeleton

如此一来插件就能识别这个触发时机对应的data了，主要是修改key和data中的类型

触发时机的data: 重构流程
--------------------------

上文提到了Damage系列时机对应了DamageStruct作为data。data是一个表，为了后面的
用途需要将其改成类实例。

老代码：

.. code:: lua

   ---@class DamageStruct
   ---@field public from? ServerPlayer @ 伤害来源
   ---@field public to ServerPlayer @ 伤害目标
   ---@field public damage integer @ 伤害值
   
在新代码中，DamageStruct应该是一个继承于Object的类，而之前的表形式则是这样的
类的构造函数。为此改成

.. code:: lua

   ---@class DamageStructSpec
   ---@field public from? ServerPlayer @ 伤害来源
   ---@field public to ServerPlayer @ 伤害目标
   ---@field public damage integer @ 伤害值

   ---@class DamageStruct: DamageStructSpec, TriggerData
   DamageStruct = TriggerData:subclass("DamageStruct")

这样就完成了类型的定义。在实例化时用 ``DamageStruct:new(data)`` 就能创建

接下来是落实到代码中，一般来说调用 ``logic:trigger`` 的函数都位于游戏事件中，
因此要将这里传入的data改成实例，归根结底就是让这个GameEvent的data作为类实例。
为此修改相关函数：

.. code:: lua`

   ---@param damageStruct DamageStructSpec
   ---@return boolean
   function HpEventWrappers:damage(damageStruct)
     local data = DamageStruct:new(damageStruct)
     return exec(Damage, data)
   end

如上，首先修改参数的类型，这样room:damage函数和之前版本的用法完全没有区别，然后
在执行事件之前，先构建好DamageStruct类型data的实例。当然了，不少情况下GameEvent内
其余代码或多或少也需要进行修改。

关于遗计与反馈的多发问题
---------------------------

与上面两节关联并不大，暂且搁置
