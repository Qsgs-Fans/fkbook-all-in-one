象棋#4 实现客户端与UI
===============================

本文介绍客户端的运行、数据保持、UI呈现与人机交互。核心思想是， **客户端不断接收服务端信息，并通过UI与人类交互。以及绝对不要在QML代码中直接编写UI交互逻辑。**

基本知识
-------------

客户端的类图如下，和服务端比较类似，也是有相应的类完成基础的与C++交互、通用功能等，但少了AI和GameLogic：

.. uml:: uml/client-class.puml

然而实际上客户端开发更难，难就难在QML遍地是坑！懂得都懂.jpg

.. todo::

   并且此时QML写法还不够固定，不好展开说。本文可能主要还是说Lua更多。

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

人机交互
-------------

象棋只有一种交互方式，那就是走子。这也是客户端相关Lua代码中比较复杂的一部分，
它的主要目的是解耦UI显示与UI逻辑，让我们脱离QML苦海（一定程度上）。

总结
-------------

Qml太坏了，我实在想不出写点啥。总之这是客户端的一部分，重点是人机交互部分如何逃离QML的。
