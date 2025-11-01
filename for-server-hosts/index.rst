.. SPDX-License-Identifier:	CC-BY-NC-SA-4.0

写给服主
==========

服主负责建立、维护一个供多人联机游玩的服务器。

这部分文档主要针对的是开设一个7*24小时无时无刻不在运行着的服务器，
并且服务器在公网上可访问。

与这样的服务器相对的则是局域网联机游戏。这种情况下，需要先推选出一个服主玩家，
服主玩家需要先登录一次公共服（获取公共服的拓展），然后再单机启动。
其他玩家在确保和服主在同一个局域网的前提下，点击“加入服务器”，然后点击“探测局域网”。
这时服主的机器应当会显示出来，选中，输入用户名密码即可。

FreeKill的服务器必须使用Linux系统搭建，但是具体发行版随意，理论上各种Linux都可以搭建。
若您对Linux不了解，可以看看 :doc:`new-to-linux/index` 。

.. todo::

   Linux介绍下还混有很老旧的开服资料，没力气改了，需要帮助

- :doc:`setup`
- :doc:`config`
- :doc:`data`
- :doc:`manage`

.. toctree::
  :hidden:
  :titlesonly:

  new-to-linux/index.rst
  setup.rst
  config.rst
  data.rst
  manage.rst
  14-ipv6.rst
  15-server-owner.rst
