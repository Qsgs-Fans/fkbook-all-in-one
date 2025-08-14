Player
=========

见于 ``src/server/user`` 。需要动态创建和释放。生命周期受Room限制。

Player持有 ``unique_ptr<Router>`` ，间接持有 ``shared_ptr<ClientSocket>`` 。

对象创建者
-------------

对象通过 ``std::make_shared`` 创建，创建者：

- UserManager：当一个ClientSocket通过认证后，为其创建一个Player管理其时
- UserManager：创建机器人时
- Room：玩家逃跑时，创建新Player用来接管逃跑玩家的ClientSocket时

对象管理者
--------------

由UserManager中两个 ``std::unordered_map<int, std::shared_ptr<Player>>`` 管理。

不需要时，通过 ``UserManager::deletePlayer`` 释放。

基于UserManager中的方法从id查询Player时均返回weak_ptr，但要注意lock后会创建新shared_ptr。

使用场景
--------------

- 作为ClientSocket的包装，进行服务端客户端之间的数据传输。
- 提供了管理连接状态的接口（踢出玩家）
- 当socket状态异常时，修改自己的连接状态

释放时机
--------------

不被Lua需要，且也没有需要自己管理的ClientSocket时。

- 不被Lua需要：处于大厅；处于不被Lua需要的房间；是个旁观者
- 不存在受管理的ClientSocket：本来就不管理socket（人机），或者因掉线导致socket被设为nullptr。

例外的时，若人机玩家处于创建了自己的房间，则暂时不受这两条约束，释放条件改为：

- 当游戏开始后，顺应以上两点约束
- 即将进入大厅时（被踢出房间）

实现详情
--------------

掉线
~~~~~~

从网络编程的角度考虑，当TCP连接断开时，需要回收socket的资源。
Player作为Socket的封装，其释放的时机基本上就是断线时。
为了便于思考，将逃跑也并入掉线中（逃跑的话会把原玩家的socket移动到新创建的玩家，
原玩家改为走人机的逻辑，可以认为是掉线的情况之一）。

当掉线时，第一件事是把socket设为nullptr，这样必定满足不存在受自己管理的ClientSocket。

然后，若不被Lua需要：

1. 从所处房内删除
2. 释放

否则：

1. 将网络状态改为断线
2. 试图唤醒Lua，提示玩家掉线

网络状态变更
~~~~~~~~~~~~~~~~

需要告诉房间其他玩家自己的网络状态变了，此外需要告诉Lua。

考虑到掉线本身也唤醒Lua，因此向Lua通知网络异常必须发生在实际唤醒之前。

断线重连当然也是变更。其代码基本上满足这两点。

.. todo::

   由于pushRequest的异步性，存在在Lua游戏结束时触发重连的极端情况，此时C++中玩家的
   socket已经正常所以不会释放，但是Lua的 ``ServerPlayer:reconnect`` 触发不了，
   导致重连玩家的客户端不断转圈圈。修复应该不难。

.. todo::

   上面对重连的叙述也适用于旁观。
