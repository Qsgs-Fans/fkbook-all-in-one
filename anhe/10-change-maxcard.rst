手牌上限修改
==========

当我们知道怎样创建技能的时候，忽然发现了一个很诱人的技能类型：手牌上限技。要知道手牌上限对于一个武将来说那实在是太重要了，它直接影响了武将的存关键牌能力以及回合外防御能力。
前面我们已经知道，创建一个手牌上限技需要用到的函数是:  ``fk.CreateMaxCardsSkill``, 它的原型是：

.. code:: lua

  fk.CreateMaxCardsSkill{
    name = "xxx",
    correct_func = xxx,
  }

其中correct_func作为规定如何修改手牌上限的函数，原型是 ``function(self, player)``。
这里，self自然就是技能本身了，target则表示被修改了手牌上限的那个角色。这两个参数的存在有了让我们动态改变手牌上限的可能。当然，如果上限的改变量始终是一个常数，比如手牌上限始终+3之类的，直接返回那个数值3就可以啦。

现在我们打算设计这样的一个技能：“神通：锁定技，你的手牌上限为当前体力值的2倍。”

获取体力值的方法是调用Player的成员hp，即player.hp。
悄悄地告诉自己：获取体力上限的方法则是它的成员maxHp，即player.maxHp。
由于手牌上限是体力值的2倍，也就是在原来的基础上加上体力值，因此我们可以先获取到当前的体力值，然后返回这个体力值就好了。

不过需要注意的一点是，在手牌上限修改之前应当先进行技能判定，只有对拥有这个技能的角色才可以产生修改的效果。否则的话，全场所有人的手牌上限就都被改掉喽～

代码如下：
.. code:: lua

  LuaShentong = fk.CreateMaxCardsSkill{
    name = "lua_shentong",
    correct_func = function(self, player)
      if player:hasSkill(self) then
        return player.hp
      end
    end,
  }


