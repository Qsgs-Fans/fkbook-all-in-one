常用API
============


Room类
--------

Room类是房间类，包括多个属性和函数，大部分的操作都是由该类和player类完成的。算是需要经常了解的类。


属性：
~~~~~~

原文件地址：packages\freekill-core\lua\server\room.lua

 Room是fk游戏逻辑运行的主要场所，同时也提供了许多API函数供编写技能使用。

 一个房间中只有一个Room实例，保存在RoomInstance全局变量中。


@class Room : AbstractRoom, GameEventWrappers, CompatAskFor


@field public room fk.Room @ C++层面的Room类实例，别管他就是了，用不着


@field public id integer @ 房间的id


@field private main_co any @ 本房间的主协程


@field public players ServerPlayer[] @ 这个房间中所有参战玩家


@field public alive_players ServerPlayer[] @ 所有还活着的玩家


@field public observers fk.ServerPlayer[] @ 旁观者清单，这是c++玩家列表，别乱动


@field public current ServerPlayer @ 当前回合玩家


@field public game_started boolean @ 游戏是否已经开始


@field public game_finished boolean @ 游戏是否已经结束


@field public extra_turn_list table @ 待执行的额外回合表


@field public tag table<string, any> @ Tag清单，其实跟Player的标记是差不多的东西


@field public general_pile string[] @ 武将牌堆，这是可用武将名的数组


@field public logic GameLogic @ 这个房间使用的游戏逻辑，可能根据游戏模式而变动


@field public request_queue table<userdata, table>


@field public request_self table<integer, integer>


@field public last_request Request @ 上一次完成的request


@field public skill_costs table<string, any> @ 存放skill.cost_data用


@field public card_marks table<integer, any> @ 存放card.mark之用


@field public current_cost_skill TriggerSkill? @ AI用


@field public _test_disable_delay boolean? 测试专用 会禁用delay和烧条


.. note::

    这里的属性比较多，很多是房间的构造属性和通信属性，我们所需要了解的只有几个常用的属性。

    room.players 这个属性是一个ServerPlayer数组，里面包含了所有参战玩家的实例。 这里的玩家不会包括旁观者，但是会包括阵亡的玩家，所以需要注意。

    room.alive_players 这个属性是一个ServerPlayer数组，里面包含了所有还活着的玩家的实例。 这个参数是我们经常用到的，比如南蛮入侵就不会指定阵亡角色。

    room.current 这个属性是一个ServerPlayer实例，表示当前回合的玩家。 这个用来特殊指定，例如当前回合的玩家等，不算常用。

    room.tag 这个属于是房间的标记，可以用来存放一些自定义数据，比如游戏模式、难度等。

    room.general_pile 这个属性是一个字符串数组，里面包含了本房间内的所有可用的武将名。

    room.logic 这个属性是游戏逻辑的实例，用来查找事件栈，终止事件等比较常用，但是新人的话还是不用管，多看看其他大佬是怎么用这个的。



函数：
~~~~~~

根据角色id，获得那名角色本人
@param id integer @ 角色的id
@return ServerPlayer @ 这个id对应的ServerPlayer实例
function Room:getPlayerById(id)

.. note::

  很常用的函数，通过玩家id定位一名玩家。每个玩家的id是唯一的，且AI电脑的id是负数。


根据角色座位号，获得那名角色本人
@param seat integer @ 角色的座位号
@return ServerPlayer @ 这个座位号对应的ServerPlayer实例
function Room:getPlayerBySeat(seat)

.. note::

  不算常用的函数，但是有时候需要根据座位号定位一名玩家。玩家的座位号是从1开始的，逆时针方向计数。


@param players ServerPlayer[]
function Room:sortByAction(players)

将给定的玩家列表按照座位号的先后顺序排序。


@param players ServerPlayer[]
@return ServerPlayer[]
function Room:deadPlayerFilter(players)

获取给定的玩家列表中的死亡玩家


获得当前房间中的所有角色。
如果按照座位排序，返回的数组的第一个元素是当前回合角色，并且按行动顺序进行排序。
@param sortBySeat? boolean @ 是否按座位排序，默认是
@return ServerPlayer[] @ 房间中角色的数组
function Room:getAllPlayers(sortBySeat)

.. note::

  我的评价是不如room.players（x



获得所有存活角色，参看getAllPlayers
@param sortBySeat? boolean @ 是否按座位排序，默认是
@return ServerPlayer[]
function Room:getAlivePlayers(sortBySeat)

.. note::

  实际上现在都直接用room.alive_players了，老东西！(bushi



获得除一名角色外的其他角色。
@param player ServerPlayer @ 要排除的角色
@param sortBySeat? boolean @ 是否按座位排序，默认是
@param include_dead? boolean @ 是否要把死人也算进去？
@return ServerPlayer[] @ 其他角色列表
function Room:getOtherPlayers(player, sortBySeat, include_dead)

.. note::

  很常用的函数，这个函数是用来获取本房间内**全部参战**的玩家中除一名角色外的其他角色


获得当前房间中的主公。
由于某些游戏模式没有主公，该函数可能返回nil。
@return ServerPlayer? @ 主公
function Room:getLord()


从摸牌堆中获取若干张牌。
如果牌堆中没有足够的牌可以获得，那么会触发洗牌；还是不够的话，游戏就平局。
@param num integer @ 要获得的牌的数量
@param from? string @ 获得牌的位置，可以是 ``"top"`` 或者 ``"bottom"``，表示牌堆顶还是牌堆底
@return integer[] @ 得到的id
function Room:getNCards(num, from)

.. note::

  很常用的函数，请注意，这里的函数是从牌堆中**获取**，而非摸若干张牌，要区分开，
  
  举例就是观星和摸牌的区别，我们只是获取这些牌的信息，且获取的方式是按照顺序连续获取的


将一名玩家的某种标记数量相应的值。
在设置之后，会通知所有客户端也更新一下标记的值。之后的两个相同
@param player ServerPlayer @ 要被更新标记的那个玩家
@param mark string @ 标记的名称
@param value any @ 要设为的值，其实也可以设为字符串
function Room:setPlayerMark(player, mark, value)

.. note::

  非常常用的函数！如果你需要设置玩家的标记，一定要使用这个函数！不要去Player那边的setMark！



将一名玩家的mark标记增加count个。
@param player ServerPlayer @ 要加标记的玩家
@param mark string @ 标记名称
@param count? integer @ 要增加的数量，默认为1
function Room:addPlayerMark(player, mark, count)

.. note::

  非常常用的函数！如果你需要添加玩家的标记，一定要使用这个函数！不要去Player那边的addMark！



将一名玩家的mark标记减少count个。
@param player ServerPlayer @ 要减标记的玩家
@param mark string @ 标记名称
@param count? integer  @ 要减少的数量，默认为1
function Room:removePlayerMark(player, mark, count)

.. note::

  非常常用的函数！如果你需要移除玩家的标记，一定要使用这个函数！不要去Player那边的removeMark！


--清除一名角色手牌中的某种标记
@param player ServerPlayer @ 要清理标记的角色
@param name string @ 要清理的标记名
function Room:clearHandMark(player, name)


将一张卡牌的某种标记数量相应的值。
在设置之后，会通知所有客户端也更新一下标记的值。之后的两个相同
@param card Card @ 要被更新标记的那张牌
@param mark string @ 标记的名称
@param value any @ 要设为的值，其实也可以设为字符串
function Room:setCardMark(card, mark, value)

.. note::

  非常常用的函数！如果你需要设置卡牌的标记，一定要使用这个函数！


将一张卡牌的mark标记增加count个。
@param card Card @ 要被增加标记的那张牌
@param mark string @ 标记名称
@param count? integer @ 要增加的数量，默认为1
function Room:addCardMark(card, mark, count)

.. note::

  非常常用的函数！如果你需要增加卡牌的标记，一定要使用这个函数！


将一名玩家的mark标记减少count个。
@param card Card @ 要被减少标记的那张牌
@param mark string @ 标记名称
@param count? integer @ 要减少的数量，默认为1
function Room:removeCardMark(card, mark, count)

.. note::

  非常常用的函数！如果你需要移除卡牌的标记，一定要使用这个函数！


设置角色的某个属性，并广播给所有人
@param player ServerPlayer
@param property string @ 属性名称
function Room:setPlayerProperty(player, property, value)

.. note::

  不算常用的函数，一般是用来同步服务器中玩家的属性的，比如体力、护甲、武将牌之类的等。正常用不到。


将房间中某个tag设为特定值。
注意：客户端无法获取room tag，请改用setBanner
当在编程中想在服务端搞点全局变量的时候哦，不要自己设置全局变量或者上值，而是应该使用room的tag。
@param tag_name string @ tag名字
@param value any @ 值
function Room:setTag(tag_name, value)

.. note::

  DIY作者如果需要房间标记，请使用Banner！



获得某个tag的值。
@param tag_name string @ tag名字
function Room:getTag(tag_name)


删除某个tag。
@param tag_name string @ tag名字
function Room:removeTag(tag_name)


设置房间banner于左上角，用于模式介绍，仁区等
function Room:setBanner(name, value)

.. note::

  这个函数是用来设置房间的banner的，banner可以立即为房间的全局标记。


设置房间的当前行动者
@param player ServerPlayer
function Room:setCurrent(player)

.. note::

  这个函数是用来设置房间的当前行动者的，一般是由游戏规则设置的，例如身份场主公优先行动。



@param player ServerPlayer
@param general string
@param changeKingdom? boolean
@param noBroadcast? boolean
function Room:setPlayerGeneral(player, general, changeKingdom, noBroadcast)

.. note::

  这个函数是用来设置玩家的武将牌，仅改变武将牌的时候使用。



@param player ServerPlayer
@param general string
function Room:setDeputyGeneral(player, general)

.. note::

  这个函数是用来设置玩家的副将牌，仅改变武将牌的时候使用。


为角色设置武将，并从武将池中抽出，若有隐匿技变为隐匿将。注意此时不会进行选择势力，请随后自行处理
@param player ServerPlayer
@param general string @ 主将名
@param deputy? string @ 副将名
@param broadcast? boolean @ 是否公示，默认否
function Room:prepareGeneral(player, general, deputy, broadcast)

.. note::

  这个函数是用来设置玩家的武将，一般用在模式选将后声明选将的时候使用。




@param player ServerPlayer
function Room:toJsonObject(player)

将房间对象转成json对象，供客户端使用。正常用不到，属于底层函数


------------------------------------------------------------------------
-- 网络通信有关
------------------------------------------------------------------------

向所有角色广播一名角色的某个property，让大家都知道
@param player ServerPlayer @ 要被广而告之的那名角色
@param property string @ 这名角色的某种属性，像是"hp"之类的，其实就是Player类的属性名
function Room:broadcastProperty(player, property)





将player的属性property告诉p。
@param p ServerPlayer @ 要被告知相应属性的那名玩家
@param player ServerPlayer @ 拥有那个属性的玩家
@param property string @ 属性名称
function Room:notifyProperty(p, player, property)





向多名玩家广播一条消息。
@param command string @ 发出这条消息的消息类型
@param jsonData string @ 消息的数据，一般是JSON字符串，也可以是普通字符串，取决于client怎么处理了
@param players? ServerPlayer[] @ 要告知的玩家列表，默认为所有人
function Room:doBroadcastNotify(command, jsonData, players)





延迟一段时间。
@param ms integer @ 要延迟的毫秒数
function Room:delay(ms)




延迟一段时间。界面上会显示所有人读条了。注意这个只能延迟多少秒。
@param sec integer @ 要延迟的秒数
function Room:animDelay(sec)





将焦点转移给一名或者多名角色，并广而告之。
---
形象点说，就是在那些玩家下面显示一个“弃牌 思考中...”之类的烧条提示。
@param players ServerPlayer | ServerPlayer[] @ 要获得焦点的一名或者多名角色
@param command string @ 烧条的提示文字
@param timeout integer? @ focus的烧条时长
function Room:notifyMoveFocus(players, command, timeout)




向战报中发送一条log。
@param log LogMessage @ Log的实际内容
function Room:sendLog(log)



-- 为一些牌设置脚注
@param ids integer[] @ 要设置虚拟牌名的牌的id列表
@param log LogMessage @ Log的实际内容
function Room:sendFootnote(ids, log)




为一些牌设置虚拟转化牌名
@param ids integer[] @ 要设置虚拟牌名的牌的id列表
@param name string @ 虚拟牌名
function Room:sendCardVirtName(ids, name)



播放某种动画效果给players看。
@param type string @ 动画名字
@param data any @ 这个动画附加的额外信息，在这个函数将会被转成json字符串
@param players? ServerPlayer[] @ 要观看动画的玩家们，默认为全员
function Room:doAnimate(type, data, players)





在player脸上展示名为name的emotion动效。
---
这就是“杀”、“闪”之类的那个动画。
@param player ServerPlayer @ 被播放动画的那个角色
@param name string @ emotion名字，可以是一个路径
function Room:setEmotion(player, name)




在一张card上播放一段emotion动效。
---
这张card必须在处理区里面，或者至少客户端觉得它在处理区。
@param cid integer @ 被播放动效的那个牌的id
@param name string @ emotion名字，可以是一个路径
function Room:setCardEmotion(cid, name)




播放一个全屏大动画。可以自己指定qml文件路径和额外的信息。
@param path string @ qml文件的路径，有默认值
@param extra_data any @ 要传递的额外信息
function Room:doSuperLightBox(path, extra_data)




基本上是个不常用函数就是了
function Room:sendLogEvent(type, data, players)




播放一段音频。
@param path string @ 音频文件路径
function Room:broadcastPlaySound(path)





在player的脸上播放技能发动的特效。
---
与此同时，在战报里面发一条“xxx发动了xxx”
@param player ServerPlayer @ 发动技能的那个玩家
@param skill_name string @ 技能名
@param skill_type? string | AnimationType @ 技能的动画效果，默认是那个技能的anim_type
@param tos? integer[] | ServerPlayer[] @ 技能目标，填空则不声明
function Room:notifySkillInvoked(player, skill_name, skill_type, tos)






播放从source指到targets的指示线效果。
@param source integer | ServerPlayer @ 指示线开始的那个玩家
@param targets integer[] | ServerPlayer[] @ 指示线目标玩家的列表
function Room:doIndicate(source, targets)







------------------------------------------------------------------------
 交互方法
------------------------------------------------------------------------


@class AskToUseActiveSkillParams: AskToSkillInvokeParams


@field skill_name string @ 请求发动的技能名


@field cancelable? boolean @ 是否可以点取消


@field no_indicate? boolean @ 是否不显示指示线


@field extra_data? table @ 额外信息（使用```skillName```指定烧条时的显示技能名）


@field skip? boolean @ 是否跳过实际执行流程

询问player是否要发动一个主动技。
---
如果发动的话，那么会执行一下技能的onUse函数，然后返回选择的牌和目标等。
@param player ServerPlayer @ 询问目标
@param params AskToUseActiveSkillParams @ 各种变量
@return boolean, { cards: integer[], targets: ServerPlayer[], interaction: any }? @ 返回第一个值为是否成功发动，第二值为技能选牌、目标等数据
function Room:askToUseActiveSkill(player, params)

.. note::

  这个函数是用来询问玩家是否要发动一个主动技能的，很常用，需要熟练了解。





@class AskToDiscardParams: AskToUseActiveSkillParams


@field min_num integer @ 最小值


@field max_num integer @ 最大值


@field include_equip? boolean @ 能不能弃装备区？


@field pattern? string @ 弃牌需要符合的规则


@field skip? boolean @ 是否跳过弃牌（即只询问选择可以弃置的牌）

询问一名角色弃牌。
---
在这个函数里面牌已经被弃掉了（除非skipDiscard为true）。
@param player ServerPlayer @ 弃牌角色
@param params AskToDiscardParams @ 各种变量
@return integer[] @ 弃掉的牌的id列表，可能是空的
function Room:askToDiscard(player, params)







@class AskToChoosePlayersParams: AskToUseActiveSkillParams


@field targets ServerPlayer[] @ 可以选的目标范围


@field min_num integer @ 最小值


@field max_num integer @ 最大值


@field target_tip_name? string @ 引用的选择目标提示的函数名

询问一名玩家从targets中选择若干名玩家出来。
@param player ServerPlayer @ 要做选择的玩家
@param params AskToChoosePlayersParams @ 各种变量
@return ServerPlayer[] @ 选择的玩家列表，可能为空
function Room:askToChoosePlayers(player, params)





@class AskToCardsParams: AskToUseActiveSkillParams


@field min_num integer @ 最小值


@field max_num integer @ 最大值


@field include_equip? boolean @ 能不能选装备


@field pattern? string @ 选牌规则


@field expand_pile? string|integer[] @ 可选私人牌堆名称，或额外可选牌

询问一名玩家选择自己的几张牌。
---
与askForDiscard类似，但是不对选择的牌进行操作就是了。
@param player ServerPlayer @ 要询问的玩家
@param params AskToCardsParams @ 各种变量
@return integer[] @ 选择的牌的id列表，可能是空的
function Room:askToCards(player, params)







@class AskToViewCardsAndChoiceParams: AskToSkillInvokeParams


@field cards integer[] @ 待选卡牌


@field default_choice? string @ 始终可用的分支，会置于最左侧且始终可用，若为空则choice的第一项始终可用。当需要```filter_skel_name```审查时**建议填入**


@field choices string[]? @ 可选选项列表，默认值为“确定”，受```filter_skel_name```的审查


@field filter_skel_name? string @ 带```extra.choiceFilter(cards: integer[], choice: string, extra_data: table?): boolean?```的技能**骨架**名，无则所有选项均可用


@field cancel_choices? string[] @ 可选选项列表（不选择牌时的选项），默认为空


@field extra_data? table @ 额外信息，因技能而异了

询问玩家观看一些牌并做出选项，但是选项有额外的点亮标准
@param player ServerPlayer @ 要询问的玩家
@param params AskToViewCardsAndChoiceParams @ 参数列表
@return string
function Room:askToViewCardsAndChoice(player, params)





@class AskToChooseCardsAndChoiceParams: AskToViewCardsAndChoiceParams


@field all_cards? integer[]  @ 会显示的所有卡牌


@field min_num? integer  @ 最小选牌数（默认为1）


@field max_num? integer  @ 最大选牌数（默认为1）

询问玩家选择牌和选项，但是选项有额外的点亮标准
@param player ServerPlayer @ 要询问的玩家
@param params AskToChooseCardsAndChoiceParams @ 参数列表
@return integer[], string
function Room:askToChooseCardsAndChoice(player, params)





@class AskToChooseCardsAndPlayersParams: AskToChoosePlayersParams


@field min_card_num integer @ 选卡牌最小值


@field max_card_num integer @ 选卡牌最大值


@field equal? boolean @ 是否要求牌数和目标数相等，默认否


@field pattern? string @ 选牌规则，默认为"."


@field expand_pile? string|integer[] @ 可选私人牌堆名称，或额外可选牌


@field will_throw? boolean @ 选卡牌须能弃置

询问玩家选择X张牌和Y名角色。
---
返回两个值，第一个是选择目标列表，第二个是选择的牌id列表，第三个是否按了确定
@param player ServerPlayer @ 要询问的玩家
@param params AskToChooseCardsAndPlayersParams @ 各种变量
@return ServerPlayer[], integer[], boolean @ 第一个是选择目标列表，第二个是选择的牌id列表，第三个是否按了确定
function Room:askToChooseCardsAndPlayers(player, params)







@class AskToYijiParams: AskToChoosePlayersParams


@field targets? ServerPlayer[] @ 可分配的目标角色，默认为所有存活角色


@field cards? integer[] @ 要分配的卡牌。默认拥有的所有牌


@field expand_pile? string|integer[] @ 可选私人牌堆名称，或额外可选牌


@field single_max? integer|table @ 限制每人能获得的最大牌数。输入整数或(以角色id为键以整数为值)的表


@field skip? boolean @ 是否跳过移动。默认不跳过


@field moveMark? table|string @ 移动后自动赋予标记，格式：{标记名(支持-inarea后缀，移出值代表区域后清除), 值}

询问将卡牌分配给任意角色。
@param player ServerPlayer @ 要询问的玩家
@param params AskToYijiParams @ 各种变量
@return table<integer, integer[]> @ 返回一个表，键为角色id，值为分配给其的牌id数组
function Room:askToYiji(player, params)






@class AskToChooseGeneralParams

@field generals string[] @ 可选武将

@field n? integer @ 可选数量，默认为1

@field no_convert? boolean @ 可否同名替换，默认可

@field rule? string @ 选将规则名（使用```Fk:addChooseGeneralRule```定义），默认为askForGeneralsChosen

@field extra_data? table @ 额外信息，键值表。预留：```skill_name```技能名

@field heg? boolean @ 是否应用国战ui（提示珠联璧合和主副将调整阴阳鱼）。默认选将规则为heg_general_choose

询问玩家选择一名武将。
@param player ServerPlayer @ 询问目标
@param params AskToChooseGeneralParams @ 各种变量
@return string|string[] @ 选择的武将，一个是string，多个是string[]
function Room:askToChooseGeneral(player, params)





询问玩家若为神将、双势力需选择一个势力。
@param players? ServerPlayer[] @ 询问目标
function Room:askToChooseKingdom(players)





@class AskToChooseCardParams: AskToSkillInvokeParams


@field target ServerPlayer @ 被选牌的人


@field flag string | table @ 用"hej"三个字母的组合表示能选择哪些区域, h 手牌区, e - 装备区, j - 判定区


@field skill_name string @ 原因，一般是技能名

询问player，选择target的一张牌。
@param player ServerPlayer @ 要被询问的人
@param params AskToChooseCardParams @ 各种变量
@return integer @ 选择的卡牌id
function Room:askToChooseCard(player, params)




@class AskToPoxiParams


@field poxi_type string @ poxi关键词


@field data any @ 牌堆信息


@field extra_data any @ 额外信息


@field cancelable? boolean @ 是否可取消

谋askForCardsChosen，需使用```Fk:addPoxiMethod```定义好方法


选卡规则和返回值啥的全部自己想办法解决，```data```填入所有卡的列表（类似```ui.card_data```）


注意一定要返回一个表，毕竟本质上是选卡函数
@param player ServerPlayer @ 要被询问的人
@param params AskToPoxiParams @ 各种变量
@return integer[] @ 选择的牌ID数组
function Room:askToPoxi(player, params)




@class AskToChooseCardsParams: AskToChooseCardParams


@field min integer @ 最小选牌数


@field max integer @ 最大选牌数


@field pattern? string @ 只针对可见牌的选牌规则

完全类似askForCardChosen，但是可以选择多张牌。
相应的，返回的是id的数组而不是单个id。
@param player ServerPlayer @ 要被询问的人
@param params AskToChooseCardsParams @ 各种变量
@return integer[] @ 选择的id
function Room:askToChooseCards(player, params)





@class AskToChoiceParams


@field choices string[] @ 可选选项列表


@field skill_name? string @ 技能名


@field prompt? string @ 提示信息


@field detailed? boolean @ 选项是否详细描述


@field all_choices? string[] @ 所有选项（不可选变灰）


@field cancelable? boolean @ 是否可以点取消

询问一名玩家从众多选项中选择一个。
@param player ServerPlayer @ 要询问的玩家
@param params AskToChoiceParams @ 各种变量
@return string @ 选择的选项
function Room:askToChoice(player, params)



@class AskToChoicesParams: AskToChoiceParams


@field min_num number @ 最少选择项数

@field max_num number @ 最多选择项数

询问一名玩家从众多选项中勾选任意项。
@param player ServerPlayer @ 要询问的玩家
@param params AskToChoicesParams @ 各种变量
@return string[] @ 选择的选项
function Room:askToChoices(player, params)




@class askToJointChoiceParams

@field players ServerPlayer[] @ 被询问的玩家

@field choices string[] @ 可选选项列表

@field skill_name? string @ 技能名

@field prompt? string @ 提示信息

@field send_log? boolean @ 是否发Log，默认否

同时询问多名玩家从众多选项中选择一个（要求所有玩家选项相同，不同的请自行构造request）
@param player ServerPlayer @ 发起者
@param params askToJointChoiceParams @ 各种变量
@return table<Player, string> @ 返回键值表，键为Player、值为选项
function Room:askToJointChoice(player, params)



@class askToJointCardsParams

@field players ServerPlayer[] @ 被询问的玩家

@field min_num integer @ 最小值

@field max_num integer @ 最大值

@field include_equip? boolean @ 能不能选装备

@field skill_name? string @ 技能名

@field cancelable? boolean @ 能否点取消

@field pattern? string @ 选牌规则

@field prompt? string @ 提示信息

@field expand_pile? string @ 可选私人牌堆名称

@field will_throw? boolean @ 是否是弃牌，默认否（在这个流程中牌不会被弃掉，仅用作禁止弃置技判断）

同时询问多名玩家选择一些牌（要求所有玩家选牌规则相同，不同的请自行构造request）
@param player ServerPlayer @ 发起者
@param params askToJointCardsParams @ 各种变量
@return table<Player, integer[]> @ 返回键值表，键为Player、值为选择的牌id列表
function Room:askToJointCards(player, params)



@class AskToSkillInvokeParams

@field skill_name string @ 询问技能名（烧条时显示的技能名）

@field prompt? string @ 提示信息

询问玩家是否发动技能。
@param player ServerPlayer @ 要询问的玩家
@param params AskToSkillInvokeParams @ 各种变量
@return boolean @ 是否发动
function Room:askToSkillInvoke(player, params)



@class AskToArrangeCardsParams: AskToSkillInvokeParams

@field card_map any @ { "牌堆1卡表", "牌堆2卡表", …… }

@field prompt? string @ 操作提示

@field box_size? integer @ 数值对应卡牌平铺张数的最大值，为0则有单个卡位，每张卡占100单位长度，默认为7

@field max_limit? integer[] @ 每一行牌上限 { 第一行, 第二行，…… }，不填写则不限

@field min_limit? integer[] @ 每一行牌下限 { 第一行, 第二行，…… }，不填写则不限

@field free_arrange? boolean @ 是否允许自由排列第一行卡的位置，默认不能

@field pattern? string @ 控制第一行卡牌是否可以操作，不填写默认均可操作

@field poxi_type? string @ 控制每张卡牌是否可以操作、确定键是否可以点击，不填写默认均可操作

@field default_choice? table[] @ 超时的默认响应值，在带poxi_type时需要填写

询问玩家在自定义大小的框中排列卡牌（观星、交换、拖拽选牌）
@param player ServerPlayer @ 要询问的玩家
@param params AskToArrangeCardsParams @ 各种变量
@return table[] @ 排列后的牌堆结果
function Room:askToArrangeCards(player, params)




@class AskToGuanxingParams : AskToSkillInvokeParams

@field cards integer[] @ 可以被观星的卡牌id列表

@field top_limit? integer[] @ 置于牌堆顶的牌的限制(下限,上限)，不填写则不限

@field bottom_limit? integer[] @ 置于牌堆底的牌的限制(下限,上限)，不填写则不限

@field skill_name? string @ 烧条时显示的技能名

@field title? string @ 观星框的标题

@field skip? boolean @ 是否进行放置牌操作

@field area_names? string[] @ 左侧提示信息

询问玩家对若干牌进行观星。

观星完成后，相关的牌会被置于牌堆顶或者牌堆底。所以这些cards最好不要来自牌堆，一般先用getNCards从牌堆拿出一些牌。
@param player ServerPlayer @ 要询问的玩家
@param params AskToGuanxingParams @ 各种变量
@return table<"top"|"bottom", integer[]> @ 观星后的牌堆结果
function Room:askToGuanxing(player, params)







@class AskToExchangeParams

@field piles integer[][] @ 卡牌id列表的列表，也就是……几堆牌堆的集合

@field piles_name? string[] @ 牌堆名，不足部分替换为“牌堆1、牌堆2...”

@field skill_name? string @ 烧条时显示的技能名

询问玩家任意交换几堆牌堆。

@param player ServerPlayer @ 要询问的玩家
@param params AskToExchangeParams @ 各种变量
@return integer[][] @ 交换后的结果
function Room:askToExchange(player, params)




抽个武将
---
同getNCards，抽出来就没有了，所以记得放回去。
@param n number @ 数量
@param position? string @位置，top/bottom，默认top
@return string[] @ 武将名数组
function Room:getNGenerals(n, position)




把武将牌塞回去（……）
@param g string[] @ 武将名数组
@param position? string @位置，top/bottom/random，默认random
@return boolean @ 是否成功
function Room:returnToGeneralPile(g, position)



抽特定名字的武将（抽了就没了）
@param name string? @ 武将name，如找不到则查找truename，再找不到则返回nil
@return string? @ 抽出的武将名
function Room:findGeneral(name)




自上而下抽符合特定情况的N个武将（抽了就没了）
@param func fun(name: string):any @ 武将筛选函数
@param n? integer @ 抽取数量，数量不足则直接抽干净
@return string[] @ 武将组合，可能为空
function Room:findGenerals(func, n)



将从Request获得的数据转化为UseCardData，或执行主动技的onUse部分
一般DIY用不到的内部函数
@param player ServerPlayer
@return UseCardDataSpec|string? @ 返回字符串则取消使用，若返回技能名，在当前询问中禁用此技能
function Room:handleUseCardReply(player, data)




@class AskToUseRealCardParams

@field pattern string|integer[] @ 选卡规则，或可选的牌id表

@field skill_name? string @ 烧条时显示的技能名

@field prompt? string @ 询问提示信息。默认为：请使用一张牌

@field extra_data? UseExtraData|table @ 额外信息，因技能而异了

@field cancelable? boolean @ 是否可以取消。默认可以取消

@field skip? boolean @ 是否跳过使用。默认不跳过

@field expand_pile? string|integer[] @ 可选私人牌堆名称，或额外可选牌

询问玩家从一些实体牌中选一个使用。默认无次数限制，与askForUseCard主要区别是不能调用转化技
@param player ServerPlayer @ 要询问的玩家
@param params AskToUseRealCardParams @ 各种变量
@return UseCardDataSpec? @ 返回卡牌使用框架。取消使用则返回空
function Room:askToUseRealCard(player, params)




@class askToUseVirtualCardParams: AskToSkillInvokeParams

@field name string|string[] @ 可以选择的虚拟卡名，可以多个

@field subcards? integer[] @ 虚拟牌的子牌，默认空

@field card_filter? table @选牌规则，优先级低于```subcards```，可选参数：```n```（牌数，填数字表示此只能此数量，填{a, b}表示至少为a至多为b）```pattern```（选牌规则）```cards```（可选牌的范围）

@field prompt? string @ 询问提示信息。默认为：请视为使用xx

@field extra_data? UseExtraData|table @ 额外信息，因技能而异了

@field cancelable? boolean @ 是否可以取消。默认可以取消

@field skip? boolean @ 是否跳过使用。默认不跳过

@field expand_pile? string|integer[] @ 可选私人牌堆名称，或额外可选牌

询问玩家使用一张虚拟卡，或从几种牌名中选择一种视为使用
@param player ServerPlayer @ 要询问的玩家
@param params askToUseVirtualCardParams @ 各种变量
@return UseCardDataSpec? @ 返回卡牌使用框架。取消使用则返回空
function Room:askToUseVirtualCard(player, params)





@class askToPlayCardParams: AskToSkillInvokeParams

@field cards? integer[] @ 可以选择的卡牌，默认包括手牌和“如手牌”

@field pattern? string @ 选卡规则，与可用卡牌取交集

@field extra_data? UseExtraData|table @ 额外信息，因技能而异了

@field skip? boolean @ 是否跳过使用。默认不跳过

@field cancelable? boolean @ 是否可以取消。目前不支持无法取消

询问玩家（如在空闲时间点一般）使用一张实体牌，支持转化技。
@param player ServerPlayer @ 要询问的玩家
@param params askToPlayCardParams @ 各种变量
@return UseCardDataSpec? @ 返回关于本次使用牌的数据，以便后续处理
function Room:askToPlayCard(player, params)




@class askToNumberParams: AskToSkillInvokeParams

@field prompt? string @ 询问提示信息。默认为：请选择一个数字

@field min integer @ 最小值

@field max integer @ 最大值

@field cancelable? boolean @ 是否可以取消。默认不可取消

询问玩家选择一个数字
@param player ServerPlayer @ 要询问的玩家
@param params askToNumberParams @ 各种变量
@return integer? @ 返回选择的数字。取消则返回空
function Room:askToNumber(player, params)




@class AskToUseCardParams: AskToSkillInvokeParams

@field pattern string @ 使用牌的规则

@field cancelable? boolean @ 是否可以取消。默认可以取消

@field extra_data? UseExtraData|table @ 额外信息，因技能而异了

@field event_data? CardEffectData @ 事件信息，如借刀事件之于询问杀

-- available extra_data:
-- * must_targets: integer[]
-- * exclusive_targets: integer[]
-- * fix_targets: integer[]
-- * bypass_distances: boolean
-- * bypass_times: boolean
---
询问玩家使用一张牌。
@param player ServerPlayer @ 要询问的玩家
@param params AskToUseCardParams @ 各种变量
@return UseCardDataSpec? @ 返回关于本次使用牌的数据，以便后续处理
function Room:askToUseCard(player, params)




询问一名玩家打出一张牌。
@param player ServerPlayer @ 要询问的玩家
@param params AskToUseCardParams @ 各种变量
@return RespondCardDataSpec? @ 打出的事件
function Room:askToResponse(player, params)




同时询问多名玩家是否使用某一张牌。
---
函数名字虽然是“询问无懈可击”，不过其实也可以给别的牌用就是了。
@param players ServerPlayer[] @ 要询问的玩家列表
@param params AskToUseCardParams @ 各种变量
@return UseCardDataSpec? @ 最终决胜出的卡牌使用信息
function Room:askToNullification(players, params)





@class AskToAGParams

@field id_list integer[] | Card[] @ 可选的卡牌列表

@field cancelable? boolean @ 能否点取消

@field skill_name? string @ 烧条时显示的技能名

-- AG(a.k.a. Amazing Grace) functions
-- Popup a box that contains many cards, then ask player to choose one

询问玩家从AG中选择一张牌。
@param player ServerPlayer @ 要询问的玩家
@param params AskToAGParams @ 各种变量
@return integer @ 选择的卡牌
function Room:askToAG(player, params)



告诉一些玩家，AG中的牌被taker取走了。
@param taker ServerPlayer @ 拿走牌的玩家
@param id integer @ 被拿走的牌
@param notify_list? ServerPlayer[] @ 要告知的玩家，默认为全员
function Room:takeAG(taker, id, notify_list)




关闭player那侧显示的AG。
---
若不传参（即player为nil），那么关闭所有玩家的AG。
@param player? ServerPlayer @ 要关闭AG的玩家
function Room:closeAG(player)




@class AskToMiniGameParams

@field skill_name string @ 烧条时显示的技能名

@field game_type string @ 小游戏框关键词

@field data_table table<integer, any> @ 以每个playerID为键的数据数组

-- TODO: 重构request机制，不然这个还得手动拿client_reply
@param players ServerPlayer[] @ 需要参与这个框的角色
@param params AskToMiniGameParams @ 各种变量
function Room:askToMiniGame(players, params)




@class AskToCustomDialogParams

@field skill_name string @ 烧条时显示的技能名

@field qml_path string @ 小游戏框关键词

@field extra_data any @ 额外信息，因技能而异了

-- Show a qml dialog and return qml's ClientInstance.replyToServer
-- Do anything you like through this function

-- 调用一个自定义对话框，须自备loadData方法
@param player ServerPlayer @ 询问的角色
@param params AskToCustomDialogParams @ 各种变量
@return string @ 格式化字符串，可能需要json.decode
function Room:askToCustomDialog(player, params)




@class AskToMoveCardInBoardParams

@field target_one ServerPlayer @ 移动的目标1玩家

@field target_two ServerPlayer @ 移动的目标2玩家

@field skill_name string @ 技能名

@field flag? "e" | "j" @ 限定可移动的区域，值为nil（装备区和判定区）、‘e’或‘j’

@field move_from? ServerPlayer @ 移动来源是否只能是某角色

@field exclude_ids? integer[] @ 本次不可移动的卡牌id

@field skip? boolean @ 是否跳过移动。默认不跳过

询问移动场上的一张牌。不可取消
@param player ServerPlayer @ 移动的操作者
@param params AskToMoveCardInBoardParams @ 各种变量
@return { card: Card | integer, from: ServerPlayer, to: ServerPlayer }? @ 选择的卡牌、起点玩家id和终点玩家id列表
function Room:askToMoveCardInBoard(player, params)





@class AskToChooseToMoveCardInBoardParams: AskToUseActiveSkillParams

@field flag? "e" | "j" @ 限定可移动的区域，值为nil（装备区和判定区）、‘e’或‘j’

@field exclude_ids? integer[] @ 本次不可移动的卡牌id

@field froms? ServerPlayer[] @ 移动来源角色列表

@field tos? ServerPlayer[] @ 移动目标角色列表

询问一名玩家选择两名角色，在这两名角色之间移动场上一张牌
@param player ServerPlayer @ 要做选择的玩家
@param params AskToChooseToMoveCardInBoardParams @ 各种变量
@return ServerPlayer[] @ 选择的两个玩家的列表，若未选择，返回空表
function Room:askToChooseToMoveCardInBoard(player, params)





改变玩家的护甲数
@param player ServerPlayer
@param num integer @ 变化量
function Room:changeShield(player, num)




-- 杂项函数

function Room:adjustSeats()



令两名玩家交换座位
@param a ServerPlayer @ 玩家1
@param b ServerPlayer @ 玩家2
@param arrange_turn? boolean @ 是否更新本轮额定回合，默认是
function Room:swapSeat(a, b, arrange_turn)




将一名玩家移动至指定座位
@param player ServerPlayer @ 被移动的玩家
@param seat integer @ 目标座位
@param arrange_turn? boolean @ 是否更新本轮额定回合，默认是
function Room:moveSeatTo(player, seat, arrange_turn)





将一名玩家移动至某人的下家/上家
@param player ServerPlayer @ 被移动的玩家
@param target ServerPlayer @ 目标玩家，移动成为这个玩家的下家（例如target为8号位，则移动后target为7号位，player为8号位）
@param is_last boolean? @ 是否移动成为这个玩家的上家，默认否
@param arrange_turn? boolean @ 是否更新本轮额定回合，默认是
function Room:moveSeatToNext(player, target, is_last, arrange_turn)




按输入的角色表重新改变本轮额定回合。若无输入则更新本轮剩余额定回合
@param players? ServerPlayer[]
function Room:arrangeTurn(players)




按输入的角色表重新改变座位。若无输入，仅更新角色座位UI
@param players? ServerPlayer[]
function Room:arrangeSeats(players)



洗牌。
function Room:shuffleDrawPile()



-- 强制同步牌堆（用于在不因任何移动事件且不因洗牌导致的牌堆变动）
function Room:syncDrawPile()



结束一局游戏。
@param winner string @ 获胜的身份，空字符串表示平局
function Room:gameOver(winner)




获取一局游戏的总结，包括每个玩家的回合数、回血、伤害、受伤、击杀
@return table<integer, integer[]> @ 玩家id到总结的映射
function Room:getGameSummary()




获取可以移动场上牌的第一对目标。用于判断场上是否可以移动的牌
@param flag? "e"|"j" @ 判断移动的区域
@param players? ServerPlayer[] @ 可被移动的玩家列表
@param excludeIds? integer[] @ 不能移动的卡牌id
@param targets? ServerPlayer[] @ 可移动至的玩家列表，默认为```players```
@return ServerPlayer[] @ 第一对玩家列表，第一个是来源，第二个是目标 可能为空表
function Room:canMoveCardInBoard(flag, players, excludeIds, targets)




现场印卡。当然了，这个卡只和这个房间有关。
@param name string @ 牌名
@param suit? Suit @ 花色
@param number? integer @ 点数
@return Card
function Room:printCard(name, suit, number)




刷新使命技状态
@param player ServerPlayer
@param skillName string
@param failed? boolean
function Room:updateQuestSkillState(player, skillName, failed)




废除区域
@param player ServerPlayer @ 被废除区域的玩家
@param playerSlots string | string[] @ 被废除区域的名称
function Room:abortPlayerArea(player, playerSlots)




恢复区域
@param player ServerPlayer
@param playerSlots string | string[]
function Room:resumePlayerArea(player, playerSlots)




@param player ServerPlayer
@param playerSlots string | string[]
function Room:addPlayerEquipSlots(player, playerSlots)




@param player ServerPlayer
@param playerSlots string | string[]
function Room:removePlayerEquipSlots(player, playerSlots)



@param player ServerPlayer
@param playerSlots string[]
function Room:setPlayerEquipSlots(player, playerSlots)




设置休整
@param player ServerPlayer
@param roundNum integer
function Room:setPlayerRest(player, roundNum)




结束当前回合（不会终止结算）即结束当前阶段，且不执行本回合之后的阶段
function Room:endTurn()




--清理遗留在处理区的卡牌
@param cards? integer[] @ 待清理的卡牌。不填则清理处理区所有牌
@param skillName? string @ 技能名
function Room:cleanProcessingArea(cards, skillName)




为角色或牌的表型标记添加值
@param sth ServerPlayer|Card @ 更新标记的玩家或卡牌
@param mark string @ 标记的名称
@param value any @ 要增加的值
function Room:addTableMark(sth, mark, value)




为角色或牌的表型标记添加值，若已存在则不添加
@param sth ServerPlayer|Card @ 更新标记的玩家或卡牌
@param mark string @ 标记的名称
@param value any @ 要增加的值
@return boolean @ 是否添加成功
function Room:addTableMarkIfNeed(sth, mark, value)




为角色或牌的表型标记移除值，移为空表后重置标记值为0
@param sth ServerPlayer|Card @ 更新标记的玩家或卡牌
@param mark string @ 标记的名称
@param value any @ 要移除的值
@return boolean @ 是否移除成功(若标记中未含此值则移除失败)
function Room:removeTableMark(sth, mark, value)




@alias TempMarkSuffix "-round" | "-turn" | "-phase"

无效化技能
@param player ServerPlayer @ 技能被无效的角色
@param skill_name string @ 被无效的技能
@param temp? TempMarkSuffix|"" @ 作用范围，``-round`` ``-turn`` ``-phase``或不填
@param source_skill? string @ 控制失效与否的技能。（保证不会与其他控制技能互相干扰）
function Room:invalidateSkill(player, skill_name, temp, source_skill)




有效化技能
@param player ServerPlayer @ 技能被有效的角色
@param skill_name string @ 被有效的技能
@param temp? TempMarkSuffix|"" @ 作用范围，``-round`` ``-turn`` ``-phase``或不填
@param source_skill? string @ 控制生效与否的技能。（保证不会与其他控制技能互相干扰）
function Room:validateSkill(player, skill_name, temp, source_skill)




将触发技或状态技添加到房间
@param skill Skill|string
function Room:addSkill(skill)



检查房间是否已经被加入了触发技或状态技
@param skill Skill|string
@return boolean
function Room:hasSkill(skill)




在判定或使用流程中，将使用或判定牌应用锁视转化，发出战报，并返回转化后的牌
@param id integer @ 牌id
@param player ServerPlayer @ 使用者或判定角色
@param JudgeEvent boolean? @ 是否为判定事件
@return Card @ 返回应用锁视后的牌
function Room:filterCard(id, player, JudgeEvent)



进行待执行的额外回合
function Room:ActExtraTurn()



获得一名角色的客户端手牌顺序
本bug由玄蝶提供
@param player ServerPlayer @ 角色
@return integer[] @ 卡牌ID，有元素检测就是了……
function Room:getPlayerClientCards(player)




同步一名角色的客户端手牌顺序
本bug由玄蝶提供
@param player ServerPlayer @ 角色
@return integer[] @ 卡牌ID，有元素检测就是了……
function Room:syncPlayerClientCards(player)




禁止排序手牌，在此时点，客户端手牌顺序将应用于服务端手牌顺序
@param player ServerPlayer @ 角色
@param suffix string? @ 后缀，如“-turn”
function Room:banSortingHandcards(player, suffix)




解禁排序手牌，配合banSortingHandcards使用。
@param player ServerPlayer @ 角色
@param suffix string? @ 后缀，如“-turn”，一般是你用banSortingHandcards时填入的后缀
function Room:unbanSortingHandcards(player, suffix)

