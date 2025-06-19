濒死与死亡
============

濒死
-----

::

  （主效果）
  以濒死角色为承担者，触发“进入濒死时”
  fk.EnterDying  @进入濒死时

  对所有存活角色依次进行：
    以其为承担者，触发“求桃时”
    fk.AskForPeaches   @求桃时

    向其询问是否对濒死角色使用桃，濒死的角色还可使用酒
    若已救活，则退出循环
  以濒死角色为承担者，触发“求桃完成后”
  fk.AskForPeachesDone   @求桃完成后

  若濒死角色体力值仍不大于0，则死亡

::

  （后续效果）
  以濒死角色为承担者，触发“脱离濒死后”
  fk.AfterDying    @脱离濒死后

  濒死相关时机的data为DyingData，继承DyingDataSpec

死亡
-----

::

  （前置判断）
  若该角色已死亡，则判断不通过

::

  （主效果）
  以死者为承担者，触发“游戏结束判定前”
  fk.BeforeGameOverJudge    @在游戏结束判定前

  将该角色设为已死亡
  以死者为承担者，触发“游戏结束判定时”
  fk.GameOverJudge  @游戏结束判定时

  以死者为承担者，触发“死亡时”
  fk.Death   @死亡时

  以死者为承担者，触发“埋葬死者时”
  fk.BuryVictim   @埋葬死者时

  以死者为承担者，触发“死亡后”
  fk.Deathed   @死亡后
  
  死亡结算时机的data为DeathData，继承DeathDataSpec

复活
-----

::

  将死者复活
  以死者为承担者，触发“复活后”
  fk.AfterPlayerRevived   @角色复活后
  
  复活结算时机的data为ReviveData，继承ReviveDataSpec