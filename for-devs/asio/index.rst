freekill-asio
=================

freekill-asio是一个基于原版FreeKill服务端进行细心重构（主要是删除Qt）的、
多线程的FreeKill服务端实现。该系统基于C++17 std和libasio异步网络库构建，
且使用了大量POSIX API，专为运行在较低配置的Linux服务器上而设计。（单进程架构，未考虑伸缩性）

项目规模一般，由大约5000行左右的C++代码实现，因为FreeKill服务端的功能无非就这些：

.. uml:: uml/use-case.puml

需要注意的是项目并不依赖Lua（不会链接到Lua库），而游戏逻辑是完全用Lua实现的。
因此项目中采用多进程+RPC管理Lua VM（在子进程中运行），当Lua执行结束后直接结束进程即可。

其中RPC方案使用了改造版的json-rpc 2.0，本身遵循json-rpc的思想，但是实际的数据传输使用
CBOR编码格式而不是JSON。在C++中针对Lua传来的rpc cbor包进行了比较细致的解析，
尽可能避免动态分配内存（这一块的调用非常非常频繁，不单独优化不行）。

由于没有了Qt，因此几个Qt特性自然有平替：

- 内存管理：这里用RAII+智能指针实现内存管理。通过weak_ptr在使用之前检测指针有效性。
- 信号与槽：这里使用注册回调函数（lambda、 ``std::bind`` 等）实现相当于信号槽的功能。
- 基础设施：一律STL解决，网络库采用libasio，其余std没有的琐碎功能使用功能对应的C库。

总而言之，从大的角度看，程序使用Server单例完成诸多基本功能，Server单例又持有若干
unique_ptr。需要关心的主要是几个动态创建和释放的组件： ``ClientSocket`` 、 ``Player`` 、
``Room`` 和 ``RoomThread`` 。一旦对它们的生命周期管理怠慢，程序就会崩溃。

.. toctree::
   :titlesonly:

   room.rst
   player.rst

   safety.rst
