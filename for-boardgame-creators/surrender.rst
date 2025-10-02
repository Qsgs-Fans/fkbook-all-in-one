象棋#5 投子与提和
==================

本文介绍客户端如何向服务端发送游戏流程之外的消息，以实现认输与求和功能等。

基本知识
----------

在绝大多数情况下，扮演发信者的都是服务端，客户端则通常被动的等待服务端发来数据。
客户端向服务端发出消息也较为常见，即向服务端发送Reply时。

而还有一种较少见但十分有用的情况，那就是客户端主动向服务端发送Notification包，
包体一样的也是 ``(command, data)`` 元组。因为包的类型是Notification，
所以客户端也不用等待回复了，发完即可，我们主要来看看服务端是如何处理的。

服务端处理它们的最开始环节都是在C++代码中实现的，我们直接快进到关键方法：

.. code:: cpp

  void Room::handlePacket(Player &sender, const Packet &packet) {
    static const std::unordered_map<std::string_view, room_cb> room_actions = {
      {"QuitRoom", &Room::quitRoom},
      {"AddRobot", &Room::addRobotRequest},
      {"KickPlayer", &Room::kickPlayer},
      {"Ready", &Room::ready},
      {"StartGame", &Room::startGame},
      {"Chat", &Room::chat},
    };

    if (packet.command == "PushRequest") {
      std::string_view sv;
      auto ret = cbor_stream_decode(
        (cbor_data)packet.cborData.data(), packet.cborData.size(),
        &Cbor::stringCallbacks, &sv
      );
      if (ret.read == 0) return;
      pushRequest(fmt::format("{},{}", sender.getId(), sv));
      return;
    }

    auto iter = room_actions.find(packet.command);
    if (iter != room_actions.end()) {
      auto func = iter->second;
      (this->*func)(sender, packet);
    }
  }

当玩家处于游戏房间（而不是大厅）时，从客户端发出的notification会在服务端走到这一步。
而这个方法的处理逻辑是：

- 若 ``command`` 为PushRequest，则进行稍微特殊的处理
- 若 ``command`` 为其他，则调用unordered_map中记录的对应handler

稍微调查一下其他代码可以知道，只有PushRequest会将相关数据传递到Lua中。
还是来看关键代码：

.. code:: cpp

  void RoomThread::pushRequest(const std::string &req) {
    emit_signal(std::bind(push_request_callback, req));
  }

  // 在构造方法中定义
  push_request_callback = [&](const std::string &msg) {
    L->call("HandleRequest", msg);
  };

``emit_signal`` 方法用来确保某个function必定在RoomThread对应的线程中执行，
而这个线程是专门用于执行Lua代码的。若线程仍处于忙碌中，则asio库会将相应的function
加入到队列（一种数据结构）中，当线程执行完任务返回事件循环时，就会优先从队列中
取出未完成的任务执行。 ``L->call`` 表示调用某个Lua函数，
``HandleRequest`` 函数位于 lua/server/scheduler.lua （就不粘贴代码了）

RoomThread线程的任务
~~~~~~~~~~~~~~~~~~~~~~

该线程的任务就是运行游戏逻辑的代码，以及处理一些理应由Lua来完成的任务。
无论是哪一种，从C++代码转移到Lua的关键Lua函数无外乎这两个：

- ``ResumeRoom`` : 进入游戏逻辑（即GameLogic）相关代码，并等待返回（主要是协程被挂起）
- ``HandleRequest`` : 进入PushRequest对应的处理代码，handler由Room决定

下图描述了RoomThread线程中的状态转换情况。

.. uml:: uml/lua-thread-stat.puml

由于我们之前已经看了服务端游戏逻辑，所以先来聊聊 ``ResumeRoom`` ，
它主要调用了 ``Room:resume`` 方法。在Lua中，每个游戏房间对应一个协程，
``Room:resume`` 的任务就是继续执行该协程，直到挂起或结束，而情况也只有这几种：

- 当 ``Request:ask`` 等待真人玩家回复时，协程会挂起
- 当 ``Room:delay`` 时，协程会挂起
- 当 ``Room:gameOver`` 时，协程会结束

上面的挂起情况会在延时结束后再次 ``ResumeRoom`` ，这就是类似的情况了。
总之在协程暂停运行之前，RoomThread都被Lua代码占用着，回不到事件循环。
如果Lua陷入死循环了那么就无力补救了，整个线程就卡死在那里了，
导致客户端察觉到服务端毫无动静但可以聊天；如果Lua进入了某个CPU密集型任务
（如某些很复杂的AI策略），那么就会导致服务端整体的响应变得很慢。

接下来是另外一种情况，处理PushRequest使用的 ``HandleRequest`` 函数，
它主要调用了 ``room.callbacks[command](room, playerId, data)`` 。
因此Room提供了 ``addCallback`` 方法来注册新的handler：

.. code:: lua

   -- lua/server/roombase.lua 这些应当是通用的，所以写在这里
   self:addCallback("reconnect", self.playerReconnect)
   self:addCallback("observe", self.addObserver)
   self:addCallback("leave", self.removeObserver)
   self:addCallback("surrender", self.handleSurrender)

在所有Room的通用基类中，已经设置了重连、旁观、投降的处理逻辑。

总结一下就是：

- 如果客户端需要发送notification，则Room中需要先规划好对应的handler
- 由于PushRequest实际处理的原理，notification并不能在Lua及时处理，
  比较极端的情况下会短暂出现Lua与C++数据不同步的现象

投降
--------

投降是预定义好的，写在游戏模式的 ``surrender_func`` 中。

.. todo::

   不想写了 等后人补全

和棋
--------

我们需要自己addCallback，处理和棋请求
