象棋#2 定义动态数据
===========================

本文介绍数据同步的原理，以及如何定义这样的数据。核心思想是， **把数据定义以及直接操作数据的方法都写在基类。**

背景知识
------------

Freekill是一个C/S架构的程序。

服务端负责的是：

- 同时运行多个房间（这里不关心）
- 运行房间中的游戏逻辑
- 通过网络向客户端同步数据、与之交互

客户端负责的是：

- 连接到服务器、加入房间、显示等待UI（这里不关心）
- 游戏开始后，显示游戏界面
- 接收服务端传来的消息，并调用对应的回调函数以同步数据、更新UI等
- 特定的消息会询问用户做出选择等。客户端此时需要用户进行交互

.. note::

   单机启动的本质上在本机上启动一个服务端，然后连接到本机。游戏逻辑依然运行在“服务端”的那个线程。

从桌游开发者的角度而言，必须弄清服务端和客户端的任务，以及具体代码在哪一端执行的。
就编程语言来说，服务端的代码是完完全全的Lua，客户端则需要Lua处理数据、QML绘制UI界面。

在上面的职责中，我们提到了 **同步数据** 。这里的数据指的就是游戏途中会动态改变的状态了。
由于游戏逻辑的代码是服务端运行的，因此这个状态肯定是由服务端主动更新，然后服务端再向客户端发送更新信息。
客户端则相对被动的接收服务端发来的信息，以此实现与服务端的数据同步。

一般情况下，服务端都是更改少量数据，并发送一个比较小的TCP报文发给客户端让他做出一样的更改
（也就是所谓的增量同步）。不过在断线重连、旁观这两个场景下，服务端就需要向一无所知的客户端发送整个房间内状态了
（也就是所谓的全量同步）。

总之，我们需要明白这个点： **服务端和客户端存在共享数据** 。根据桌游的不同，
实际数据可能很简单，也可能非常复杂。

又如前面所说，桌游需要人员和场地才能进行，放在Freekill中的话，人员就是 ``Player`` ，
场地则是游戏房间（ ``RoomBase`` ）。如此的人员和房间也分客户端和服务端，
毕竟两个端担任的职责区别很大。一般来说，服务端的人员（ ``ServerPlayer`` ）
与房间（ ``Room`` ）会提供一些向客户端发送信息的方法，
客户端的人员（ ``ClientPlayer`` ）和房间（ ``Client`` ）则提供与UI界面交互的方法等。

.. uml:: uml/basic-cs.puml

但不论如何，二者都会保存共同的动态数据。从类图可以看出两端有共同的基类，这样的数据就保存在基类之中。

定义动态数据
---------------

说了那么多，终于到了中国象棋的盘面数据定义环节。

中国象棋的盘面状态倒是相当简单：只要有盘面信息就可以了，而且棋子也是固定的32枚。
之前定义棋子时我们给每个棋子分配了数字id，所以用 ``int board[10][9]`` 表示盘面足矣~

上面说了数据保存到基类中，因此：

- 如果有需要保存在房间中的数据，就写在我们自己RoomBase类
- 如果有需要保存在玩家身上的数据，就写在我们自己的Player类

对于象棋而言，玩家不必保存什么信息，基类 ``Base.Player`` 已经提供了座位、身份（红方黑方）等。
我们只需要在 ``RoomBase`` 上动土就行了， ``Player`` 留空！

行棋至此，我们多了两个自定义的类：

.. uml:: uml/roombase-cs.puml

我们拓展了Freekill本身提供的Player和RoomBase两个基类，以放置自定义的数据。

来看代码， ``xiangqi/core/roombase.lua``:

.. code:: lua

   ---@class Xiangqi.RoomBase : Base.RoomBase
   ---@field public board integer[][]
   local RoomBase = Fk.Base.RoomBase:subclass("Xiangqi.RoomBase")

   local Xq = require "packages.chess-games.xiangqi"
   local ReqPlayChess = require "packages.chess-games.xiangqi.core.handler.playchess"

   function RoomBase:initialize()
     Fk.Base.RoomBase.initialize(self)

     self.board = Xq:createBoard()
     self:addRequestHandler("Xiangqi.PlayChess", ReqPlayChess)
   end

   -- ...

   return RoomBase

也是给RoomBase加了个字段board，在构造时请出了Engine实例，创建一个全新的棋盘。
``ReqPlayChess`` 又是什么呢？这个得留到客户端那一篇再细说。
我们现在只要知道增加了board数据保存盘面即可。

数据同步
-------------

增量同步
~~~~~~~~~~~

象棋中唯一的状态是棋盘，唯一的改变状态方式是走子。
显然，服务端和客户端都有必要实现走子操作更改数据的方式，这个更改方式是相同的，
因此将走子的方法写在基类之中。

.. code:: lua

   function RoomBase:movePieceTo(pieceId, fromX, fromY, x, y)
     local id = self.board[fromY][fromX]
     if id ~= pieceId then return end
     self.board[fromY][fromX] = 0
     self.board[y][x] = pieceId
   end


为了结合实例说明，我们可以看服务端和客户端对该方法的调用：

.. code:: lua

   -- server/room.lua: 服务端
   function Room:movePieceTo(pieceId, fromX, fromY, x, y)
     RoomBase.movePieceTo(self, pieceId, fromX, fromY, x, y)
     self:doBroadcastNotify("Xiangqi.MovePieceTo", { pieceId, fromX, fromY, x, y })
   end

   -- client/client.lua: 客户端
   function Client:handleMovePieceTo(data)
     local pieceId, fromX, fromY, x, y = data[1], data[2], data[3], data[4], data[5]
     self:movePieceTo(pieceId, fromX, fromY, x, y)
   end

这段代码中，服务端先调用基类的方法修改数据，再调用 ``doBoardcastNotify`` 通知全体玩家
（也就是发通知给所有客户端）盘面发生了变化。客户端收到之后，调用对应的回调方法，
进一步通过基类的方法（直接从基类继承）更新数据。

总之，增量同步的流程是：服务端更新 -> 服务端发信 -> 客户端收到后也更新

一般来说，每种会改变状态的操作都会在RoomBase中设置一个基础的改变数据的方法，
然后在Client和Room中分别按需调用，完成数据的同步。

全量同步
~~~~~~~~~~~

当用户从掉线状态返回，或者旁观其他棋局时，客户端中只有Engine中的那些静态数据，
而完全没有该房间的动态数据。为了解决这个问题有两种思路：

- 服务端保存所有走子记录，旁观时一次性发送所有走子，客户端遍历走子记录并从最初一步步更新状态
- 服务端直接把所有数据发送给客户端

第一种办法有点类似分布式里面的replica log，当新用户加入时，这种办法显然是效率过低的。
这种情况下就通过全量同步的方式将自己的数据发给客户端。客户端拿到完整信息后，
之后的数据同步就正常按照增量同步的方式来。

在 ``RoomBase`` 类（以及 ``Player`` 类，象棋只是不需要给Player新的数据而已）中，实现全量同步的核心是两个方法：
``serialize()`` 和 ``deserialize(data)`` 。前者把相关信息整合成一个可以通过TCP报文传输的格式，
后者则解析收到的信息，并更新相应的字段。

.. hint::

   Freekill的数据传输格式为CBOR格式，该格式相比JSON的自由度更高，但一样的千万注意不要把类实例放到里面。 ``serialize`` 返回的数据应当只包含基本数据类型（数字、字符串、布尔、nil）以及数组、键值表。

Freekill提供的基类自然囊括了通用的需要同步的信息，我们根据需求自己再往其中添加即可。

.. code:: lua

   function RoomBase:serialize()
     local o = Fk.Base.RoomBase.serialize(self)
     o.board = self.board
     return o
   end

   function RoomBase:deserialize(o)
     Fk.Base.RoomBase.deserialize(self, o)
     self.board = o.board
   end

当用户请求旁观时， ``serialize`` 会将当前状态整合成一个Lua表，我们的子类可以添加自定义字段；
``deserialize`` 会解析该信息，也是先调用基类方法解析，再赋值自定义字段。

.. danger::

   字段命名一定不要和基类产生冲突！否则会覆盖掉那些信息，导致数据同步失灵！

.. tip::

   Freekill的录像功能也是基于数据同步实现的。录像文件分为完整的可重放录像，以及终盘战况录像。

   重放录像的原理是保存客户端收到过的所有来自服务端的信息，重放时从Client的最状态开始，一条一条地重现那些信息，这会进一步触发UI效果等，从而实现录像播放。

   终盘战况则是在游戏结束时用 ``serialize`` 保存结束时的状态，当用户想要查看时，就从这个状态中恢复所有数据，类似于进行了全量同步。

   （TODO：目前并未实现该功能）录像重放过程中可以拖动进度条快速查看不同时间段的状态，这个功能是通过全量同步和增量同步结合实现的。在录像播放途中，程序会每隔一段时间保存该时间点的状态（也就是快照），当用户拖动完进度条后，程序先找到距离该时点最近的一个快照，恢复快照数据，再从快照时间点开始，到拖动进度条时间结束，快速重放这中间记录的录像（也就是增量同步），最后呈现到UI中。

总结
----------

在这篇文档中，我们首先为自定义桌游的RoomBase增加了自定义数据。
然后我们针对增量同步与全量同步两种数据同步方式，分别在RoomBase中定义了通过操作改变数据的方法，
以及将全部数据进行序列化与反序列化的方法。
