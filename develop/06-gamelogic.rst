服务端 - 多房间与游戏流程
==========================

从这里开始Lua代码就要发挥相当重要的作用了，首先来看单线程环境下的并发实现。

房间调度
---------

每个房间对应一个Lua协程。对于房间数量很多的情况，需要为一定数量的房间各启用\
一个线程，每一个线程由RoomThread类管理。

在房间调度模块，关注的对象只有RoomThread内部的工作流程。而调度本身是通过事件\
循环（Qt提供）进行的，每个房间在工作很短一段时间后必须主动让出线程控制权，在Lua
的角度体现为让出协程，在C++的角度则是函数返回。该模块主要的作用范围是C++代码，
主要有三个类发挥着作用。

.. uml:: ./uml/s-logic-schedule.puml

.. uml:: ./uml/s-logic-schedule-stat.puml

.. uml::

  @startuml
  title 信号pushRequest的发起与处理
  !include uml/s-logic-schedule-sig.iuml

  Rou -> R : notify
  activate R
  R -> S : pushRequest
  S -> L : handleRequest
  deactivate R
  @enduml

.. uml::

  @startuml
  title 信号delay的发起与处理
  !include uml/s-logic-schedule-sig.iuml

  L -> R : delay
  activate L
  R -> S : delay
  S <-- S : doDelay
  S -> L : resumeRoom
  deactivate L
  @enduml

.. uml::

  @startuml
  title 信号wakeUp的发起与处理
  !include uml/s-logic-schedule-sig.iuml

  Rou -> R : reply/Room::abandoned
  activate R
  R -> S : wakeUp
  S -> L : resumeRoom
  deactivate R
  @enduml

setRequestTimer在发起请求之后调用，用来创建一个计时器，当时间达到出牌时间时唤醒
房间。destroyRequestTimer用于清理本次request创建的计时器。其工作原理如图所示，
注意图中省略了一部分信息传递流程。

.. uml:: uml/s-logic-request-timer.puml

请求与答复
-----------

此处指的是类似服务器询问玩家是否发动某某技能，玩家选择如何作出答复的过程。
该概念需要Lua和C++代码的紧密配合才能正常运转，因此从C++和Lua两方进行说明。
先明确一下需要实现的功能：

1. 能向玩家发送请求包，能检测玩家是否已经做出回复
2. 在玩家出现网络状态波动时，能及时进行响应
3. 当玩家消耗了所有用时都不答复时，能正确按默认条件处理
4. 支持一名玩家同时控制多个角色

从这里开始会涉及Lua的类了，在Lua类和C++类共存的图中，Lua类标记为浅蓝色。
在这三个相关类中，Lua侧的Request类无疑发挥最重要的作用，一般的使用方法是构造，
填充data和默认回复，再调用ask方法进行询问与等待。

.. uml:: uml/s-logic-request-class.puml

游戏逻辑
---------

此处完全由Lua实现，这里主要说明事件机制的实现方案，及其运行与中断的机制。
