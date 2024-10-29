关于环境搭建
=============

按道理项目的README写着，但这里还是需要额外说明一些。

首先第一步，自然是克隆仓库了，git clone走一波。（链接在上一章）

而关于本体的修改，又分为修改cpp代码和不碰cpp代码两种，后者因为无需编译，\
步骤也简单了不少。

不编译
--------

新月杀把占了源码大头的Lua和Qml代码都直接放在文件夹里面呢。这意味着\
只要修改它们就能实现对本体的改进了。这种情况下，环境搭建的步骤如下：

1. 克隆仓库，也就是用\ ``git clone``\ 把仓库下载到本地。因为存在子模块，\
   你还需要使用\ ``git submodule update --init``\ 来拉取子模块内容。
2. 下载新月杀最新版本，将游戏文件夹中所有文件复制到仓库中（若询问是否替换，\
   点“否”即可），因为有ignore文件，你复制的exe和dll等等不会被git考虑。
3. 双击FreeKill.exe启动新月杀。
4. 对各种脚本文件进行修改啥的吧，直接启动新月杀即可进行测试。完成之后一样的\
   进行commit和push，然后去网页发起PR。

编译
------

若想改的更加深入一些，就需要进行编译了。

事先声明：编译FK对于初次接触Qt的玩家而言是个比较折磨的过程。

全平台通用步骤
~~~~~~~~~~~~~~~~

FreeKill采用Qt 6.5.3 LTS 进行构建，因此需要先安装Qt6的开发环境。

无论是Win还是Linux，都建议用Qt官方的下载器
(https://download.qt.io/official_releases/online_installers/) 进行安装。\
当然了，在一些软件更新很频繁的Linux发行版里面，可能已经能从包管理器安装Qt6，\
对此后文细说。这个环节介绍用Qt安装器安装的步骤。

Qt安装的流程不赘述。为了编译FreeKill，至少需要安装以下的组件：

- Qt 6: MinGW 11.2.0 64-bit
- Qt 6: Qt5 Compat
- Qt 6: Shader Tools （为了使用GraphicalEffects）
- Qt 6: Multimedia
- QtCreator
- CMake、Ninja
- OpenSSL最新版

接下来根据平台的不同，步骤也稍有区别。

--------------

Windows
~~~~~~~~

从网络上下载swig。swig在其官网可以下载。

全都下载完成之后，将含有swig.exe的文件夹设置到Path环境变量里面去。

接下来使用QtCreator打开项目，然后尝试编译。

这时遇到cmake报错：OpenSSL:Crypto not found. 
这是因为我们还没有告诉编译器OpenSSL的位置，点左侧“项目”，查看构建选项，
在CMake的Initial Configuration中，点击添加按钮，新增String型环境变量
``OPENSSL_ROOT_DIR``, 将其值设为跟Qt一同安装的OpenSSL的位置
（如C:/Qt/Tools/OpenSSL/Win_x64）。然后点下方的Re-configure with Initial
Parameters，这样就能正常编译了。

运行的话，在Qt Creator的项目选项->运行中，先将工作目录改为项目所在的目录
（git仓库的目录）。然后先将编译好了的FreeKill.exe放到项目目录中，
在目录下打开CMD，执行windeployqt FreeKill.exe。调整目录下的dll
文件直到能运行起来为止，之后就可以在Qt Creator中正常运行和调试了。

--------------

Linux
~~~~~~

通过包管理器安装一些额外软件包方可编译。

Debian一家子：

.. code:: sh

   $ sudo apt install liblua5.4-dev libsqlite3-dev libreadline-dev libssl-dev swig

Arch Linux：

.. code:: sh

   $ sudo pacman -Sy lua sqlite swig openssl libgit2

然后使用配置好的QtCreator环境即可编译。

如果你不想用Qt安装器的话，可以用包管理器安装依赖，下面仅举例Arch：

.. code:: sh

   $ sudo pacman -S qt6-base qt6-declarative qt6-5compat qt6-multimedia
   $ sudo pacman -S cmake lua sqlite swig openssl swig

然后可以用命令行编译：

.. code:: sh

   $ mkdir build && cd build
   $ cmake ..
   $ make -j8

如果你使用 Nix/NixOs 的话，可以在clone repo后直接使用 nix flake 构建：

.. code:: sh

   $ git clone https://github.com/Notify-ctrl/FreeKill
   $ nix build '.?submodules=1'

--------------

MacOS
~~~~~~

安装依赖：
.. code:: sh

   $ brew install openssl # 安装OpenSSL
   $ brew install libgit2@1.8.3 # 安装libgit2
   $ brew install qt6 # 安装qt6 
   $ brew install cmake # 安装cmake
   $ brew install swig # swig
   $ brew install lua@5.4.7 # lua
   

如果libgit2 和lua之前安装过，请将下面路径中的版本号修改为对应的版本号。
安装好依赖后，需要将路径倒入到CMakeLists.txt 中，具体如下：

.. code:: cmake
   
   ...
   set(LIBGIT2_DIR "/opt/homebrew/Cellar/libgit2/1.8.3")
   set(LUA_DIR "/opt/homebrew/Cellar/lua/5.4.7")
   
   ... 
   include_directories("${LUA_DIR}/include/lua")
   include_directories("${LIBGIT2_DIR}/include")

   ...
   link_directories("${LIBGIT2_DIR}/lib")
   link_directories("${LUA_DIR}/lib")

   target_link_libraries(FreeKill PRIVATE git2)

这样cmake就可以自动找到依赖并生成项目了。

生成项目

.. code:: sh

   $ mkdir build && cd build
   $ cmake ..
   $ make -j8

也可以参考 [CMakeLists.txt.OSX](https://github.com/Qsgs-Fans/FreeKill/blob/master/CMakeLists.txt.OSX) 文件。

--------------

编译安卓版
~~~~~~~~~~~

用Qt安装器装好Android库，然后配置一下android-sdk就能编译了。
