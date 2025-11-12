游戏&子模式自定义config	
===============================

可以给自定义桌游、自定义游戏模式增加一些配置项了，做到不同模式调节不同配置（比如斗地主可看手牌，象棋设置步时局时等）。

在创建房间时，左侧有“游戏设置”和“模式设置”两栏。前者是这个桌游给的通用设置项，后者是游戏模式特化的设置项。

这些配置信息通过sqlite保存在客户端的一张表里面。

定义配置项
----------------

首先需要手动引入一下配置项相关组件：

.. code:: lua

    local W = require 'ui_emu.preferences'

这个W命名是仿照QML中的习惯来的。然后造一张表，表中内容大致如下（以lunarltk为例子）：

.. code:: lua

    local settings = {
      W.PreferenceGroup {
        title = "Properties",

        W.SpinRow {
          _settingsKey = "generalNum",
          title = "Select generals num",
          from = 3,
          to = 18,
        },

        W.SpinRow {
          _settingsKey = "generalTimeout",
          title = "Choose General timeout",
          from = 10,
          to = 60,
        },

        W.SpinRow {
          _settingsKey = "luckTime",
          title = "Luck Card Times",
          from = 0,
          to = 8,
        },
      },

      W.PreferenceGroup {
        title = "Game Rule",

        W.SwitchRow {
          _settingsKey = "enableFreeAssign",
          title = "Enable free assign",
        },

        W.SwitchRow {
          _settingsKey = "enableDeputy",
          title = "Enable deputy general",
        },
      },
    }

如上，settings表是一个列表，每个元素都是 ``W.PreferenceGroup`` 。
``W.PreferenceGroup`` 是必须有的，作用是实现配置项分组，这样在页面中配置项会显示成不同的板块，
写法是先指定title，然后再在后面补充带值的组件。

.. note::

   其实这个写法同样受到QML启发，不过这是完全合乎Lua语法的。

W中的每个组件都可以指定一个 ``title`` 字段，用于指定文本。
组件还可以显示附加的说明文本，前提是为 ``help: <title>`` 编写了翻译。例：

.. code:: lua

  Fk:loadTranslationTable {
    ["Luck Card Times"] = "手气卡次数",
    ["help: Luck Card Times"] = "可以更换初始手牌的最多次数。",
  }

然后是所有的可以指定一个值的组件们：

- ``W.SwitchRow``：显示一个开关，对应的值为布尔
- ``W.ComboRow``：显示一个下拉框，可选项由 ``model`` 字段指定，这个必须是字符串列表，对应的值为字符串
- ``W.SpinRow``：显示一个数值调整器，范围由 ``from`` 和 ``to`` 字段指定，都必须是int，对应的值为int
- ``W.EntryRow``：显示一个输入框，让用户自己输入。对应的值为字符串

以上所有带值的组件都必须指定一个 ``_settingsKey`` 字段，表示这个值对应配置信息中的哪个key。

应用与读取配置项
------------------

若是为了桌游而添加配置，则在创建桌游时指定 ``ui_settings`` 字段：

.. code:: lua

  Fk:addBoardGame {
    name = "lunarltk",
    -- ...
    ui_settings = settings,
  }

若是为了游戏模式而添加配置，可以直接赋值：

.. code:: lua

  local mode = fk.CreateGameMode { --[[ ... ]] }
  mode.ui_settings = settings

在代码中使用 ``room:getSettings(key)`` 即可读取配置内容。其中：

- ``room`` 可以是任何Room或者Client
- ``key`` 是对应的key，也就是上面 ``_settingsKey`` 字段

.. warning::

   ``_settingsKey`` 字段不要产生重复！
