网络通信协议
=============

FreeKill作为桌游软件，面临的通信场景较为简单。

高层网络通信
--------------

高层次通信代码写的比较散，参阅源码的 ``src/server`` 以及Lua中用了 ``doNotify`` 的地方。

总体而言，网络通信分为以下几个场景：

- 服务端 -> 客户端（Request包）
  - 服务端 <- 客户端（Reply包）
  - 或者因超时而放弃本次Request
- 服务端 -> 客户端（Notify包）
- 服务端 <- 客户端（Notify包）

连接建立和数据同步等就是通过交换这些包进行的。

底层网络通信
--------------

参阅源码的 ``src/network`` （Qt版或者Asio版都可）。

FreeKill的通信是在TCP传输层协议之上的一小层，通过TCP流式传输CBOR数据，
每两个CBOR数据之间没有间隙，读取完一个CBOR包后应当立刻有下一个CBOR包可以读取。

包的格式固定为长度为4或者6的CBOR array（类型为CBOR类型）：

..

  [ uint requestId, uint type, bytes command, bytes data, (uint timeout, int timestamp) ]

- requestId: 表示一个Request包的id，客户端应该发回id一致的reply
- type: 基于位运算，通过一个整数表示包类型。
- command: 包的command。
- data: 包携带的data。必定是一个CBOR编码过的二进制串（除了部分例外）
- timeout: Request包特有，表示本次请求的时长
- timestamp: Request包特有，表示发包时服务端的时间戳

