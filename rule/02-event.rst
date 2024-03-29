事件与时机
============

本文来说明一下事件和时机的结算规则（在新月杀中）。

事件的结算流程
-----------------

事件指的就是诸如回血、摸牌之类的一个完整动作，一个事件的结算流程如下：

1. 首先进行事件能否进行的前置判断，若未通过则不进行事件。
2. 进行事件的实际效果（主要效果）。
3. 进行事件结束时的结算（清理效果）。
4. 一些事件在完成之后仍会存在一些结算（后续效果）。

事件的几个要素如下：前置判断、主效果、清理效果、后续效果、相关数据。

关于插入结算
~~~~~~~~~~~~

这也就是所谓的插结了，意思是说在事件A尚未结束时又引入事件B。
这个概念从三国杀诞生之时就已经引入了，虽然很少被明说出来。
按照规则而言，后续来的事件优先进行结算。然后后续事件又可能进一步插入新的事件，
最后插结的情况会变得很长很长，将其称为“事件栈”。

.. hint::

  栈就是一个有序序列而已，只能在最末尾加入，在最末尾删除。

举个例子，现在是我的出牌阶段询问出牌，此时实际上已经发生了如下很多次插入：

::

  轮次事件 -> 回合事件 -> 阶段事件

我们还能在出牌阶段使用牌，这样就又会进一步插入使用牌事件等等。

下面介绍一下关于插结相关的用语。

- 当前事件：目前正在结算的事件，在事件栈的最后。
- 父事件：在事件栈中，某个事件紧邻着的前一个事件称为父事件。
  例如在上面的例子中，阶段事件的父事件就是回合事件。
- 子事件：在事件栈中，某个事件紧邻着的后一个事件称为子事件。
  例如在上面的例子中，轮次事件的子事件就是回合事件。

引入事件栈的概念后，事件的执行流程就更加清晰了，具体如下：

::

  先进行事件的前置判断;
  若通过，则:
    将这个事件加入事件栈;
    执行事件的主效果;
    执行事件的清理效果;
    事件结束了，将事件从事件栈删除;
    执行事件的后续效果;

关于终止一切结算
~~~~~~~~~~~~~~~~~

这个概念在一将成名2013中由朱然提出，“终止一切结算并结束当前回合”。
意思就是先将自上次回合事件以来插入的所有事件全部终止，这样当前事件就变成了
回合事件；再将回合事件也一并终止。

只有正在进行主效果的事件可以被终止。

事件被终止时，立刻停止效果的执行，然后执行清理效果。

被终止的事件不执行其后续效果。

触发时机的结算流程
-------------------

触发时机的作用就是触发各种触发型技能。例如“造成伤害后”。

触发时机的要素有：时机本身、时机承担者、相关数据。

.. note::

   与规则集不同，新月杀的触发时机不会给每个小时机更加细分出①、②。

“时机承担者”是一个新的用语，其用来指代在这次触发时机中那名比较有代表性的玩家。
根据时机不同，其承担者也不同。
后面会出现许多“以XX为承担者，触发XX时机”的描述，请不要感到困惑。
有些关于触发时机的描述没写承担者，那么就表示没有承担者。

新月杀对于触发技流程的实现仍需优化，目前的实现如此：

::

  从当前行动者开始，按逆时针顺序对每名玩家进行检测，检测的内容为:
    选出所有该玩家满足发动条件的触发技
    若有多个，则询问其选择其中之一先发动，否则直接下一步
    对该玩家执行该技能的消耗环节，若通过则技能生效
    若时机已经被终止或者事件已经被终止，则结束触发流程

有些技能的优先级不同，例如武将技能比装备技能优先发动。对于优先级不同的技能，
上述检测会进行多次。

一些触发时机可能可以对数据进行修改，或者直接终止事件。这样的时机通常是形如
“XXX时”或者“XXX前”的。
