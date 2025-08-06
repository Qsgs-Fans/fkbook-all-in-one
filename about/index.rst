关于FreeKill
================

FreeKill是一款免费开源的桌游引擎（至少现阶段愿景如此）。本文档介绍了FreeKill的方方面面，
目标是让玩家、拓展作者、开发者以及想要参与其中的人找到入手FreeKill的参考点。

本文档使用 `Sphinx <https://sphinx-doc.cn/en/master/>`_ 构建，选用的主题是
`Book <https://sphinx-book-theme.readthedocs.io/en/latest/>`_ 。
文档的源码可以在 `Github <https://github.com/Qsgs-Fans/fkbook-all-in-one>`_
和 `Gitee <https://gitee.com/Qsgs-Fans/fkbook-all-in-one>`_ 找到。
我们十分欢迎大家来贡献文档（并且十分需要贡献者）。有关对文档的贡献，详见 :doc:`contribute-to-doc` 。

开始阅读
-----------

本文档是根据目标受众的不同而组织的：

- :doc:`../for-players/index` 主要为玩家讲述游戏的下载与使用。
- :doc:`../for-creators/index` 讲述了拓展和资源包的开发，以及其他编程相关指引等。
- :doc:`../for-server-hosts/index` 讲述联机服务器搭建方法。
- :doc:`../for-devs/index` 讲述了FreeKill的C++层运行逻辑，以及如何贡献。

FreeKill文档的目标
---------------------

FreeKill文档的目标是作为FreeKill项目的核心参考手册，为感兴趣的人提供尽可能详尽的指引。
代码贡献者以及文档编写者都可以来共同编写这份文档。

文档的内容预计会包含：

- API参考，示例与教程等
- 针对底层运行原理的说明与贡献指引
- 客户端与服务端后台的使用方法

其他FreeKill网站
--------------------

重要Repo
~~~~~~~~~~

- `FreeKill Github Repo <https://github.com/Qsgs-Fans/FreeKill>`_ ：FreeKill客户端和服务端主仓库，主要是C++相关。
- `freekill-core Gitee Repo <https://gitee.com/Qsgs-Fans/freekill-core>`_ ：FreeKill核心开发仓库，包括最核心的客户端QML和服务端Lua。
- `freekill-asio Github Repo <https://githun.com/Qsgs-Fans/freekill-asio>`_ ：移除Qt依赖后用C++重构的服务端，旨在提升FreeKill服务端的性能。

交流场所
~~~~~~~~~~

- `FreeKill Discord <https://discord.gg/tp35GrQR6v>`_
- `百度贴吧 - 新月杀吧 <https://tieba.baidu.com/f?kw=%E6%96%B0%E6%9C%88%E6%9D%80>`_


.. toctree::
   :titlesonly:
   :hidden:

   contribute-to-doc.rst
   doc-todo.rst
