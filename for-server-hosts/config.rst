服务器配置文件说明
======================

FreeKill服务端采用JSON作为配置文件，因此无法提供带注释的配置文件。
本文档意在说明配置文件的内容。

例子文件详见 `freekill.server.config.json.example <https://gitee.com/notify-ctrl/freekill-asio/blob/master/freekill.server.config.json.example>`_ 。要让配置文件生效，需要将该文件更名为freekill.server.config.json，并放在程序目录下。

默认内容如下：

.. code:: json

  {
    "banwords": [],
    "description": "FreeKill Server",
    "iconUrl": "default",
    "capacity": 100,
    "tempBanTime": 20,
    "motd": "Welcome!",
    "hiddenPacks": [],
    "enableBots": true,
    "enableWhitelist": false,
    "roomCountPerThread": 2000,
    "maxPlayersPerDevice": 50
  }

- banwords: 字符串数组，服务器的违禁词汇列表。
  违禁词发不出去也不能作为用户名/房间名。
- description: 服务器简介，显示在加入服务器的界面中。
- iconUrl: 服务器图标对应的图片链接，必须是网络图片。
- capacity: 服务器最大承载玩家的容量。
- tempBanTime: 对于逃跑玩家的自动封禁时长，单位为分钟。设为0即可关闭自动封禁功能。
- motd: 用户进入大厅后，看到的服务端公告，支持markdown格式。
  不过因为JSON不能写多行字符串，你得把写好的markdown中所有换行符全替换成\
  \n才好哦。
- hiddenPacks: 服务器想要隐藏的拓展包列表，对于DIY服应该是有用的。
- enableBots: 是否允许玩家添加机器人，视情况设定。
- enableWhitelist: 是否开启白名单功能
- maxPlayersPerDevice: 每个设备最多允许注册多少个账号

