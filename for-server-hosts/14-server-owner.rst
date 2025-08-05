操练：见习服主
===============

以上都只是启动服务器而已，但服务器处于空白的状态。此时你作为一名服主，\
应当自己去打理服务器了。

这篇文章介绍关于打理新月杀服务器的种种方式，包括下包啊、日常维护啊之类的。
在阅读之前，你应该先明白服主自身的责任：

1. 尊重他人的隐私。
2. 操作之前，还请三思。
3. 能力越大，责任也越大。

那么我们开始吧。

在新月杀自己的shell中使用help命令即可阅读各种帮助：

::

  fk> help
  08/14 14:57:37 Shell[I] Running command: "help"
  08/14 14:57:37 Shell[I] Frequently used commands:
  08/14 14:57:37 Shell[I] help: Display this help message.
  08/14 14:57:37 Shell[I] quit: Shut down the server.
  08/14 14:57:37 Shell[I] crash: Crash the server. Useful when encounter dead loop.
  08/14 14:57:37 Shell[I] lsplayer: List all online players.
  08/14 14:57:37 Shell[I] lsroom: List all running rooms.
  08/14 14:57:37 Shell[I] reloadconf/r: Reload server config file.
  08/14 14:57:37 Shell[I] kick: Kick a player by his <id>.
  08/14 14:57:37 Shell[I] msg/m: Broadcast message.
  08/14 14:57:37 Shell[I] ban: Ban 1 or more accounts, IP, UUID by their <name>.
  08/14 14:57:37 Shell[I] unban: Unban 1 or more accounts by their <name>.
  08/14 14:57:37 Shell[I] banip: Ban 1 or more IP address. At least 1 <name> required.
  08/14 14:57:37 Shell[I] unbanip: Unban 1 or more IP address. At least 1 <name> required.
  08/14 14:57:37 Shell[I] banuuid: Ban 1 or more UUID. At least 1 <name> required.
  08/14 14:57:37 Shell[I] unbanuuid: Unban 1 or more UUID. At least 1 <name> required.
  08/14 14:57:37 Shell[I] resetpassword/rp: reset <name>'s password to 1234.
  08/14 14:57:37 Shell[I]
  08/14 14:57:37 Shell[I] ===== Package commands =====
  08/14 14:57:37 Shell[I] install: Install a new package from <url>.
  08/14 14:57:37 Shell[I] remove: Remove a package.
  08/14 14:57:37 Shell[I] lspkg: List all packages.
  08/14 14:57:37 Shell[I] enable: Enable a package.
  08/14 14:57:37 Shell[I] disable: Disable a package.
  08/14 14:57:37 Shell[I] upgrade/u: Upgrade a package. Leave empty to upgrade all.
  08/14 14:57:37 Shell[I] For more commands, check the documentation.

help命令会列出所有的操作方法。一一说明吧。

拓展包管理相关
---------------

新月杀提供了六条管理拓展包的命令。help里面已经说的很明白了。

欲安装拓展包，需使用install命令，参数是那个拓展包的git链接。
比如安装神话再临包就是：

::

  fk> install https://gitee.com/Qsgs-Fans/shzl

官方武将的拓展包都由这个Qsgs-Fans账号维护，去gitee中看看吧。

.. note::

  注意安装任何拓展包之前都先安装好utility包，因为很多拓展在引用它的代码：

  ::

    fk> install https://gitee.com/Qsgs-Fans/utility

欲删除、启用、禁用拓展包，需要带拓展包的名字作为命令参数。
现在例如删除刚刚安装的神话再临包：

::

  fk> remove shzl

直接删除的话后悔了又要重新下载，因此用的更多的是禁用与启用。

::

  fk> disable shzl
  fk> enable shzl

上面两行指令就是先禁用神话再临再启用神话再临。包只要被禁用了，就不会被加载到\
游戏中。

欲查询拓展包，使用lspkg命令。这会显示所有拓展包。

更新则是upgrade命令，可以短写为u。更新如果指定包名那就只更新那个包，\
如果不指定的话就是全部更新。

::

  fk> upgrade shzl
  fk> u

上面两条指令中，第一条指明更新神话再临包；第二条则是更新本服安装的所有拓展包\
（包括已经被禁用的拓展包）。

.. danger::

  在修改完拓展包相关之后，如果未启动服务器，那么连进来的玩家会陷入无穷无尽的\
  自动同步拓展包！因此在更新完拓展包之后一定要重启服务器！

人员管理相关
-------------

使用ban命令即可封禁用户，使用他的用户名作为参数。

::

  fk> ban notify

ban命令会同时封禁用户名和设备码。

使用banip命令可以封禁用户的ip地址，参数一样的是用户名。

同理，unban和unbanip命令可以解封相应的用户。

如果用户因为逃跑被自动封禁，则无法使用除了重启之外的任何手段解封。

其他命令
--------

msg命令（简写为m）可以向全服发送通告，参数就是通告内容。

::

  fk> m 恭喜！玩家<b>神话天尊</b>在排位赛中升级到了最强的枭雄段位！

resetpassword命令（简写为rp）可以将用户的密码重置为1234。指定用户名就行了。

::

  fk> rp notify

reloadconf（简写为r）可以重新加载服务器端的配置文件而无须重启服务器。\
在修改了服务器公告之后这个命令很有用。

关于服务器的配置文件
---------------------

上文提到了关于服务器的各种命令。 除了那些命令之外，\
服主还可以用配置文件对服务器进行定制。

服务器的配置文件存放在freekill.server.config.json中。若无此文件，那么可以\
先将游戏目录下的配置样例复制一份：

::

   $ cp freekill.server.config.json.example freekill.server.config.json

然后使用nano编辑freekill.server.config.json吧，默认内容如下：

.. code:: json

    {
      "banwords": [],
      "description": "FreeKill Server",
      "iconUrl": "https://img1.imgtp.com/2023/07/01/DGUdj8eu.png",
      "capacity": 100,
      "tempBanTime": 20,
      "motd": "Welcome!",
      "hiddenPacks": [],
      "enableBots": true
    }

编辑他们即可修改服务器的相关设置，各项含义如下：

- banwords: 字符串数组，服务器的违禁词汇列表。
  违禁词发不出去也不能作为用户名/房间名。
- description: 服务器简介，显示在加入服务器界面的那行文字。
- iconUrl: 服务器图标对应的图片链接，必须是网络图片。最好是http协议的图片，
  就目前来看只能是挂在自己服务器上了。
- capacity: 服务器最大承载玩家的容量。新月杀服务器主要瓶颈在于带宽，
  保守一点估计的话，每1 Mbps可以承载60名玩家同时游戏。
- tempBanTime: 对于逃跑玩家的自动封禁时长，单位为分钟。设为0
  即可关闭自动封禁功能，不要设为负数。
- motd: 用户进入大厅时候在屏幕右侧看到的文字，支持markdown格式。
  不过因为JSON不能写多行字符串，你得把写好的markdown中所有换行符全替换成\
  \n才好哦。
- hiddenPacks: 服务器想要隐藏的拓展包列表，对于DIY服应该是需要的。
- enableBots: 是否允许玩家添加机器人，视情况设定。

关于数据库
-----------

服务器会存储各个玩家的注册时间、游戏时长，以及他们的胜率；相应的也会存储各个\
武将的胜率。作为服主可以对数据库进行查询。

新月杀采用sqlite作为数据库管理系统，因此数据库只是单个文件而已。对于比较小的\
服务器来说这个选择也挺不错。数据库对应的文件是server/users.db。

这里介绍某些常见查询需要用到的SQL语句，至于使用何种工具查询就取决于你自己了；
你可以在shell里面直接用\ ``sqlite3 users.db``\ 对数据库进行查询，或者将数据库\
下载到本机然后用各种有GUI的软件进行查看。

关于SQL语法本身不进行解释，请自行学习。弄明白表结构之后你也可以自己写出\
更加好用的sql语句。

.. warning::

  因为sqlite本身对并发支持很弱，如果服务器非常活跃的话不要直接查询正在被\
  游戏进程使用中的users.db，否则可能导致游戏因为不能操作数据库而崩溃。\
  这种情况下考虑先复制一份数据库文件或者下载到本地都行。

查胜率
~~~~~~~

查询玩家notify的全模式胜率：

.. code:: sql

   SELECT * FROM playerWinRate WHERE name='notify';

查询玩家notify的斗地主模式胜率：

.. code:: sql

   SELECT * FROM playerWinRate WHERE name='notify' AND mode='m_1v2_mode';

.. hint::

   服务端安装gamemode拓展包后即可游玩更多游戏模式。

查询全服所有玩家斗地主胜率排行，只查询大于300场者，按胜率从高到低排列，\
只取前20名：

.. code:: sql

   SELECT * FROM playerWinRate WHERE mode='m_1v2_mode' AND total>300
     ORDER BY winRate DESC LIMIT 20;

查询武将貂蝉（内部名diaochan）的斗地主模式胜率：

.. code:: sql

   SELECT * FROM generalWinRate WHERE general='diaochan' AND mode='m_1v2_mode';

可以看出武将胜率表相对于玩家的而言只是把name换成general，所以不再赘述。

查特定人特定模式特定武将
~~~~~~~~~~~~~~~~~~~~~~~~~

.. warning::

   因为这么存的话数据库变得太大了，以后的更新可能不再按玩家-模式-武将的方式\
   单独存储一个很大的表而是分两张表存。

   简而言之就是这里所说的SQL后面可能会失效。
   但因为大家很鸽说不定一直不去改也不好说。

查询玩家notify在斗地主模式下的所有武将游玩记录，只显示五条：

.. code:: sql

   SELECT name, general, win, lose, draw, (win + lose + draw) AS total,
     ROUND(win * 1.0 / (win + lose + draw) * 100, 2) AS winRate
     FROM winRate, userinfo
     WHERE winRate.id = userinfo.id AND name = 'notify' 
     AND mode = 'm_1v2_mode'
     LIMIT 5;

可以自己在WHERE后面追加更多条件，或者排序之类的。

查询武将貂蝉（内部名diaochan）在斗地主中被全服玩家们游玩过的记录，
按总场次从高到低排序，显示前面10条：

.. code:: sql

   SELECT name, general, win, lose, draw, (win + lose + draw) AS total,
     ROUND(win * 1.0 / (win + lose + draw) * 100, 2) AS winRate
     FROM winRate, userinfo
     WHERE winRate.id = userinfo.id AND mode = 'm_1v2_mode'
     AND general = 'diaochan'
     ORDER BY total DESC LIMIT 10;

查注册、登录时间以及游玩时长
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

查询玩家notify的注册时间、上次登陆与游戏时长：

.. code:: sql

  SELECT userinfo.id as Id, name, ROUND(totalGameTime / 3600.0, 2) || " h" AS 'Time',
    DATETIME(registerTime, 'unixepoch', 'localtime') AS RegTime,
    DATETIME(lastLoginTime, 'unixepoch', 'localtime') as LastLogTime
    FROM usergameinfo, userinfo
    WHERE userinfo.id = usergameinfo.id AND userinfo.name = 'notify';

查询近7天以来登录到服务器的玩家列表：

.. code:: sql

  SELECT userinfo.id as Id, name, ROUND(totalGameTime / 3600.0, 2) || " h" AS 'Time',
    DATETIME(registerTime, 'unixepoch', 'localtime') AS RegTime,
    DATETIME(lastLoginTime, 'unixepoch', 'localtime') as LastLogTime
    FROM usergameinfo, userinfo
    WHERE userinfo.id = usergameinfo.id AND
      DATE(lastLoginTime, 'unixepoch', 'localtime') >=
      DATE('now', 'localtime', '-7 days') AND
      DATE(lastLoginTime, 'unixepoch', 'localtime') <
      DATE('now', 'localtime', 'start of day', '+1 days');

想要方便的查看所有人的游玩信息，可以创建一个视图：

.. code:: sql

   CREATE VIEW IF NOT EXISTS gameinfoView AS
     SELECT userinfo.id as Id, name, ROUND(totalGameTime / 3600.0, 2) || " h" AS 'Time',
       DATETIME(registerTime, 'unixepoch', 'localtime') AS RegTime,
       DATETIME(lastLoginTime, 'unixepoch', 'localtime') as LastLogTime
       FROM usergameinfo, userinfo
       WHERE userinfo.id = usergameinfo.id;


查询全服游玩时长排行：

.. code:: sql

   SELECT name, ROUND(totalGameTime / 3600.0, 2) || " h" AS 'Time'
     FROM usergameinfo, userinfo
     WHERE userinfo.id = usergameinfo.id
     ORDER BY totalGameTime DESC LIMIT 20;

sqlite命令行导出csv文件
~~~~~~~~~~~~~~~~~~~~~~~~

这里专门对sqlite命令行进行解说，其他软件应该有更好办法。

::

   sqlite> .mode csv
   sqlite> .output test.csv

这两条命令之后，接下来查询结果就输出为csv格式，并保存在test.csv文件中。
接下来就运行一条自己想要的语句吧，然后退出sqlite，那个文件中就有查询结果了。
