拓展规范文档
================

简介
-------

本文档仍处于草稿状态。
本文档针对未来的某个重构了拓展写法的新版本，目前（v0.5.3）应该是尚未实装，
仍在讨论可行性之中。

新月杀本身仅含有最基本的标准包，拓展是用以拓展游戏玩法的，其由一个或多个包
(package) 组成。为了使拓展的开发与维护更加便捷、统一，特制定此规范。

拓展与包的基本结构
--------------------

拓展存在于游戏目录的 ``packages`` 目录之下，其本身是一个目录。文件结构如下：

::

    extension
    ├── audio
    │   ├── card
    │   ├── death
    │   ├── skill
    │   └── win
    │
    ├── image
    │   ├── anim
    │   ├── card
    │   ├── generals
    │   ├── mark
    │   └── role
    │
    ├── init.lua
    │
    └── pkg
        ├── package1
        │   ├── init.lua
        │   └── skills
        │       ├── jianxiong.lua
        │       └── ...
        │
        ├── package2
        └── ...

拓展根目录中的 ``init.lua`` 需要加载其包含的所有子扩展包。

``audio`` ， ``image`` 分别为声音和图像资源文件夹。

``pkg`` 文件夹内为你的子扩展包文件夹。

这些文件夹拥有相对固定的名称，**请不要随意更改**

子扩展包可以用来拓展更多的技能、武将、卡牌、游戏模式。

如果你看过新人入门教程，这里就是你的DIY武将在开发时，所需要了解的各种文件与代码的规范。

audio
^^^^^^
``audio`` 是你的语音文件夹，其内部包括了 ``death`` 文件夹， ``skill`` 文件夹和 ``card`` 文件夹。


.. warning::

    ``audio`` 中的语音文件，应 **全部是mp3格式。**

    如果单纯的从其他格式以重命名的方式修改为mp3，可能会导致无法播放，请注意使用转化软件或者在线网站。

    一个扩展包只能有一个 ``audio`` 文件夹与 ``image`` 文件夹，其内部可能存放多个其他文件夹。

``death`` 文件夹内部应放置武将的【阵亡语音】，**该语音的命名应与武将的代码名称相同。**

``skill`` 文件夹内部应放置武将的【技能语音】，**该语音的命名应与武将技能的代码名称相同。**

``win`` 文件夹内部应放置武将的【胜利语音】，**该语音的命名应与武将的代码名称相同**

``card`` 文件夹内部应放置【卡牌语音】， ``card`` 内部又分为 ``female`` 与 ``male`` 文件夹。 ``female`` 与 ``male``
分别对应卡牌在使用时所播放的女性语音与男性语音。**一张卡牌对应一个语音，语音的命名与卡牌的代码名称相同。**

.. note::

    如果你的武将技能有多个语音，语音的命名格式应为武将技能的代码名称+语音编号。

    语音编号从1开始计算，例如testGeneral_skill1.mp3和testGeneral_skill2.mp3。


image
^^^^^^^

``image`` 是你的武将立绘与势力图片的文件夹，其内部包括了 ``generals`` 文件夹和 ``kingdom`` 和 ``card`` 文件夹。

.. warning::

    ``image`` 中的【武将立绘】文件，应 **全部是jpg格式。**

    ``image`` 中的【势力图片】文件，应 **全部是png格式。**

    ``image`` 中的【卡牌图片】文件，应 **全部是png格式。**

``generals`` 文件夹内部应放置武将的【立绘】， **该立绘的命名应与武将的代码名称相同。**

对于武将的立绘同时拥有其文件大小的要求，请记住武将的立绘格式应为 **250x292** 大小。

``kingdom`` 文件夹内部应放置【DIY势力图片】，势力图片拥有三个部分，**均为png图片。**

.. note::

    如果你仅仅需要原版三国杀的势力，则不用创建本文件夹。


.. figure:: pic/shu.png
   :align: center

   势力的图标(格式最好在30x30-35x35之间)

.. figure:: pic/shu-magatama.png
   :align: center

   势力的阴阳玉(格式为10x12)

.. figure:: pic/shu-back.png
   :align: center

   势力的将框(格式为175x233)

势力图标的名称应为该势力的【英文代码名称】

势力阴阳玉的名称应为图标名称+(-magatama)。例如shu-magatama.png。

势力将框的名称应为图标名称+(-back)。例如shu-back.png。


``card`` 文件夹内部应放置【DIY卡牌图片】，其内部存放了三部分，**均为png图片。**

- ``delayedTrick`` 文件夹
- ``equipIcon`` 文件夹
- 卡牌立绘文件.png等

``delayedTrick`` 文件夹里面存放了DIY延时锦囊在使用后的图标。格式为 **47x55** （若不需要则可以不用创建本文件夹）

``equipIcon`` 文件夹内部存放了DIY装备的小图标（即装备栏所见的小图标）。格式为 **28x22** （若不需要则可以不用创建本文件夹）

.. warning::

    delayedTrick与equipIcon图标的命名格式需要与对应的延时锦囊牌或装备牌代码名称相同。


卡牌立绘则是主要的部分，在card文件夹中放置你的diy卡牌立绘。格式为**93x130 png**文件。

init.lua
^^^^^^^^^

``init.lua`` 文件是你扩展包的核心文件，**如果没有 init.lua ，新月杀就不会加载你的 extension/ 文件夹。**

在init文件中，应包含以下的函数或语句。

- 各个子扩展包的引用语句
- 各个子扩展包的翻译表语句
- 返回值一个表，其元素为各个子扩展包(Pakage对象)
 
完整的 ``init.lua`` 示例结构如下：


.. code-block:: lua
   :linenos:

   local prefix = "packages.extension.pkg."
   -- 这一行定义了扩展的和子扩展包文件夹，extension 为你的扩展名，应与文件夹名相对应。
   
   Fk:loadTranslationTable { ["extension"] = "扩展名" }
   -- 这一行是扩展的翻译表
   
   local package1 = require(prefix .. "package1")
   local package2 = require(prefix .. "package2")
   -- 这两行定义了子扩展包的引用，返回的为Package对象
   
   Fk:loadTranslationTable {
     ["package1"] = "包一名",
     ["package2"] = "包二名",
   }
   -- 这两行是子扩展包的翻译表
   
   return {
     package1,
     package2,
   }
   -- 这一部分是return语句，作用返回你的各个子扩展包，需要与前面相对应。
   -- 写在return里的文件会被新月杀发现然后执行



子扩展包的结构
----------

首先，我们要明白一个概念，扩展包是你的个人扩展，在这个大分类中包含了你的武将子扩展包，卡牌子扩展包和模式子扩展包。

每个子扩展包目录中的 ``init.lua`` 需要加通过 ``extension:loadSkillSkelsByPath`` 定义技能搜索目录。然后其余部分定义该包含有的武将、卡牌和游戏模式等，其应返回值是extension（一个Pakage对象）。


``init.lua`` 中通常需包含以下内容。

- 创建一个Package对象取名为extention。（这个命名是历史遗留）
- 定义技能搜索目录
- 创建若干武将对象并为他们添加技能，或者添加卡牌与游戏模式
- 为该子扩展包中武将前缀，势力，各个武将，卡牌等信息添加翻译表

每个技能应位于包的 ``skills/`` 目录下，置于单独的Lua文件中， 其应返回一个技能骨架（SkillSkelton）对象。

这里是一个典型的子扩展包的文件目录示例。其具体结构随子扩展包类型不同而略有区别。

::

    package1
    ├── init.lua
    └── skills
        ├── testGeneral_skill1.lua
        └── testGeneral_skill2.lua

package1是你的扩展包【英文代码】名称，请注意，**不要使用中文命名**


武将子扩展包
----------

一个典型的武将子扩展包的 ``init.lua`` 示例如下 

.. code-block:: lua
    :linenos:

    local extension = Package:new("package1")
    extension.extensionName = "extension"
    -- 这一部分是武将扩展包的创建语句。
    -- 第一行为创建子扩展包，名称为package1。这里一般与你的子扩展包文件夹名一致。
    -- 第二行为你的扩展包名，extension。请注意，包名一般与你的扩展文件夹名一致。

    extension:loadSkillSkelsByPath("./packages/extension/pkg/package1/skills")
    -- 这一部确定分子扩展包技能搜索路径

    Fk:loadTranslationTable {
      ["package1"] = "扩展武将包",
      ["testKingdom"] = "扩展武将势力",
      ["test"] = "武将前缀",
    }

    General:new(extension, "test__General1", "testKingdom", 3, 4, General.Male):addSkills { "test__General_skill1", "test__General_skill2" }
    -- 这一部分是武将的创建函数。具体参数详情请查看General类。
    -- 我们创建了一个名为test__General1的武将，他的势力是testKingdom，初始体力为3，体力上限为4，是一名男性。
    -- 并为他添加了两个技能

    Fk:loadTranslationTable {
      ["test__General1"] = "武将的名称",
      ["#test__General1"] = "武将的称号",
      -- #+武将代码名称 (若不写此条目，默认为【官方】)
      ["~test__General1"] = "武将阵亡语音台词",
      -- ~+武将代码名称 (若不写此条目则无语音台词)
      ["designer:test__General1"] = "武将的设计者",
      -- designer:+武将代码名称 (若不写此条目，默认为【官方】)
      ["illustrator:test__General1"] = "武将立绘的画师",
      -- illustrator:+武将代码名称 (若不写此条目，默认为【官方】)
      ["cv:test__General1"] = "武将语音的配音",
      -- cv:+武将代码名称 (若不写此条目，默认为【官方】)
    }


    local General2 = General:new(extension, "test__General2", "testKingdom", 3, 4, General.Male)

    General2:addSkills { "test__General2_skill1", "test__General2_skill2" }
    General2:addRelatedSkills { "test__General2_skill3" }

    Fk:loadTranslationTable {
      -- 这其中应包含武将二的相关翻译表，这里不再赘述
    }
    -- 这一部分展示了带衍生技的武将的创建方式

    return extension
    -- 千万不要忘记在文件的末尾加入返回语句
    -- 这里返回的是local extension = Package:new("package1") 之前创建子扩展包时的对象。

``skills`` 文件夹包含每个技能的实现，以下是一个典型的武将技能的实现文件

.. code-block:: lua
    :linenos:

    local skill1 = fk.CreateSkill {
      name = "test_skill1",        --技能代码名
      tags = { Skill.Compulsory, } -- 技能标签，比如锁定技
    }
    -- 这一部分创建了技能骨架，具体参见SkillSkeletonSpec类
    skill1:addEffect("active", {})
    -- 添加一个主动效果
    skill1:addEffect(fk.AfterCardsMove, {})
    -- 添加一个触发技效果
    -- 还可以添加其他技能效果，关于技能效果类型请参见技能管理


    Fk:loadTranslationTable {
      ["test_skill1"] = "技能名",
      [":test_skill1"] = "技能描述",
      ["$test_skill1"] = "技能语音1",
      ["$test_skill2"] = "技能语音2",
    }
    -- 这一部分是该技能相关的翻译表

    return skill1
    -- 返回我们创建的技能骨架对象

卡牌子扩展包
--------

一个典型的卡牌子扩展包的 ``init.lua`` 示例如下
    
.. code-block:: lua
    :linenos:

	local extension = Package:new("package2", Package.CardPack)
    extension.extensionName = "extension"
    -- 这一部分与武将扩展一致
    extension.game_modes_whitelist = { "test_Gamemode1" }
    extension.game_modes_blacklist = { "test_Gamemode2", "test_Gamemode3" }
    -- 这一部分定义了该扩展的黑白名单
    Fk:loadTranslationTable {
      ["package2"] = "子扩展包名",
    }

    extension:loadSkillSkelsByPath("./packages/extension/pkg/package2/skills")
    -- 该子扩展包技能查找路径
    local card1 = fk.CreateCard {
      name = "test_card1",
      type = Card.TypeBasic,
      skill = "test_card1_skill",
    }
    -- 这里是创建卡牌的创建函数，具体参见CardSpec类

    Fk:loadTranslationTable {
      ["test_Card1"] = "卡牌的名称",
      [":test_Card1"] = "卡牌效果的描述",
      -- <b>牌名：</b>卡牌名称<br/><b>类型：</b>装备牌·武器（装备牌拥有副类时遵照此格式）<br /><b>攻击范围</b>：1<br /><b>武器技能</b>：技能描述。
      -- <b>牌名：</b>卡牌名称<br/><b>类型：</b>基本牌<br /><b>时机</b>：出牌阶段<br /><b>目标</b>：一名其他角色<br /><b>效果</b>：对目标造成一点伤害
      -- 若类型为延时锦囊则直接写延时锦囊牌 即可。
      -- 若某些卡牌拥有主动效果，例如丈八蛇矛，则需要对武器牌的skill进行翻译。翻译格式与武将技能格式一样。
    }

    extension:loadCardSkels { card1, }
    -- 为我们创建的卡牌添加技能

    extension:addCardSpec("test_card1", Card.Heart, 1)
    extension:addCardSpec("test_card1", Card.Club, 1)
    extension:addCardSpec("test_card1", Card.Diamond, 1)
    extension:addCardSpec("test_card1", Card.Spade, 1)
    -- 这里是往本卡牌扩展中添加卡牌


    return extension
    -- 千万不要忘记在文件的末尾加入返回语句
    -- 这里返回的是local extension = Package:new("package2") 之前创建子扩展包时的对象。

卡牌技能的效果以技能的形式放于 ``skills`` 文件夹内

模式子扩展包
--------

对于模式子扩展包，我们的惯例是将创建模式子扩展包的语句加入整个扩展根目录的 ``init.lua`` 中。但也可以如武将或者卡牌子扩展包那样置于子扩展包文件夹内。

模式子扩展包的文件夹内应存在 ``rule_skills`` 文件夹用于存放游戏规则技能的定义。

一个典型的模式子扩展包的 ``init.lua`` 示例如下

.. code-block:: lua
    :linenos:

    local extension = Package:new("test_mode", Package.SpecialPack)
    -- 创建扩展包对象
    extension.extensionName = "test_mode"
    -- 定义扩展包名称

    extension:loadSkillSkelsByPath("./packages/extension/pkg/package3/rule_skills")
    -- 加载游戏规则技能
    Fk:loadTranslationTable {
      ["test_mode"] = "模式包名称",
    }
    local test_mode = require "packages/extension/package3/test_mode"
    -- 引用游戏模式定义文件

    extension:addGameMode(test_mode)
    -- 这里是往本扩展包中添加游戏模式，参数为定义好的游戏模式对象。


    return extension
    -- 返回扩展包对象

模式的具体实现应该置于 ``testmode.lua`` 文件中，示例如下


.. code-block:: lua
    :linenos:
	
    local jieshao = [[
         这里是游戏模式的介绍，可以写一些游戏规则，游戏机制等。
       ]]

    -- 定义游戏模式的逻辑，这里放的是主要的部分。由于该部分太长，所以不放在主函数中。
    local role_getlogic = function() end

    -- 定义游戏模式，这里从身份模式举例
    local test_mode = fk.CreateGameMode {
      name = "testMode",       -- 定义游戏模式的名称
      minPlayer = 2,           -- 定义游戏模式的最少玩家数量
      maxPlayer = 8,           -- 定义游戏模式的最多玩家数量
      rule = "game_rule",      -- 定义游戏的规则技能
      logic = role_getlogic,   -- 定义游戏模式的逻辑
      main_mode = "role_mode", -- 定义游戏模式的主模式，这里是身份模式
      ......                   -- 其他参数
    }

    Fk:loadTranslationTable {  -- 翻译表
      ["testMode"] = "测试模式",
      [":testMode"] = jieshao, -- 模式的介绍
    }

    return test_mode

模式子扩展包的基本代码格式已经介绍完毕，下面我们介绍一下游戏模式的主要定义。



游戏模式的主要定义和逻辑定义
^^^^^^^^^^^^^^^^^^^^^^^^^^

原GameModeSpec类的定义地址：packages/freekill-core/lua/fk_ex.lua  这里说明的很详细！

rule参数相当于给本模式添加一个全局的技能，这个技能的就是游戏的基础规则，默认优先级是0。

.. warning::

    在定义游戏规则的技能时，不需要给技能的effect添加global参数。



接下来我们主要介绍role_getlogic，这一部分是游戏模式的主要逻辑。

逻辑的定义地址：packages/freekill-core/lua/server/gamelogic.lua

我们首先来看run()函数，这里定义了我们逻辑的主要模块的加载顺序：

.. code-block:: lua
   :linenos:

   function GameLogic:run()
    -- default logic
    local room = self.room
    table.shuffle(self.room.players)
    self.room.game_started = true
    room:doBroadcastNotify("StartGame", "")


    self:assignRoles()           -- 身份分配
    self:adjustSeats()           -- 安排座位。若有主公则作为1号位
    self:chooseGenerals()        -- 进行选将

    self:buildPlayerCircle()     -- 构建玩家圈
    self:broadcastGeneral()      -- 公布选将结果
    self:prepareDrawPile()       -- 准备牌堆
    self:attachSkillToPlayers()  -- 给玩家添加初始技能
    self:prepareForStart()       -- 准备开始 
  
    self:action()                -- 开始游戏
  end


这里面执行的顺序是非常重要的，需要修改效果的话，要注意修改模块的部分和模块的加载顺序！

接下来，我们对应来介绍每个模块的作用和注意事项。


assignRoles()
^^^^^^^^^^^^^

身份分配模块，这里是分配身份的主要逻辑。

如果你对玩家的身份需要修改的话，可以更改该模块中的self.role_table表中的内容。


adjustSeats()
^^^^^^^^^^^^^

安排座位模块，例如2v2,3v3模式就需要对玩家的座位进行调整。


chooseGenerals()
^^^^^^^^^^^^^^^^

选将模块，这里可以对玩家的选将池进行设定，当然将池的白名单也可以在这里去设置。


buildPlayerCircle()
^^^^^^^^^^^^^^^^^^^

构建玩家圈模块，这是链接玩家执行顺序的地方，基本不用改动。


broadcastGeneral()
^^^^^^^^^^^^^^^^^^^

公布选将结果模块，这里是会设定玩家的武将图像，设定武将的初始体力，体力上限和护甲等，玩家属性方面的设置。


prepareDrawPile()
^^^^^^^^^^^^^^^^^

准备牌堆模块，这里是对牌堆的初始化，如果你需要自定义牌堆的话，可以放在这里进行修改。


attachSkillToPlayers()
^^^^^^^^^^^^^^^^^^^^^^^

给玩家添加初始技能模块，这里是给玩家添加初始技能，包括斗地主的飞扬跋扈等。

如果你需要给玩家添加其他初始技能 ，可以放在这里进行修改。


prepareForStart()
^^^^^^^^^^^^^^^^^

准备开始模块，这里游戏开始前的准备，会将全部的全局触发技放到本房间。当然这个模块大部分是用来关闭手杀特效的（


action()
^^^^^^^^

游戏正式准备开始的模块，在这里会触发相关的游戏时机，例如fk.GamePrepared，fk.DrawInitialCards等。


至此，我们介绍了游戏模式的主要逻辑，以及各个模块的作用和注意事项。

根据自己的需求修改对应的模块即可，没必要所有模块全部更改，所有在自定义游戏模式时，如果有不需要修改模块可以不用写。

在运行时，会根据main_mode参数判断是否是某种模式的衍生，如果是，则会默认执行对应游戏类型（身份模式，1v2模式等）的模块逻辑。


