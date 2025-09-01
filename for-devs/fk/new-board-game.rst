关于创建新类型桌游
===================

在cpp中我们实现了基本的room，里面保存了人数、人员、房间设置的基本信息，客户端中与之相关的是房间内等待界面。游戏的进一步实际运行交给了服务端Lua、客户端Lua、该游戏实际页面。

我们可以把这些想象成桌游店：在游戏开始之前，只是一堆人坐在桌子周围，桌上有即将交给店主的本局游戏信息（至少是想玩哪种桌游）。人员集齐并决定开始游戏后，店主再把会用到的游戏配件送过来，具体怎么去玩就留给玩家自己了；在程序中还有一个“发牌员”般的存在负责发牌、记录数据、处理具体结算等。

因此，一种桌游应该有以下要素：

- ``engine`` : 静态游戏配件
- ``abstract_room_klass``, ``player_klass`` : 发牌员需要记住的数据
- ``logic_klass`` : 发牌员需要遵循的结算规则，即GameLogic
- ``client_klass``, ``room_page`` : 发牌员的“发牌”如何让客户端处理，即command+data

架构和API设计
---------------

整体分析后，通用架构应该如下图：

.. uml:: uml/boardgame-all.puml

其中，用户应该要做以下的事情才能拓展自己的新桌游：

- 派生Core中的Player和RoomBase类，增添数据成员
- 定义一堆自己觉得有必要的类，然后派生Core中的Engine类来管理类以及实例
- 派生自己的Player和RoomBase类，分别对应图中Client侧和Server侧

  - 派生后都需要include一下mixin来实现图中的接口，参见已有例子

- 对于server侧，派生GameLogicBase，重写run()方法
- 对于server侧，可以向Room中添加自己的API了
- 对于client侧，向Client中编写若干新方法来处理自定义新command
- 对于客户端，编写新QML页面作为游戏页面。详见“QML重构”篇

之前的草稿
--------------

由于FreeKill主打一个可拓展，新游戏品类也得可以自定义拓展方式了

- ``ex-util.lua`` : 返回拓展常用组件

文件架构
--------------

    - game_name
      - core
        - player.lua
        - abstract_room.lua
        - engine.lua
        - 其他需要放入engine之中的
      - client
        - client.lua
      - server
        - room.lua
        - gamelogic.lua
      - ex-util.lua

可能可以，那新月杀的玩法怎么拆出去呢？

有一个问题是拓展加载问题，现在底层逻辑是 ``engine:loadPackages`` ，但是由于顺序问题，拓展可能先于游戏扩加载。只能强制拓展都require一次这个ex-util.lua了，那个lua文件必须把自己的engine初始化好供使用。loadPackages具体走到加载游戏扩的时候，require的复用机制会出来救场的，这样不至于初始化两次engine。

**自然而然的，游戏扩里面不要用全局变量，多写一次require吧。** 本体这些全局变量实在是设计失误，现在也没道理说全部拆掉了，下辈子注意吧。新的游戏类型扩展要注意不能加全局变量。

拆分新月杀
---------------

新月杀是现在唯一支持的桌游类型。既然要拓展新的桌游类型，那么新月杀应该和新游戏站在同一起跑线了（全局变量和类名除外），怎么拆分呢？和UI拆分的想法一样，我们也可以对一个大类也拆分出一个基类，比如Package类虽然是管理三国杀的游戏概念的，但是本身值得提出一个基类。

Core
~~~~~~~~

Skill
++++++++

这个应该可以通用，Skill不就是改变某些函数返回以及影响游戏流程嘛。可能TriggerSkill和StatusSkill也可以通用，Active和ViewAs恐怕不行。

Card
++++++++

这个应该可以通用（提出基类后），现在的Card实现太多三国杀特有内容了

General
++++++++

这个很难通用吧，严格来说它甚至得是Card的子类

Package
+++++++++

上面三者的综合。这个只提出基类可能可以通用

Engine
+++++++++

上面四者的综合。注意Fk这个全局变量除了扮演桌游配件之外，它还负责很多整个游戏的协调（包加载等核心特性）。我们暂且把Fk认定为继承两个类吧，单就桌游配件而言，Engine要保存的应该不多。

AbstractRoom
+++++++++++++++

无疑得通用，需要提出不含三国杀的基类。

GameMode
++++++++++

不仅要通用，还得跟Game坐一桌，也需要提一个基类出来。

其他
+++++

- debug.lua : 毫无疑问通用
- request\_handler.lua : 应该是通用的，内容是基础的UI逻辑交互
- util.lua : 一大堆全局变量，毫无疑问通用
- trigger\_event.lua : 单就触发这个机制应该有用，可以通用

Server
~~~~~~~~~~~

GameLogic
+++++++++++++++

单纯的逻辑运行、事件机制和事件栈那一套应该在很多桌游派的上用场，这部分考虑通用化

Room
++++++++

派生自AbstractRoom，和logic的交互以及协程处理那部分可以通用

ServerPlayer
+++++++++++++++

doNotify之类的基础设施通用，其余不像能通用的

GameEvent
++++++++++++

这个类本身也通用；具体子类中除了GameEvent.Game之外，其他应该都不是通用的

其他
++++++

- network.lua: 其实定义了 ``Request`` 类，这个通用
- request.lua: notification的处理，这个按理说通用但其实还没做可拓展性处理
- scheduler.lua, rpc/: 这两位层次太底层了，通用的
- system_enum.lua: 我不好说，应该不是通用的而是三国杀特有的

Client
~~~~~~~~~~~

先把fk.client\_callback这个全局表整改了，参考Qml里面全局callback的解法，把handler绑定到具体Client实例吧。

Client虽然继承AbstractRoom但是其实为所有Qml页面都提供数据支持，因此哪部分代码是基类应该很明显。

ClientPlayer
~~~~~~~~~~~~~~

基类完成到ui的信息发送就行了，和具体client关联
