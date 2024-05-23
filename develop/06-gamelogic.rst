服务端 - 游玩
==============

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

游戏逻辑
---------

此处完全由Lua实现，这里主要说明事件机制的实现方案，及其运行与中断的机制。
