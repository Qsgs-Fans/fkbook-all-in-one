象棋#4 实现客户端与UI
===============================

本文介绍客户端的运行、数据保持、UI呈现与人机交互。核心思想是， **客户端不断接收服务端信息，并通过UI与人类交互。以及绝对不要在QML代码中直接编写UI交互逻辑。**

基本知识
-------------

客户端的类图如下，和服务端比较类似，也是有相应的类完成基础的与C++交互、通用功能等，但少了AI和GameLogic：

.. uml:: uml/client-class.puml

客户端处理服务端发来数据的方式
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

然后我们需要了解一下网络通信，还好有文档了，不再赘述，一言以蔽之就是服务端会发送 ``(command, data)`` 元组过来。

- :doc:`../for-devs/protocol`

结合一下代码：

.. code:: lua

   self:addCallback("Xiangqi.MovePieceTo", self.handleMovePieceTo, true)

这句代码表示当传来了 ``Xiangqi.MovePieceTo`` 的command时，以相应data为参数调用 ``self.handleMovePieceTo`` 方法。
最后的参数填一个true，表示在执行完Client的方法后，会将同样的command和data转交给QML，供其继续处理。QML的话目前很难画图说明。

由于要不要把command和data传输到QML是完全由Lua控制的，Lua的Client调用 ``notifyUI`` 方法即可向UI传递消息，这给了Client实现时比较高的自由度。

从服务端发信到客户端做出反应的流程大致如图：

.. uml:: uml/send-notification.puml

客户端实现人机交互的相关类
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

然而实际上客户端开发更难，难就难在QML。

.. todo::

   并且此时QML写法还不够固定，不好展开说。本文可能主要还是说Lua更多。

我们的基本路线是：与UI交互相关的逻辑不要直接写在QML里面。QML写起来令人折磨固然是一方面，但是主要原因还是 **避免UI呈现与UI逻辑耦合** 。我们在Lua中使用 ``RequestHandler`` 这个类实现与用户交互相关的UI逻辑。

.. note::

   之所以单独把交互相关的逻辑提取出来，而且还放在core里面，是因为这样的逻辑不仅客户端可以使用，服务端的AI也可以使用。

   AI要解决的问题就是如何像一个客户端一样思考、返回相应格式的结果，基本原则就是要遵守规则，而在AI中复用RequestHandler就能复用相同的UI逻辑（从而遵守规则）等，一定程度上减少重复代码。

当使用Lua编写UI交互逻辑时，我们会去按需求派生这三个类。

.. uml:: uml/request-handler.puml

Item
++++++

表示一个模拟的ui组件。我们完全不关心它的ui呈现相关属性（如x, y, width, height等），
只关心其在ui逻辑上相关的属性。
最基本的Item包含了一个enabled字段，表示是否能交互。

在客户端的场景下，每个Item应当绑定到实际QML界面中的某个实际ui元素。
基本思想是通过该Item的 ``class.name`` 和 ``id`` 与实际ui元素进行映射。

当基于Item派生并新增字段时，重点要去重写 ``toData`` 和 ``setData`` 方法，
它们分别用于将信息传递到QML、修改Item本身的属性。

Scene
++++++++

表示模拟的ui场景。用途是保存所有模拟ui组件，并与实际的ui界面进行信息交换。

Scene中的方法都是在RequestHandler中手动调用的，用来更新整体界面或者个别ui组件。

- 构造方法：一般会在RequestHandler构造时调用。根据实际ui场景初始化scene。
- ``addItem``: 向场景中添加新的模拟ui组件
- ``removeItem``: 从场景中删除一个模拟ui组件
- ``getAllItems``: 获取某个类别的所有模拟ui组件
- ``update``: 更新某个模拟ui组件的字段的值。不能直接修改item的属性，而要通过该方法去修改

RequestHandler
+++++++++++++++++

这是ui逻辑相关代码实际所在的类。当服务端发来一个request型的数据时，客户端会构建该类的实例，
用来运行ui逻辑。

与ui逻辑挂钩是这三个方法，子类必须给出具体实现：

- ``setup()`` : 当这次交互刚开始时，调用该方法
- ``finish()`` : 当这次交互结束时（点击确定，或因超时被服务端结束掉），调用该方法
- ``update()`` : 当Qml中产生某些ui事件（如点击）时，调用该方法。若返回true则表示交互已结束

这三个方法调用后，底层都会把scene的数据传输到Qml界面中。因此Lua中的ui逻辑需要修改ui时，操作scene即可，
这样就避免了与实际Qml界面的耦合。

而在构造方法中操作scene并不会向qml传递数据。因此构造方法的职责是根据具体ui的实际情况，初始化对应的scene。

客户端实际人机交互的流程
~~~~~~~~~~~~~~~~~~~~~~~~~~~

基本流程还是不变的：服务端发来command和data，客户端执行对应回调，然后客户端自己控制向Qml传输哪些数据。

但是如前所述，交互流程涉及 ``RequestHandler`` 类，为了说明交互的整体流程，我们直接从象棋的代码入手。

交互开始
+++++++++++

在收到询问走子时，客户端执行的回调是 ``Client:playChess`` ，代码如下：

.. code:: lua

   function RoomBase:initialize()
     -- ...
     self:addRequestHandler("Xiangqi.PlayChess", ReqPlayChess)
   end

   function Client:playChess(data)
     self:setupRequestHandler(Self, "Xiangqi.PlayChess", data)
   end

可以看到RoomBase中就注册了相应的 ``RequestHandler`` 类型。
``Self`` 是个全局变量，表示这个客户端的用户自己。因此整个回调的流程如图：

.. uml:: uml/send-request.puml

处理UI事件
+++++++++++

当 ``onClicked`` 之类的UI事件发生时，QML会调用一个Lua函数，进而进入 ``update`` 方法。流程如图：

.. uml:: uml/request-ui-clicked.puml

因超时而结束交互的代码原理与此类似。

编写Client负责的代码
------------------------

首先是用addCallback指定回调，而发了什么command由服务端决定。
因为Client继承了RoomBase，所以需要的数据它都有。

然后是将信息发送到QML，调用 ``notifyUI`` 方法即可。
我们稍微翻到QML页面中，可以看到也有很多addCallback。
它接收来自Lua客户端的数据，并调用对应的QML回调函数，从而影响UI的呈现。

最后是旁观重连相关。之前不是说过了基于全量同步么？
确实有全量同步，不过当时只是向客户端同步了数据，还有UI界面没显示呢？
``sendDataToUI`` 方法就是用来把信息同步到QML的。

象棋只有一种交互方式，那就是走子。这也是客户端相关Lua代码中比较复杂的一部分，
它的主要目的是解耦UI显示与UI逻辑，让我们脱离QML苦海（一定程度上）。

总结
-------------

Qml太坏了，我实在想不出写点啥。总之这是客户端的一部分，重点是人机交互部分如何逃离QML的。
