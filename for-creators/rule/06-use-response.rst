使用与打出
=============

使用牌事件
------------

使用牌事件携带的数据包含下列要素：

- 使用者
- 使用的牌
- 指定的目标
- 目标卡牌
- 响应何种事件（若有目标卡牌）
- 对哪些目标无效
- 是否不计次数
- 令哪些目标不可响应
- 令哪些目标不可抵消
- 额外增加的伤害基数
- 额外增加的回复基数

::

  （主效果）
  某些牌有预使用效果，若有先执行预使用效果
  以使用者为承担者，触发时机“使用牌前”
  （若在触发本时机技能的on_use函数中return true则导致本事件与后续此事件流程终止）
  fk.PreCardUse   @使用牌前

  将此牌或此牌的子卡移动到处理区
  若不是不计次数的，则增加使用计数

  以使用者为承担者，触发时机“声明使用牌后”
  fk.AfterCardUseDeclared     @声明使用牌后

  以使用者为承担者，触发时机“声明目标后”
  fk.AfterCardTargetDeclared   @声明目标后

  以使用者为承担者，触发时机“使用牌时”
  fk.CardUsing    @使用卡牌时

  data为UseCardData，继承UseCardDataSpec。



  若此牌不是用来响应其他牌的，且指定了角色为目标，则:
    对所有目标依次执行:
      以使用者为承担者，触发“指定目标时”（可能修改使用信息）
      fk.TargetSpecifying   @指定目标时

    对所有目标依次执行:
      以目标为承担者，触发“成为目标时”（可能修改使用信息）
      fk.TargetConfirming    @成为目标时

    对所有目标依次执行:
      以使用者为承担者，触发“指定目标后”
      fk.TargetSpecified       @指定目标后

    对所有目标依次执行:
      以目标为承担者，触发“成为目标后”
      fk.TargetConfirmed      @成为目标后

   目标相关类时机的data为AimData，继承AimDataSpec。

  以使用者为承担者，触发时机“使用牌时”
  fk.BeforeCardUseEffect    @卡牌使用效果前
  使用牌的时机data均为UseCardData，继承UseCardDataSpec。


  若使用的是装备牌，则目标装备该装备，会替换原有装备
  否则若使用的是延时锦囊牌，则将此牌置入目标判定区
  除此之外的情况:
    若是用来响应其他牌的:
      进行卡牌生效事件
    否则:
      对卡牌的所有目标，依次进行卡牌生效事件

::

  （清理效果）
  以使用者为承担者，触发“卡牌使用结算完成后”
  fk.CardUseFinished     @卡牌使用结算完成后
  data为UseCardData，继承UseCardDataSpec。

  若使用的牌仍在处理区/仍有处于处理区的子卡，则
    将这些牌移入弃牌堆
    

卡牌生效事件
--------------

::


  ※途中若卡牌效果被抵消，或目标已死亡，则事件直接结束。
  ※效果被抵消时，触发“卡牌效果被抵消”
  （若在触发本时机技能的on_use函数中return true则导致此次抵消无效）
  fk.CardEffectCancelledOut   @卡牌效果被抵消

  以使用者为承担者，触发“卡牌预生效”
  （此时也是使用闪、无懈等牌的时机）
  （若在触发本时机技能的on_use函数中return true则导致效果被抵消）
  fk.PreCardEffect  @卡牌预生效

  以目标为承担者，触发“卡牌生效前”
  （若在触发本时机技能的on_use函数中return true则导致本事件与后续此事件流程终止）
  fk.BeforeCardEffect  @卡牌生效前

  以目标为承担者，触发“卡牌生效时”
  （若在触发本时机技能的on_use函数中return true则导致本事件与后续此事件流程终止）
  fk.CardEffecting   @卡牌生效时

  根据卡牌上绑定的技能，进行技能生效事件，此时正式执行卡牌的效果

  以目标为承担者，触发“卡牌生效后”
  （若在触发本时机技能的on_use函数中return true则导致本事件与后续此事件流程终止）
  fk.CardEffectFinished   @卡牌生效后



  卡牌效果类时机的data为CardEffectData，继承CardEffectDataSpec

  
打出牌事件
------------

::

  （主效果）
  以打出者为承担者，触发“打出卡牌前”
  （若在触发本时机技能的on_use函数中return true则导致本事件与后续此事件流程终止）
  fk.PreCardRespond   @打出卡牌前

  将打出的牌移动到处理区
  以打出者为承担者，触发“打出卡牌后”
  fk.CardResponding   @打出卡牌后

::

  （清理效果）
  以打出者为承担者，触发“卡牌打出结算完成后”
  fk.CardRespondFinished @卡牌打出结算完成后

  若打出的牌仍在处理区/仍有处于处理区的子卡，则
    将这些牌移入弃牌堆
  打出牌事件的所有data类型均为RespondCardData，继承RespondCardDataSpec



询问卡牌的使用或者打出
----------------------

::  

  以询问者为承担者，触发“询问卡牌使用时”
  fk.AskForCardUse   @询问卡牌使用时

  以询问者为承担者，触发“询问卡牌打出时”
  fk.AskForCardResponse   @询问卡牌打出时

  以询问者为承担者，触发“处理询问卡牌使用或打出时”
  fk.HandleAskForPlayCard   @处理询问卡牌使用或打出时

  以询问者为承担者，触发“询问卡牌使用后”
  fk.AfterAskForCardUse   @询问卡牌使用后

  以询问者为承担者，触发“询问卡牌打出后”
  fk.AfterAskForCardResponse  @询问卡牌打出后

  以询问者为承担者，触发“询问无懈可击后”
  fk.AfterAskForNullification   @询问无懈可击后

  询问的data类型均为AskForCardData

::
