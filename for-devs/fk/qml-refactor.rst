QML重构
==========

在开坑FreeKill之前我曾写过挺久Lua和Cpp，但是在新建文件夹之时在QML面前还是彻头彻尾的新人玩家。
在本着“能用就行”原则的艰难摸索下还是让这个QML客户端顺利运行起来并发布到了不同的操作系统上——
代价就是这些QML代码实在是写的烂。在参考了不少文档以及成功案例后，决定进行本次大重构。

重构之前的上课环节
--------------------

- SOLID原则。
- https://refactoring.guru 重构之原则、如何设计
- https://github.com/Furkanzmc/QML-Coding-Guide 一个QML经验贴

总结一下，整个重构的大前提是：

- 保持UI模块单一性。不使用外部id，除非import进来
- 使用依赖注入（require property xxx + xxx: instance）让依赖转为抽象而不是具体实现

为了实现这样的低耦合单一功能性，需要先想好要哪些模块、每个模块是做啥的。

重构之前的画饼环节
---------------------

为什么要劳神费力搞这次重构？一言以蔽之，为了实现拓展新Page。具体原因有：

CommandHandler相关
~~~~~~~~~~~~~~~~~~~~~

最常见的例子是服务器发来command+data，客户端找到方法后调用。这种情况下发信源只有socket，UI组件作为收信方。

但实际上也遇到过某个组件需要直接调用其他组件的某某方法的例子了，比如武将一览或者聊天中播放配音的事情，这种情况下没有socket参与，发信者是某个其他组件。实现方式甚至是把对应的handler的代码复制了一遍。

现在还有新需求，即相同的command在不同的Page下应当产生不同的行为，即调用不同的回调。

问题1: 组件之间也会用到command+data
+++++++++++++++++++++++++++++++++++++

解法：使用中介者设计模式。所有的UI发信来源全部交给某个中介者，中介决定交给谁、交给其哪些数据。

问题2: command的多态
+++++++++++++++++++++++

解法：将callbacks注册到Page实例中而不是全局变量。

可随游戏类型不同而不同的游戏界面
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

加载不同的Page就行了，然而问题就出在如何轻松编写这样的Page上。

自由自在的美化（难）
~~~~~~~~~~~~~~~~~~~~~~~~

需要完全分离UI与逻辑，同时给用户选项，选择加载哪种实现。先看看抄作业之QtQuick.Controls:

- QtQuick.Controls模块在导入时，根据选定的style自动导入那个style对应的模块
- style的组件都继承QtQuick.Template中的组件，并给出实际UI方案上的实现
- QtQuick.Template全部用C++编写，将不希望被修改的方法设了只读

QML无法实现自动导入以及访问权限。

阶段一：重排模块架构
-------------------------

现在话题来到实际的重构上面。原版的QML基本没有对模块的抽象，所有东西都乱成一团、藕来藕去，因此还要写小作文规范一下。

以及不小心实现了新组件Mediator，并把Page都套壳Loader。针对重构而言一次做两件事是不好的。

main.qml
~~~~~~~~~~~~

理论上不属于任何模块的qml，是整个程序的入口，定义着窗体的基础行为。

- 游戏基础分辨率是960x540，并在这个基础上根据实际分辨率缩放；考虑改成1200x540
- main.qml要控制好拉伸
- 经常有访问realMainWin的，但只有宽高（主要是Popup干的），由于QML本身有个全局的Window所以这里无需单独搞个模块

Fk
~~~~~~~~~

包含着函数库以及从C++中传来的全局属性（不要用全局属性，在Fk中通过单例封装）：

- 调用Lua函数、执行Lua代码相关
- 调用其他从Cpp开放过来的方法
- SkinBank
- util（怎么没啥存在感一样）
- TODO Config
- TODO ColorScheme
- TODO command+data中介 接收Backend.notifyUI信号以及从其他qml信源传来的信号
- TODO Root page, 将实际的显示内容从main.qml剥离

Fk.Widgets
~~~~~~~~~~~~~~

包含通用组件类型的定义。新版中我们尽量不用QtQuick.Controls。
就不列了，主要是一些按钮之类的。

Fk.Components
~~~~~~~~~~~~~~~~~~~~

存储由core管理的各页面的特有小组件，下设多个文件夹，比如 ``Fk.Components.Lobby`` 之类的。

Fk.Pages.Common
~~~~~~~~~~~~~~~~~~~~

整个程序内通用Page，每个Page一个qml。

每个Page多少会处理一些command+data，之前是把逻辑写在Logic.js中，而Logic.js是直接对某个全局变量赋值，这次我们不能重蹈覆辙

参考Fk/RootPage.qml的做法，将页面的基类从 ``Item`` 改为 ``W.PageBase`` （需要 ``import Fk.Widgets as W`` ），然后在 ``Component.onCompleted`` 中注册某个command的回调。command不要直接写死字符串，去 ``command.mjs`` 中注册。

此外，不要再使用全局变量以及这个QML文件之外的id。用 ``Mediator.notify`` 进行解耦（参考Init.qml）。涉及用到了 ``Backend`` 或者 ``ClientInstance`` 或者 ``Pacman`` 的，一般 Fk/CppProperty.qml 中会有个对应的方法处理，没有就补一个，在QML中都使用 ``Cpp.XXX`` 和 ``Lua.XXX`` 。这个就是为了让import更加清晰，消除令人费解的全局变量用的。

建议配置好qmlls语言服务器，然后致力于消除掉 ``Unqualified access`` 警告，都可以用上面说的办法消除（组件之间解耦以及用API单例（Cpp, Lua之类的）。喂饭之VSCode用户可以看看Qt官方文档调教好qmlls（当然了你还得装个最新版Qt，越新越好，依赖组件还是那几个没变化）：

- https://doc.qt.io/vscodeext/index.html
- https://doc.qt.io/vscodeext/vscodeext-how-to-turn-on-qmlls.html

简单概括就是找到Qt Qml插件下载安装，然后他提醒你要不要下载qmlls，点击下载，然后按图中配置：

.. figure:: pic/vscode-qmlls.jpg
   :align: center

其中/usr/lib/qt6/qml是Linux系统一般的Qt安装位置，对于Windows系统的话，这个目录可能是 ``C:\Qt\6.9.0\lib\qml`` 之类的路径，总之就是Qt安装目录里面有个QtQuick文件夹的地方。

此外，非常推荐安装Error Lens。我们重构的目的之一就是赶走Unqualified access警告提高内聚性，所以一目了然是最好的。

Lua代码暂时没啥好改的。

Fk.Pages.LunarLTK
~~~~~~~~~~~~~~~~~~~~~~

新月杀的Page，里面就一个qml。你一个人一桌去吧

实际上应当把新月杀用到的对话框也作为单独的Page QML放在一起，就像是有个叫LunarLTK的拓展包一样，它的qml/Pages下应该会存放的内容。

说到拓展包自定义页面和组件，其组织形式应该是qml/Pages和qml/Components两个文件夹，模块的命名为Fk.Pages.XXX和Fk.Components.XXX。暂定，后面真支持了需要从头写小作文进行介绍。

阶段二：明确逻辑拆分，以及解耦
----------------------------------

SOLID原则之S——单一化。现在很多组件都涉及自己直接调Lua.call拿数据，违背了：

- 单一原则：组件只显示就行了，数据由外部负责传入（而不是内部想办法找）
- 依赖反转原则：直接依赖了Lua代码获取数据，相当于依赖着具体实例。根据D原则应该依赖一个抽象。

再举个逻辑分离到Lua比较成功的request handler例子，其实QML也没设计好：

- 直接依赖Lua.call
- updateRequestUI之类的调用复用程度实在过低，最好依赖某个基类

美化需求太难，先不分析。该明确这个阶段的重构目标了：

- 将数据获取、逻辑运行都做成抽象类，Lua系列是它们的一种实现
- 基于PageBase开一个新类，专门表示该类用到了外部逻辑处理，规定好统一接口（Lua是这个接口的一个实现）

很不幸垃圾QML天生不支持多态，只能手动通过依赖注入告诉他用某某实现了。这样的依赖注入也没必要手写，暂时写在Config（又是他？），就好比QML本身可以通过环境变量修改渲染后端一样，我们也可以通过修改某个字符串值来修改这些抽象的具体实现（主要为了单元化测试吧我觉得，qmlscene没啥用这一块需要缓解）
