以静态链接方式编译
=====================

手动下依赖、手动编译还是有点吃操作了，有没有更简单的开服方式？

有的有的，第一种是打包成deb包，这样安装时会自动用apt下载依赖；而另一种则是通过静态编译生成二进制文件，这样只要解压缩就可以直接运行了，什么也不用干。

这篇文档讲的是自己通过静态链接方式编译服务器二进制文件。

下载Alpine Linux
-----------------------

前往官网 https://alpinelinux.org/ ，选择喜欢的方式安装。我这里因为主机是Linux所以用proot，结合他们提供的rootfs包安装。

.. code :: shell

   $ mkdir alpine && cd alpine
   $ wget https://dl-cdn.alpinelinux.org/alpine/v3.22/releases/x86_64/alpine-minirootfs-3.22.1-x86_64.tar.gz
   $ tar xf alpine-minirootfs-3.22.1-x86_64.tar.gz
   $ proot -S .

这应该是最快的一种安装方式，可以立刻在proot下运行起alpine Linux。接下来所有操作都是基于root账户的alpine Linux下运行的，安装方式无论用什么都行。

有需要可以先换源，参考 https://mirrors.tuna.tsinghua.edu.cn/help/alpine/

弄完后切到root的目录，后面的事都在里面做了：

.. code:: text

   # cd /root

安装依赖
---------------

根据安装方法不同，alpine的下包可能非常漫长，而我们要装的东西非常多，一条命令全安装吧：

.. code :: text

   # apk add git vim cmake build-base \
     sqlite-dev readline-dev cjson-dev spdlog-dev asio-dev \
     readline-static ncurses-static \
     openssl-libs-static zlib-static

搞完上面这堆后我们还得手动编译安装libgit2以及一个apk不提供的static库：

.. code :: text

   # git clone https://github.com/libgit2/libgit2.git
   # cd libgit2
   # mkdir build && cd build
   # cmake .. -DBUILD_SHARED_LIBS=OFF
   # make
   # make install
   # cd /root

   # git clone https://github.com/PJK/libcbor.git
   # cd libcbor
   # mkdir build && cd build
   # cmake ..
   # make
   # make install
   # cd /root

编译
---------

一样的先克隆repo并创建build目录，进入build目录

.. code:: text

   # git clone https://github.com/Qsgs-Fans/freekill-asio
   # cd freekill-asio
   # mkdir build && cd build

但这一集我们还不能直接cmake，需要额外写一些东西指定它以静态链接方式编译。在build下创建新文件alpine_static.cmake并写入以下内容：

.. code:: cmake

   # alpine_static.cmake

   set(CMAKE_BUILD_TYPE MinSizeRel)

   set(BUILD_SHARED_LIBS OFF)
   set(CMAKE_FIND_LIBRARY_SUFFIXES .a)
   set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

   set(CMAKE_EXE_LINKER_FLAGS "-static -static-libgcc -static-libstdc++ -Wl,--gc-sections ${CMAKE_EXE_LINKER_FLAGS}")

   add_library(OpenSSL::Crypto STATIC IMPORTED)
   set_target_properties(OpenSSL::Crypto PROPERTIES
     IMPORTED_LOCATION /usr/lib/libcrypto.a
   )

   add_library(cjson STATIC IMPORTED)
   set_target_properties(cjson PROPERTIES
     IMPORTED_LOCATION /usr/lib/libcjson.a
   )

   add_library(cjson-static STATIC IMPORTED)
   set_target_properties(cjson-static PROPERTIES
     IMPORTED_LOCATION /usr/lib/libcjson.a
   )

   add_library(readline STATIC IMPORTED)
   set_target_properties(readline PROPERTIES
     IMPORTED_LOCATION /usr/lib/libreadline.a
     INTERFACE_LINK_LIBRARIES "ncursesw"
   )

   # libgit2不仅要手动编译还要手动导入
   add_library(git2 STATIC IMPORTED)
   set_target_properties(git2 PROPERTIES
     IMPORTED_LOCATION /usr/local/lib/libgit2.a
     INTERFACE_LINK_LIBRARIES "z;ssl;crypto"
   )

   function(target_link_libraries target)
     set(new_args)
     foreach(arg IN LISTS ARGN)
       if(arg STREQUAL "spdlog::spdlog")
         list(APPEND new_args "fmt::fmt-header-only")
       else()
         list(APPEND new_args ${arg})
       endif()
     endforeach()

     _target_link_libraries(${target} ${new_args})
   endfunction()

回到shell（应当在build目录下），继续：

.. code:: text

   # cmake --toolchain=alpine_static.cmake ..
   # make

OK！至此已经成功的静态编译了freekill-asio，成品大约10MB。由于alpine使用了libc-musl，因此这个程序也应当不依赖glibc，在任何linux机器上都能运行（CPU架构不合以及内核实在太旧的除外）。

整一台Debian 7做做实验：

.. code::

   root@debian-amd64:~/asio# cat /etc/os-release
   PRETTY_NAME="Debian GNU/Linux 7 (wheezy)"
   NAME="Debian GNU/Linux"
   VERSION_ID="7"
   VERSION="7 (wheezy)"
   ID=debian
   ANSI_COLOR="1;31"
   HOME_URL="http://www.debian.org/"
   SUPPORT_URL="http://www.debian.org/support/"
   BUG_REPORT_URL="http://bugs.debian.org/"
   root@debian-amd64:~/asio# uname -a
   Linux debian-amd64 3.2.0-4-amd64 #1 SMP Debian 3.2.51-1 x86_64 GNU/Linux
   root@debian-amd64:~/asio# ls -lh
   total 9.4M
   -rwxr-xr-x 1 user user 9.4M Aug 14 15:49 freekill-asio
   drwxr-xr-x 2 user user 4.0K Aug 14 15:58 packages
   drwxr-xr-x 2 user user 4.0K Aug 14 15:58 server
   root@debian-amd64:~/asio# ./freekill-asio
   [25-08-14 16:00:06.719668] [2902/I] server is ready to listen on 9527
   freekill-asio, Copyright (C) 2025, GNU GPL'd, by Notify et al.
   This program comes with ABSOLUTELY NO WARRANTY.
   This is free software, and you are welcome to redistribute it under
   certain conditions; For more information visit http://www.gnu.org/licenses.

   [freekill-asio v0.0.1] Welcome to CLI. Enter 'help' for usage hints.
   fk-asio> install https://gitee.com/Qsgs-Fans/freekill-core
   [25-08-14 16:00:10.518103] [2904/I] Running command: 'install https://gitee.com/Qsgs-Fans/freekill-core '
   [25-08-14 16:00:10.617651] [2904/E] Error -17/16: the SSL certificate is invalid
   fk-asio> install https://gitee.com/Qsgs-Fans/freekill-core
   [25-08-14 16:09:00.541954] [2904/I] Running command: 'install https://gitee.com/Qsgs-Fans/freekill-core '
   [25-08-14 16:09:00.921269] [2904/E] Error -17/16: the SSL certificate is invalid
   fk-asio>
   [25-08-14 16:09:14.928014] [2904/I] Server is shutting down.

情况并不顺利，考虑效仿android故事将系统证书打包进来。这篇只是记录一下而已，真发出开服包的话问题肯定是解决了。

编译Lua 5.4以及两个依赖库
----------------------------

下载与编译Lua，但是我们需要提前准备好依赖库，将他们嵌入到Lua核心代码。

首先编译安装Lua库，不然依赖库编译不了：

.. code:: text

   # cd /root
   # wget https://www.lua.org/ftp/lua-5.4.8.tar.gz
   # tar xf lua-5.4.8.tar.gz
   # cd lua-5.4.8
   # make linux MYLDFLAGS='-static -Wl,--gc-sections'
   # make install

然后克隆并编译依赖库：

.. code:: text

   # git clone https://github.com/lunarmodules/luasocket
   # cd luasocket
   # vim src/makefile

将其中涉及all的地方改为：

.. code:: make

   all: socket.a mime.a

   socket.a: $(SOCKET_OBJS)
     $(AR) rcs socket.a $(SOCKET_OBJS)

   mime.a: $(MIME_OBJS)
     $(AR) rcs mime.a $(MIME_OBJS)

继续

.. code:: text

   # make LUAV=5.4

   # cd ..
   # git clone https://github.com/lunarmodules/luafilesystem
   # cd luafilesystem
   # cd src
   # gcc -c lfs.c -o lfs.o
   # ar rcs lfs.a lfs.o

接下来是修改Lua可执行文件的源码，去lua源码下编辑lua.c:

.. code:: c

   /* 在顶层找个地方写下声明 */
   int luaopen_lfs(lua_State *L);
   int luaopen_socket_core(lua_State *L);
   int luaopen_mime_core(lua_State *L);

   /* ... 找到luaL_openlibs(L)，在下面追加 */
   luaL_openlibs(L);  /* open standard libraries */
   luaL_requiref(L, "lfs", luaopen_lfs, 1);
   lua_pop(L, 1);
   luaL_requiref(L, "socket.core", luaopen_socket_core, 1);
   lua_pop(L, 1);
   luaL_requiref(L, "mime.core", luaopen_mime_core, 1);
   lua_pop(L, 1);

再手动编译：

.. code:: text

   # gcc src/lua.c -o lua

这样就得到了Lua 5.4的可执行文件（静态链接，已经拼好了依赖的C库）

全部整合在一起
-----------------

拼尽全力得到了静态编译的freekill-asio以及lua，该做个release了。

.. code:: text

   # cd /root
   # mkdir asio-release
   # cd asio-release
   # cp -r /root/freekill-asio/packages/ .
   # rm packages/.gitignore
   # cp -r /root/freekill-asio/server/ .
   # cp -rL /etc/ssl/certs .
   # mkdir bin
   # cp /root/freekill-asio/build/freekill-asio ./bin
   # cp /root/lua-5.4.8/lua bin/lua5.4
   # strip ./bin/freekill-asio
   # strip ./bin/lua5.4
   # mkdir luasocket
   # cp /root/lua-5.4.8/luasocket/src/*.lua luasocket/
   # touch freekill-asio
   # chmod +x freekill-asio

此处是想在release的根目录创建freekill-asio的一个wrapper脚本，因为为了跑起来Lua需要修改环境变量。往里面写入：

.. code:: sh

   #!/bin/sh

   # 令freekill-asio在execlp时能找到lua5.4
   export PATH=${PATH}:$(pwd)/bin

   # 令lua5.4能正确require "socket"
   # 我也不知道为什么这里不需要写一个?.lua跟在后面 但总之这样就能跑 不能跑的话就补个?.lua
   export LUA_PATH=";;$(pwd)/luasocket/"

   freekill-asio $@

先就这样吧，成功在debian7跑通了（freekill-core还是得安装的）。发出去试试看
