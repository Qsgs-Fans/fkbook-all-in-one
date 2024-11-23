濒死与死亡
============

濒死
-----

::

  （主效果）
  以濒死角色为承担者，触发“进入濒死时”
  fk.EnterDying = 38 @进入濒死时

  对所有存活角色依次进行：
    以其为承担者，触发“求桃时”
    （若在触发本时机技能的on_use函数中return true则导致本流程终止并进入下一流程）
    fk.AskForPeaches = 59  @求桃时

    向其询问是否对濒死角色使用桃，濒死的角色还可使用酒
    若已救活，则退出循环
  以濒死角色为承担者，触发“求桃完成后”
  fk.AskForPeachesDone = 60  @求桃完成后

  若濒死角色体力值仍不大于0，则死亡

::

  （后续效果）
  以濒死角色为承担者，触发“脱离濒死后”
  fk.AfterDying = 40   @脱离濒死后

  濒死相关时机的data为DyingStruct，详情参考解析:TriggerData中的DyStruct。

死亡
-----

::

  （前置判断）
  若该角色已死亡，则判断不通过

::

  （主效果）
  以死者为承担者，触发“游戏结束判定前”
  fk.BeforeGameOverJudge = 64   @在游戏结束判定前

  将该角色设为已死亡
  以死者为承担者，触发“游戏结束判定时”
  fk.GameOverJudge = 65 @游戏结束判定时

  以死者为承担者，触发“死亡时”
  fk.Death = 61  @死亡时

  以死者为承担者，触发“埋葬死者时”
  fk.BuryVictim = 62  @埋葬死者时

  以死者为承担者，触发“死亡后”
  fk.Deathed = 63  @死亡后
  
  死亡结算时机的data为DeathStruct，详情查看解析:TriggerData中的DeathStruct

复活
-----

::

  将死者复活
  以死者为承担者，触发“复活后”
  fk.AfterPlayerRevived = 95  @角色复活后
  
  复活结算时机的data={reason＝reason},此处的reason值一般为"rest",也可以为技能名。