服务端 - 用户登录
===================

登录模块要实现的功能：

- 服务端应保证客户端版本与自己一致
- 服务端应能保存用户的用户名和密码等信息（数据库）
- 服务端应保存用户是否被封禁的信息
- 服务端应确保用户的脚本代码与服务端所需的一致
- 完成登录后，将用户加入大厅

登录流程如图：

.. uml:: uml/s-auth-process.puml

数据库设计
------------

登录过程中需要查询用户id、密码等等信息，这些信息都保存在数据库中。本游戏中\
数据库保存的内容主要有用户登录信息、用户游玩信息、胜率信息等，结构如图所示：

.. uml:: uml/s-auth-db.puml

在登录环节查询的主要是userinfo表。其中，用户的密码以加盐哈希的方式存储。

通信底层（上）
---------------

有必要先介绍一下新月杀的底层通信实现，这里主要介绍最基础的连接与断开，以及
notify操作的实现和内存管理等。通信功能借助于Qt提供的TCP接口，并在此基础上进行拓展。

.. uml:: uml/s-network-class.puml

其中，ClientSocket是对QTcpSocket的简单包装，为最基本的send和readyRead增加了AES
加密功能，本质上面向字节流的传输。Router是进一步包装，给出了基本的应用层数据包\
格式： ``[requestId, type, command, data]`` 。ServerPlayer则是负责与Lua进行对接的，
其相关函数直接使用Router提供的。

在连接建立之前，客户端基于UDP协议向服务器取得关于服务器的基本信息（服务器头像、
描述、在线人数等），显示在加入服务器的页面中。建立连接时，首先向服务端开放的TCP
端口发起连接请求，服务端建立最初的TCP连接并发回RSA公钥，客户端将密码使用公钥加密\
后发送至服务端。服务端按照流程图所示，借助数据库进行一步步判断，最后通过登录后\
更新用户信息，并将用户加入大厅。

拓展包同步机制
---------------
