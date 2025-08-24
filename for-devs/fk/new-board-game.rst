关于创建新类型桌游
===================

在cpp中我们实现了基本的room，里面保存了人数、人员、房间设置的基本信息，客户端中与之相关的是房间内等待界面。游戏的进一步实际运行交给了服务端Lua、客户端Lua、该游戏实际页面。

我们可以把这些想象成桌游店：在游戏开始之前，只是一堆人坐在桌子周围，桌上有即将交给店主的本局游戏信息（至少是想玩哪种桌游）。人员集齐并决定开始游戏后，店主再把会用到的游戏配件送过来，具体怎么去玩就留给玩家自己了；在程序中还有一个“发牌员”般的存在负责发牌、记录数据、处理具体结算等。

因此，一种桌游应该有以下要素：

- ``engine`` : 静态游戏配件
- ``abstract_room_klass``, ``player_klass`` : 发牌员需要记住的数据
- ``logic_klass`` : 发牌员需要遵循的结算规则，即GameLogic
- ``client_klass``, ``room_page`` : 发牌员的“发牌”如何让客户端处理，即command+data

文件架构
--------------

现在的freekill-core里面的Lua纯属为三国杀单一玩法准备的。想想办法怎么拆

既然都按上面那么说了，那不如：

.. code:: text

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

可能可以，那新月杀的玩法怎么拆出去呢？
