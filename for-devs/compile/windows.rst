Windows
==========

本文介绍了在Windows中编译FreeKill的方式。

安装Qt
------------

FreeKill采用Qt 6.5.3 LTS 进行构建，因此需要先安装Qt6的开发环境。

建议用 `Qt官方下载器 <https://download.qt.io/official_releases/online_installers/>_`
进行安装。安装工具的操作除了界面是英文之外其实很直观，因此流程不做赘述，
但是建议尽量只下载必要组件而不是全部（大约安装后只占地4GB左右）。
为了编译FreeKill，至少需要安装以下的组件：

- Qt 6: MinGW 11.2.0 64-bit
- Qt 6: Qt5 Compat
- Qt 6: Shader Tools （为了使用GraphicalEffects）
- Qt 6: Multimedia
- QtCreator
- CMake、Ninja
- OpenSSL最新版

其中Qt的版本是任意的，MinGW的版本也是，都越新越好，但是要清楚开发组发布release时会使用6.5.3版。

安装其余依赖
-----------------

从网络上下载并安装swig。
swig `在其官网可以下载 <http://prdownloads.sourceforge.net/swig/swigwin-4.3.1.zip>`_ ,
下载完成之后，还需要将含有swig.exe的文件夹设置到Path环境变量里面去。

编译与运行
--------------

接下来使用QtCreator打开项目（选择Repo根目录下的CMakeLists.txt），然后尝试编译。

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
