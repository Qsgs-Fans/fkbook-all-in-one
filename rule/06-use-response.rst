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
  fk.PreCardUse = 41   @使用牌前

  将此牌或此牌的子卡移动到处理区
  若不是不计次数的，则增加使用计数

  以使用者为承担者，触发时机“声明使用牌后”
  fk.AfterCardUseDeclared = 42    @声明使用牌后

  以使用者为承担者，触发时机“声明目标后”
  fk.AfterCardTargetDeclared = 43  @声明目标后

  以使用者为承担者，触发时机“使用牌时”
  fk.CardUsing = 44   @使用卡牌时

  使用牌的时机data为CardUseStruct。具体参考解析TriggerData中的CardUseStruct

  若此牌不是用来响应其他牌的，且指定了角色为目标，则:
    对所有目标依次执行:
      以使用者为承担者，触发“指定目标时”（可能修改使用信息）
      fk.TargetSpecifying = 46   @指定目标时

    对所有目标依次执行:
      以目标为承担者，触发“成为目标时”（可能修改使用信息）
      fk.TargetConfirming = 47   @成为目标时

    对所有目标依次执行:
      以使用者为承担者，触发“指定目标后”
      fk.TargetSpecified = 48      @指定目标后

    对所有目标依次执行:
      以目标为承担者，触发“成为目标后”
      fk.TargetConfirmed = 49     @成为目标后

   目标相关类时机的data为AimStruct。具体参考解析TriggerData里面的AimStruct。


  以使用者为承担者，触发时机“卡牌生效前”
  fk.PreCardEffect = 54   @卡牌生效前
  data为CardEffectEvent。具体参考解析TriggerData里面的CardEffectEvent。

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
  fk.CardUseFinished = 50     @卡牌使用结算完成后
  data为CardUseStruct。具体参考解析TriggerData中的CardUseStruct

  若使用的牌仍在处理区/仍有处于处理区的子卡，则
    将这些牌移入弃牌堆
    

卡牌生效事件
--------------

::

  以使用者为承担者，触发“卡牌预生效”
    （此时也是使用闪、无懈等牌的时机）
    （若在触发本时机技能的on_use函数中return true则导致效果被抵消）
    fk.PreCardEffect = 54   @卡牌预生效

  以目标为承担者，触发“卡牌生效前”
  （若在触发本时机技能的on_use函数中return true则导致本事件与后续此事件流程终止）
  fk.BeforeCardEffect = 55  @卡牌生效前

  以目标为承担者，触发“卡牌生效时”
  （若在触发本时机技能的on_use函数中return true则导致本事件与后续此事件流程终止）
  fk.CardEffecting = 56  @卡牌生效时

  根据卡牌上绑定的技能，进行技能生效事件，此时正式执行卡牌的效果

  以目标为承担者，触发“卡牌生效后”
  （若在触发本时机技能的on_use函数中return true则导致本事件与后续此事件流程终止）
  fk.CardEffectFinished = 57  @卡牌生效后

  ※途中若卡牌效果被抵消，或目标已死亡，则事件直接结束。
  ※效果被抵消时，触发“卡牌效果被抵消”
  （若在触发本时机技能的on_use函数中return true则导致此次抵消无效）
  fk.CardEffectCancelledOut = 58  @卡牌效果被抵消

  卡牌效果类时机的data为CardEffectEvent。具体参考解析TriggerData里面的CardEffectEvent。

  
打出牌事件
------------

::

  （主效果）
  以打出者为承担者，触发“打出卡牌前”
  （若在触发本时机技能的on_use函数中return true则导致本事件与后续此事件流程终止）
  fk.PreCardRespond = 51   @打出卡牌前

  将打出的牌移动到处理区
  以打出者为承担者，触发“打出卡牌后”
  fk.CardResponding = 52  @打出卡牌后

::

  （清理效果）
  以打出者为承担者，触发“卡牌打出结算完成后”
  fk.CardRespondFinished = 53  @卡牌打出结算完成后

  若打出的牌仍在处理区/仍有处于处理区的子卡，则
    将这些牌移入弃牌堆
