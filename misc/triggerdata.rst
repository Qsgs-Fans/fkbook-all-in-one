.. SPDX-License-Identifier:	CC-BY-NC-SA-4.0

解析：TriggerData
============================================================

解析：System_enum.lua文件（所有基本data类型）


MoveInfo 一张牌的来源信息
------------------------

cardId integer @本次移动里面的某张牌id

.. note::
    
    例如，弃置了2张牌，此时moveInfo有两个，第一个moveInfo的cardId是第一张弃置的牌的id

fromArea CardArea @这张牌是从哪里开始移动的

fromSpecialName? string @私人牌堆名

.. note::
    
    若fromArea移至私人牌堆Special，那么fromSpecialName则为私人牌堆名，否则不对该属性进行赋值。


CardsMoveStruct 一次完整移动
---------------------------

moveInfo MoveInfo[] @ 移动信息

.. note::
    
    移动信息类的数组，每个卡牌移动事件的data都包含了多个CardsMoveStruct类，
    
    而每个CardsMoveStruct中存放了moveInfo数组，每个moveInfo里面才存放了本次移动牌的牌id。

from? integer @ 移动来源玩家ID，可能为空

to? integer @ 移动终点玩家ID，可能为空

toArea CardArea @ 移动终点区域

.. caution::
    
    类是CardArea，需要填写Card.区域，而不是Player.区域。

moveReason CardMoveReason @ 移动原因

.. note::
    
    详细查看CardMoveReason解析。

proposer? integer @ 产生移动的执行者（player）的id，可能为空

skillName? string @ 产生移动的技能名，可能为空

moveVisible? boolean @ 控制本次移动是否可见，可能为空。

specialName? string @ 移动到私人牌堆时的私人牌堆名，可能为空。

.. note::
    
    若本次移动的终点为PlayerSpecial区域（私人牌堆区域），则此值不为空。

specialVisible? boolean @ 移动至私人牌堆时是否令本次移动可见。

.. note::
    
    本次移动若移动至私人牌堆，此属性可以控制以本次移动是否可见。

drawPilePosition? integer @ 移至牌堆的索引位置

.. note::
    
    值为-1代表置入牌堆底，或者牌堆牌数+1也为牌堆底

moveMark? table|string @ 移动后自动给卡牌标记赋值

.. note::
    
    该属性格式：{标记名(支持-inarea后缀，移出值代表区域后清除), 值}。
    
    这个属性我们可以从中获取到因本次移动后而改变的卡牌标记与其对应的值，且是直接赋值而非增加值，
    
    若moveMark的值是标记名string，则会把该标记值设为1。

visiblePlayers? integer|integer[] @角色id或id数组。 控制移动对特定角色可见

.. caution::
    
    在moveVisible为false时才会生效

CardUseStruct  卡牌使用数据
--------------------------

from integer @ 使用者的id，也就是player的id

tos TargetGroup @ 角色目标组

.. note::
    
    tos里面存放的是{{player1.id},{player2.id}....}，每个tos[1]里面放的是table数据表，

    所以tos[1][1]才能获取到第一个目标的id。

card Card @ 卡牌本牌。

.. note::
    
    指触发使用牌类的时机中的牌。例如，当使用杀时，那么这里的card就指这张正在使用的【杀】。

toCard? Card @ 卡牌目标

.. note::
    
    此属性可为空。toCard是指牌响应牌的情况。例如使用【无懈可击】时，toCard就指被无懈可击响应的那张锦囊。

responseToEvent? CardUseStruct @ 响应事件目标

.. note::
    
    当你直接使用牌而无响应目标时，此属性为空。当你响应一张牌1而使用一张牌2时，

    此事件CardUseStruct就是你因响应而使用的牌2事件。

    而此事件里面的data.responseToEvent就是指你响应的目标角色使用牌1的CardUseStruct事件。

    例如你对一张杀使用了闪。那么data.responseToEvent就是其使用杀的事件。

nullifiedTargets? integer[] @ 对这些角色无效。

.. note::
    
    这是一个角色id构成的数组。当角色A使用牌对角色B无效时，可以往当前事件的data.nullfiedTargets里面加入角色B的id。

extraUse? boolean @ 是否不计入次数。data.extraUse＝true时，使用此牌不计入次数。

disresponsiveList? integer[] @ 这些角色不可响应此牌。与nullifiedTargets用法一致，内容一致。

unoffsetableList? integer[] @ 这些角色不可抵消此牌。与nullifiedTargets用法一致，内容一致。

additionalDamage? integer @ 额外伤害值（如酒之于杀）

.. note::
    
    在使用额外加伤时需要注意此牌是伤害牌且写法为

    data.additionalDamage = (data.additionalDamage or 0) + player.drank。

    而非直接的data.additionalDamage = data.additionalDamage + player.drank

    原因是该属性可能为空也就是nil，而nil是不能参与数值计算的。

additionalRecover? integer @ 额外回复值。

.. note::
    
    与额外加伤用法一致，这是额外回血值，需要注意使用的牌本身为可以回复体力的牌。

extra_data? any @ 额外数据（如目标过滤等）。

.. note::
    
    extra_data更多是作为一个存储的键值表，在本房间内全局存在。

    data.extra_data.键名＝值。需要找回表值时，需要在对应事件的data.extra_data中进行键索引，

    返回其对应的值。关闭房间后会自动清理。

customFrom? integer @ 新使用者

cardsResponded? Card[] @ 响应此牌的牌。

.. note::
    
    此属性里面是响应此牌的牌的数组。一般是在卡牌使用结束时这个时机使用，例如面对杀时使用的全部闪，

    响应南蛮时使用的全部无懈。

prohibitedCardNames? string[] @ 这些牌名的牌不可响应此牌

.. note::
    
    这个属性是一个字符串数组，里面存放的是牌名。

damageDealt? table<PlayerId, number> @ 此牌造成的伤害

.. note::
    
    此属性一般放在fk.CardUseFinished中，是一个{{player1.id,number1}，{player2.id,number2}...}的一个数组，

    该属性一般是已经被赋值后的。

additionalEffect? integer @ 额外结算次数

.. note::
    
    这个属性代表了此牌需要额外结算的次数。正常都是额外结算一次，data.additionalEffect = 1即可。

    而需要额外n次则是，data.additionalEffect = (data.additionalEffect or 0) + n。

noIndicate? boolean @ 隐藏指示线，一般是秘密指定所使用到。


DamageStruct 描述和伤害事件有关的数据。
------------------------------------

from? ServerPlayer @ 伤害来源

.. caution::
    
    该data里面的来源属性名是from而不是who，且from类型为ServerPlayer而非player.id。

    若受到无来源伤害，则该属性为空。from=nil

to ServerPlayer @ 伤害目标

damage integer @ 伤害值

.. note::
    
    造成与受到的伤害值都是damage属性。

card? Card @ 造成伤害的牌

.. note::
    
    若造成/受到本次伤害并非来自卡牌，该属性为空。

.. caution::
    
    虚拟牌也算牌。

chain? boolean @ 伤害是否是铁索传导的伤害

damageType? DamageType @ 伤害的属性

.. note::
    
    DamageType integer

    fk.NormalDamage = 1

    fk.ThunderDamage = 2

    fk.FireDamage = 3

    fk.IceDamage = 4

    若本属性为空则默认为无属性伤害。

skillName? string @ 造成本次伤害的技能名

beginnerOfTheDamage? boolean @ 是否是本次铁索传导的起点

by_user? boolean @ 是否由卡牌直接生效造成的伤害。

chain_table? ServerPlayer[] @ 铁索连环表

.. note::
    
    此属性里面存放的是因本次伤害而产生铁索连环传导的目标们


.. caution::
    
    该属性不包括因此伤害事件的目标，也就是data.to。原因是该属性由铁索连环技能组获取，对横置目标造成伤害。

    而data.to已经受到了本次伤害并解除了连环状态，所以排除data.to。


RecoverStruct 描述和回复体力有关的数据。
-------------------------------------

who ServerPlayer @ 回复体力的角色

num integer @ 回复值

.. caution::
    
    此处为变化量，且仅为不小于1的正数。

recoverBy? ServerPlayer @ 此次回复的回复来源

skillName? string @ 因何种技能而回复

card? Card @ 造成此次回复的卡牌


DyingStruct 描述和濒死事件有关的数据
----------------------------------

who integer @ 濒死角色的id

damage DamageStruct @ 造成此次濒死的伤害数据

.. caution::
    
    这里的伤害数据不仅仅是指类型为damage的伤害，血量调整与失去体力都拥有这个数据。

ignoreDeath? boolean @ 是否不进行死亡结算


DeathStruct 描述和死亡事件有关的数据
----------------------------------

who integer @ 死亡角色的id

damage DamageStruct @ 造成此次死亡的伤害数据

.. note::
    
    参考DyingStruct的damage。


AimStruct 处理使用牌目标的数据
-----------------------------

from integer @ 使用此牌者的id

card Card @ 卡牌本牌，目前被使用的牌

tos AimGroup @ 总角色目标。

.. note::
    
    tos＝{{玩家的id列表}，{}，{}}。所以要获取第一个目标就是data.tos[1][1]，第二个目标是data.tos[1][2]。

to integer @ 当前角色目标

.. note::
    
    这里的to代表了卡牌正在处理的目标角色的id，也就是tos[1]里面的正在处理的id。

    如果想要达到每个目标都执行效果，那么可以直接使用data.to而不用遍历data.tos。

subTargets? integer[] @ 子目标，角色id数组

.. note::
    
    子目标是指，卡牌在原有目标基础上，还需要额外选择一名目标。

    例如借刀杀人，是选择了一名角色发动其效果，然后再根据借刀杀人效果指定另一名角色。

    但是aoe那种不算是子目标，因为在一开始卡牌都已经全部指定了，并没有额外指定。

targetGroup? TargetGroup @ 目标组

.. note::
    
    这里存放的是使用卡牌数据中的tos，也就是卡牌目标组{{player1.id}，{player2.id}...}等。

nullifiedTargets? integer[] @ 对这些角色无效

.. note::
    
    参考CardUseStruct中的此属性。

firstTarget boolean @ 是否是第一个目标

additionalDamage? integer @ 额外伤害值（如酒之于杀）

.. note::
    
    参考CardUseStruct中的此属性。

additionalRecover? integer @ 额外回复值

.. note::
    
    参考CardUseStruct中的此属性。

disresponsive? boolean @ 是否令此牌不可响应

unoffsetable? boolean @ 是否令此牌不可抵消

fixedResponseTimes? table<string, integer>|integer @ 额外响应请求

.. note::
    
    此属性可以更改本次使用的牌所需要响应牌的次数，若无需要响应的牌则为空。

    假设你使用杀需要两张闪才能抵消，可以在on_use中增加此代码data.fixedResponseTimes["jink"]＝2。

fixedAddTimesResponsors? integer[] @ 额外响应请求的角色id数组。

.. note::
    
    该顺序是角色id数组，添加进该属性的角色id在响应其他角色的卡牌时会额外进行响应询问。

    例如无双的目标，会额外询问两次响应【闪】

additionalEffect? integer @额外结算次数

.. note::
    
    该属性是额外效果结算次数，使用时代码可为

    data.additionalEffect = (data.additionalEffect or 0) + n（n为自定义动态变化量）。

    或者data.additionalEffect = n。n为自定义固定变化量。

    当data.additionalEffect=1时，该效果额外结算一次，总共结算2次。


HpChangedData 描述和一次体力变化有关的数据
----------------------------------------

num integer @ 体力变化量，可能是正数或者负数

.. caution::
    
    这是体力变化量，而不是当前体力值。例如，3血受到1点伤害变成2血。这里的data.num为-1而不是2。
    为正代表体力增加量，为负则是体力减少量。

shield_lost integer|nil @ 护甲变化量。

.. caution::
    
    护甲变化量与体力变化量不一样，护甲变化量只有正数，代表了本次事件所失去的护甲值。若体力变化前无护甲则本属性为空。

reason string @ 体力变化原因

.. note::
    
    体力变化原因分为:"loseHp", "damage", "recover"，填写此项时需注意与其他原因string区别开来。

skillName string @ 引起体力变化的技能名

damageEvent? DamageStruct @ 引起这次体力变化的伤害数据。

.. caution::
    
    只有当体力变化原因为"damage"时，此属性才不为空。

preventDying? boolean @ 是否阻止本次体力变更流程引发濒死流程。

.. note::
    
    当此项为true时，本次体力变化后不进入濒死。可以参考周泰。


HpLostData 描述跟失去体力有关的数据
---------------------------------

num integer @ 失去体力的数值

.. caution::
    
    该属性同样是变化量，但是只有正数，代表了失去的体力数量。

skillName string @ 导致本次体力失去的技能名


MaxHpChangedData 描述跟体力上限变化有关的数据
-------------------------------------------

num integer @ 体力上限变化量

.. note::
    
    可为正，可为负。具体参考HpChangedData里面的num。



CardEffectEvent 卡牌效果的数据
-------------------------------------------

from? integer @ 卡牌使用者

to integer @ 卡牌的当前目标id

subTargets? integer[] @ 子目标（借刀！）

tos TargetGroup @ 卡牌目标组

card Card @ 卡牌本牌

toCard? Card @ 卡牌目标

responseToEvent? CardEffectEvent @ 响应事件目标

nullifiedTargets? integer[] @ 对这些角色无效

extraUse? boolean @ 是否不计入次数

disresponsiveList? integer[] @ 这些角色不可响应此牌

unoffsetableList? integer[] @ 这些角色不可抵消此牌

additionalDamage? integer @ 额外伤害值（如酒之于杀）

additionalRecover? integer @ 额外回复值

extra_data? any @ 额外数据（如目标过滤等）

customFrom? integer @ 新使用者

cardsResponded? Card[] @ 响应此牌的牌

disresponsive? boolean @ 是否不可响应

unoffsetable? boolean @ 是否不可抵消

isCancellOut? boolean @ 是否被抵消

fixedResponseTimes? table<string, integer>|integer @ 额外响应请求

fixedAddTimesResponsors? integer[] @ 额外响应请求次数

prohibitedCardNames? string[] @ 这些牌名的牌不可响应此牌

.. note::

    这里的参数效果大部分都可以在CardUseStruct里面找到，故而此处不再赘述。




SkillEffectEvent 技能效果的数据
------------------------------

from integer @ 此技能的使用者id

tos integer[] @ 此技能选择的目标角色id数组

cards integer[] @ 此技能选择的目标卡牌id数组


JudgeStruct 判定的数据
----------------------

who ServerPlayer @ 判定者

card Card @ 当前判定牌

reason string @ 判定原因

.. note::
    
    该属性是引发本次判定的技能名称。

pattern string @ 判定成立条件

skipDrop? boolean @ 是否令本次判定牌不进入弃牌堆


CardResponseEvent 卡牌响应的数据
-------------------------------

from integer @ 响应者id

card Card @ 响应的卡牌

responseToEvent? CardEffectEvent @ 响应事件目标

skipDrop? boolean @ 是否令本次响应的牌不进入弃牌堆

customFrom? integer @ 新响应者


DrawCardStruct 摸牌的数据
------------------------

who ServerPlayer @ 摸牌者

num number @ 摸牌数

skillName string @ 技能名，因什么技能摸牌。

fromPlace "top"|"bottom" @ 摸牌的位置，"top"代表牌堆顶，"bottom"代表牌堆底


TurnStruct 回合事件的数据
------------------------

reason string? @ 当前额外回合的原因，不为额外回合则为game_rule。一般为技能名。

phase_table? Phase[] @ 此回合将进行的阶段，填空则为正常流程。


PindianResult 拼点结果
---------------------

toCard Card @ 被拼点者所使用的牌

winner? ServerPlayer @ 赢家，可能不存在


PindianStruct 拼点的数据
-----------------------

from ServerPlayer @ 拼点发起者

tos ServerPlayer[] @ 拼点目标

fromCard Card @ 拼点发起者拼点牌

results table<integer, PindianResult> @ 结果

.. note::
    
    result里面的键是被拼点者的id，其对应的PindianResult里面的winner则是拼点双方的赢家，也可能是空值。

reason string @ 拼点原因，一般是技能名


UseExtraData 卡牌在使用时的额外要求
---------------------------------

.. caution::

    本数据是在函数Room:askForUseCard中的额外数据，目的是在对目标询问使用卡牌时
    为本次使用增加限制。


must_targets? integer[] @ 必须选择这些目标？（player.id）

include_targets? integer[] @ 必须选其中一个目标？player.id）

exclusive_targets? integer[] @ 只能选择这些目标？(player.id）

bypass_distances? boolean @ 本次使用卡牌无距离限制？

bypass_times? boolean @ 本次使用卡牌无次数限制？

playing? boolean @ (AI专用) 出牌阶段？（正常用不到）


AskForCardUse 询问使用卡牌的数据
---------------------------------

user ServerPlayer @ 使用者

cardName string @ 烧条信息

.. note::    

    此处为需要使用的卡牌名称。若pattern指定了则可随意写，它影响的是烧条的提示信息

pattern string @ 使用牌的规则，默认就是cardName的值

eventData CardEffectEvent @ 事件数据

extraData UseExtraData @ 额外数据

result? CardUseStruct @ 使用结果




AskForCardResponse 询问响应卡牌的数据
------------------------------------
user ServerPlayer @ 响应者

cardName string @ 烧条信息

.. note::
    
    此处为需要响应的卡牌名称。若pattern指定了则可随意写，它影响的是烧条的提示信息

pattern string @ 响应牌的规则，默认就是cardName的值

extraData UseExtraData @ 额外数据

result? Card


SkillUseStruct 使用技能的数据
----------------------------

skill Skill @ 使用的技能

willUse boolean @ 是否会发动




LogMessage 战报信息
-----------------------

.. caution::

    本数据是在添加游戏提示信息时的数据类型，具体内容请参考  制作Lua扩展章节/8. 添加提示信息  中查看

type string @ log主体

from? integer @ 要替换%from的玩家的id

to? integer[] @ 要替换%to的玩家id列表

card? integer[] @ 要替换%card的卡牌id列表

arg? any @ 要替换%arg的内容

arg2? any @ 要替换%arg2的内容

arg3? any @ 要替换%arg3的内容

toast? boolean @ 是否顺手把消息发送一条相同的toast



CardMoveReason integer 移动理由
-------------------------------

fk.ReasonJustMove = 1 @ 仅仅移动

fk.ReasonDraw = 2  @ 摸牌

fk.ReasonDiscard = 3  @  弃牌

fk.ReasonGive = 4  @ 给予

fk.ReasonPut = 5  @ 置入

fk.ReasonPutIntoDiscardPile = 6  @ 置入弃牌堆

fk.ReasonPrey = 7  @ 获取目标

fk.ReasonExchange = 8  @ 交换

fk.ReasonUse = 9  @ 使用

fk.ReasonResonpse = 10  @ 响应

fk.ReasonJudge = 11  @ 判定

fk.ReasonRecast = 12  @ 重铸


AnimationType  string 内置动画类型
-----------------------------------

理论上你可以自定义一个自己的动画类型（big会播放一段限定技动画）

基础动画类型：

-  ``special``\ ：留空anim_type时候的默认特效。看上去像一条龙的特效，一般用于定位模糊的技能。

-  ``drawcard``\ ：看上去像是凤凰展翅的特效，用于主打摸牌的技能。

-  ``control``\ ：看上去像草的特效，用于拆牌等控场类技能。

-  ``offensive``\ ：看上去像火焰的特效，用于菜刀技能或者直伤等攻击性技能。

-  ``support``\ ：看上去像莲花的特效，用于给牌、回血等辅助性技能。

-  ``defensive``\ ：看上去像花的特效，用于防御流技能。

-  ``negative``\ ：看上去像乌云的特效，用于负面技能。

-  ``masochism``\ ：看上去像金色的花的特效，用于卖血类技能。（这个类型取名也是沿用了神杀的恶趣味啊）