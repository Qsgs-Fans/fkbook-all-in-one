开发组常见用语
==================

本文档讲解一下本项目开发交流中常见的用语，并借此说明项目的组织架构。

指代Repo的用语
-----------------

我们大部分开发工作在Gitee进行，因为访问比较方便。Github上也会存在同名仓库，
那些主要是为了使用Github Action自动化构建流程，或者使用readthedocs实现文档托管，
而不太用于实际开发协作。

本体
~~~~~

所谓的“本体”，指的就是玩家下载下来的FreeKill客户端（7zip格式或者APK格式，六七十MB的那个），
并且不包括后续安装的一切拓展包。

本体的repo链接：`FreeKill Gitee Repo <https://gitee.com/notify-ctrl/FreeKill>`_ 。
它包含了FreeKill客户端的C++相关代码，并且还是QT C++。虽然C++代码只占一小部分，
但重要程度是很高的。

由于需要支持单机启动，因此本体的C++也包含服务端的基本代码。

拓展包
~~~~~~~~

FreeKill通过Git来下载、更新新的拓展包，本质上会通过 ``git clone`` 往你的packages目录下安装新拓展包，
通过 ``git fetch`` 和 ``git checkout`` 更新仓库、同步服务端的包的版本等。

当你自创拓展包时，你会新建一个文件夹，后续会在那里 ``git init`` 将其转为Git仓库，
然后再发布到开源平台上。

以上所有位于packages下、用于拓展本体功能的，都称为“拓展包”。

core
~~~~~~

“core”一词指特殊拓展包freekill-core。`freekill-core Gitee Repo <https://gitee.com/Qsgs-Fans/freekill-core>`_

为了避免每次修改本体自带Lua或者QML时都需要更新一个版本号而创建的仓库，
现在作为FreeKill真正的核心开发仓库，包括最核心的客户端QML和服务端Lua。
本体启动时，如果发现安装了core，则不会从本体自带的目录去加载各种脚本文件，
而是从core中加载：

.. code:: cpp

  Scheduler::Scheduler(RoomThread *thread) {
    L = new Lua;
    if (Pacman->shouldUseCore()) {
      QDir::setCurrent("packages/freekill-core");
    }

    L->dofile("lua/freekill.lua");
    L->dofile("lua/server/scheduler.lua");
    L->call("InitScheduler", { QVariant::fromValue(thread) });
  }

更加详细的说明请看该仓库的README。

asio
~~~~~~

asio指asio C++ library，是Boost网络库的一部分。C++标准库的Networking模块据悉也将会参考asio库的风格进行设计。

由于原先基于Qt实现的服务端有严重的性能问题，因此我们后面利用C++标准库和asio网络库对服务端进行了重构。
重构后的仓库：`freekill-asio Gitee Repo <https://gitee.com/notify-ctrl/freekill-asio>`_。
此重构的服务端不仅还原了原版服务端应当有的功能，还不断增加着新的服务端相关功能，
其中一个就是支持客户端使用多种不同的版本登录至服务端，这也增加了服务器的灵活度。
之后，服务端的C++底层相关功能都在这个仓库开发，对它的讨论也多了起来。

因此，在本项目中，很多时候“asio”一词指的是freekill-asio这个仓库。
注意这个仓库并不是拓展包，它是单独编译并作为服务端二进制文件运行的。

文档
~~~~~

你现在正在看的就是文档，文档也是单独建立repo维护的，在gitee上进行协作编写，
之后同步到github并自动部署到文档托管站。

仓库：`fkbook-all-in-one Gitee Repo <https://gitee.com/Qsgs-Fans/fkbook-all-in-one>`_。
使用rst编写，plantuml画一些UML图。具体请看README吧。

总的来说，FreeKill项目涉及的仓库分为这几类：

- 客户端仓库（本体）
- 拓展包仓库

  - 特殊且重要的拓展包freekill-core，实现本体的基础功能（core）

- 服务端重构版仓库freekill-asio （asio）
- 文档仓库fkbook-all-in-one（文档）

框架通用用语
-------------------

FreeKill作为桌游框架，其基本逻辑是服务端运行逻辑，客户端和人类交互。

新月杀特有用语
-------------------

新月杀是三国杀规则在FreeKill的实现，而三国杀规则十分繁杂，在开发途中为了方便衍生出各种用语。
由于确实很多，详见 :doc:`../for-creators/terminology` 。
