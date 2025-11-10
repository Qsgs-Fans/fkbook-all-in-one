AI方案设计
===========

设计上来说，放弃之前试图用一个大的 ``addAI`` 囊括所有策略的意图，而是将ai细分为不同的策略类，用多个 ``addAI`` 为技能骨架添加多个AI策略。

一般来说，每次发起Request询问玩家时，它的command对应着一种策略的类型。而像askForUseActiveSkill这种非常泛用的，则又可以进一步衍生出更多的策略类型（比如 ``discard_skill`` 可以衍生出“弃牌策略”这种类型）

AI做出决策的整体流程：

- 根据这个request的 ``command`` ，调用 ``SmartAI:handle<command>`` 方法。
- 这个是SmartAI类中负责定义的。一般来说，本次询问的上下文中都会有个skillName表示技能名，
  SmartAI找到技能后会要求相关技能提供一个和这个command对应的策略。
- 此时一般调用 ``SmartAI:findStrategyOfSkill(type, skillName)`` ，找到一个 ``AIStrategy`` 型的值，没有的话就用默认方案。
- 如何求解的自由度就很高了，不同的strategy根据方法实现的不同，有不同的思考手段

关于AIStrategy这个类型：

- 在定义子类（下称 ``M`` ）的文件中，需要继承AIStrategy基类，这个不是全局变量，每次都要require一下
- 实现 ``M:think(ai)`` 方法，其中ai参数为SmartAI，返回值为 ``any, number?`` ，可以进一步写明返回类型
- 实现 ``M:convertThinkResult(data)`` 方法，其中data是think方法的第一个返回值。这个方法的目的是将思考结果转换成对应request期待从客户端接收到的返回值类型。
  
  - 比如说，某个询问期望客户端发回一个玩家id，而对应的ai的think会返回一个ServerPlayer。此时就需要实现一下convertThinkResult，将它转换成id，即 ``function(data) return data.id end``

- think方法自然要根据不同技能的addAI写法有不同的思考，因此你的子类需要定义一个让用户来重写的虚函数，它一般的内容是默认的思考逻辑，也可能是空
- 最后创建一个用来新建策略的函数，函数接收的参数是对应的spec，一般来说希望用户能修改策略的哪些细节，就给spec对应的能力，在函数里面读取spec即可

和AI策略类型相关的代码都在 lua/lunarltk/server/ai/strategies 文件夹下。这次不单独开全局变量，而是将内置的策略类型放在了 ``Fk.Ltk.AI`` 这张表里面。每种策略都给出类型定义，以及一个创建方法。

.. hint::

   注意 ``SmartAI:findStrategyOfSkill(type, skillName)`` 是个泛用的方法，没说只能在handleXXX里面使用。
   因此AIStrategy除了保存实际执行思考的function之外，也可以用来保存一些数值，
   例如discard skill就可能可以新建一个策略类型，表示某张卡牌在弃牌这件事上的保留价值之类的，
   而卡牌的技能中也就可以添加此类策略。

需要注意的是目前仍有相当多的老代码残留着，还没删，为了不报错用了一些忽略性的手段。
