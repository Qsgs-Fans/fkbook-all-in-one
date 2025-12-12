关于Task
============

Task允许在不启动新Room的前提下在服务端执行一些Lua函数，这样Lua的拓展能力进一步增强。

一些使用场景：

- 制作自定义签到页面时，在服务端提供后端支持，玩家在大厅中可以完成签到
- 在某些触发事件中，允许执行一些Lua（例如玩家登录成功时，额外发送一个包之类的）
- 以及更多……

目前支持从大厅中发送包来激活一个task。

注册新Task
--------------

目前可以如此注册新task

.. code:: lua

  Fk:addTaskDef {
    type = "TaskTypeName",
    handler = function(task)
      -- ...
    end,
  }

其中那个task参数相当于room，由于player只有一个人，可用task.player取得玩家。
这个玩家相比于对局内的玩家，功能同样极其有限。

task中主要可以存取读取存档、延迟一段时间、向玩家发送notification，
虽然功能很少很少，但相信可以做出很有用的功能。

触发Task
---------------

目前可以如此触发Task（在QML中）

.. code:: js

   Cpp.notifyServer("LobbyTask", [ "TaskTypeName", data ]);
