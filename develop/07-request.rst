双端：请求与答复
=================

上篇说到游戏流程的运行，穿插在游戏流程中的自然少不了玩家们频繁的决策步骤。
是否发动技能，出牌，选择武将等等…… 本文讨论这些决策是如何发起、如何被玩家的设备\
接收与处理，以及玩家进行操作后的诸多问题。

总的来说，我们关心的是以下两个组件：

- ``Request`` 类，用于服务端。它负责与Client沟通，以及作为各种askFor函数的底层。
- ``RequestHandler`` 类，用于客户端。顾名思义就是为了处理某个Request。\
  它负责与Server沟通，以及与GUI沟通。

服务端：Request
-----------------

客户端：RequestHandler
--------------------------

向Server发送reply不用多说，重点在于它需要模拟出客户端的UI界面（如果确实存在UI界面，\
那么还需要将数据发送到真实的UI界面中），这个“模拟”包括控制各种模拟UI组件的\
enabled、selected属性等等。真实的UI只负责实际显示，因此逻辑本身就转移到了Lua中。

RequestHandler主要分为以下部分：

- RequestHandler:setup()

  用以初始化整个场景，包括向客户端传达初始UI情况。

- RequestHandler:update(elemType, id, action, data)

  当客户端的UI被干涉时，将调用正在进行中的RequestHandler的这个函数。

  若该函数返回\ ``true``\ ，则终止RequestHandler。

- RequestHandler:finish()

  RequestHandler终止后调用此函数，用以清理一些剩余的UI元素。

- RequestHandler.scene

  承载UI元素的容器，负责承载客户端传入的UI变化和向客户端传出UI所需要的变化。

  - Scene:update(elemType, id, newData)

    通过UI变化改变对应元素的属性，同时向其所属的RequestHandler传输相应的变化。

  - Scene:notifyUI()

    一般由其所属的RequestHandler或更上层部分调用。

    用以通过\ ``ClientInstance:notifyUI``\
    向客户端传出\ ``RequestHandler.change``\ 所记载的变化。

- RequestHandler.change

  承载等待传出至客户端的UI变化

