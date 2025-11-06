向文档做出贡献
================

FreeKill的文档用reST编写，基于Sphinx编译成HTML网页以及pdf文档。
文档的源码同时托管于Github和Gitee，而文档本身托管于readthedocs，
其中Github用于令readthedocs自动检测到最新更改并自动部署，
部署在Gitee则是便于贡献者参与。

搭建本地开发环境
------------------

首先要将项目克隆到本地。注意文档包含了子模块，必须递归式的克隆文档Repo：

.. code:: sh

   $ git clone --recursive https://gitee.com/Qsgs-Fans/fkbook-all-in-one.git

若你已经不用递归式方法克隆过了，你也可以手动获取子模块：

.. code:: sh

   $ git submodule init
   $ git submodule update --remote

项目使用Sphinx以及许多其他的pip依赖构建，所以你需要先安装Python3。
安装完成后，需要在Repo目录下Git Bash here，在命令行中完成编译：

.. code:: sh

   $ python -m venv .venv
   $ source .venv/bin/activate  
   # 若为Windows则改为使用下面这行命令source
   $ source .venv/Scripts/activate 

   $ pip install -r requirements.txt
   $ sphinx-build -M html . build/

然后build/html文件夹就会出现，查看index.html即可。

文档的贡献与交流
-------------------

本文档非常大程度上参考了 `Luanti文档 <https://docs.luanti.org/>`_ 的组织形式，可以参考它的格式，
讨论后进行贴合FreeKill实际的文档编写。

FreeKill文档采用reST格式编写，这个格式与Markdown很接近，如果完全第一次接触的话，
可以阅读 `reST教程 <https://learn-rst.readthedocs.io/zh-cn/latest/index.html>`_ 来学习编写方法。

文档的贡献方式为向Gitee仓库发送Pull Request。如果不知道从何下手，也请看看 :doc:`doc-todo` 。

在文档编写途中，沟通是必需的，可以用以下几种联系到我们：

- 在百度贴吧 - 新月杀吧发贴询问文档贡献相关事宜
- 加入新月杀扩展学习交流QQ群：837690225，注明贡献文档

文档的todo list
-----------------

详见Gitee仓库的issues界面： https://gitee.com/qsgs-fans/fkbook-all-in-one/issues
