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

这份文档仍在试水中。也有一个试水的repo，详见 https://gitee.com/notify-ctrl/chess-games

欢迎提出建议
