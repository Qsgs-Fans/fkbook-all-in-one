象棋#3 编写游戏逻辑
============================

本文介绍服务端的运行流程，以及游戏逻辑如何在服务端运行。核心思想是， **服务端运行游戏逻辑，并在途中不断与客户端进行交互。**

基本知识
----------

前文介绍的只是Lua中的抽象类，现在要正式和实例化的类打交道了。从之前的类图可以知道服务端涉及的类是
``Room`` 和 ``ServerPlayer`` 。但是实际上不止于此，请看类图：

.. uml:: uml/server-class.puml

.. note::

   middleclass只支持单一继承，而图中绘制出了多重继承。
   在实际的代码中，这是通过 **混入** （Mixin）的方式实现的。
   Mixin的核心目标是向目标类添加各种特定的功能和字段，而不是充当真正的基类。

   为了表示出区别，图中在遇到多重继承的表现形式时，用加粗箭头表示真正的父子继承关系。

我们依然是需要定义几个自己的类。作为基本知识，我们先关心一下它们的Mixin基类。

``ServerRoomBase`` 和 ``ServerPlayerBase`` 分别持有一个对应的C++ Room或者C++ ServerPlayer，
它们负责从C++层提供最基本的信息（名字、房间设置之类的）。
这两个基类也提供了方法来调用C++对象暴露给Lua的接口，从而实现基本的网络通信功能。
上篇文档中看到的 ``doBroadcastNotify`` 方法，就是 ``ServerRoomBase`` 提供的。
该类还提供了一些常用的 ``RoomBase`` 的服务端包装方法，毕竟其实大部分情况都是简单的调用一下
``RoomBase`` 的同名方法，然后向Client发出消息。如果Lua有装饰器就好了

除了Room和Player定义了Server特供版子类之外，还有几个其他的类需要注意，先在这里说明一下。

- ``GameLogic`` : 游戏逻辑类，定义着游戏逻辑方法，是该房间运行的核心。它还有一些比较高级的功能，但象棋不需要。
- ``AI``: AI类，包含人机玩家如何做决策的代码，需要自己去实现。为了服务端能正常运行，至少要定义一个子类并作为ServerPlayer的成员才行。（以及象棋模式并没有去实现AI）

象棋模式中的 ``ServerPlayer`` 和 ``AI`` 都是和空模板一样的，没有做什么修改，主要还是看 ``Room`` 和 ``GameLogic`` 。

编写游戏逻辑
------------------

一句话概括本文的主题就是： **游戏启动后会调用 ``GameLogic:run()`` ，直到游戏结束**。游戏会在以下几种情况结束：

- ``GameLogic:run()`` 返回，或因出错终止
- 调用 ``Room:gameOver()`` 也会导致游戏结束

关于错误处理的话题不在象棋的讨论范围内，之后再说。我们的首要任务就是实现 ``run()`` 方法，为此需要先明确游戏运行的流程。我们做一个简单版的象棋流程：决定红方黑方、摆好棋子、轮番走子，当一方被将死时游戏结束。

直接看代码：

.. code:: lua

   function GameLogic:run()
     self:adjustSeats()
     self:assignRole()

     self:initBoard()

     self:action()
   end

第一行 ``adjustSeats`` 是基类提供的，总之必须在开始游戏前调用一下，
他基于 ``room.players`` 数组的顺序决定好玩家座位相关的数据（底层需要这个）。
有些桌游可能会在决定座次之前做其他操作（例如打乱players数组实现随机座位）。

第二行是自定义的方法，用于分配身份。游戏结束时的胜负判断的是哪种身份获胜，因此它相当于阵营。
此处的身份指的就是红方与黑方。

第三行用来初始化棋盘。当然棋盘早在 ``RoomBase`` 的构造函数中初始化了，它的作用是给客户端发信息。

最后进入 ``action`` 方法，游戏正式开始，这也是自定义方法，我一般会取名action。
其中如何实现轮番走子就不再详细叙述了，毕竟重点是Freekill本身。

定义Room
-----------

.. code:: lua

   local GameLogic = require "packages.chess-games.xiangqi.server.gamelogic"
   local ServerPlayer = require "packages.chess-games.xiangqi.server.serverplayer"

   function Room:initialize(_room)
     RoomBase.initialize(self)
     Fk.Base.ServerRoomBase.initialize(self, _room)

     self.serverplayer_klass = ServerPlayer
     self.logic_klass = GameLogic
   end

我们主要看构造函数（虽然模板已经提供了），它把玩家类和游戏逻辑类传给了Room，
这样底层逻辑就知道该实例化哪个类了。

``Room`` 其他的方法基本上就是和数据传输有关的了，前文已叙述过了。

总结
-----------

本文讲述了服务端的相关类，以及游戏逻辑的实现。
