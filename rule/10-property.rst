特殊状态改变
===========

属性值变化
------

属性值变化是指在游戏中，角色的某些属性值发生变化，
比如角色的武将牌改变，势力改变等。

::

  （主效果）
  以改变者为承担者，触发“属性改变前”
  fk.BeforePropertyChange    @属性改变前

  以改变者为承担者，触发“属性改变时”
  （若本时机中返回ture，则本事件与后续此事件流程终止）
  fk.PropertyChange    @属性改变时

  以改变者为承担者，触发“属性改变后”
  fk.AfterPropertyChange   @属性改变

  三个时机的data均为PropertyChangeData，继承PropertyChangeDataSpec

  以翻面者为承担者，触发“武将牌翻面变化前”
  fk.BeforeTurnOver   @武将牌翻面变化前
  （若该时机的data.prevented为true，则本事件与后续此事件流程终止）

  以翻面者为承担者，触发“武将牌翻面变化后”

  fk.TurnedOver     @武将牌翻面变化后

  两个翻面时机的
  data = {
      who = self,
      reason = 令其翻面的技能名 or "game_rule",
    }

::

翻面
------

翻面的角色会在他们的回合开始前，跳过其回合的所有阶段
一般由“武将角色技能”触发。
这个总的动作流程如下：

::

  以翻面者为承担者，触发“武将牌翻面变化前”
  fk.BeforeTurnOver   @武将牌翻面变化前
  （若该时机的data.prevented为true，则本事件与后续此事件流程终止）

  以翻面者为承担者，触发“武将牌翻面变化后”

  fk.TurnedOver     @武将牌翻面变化后

  两个翻面时机的data可以为任意值，默认值为
  data = {
      who = self,
      reason = 令其翻面的技能名 or "game_rule",
    }

连环
-----

连环时机在触发铁索连环技能时触发，

::

  （主效果）
  以连环者为承担者，触发“连环状态改变前”
  fk.BeforeChainStateChange  @连环状态改变前
  （若该时机的data.prevented为true，则本事件与后续此事件流程终止）

  以连环者为承担者，触发“连环状态改变后”

  fk.ChainStateChanged @连环状态改变后

  两个连环时机的data可以为任意值，默认值为
  data = {
    who = self,
    reason = 触发连环的技能名 or "game_rule",
  }


::


洗牌
-----
在牌堆洗牌时触发的时机

::

  fk.AfterDrawPileShuffle  @牌堆洗牌后

  本时机无触发者，无data数据
::

RequestAsk
----------

请求询问时机，在角色请求询问时触发，

::

  （主效果）  
  以请求者为承担者，触发“请求询问前”
  fk.BeforeRequestAsk    @请求询问前

  以请求者为承担者，触发“请求询问时”
  fk.AfterRequestAsk    @请求询问后

  两个请求询问时机的data均为Request对象，无触发对象，仅仅在refresh函数中使用

::


卡牌展示
--------

在角色展示卡牌时触发的时机

::

  （主效果）
  以展示者为承担者，触发“卡牌展示后”
  fk.CardShown   @卡牌展示后

  data为CardShownData类型

::


区域变化
--------

在角色的区域废除或者恢复时

::
  （主效果）
  以变化者为承担者，触发“区域废除后”
  fk.AreaAborted   @区域废除后

  以变化者为承担者，触发“区域恢复后”
  fk.AreaResumed   @区域恢复后

  两个区域变化时机的data均为AreaAbortResumeData

::


武将牌明置或暗置
-----------------

武将牌的明置或暗置 触发的时机

::

  （主效果）
  以明置者为承担者，触发“武将牌明置时”
  fk.GeneralShown   @武将牌明置时
  
  注意，在本时机不应该触发技能

  以明置者为承担者，触发“武将牌明置后”
  fk.GeneralRevealed   @武将牌明置后

  明置时机的data为ShowGeneralData


  以暗置者为承担者，触发“武将牌暗置时”
  fk.GeneralHidden   @武将牌暗置时

  暗置时机的data为执行暗置武将牌的代码名称

::