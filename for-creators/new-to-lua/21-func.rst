Lua：函数
==========

在本节中，我们将学习编写函数。函数就是一个带有名字的代码块，用来完成具体的工作。

定义函数
----------

下面是一个打印问候语的简单函数：

.. code:: lua

   local greet = function()
     print("Hello!")
   end

   greet()

这个实例演示了最简单的函数结构。第一行使用关键字 ``function`` 来告诉Lua你要定义一个函数。
这是 *函数定义* ，向Lua指出了函数名，还可能在括号内指出函数为完成其任务需要什么样的信息。
在这里，函数名为greet()，它不需要任何信息就能完成其工作，因此括号是空的（即便如此,括号也必不可少）。

紧跟在第一行之后的那个代码块被称为 *函数体* 。代码行 ``print("Hello!")`` 是函数体内的唯一一行代码，
greet()只做一项工作：打印Hello!。

要使用这个函数，可调用它。函数调用让Lua执行函数的代码。要调用函数，
可依次指定函数名以及用括号括起的必要信息。由于这个函数不需要任何信息，
因此调用它时只需输入greet()即可。和预期的一样，它打印Hello!。

.. hint::

   注意函数定义的语法其实是和定义变量一样： ``local xxx = xxx`` 。
   事实上，Lua函数本质上是变量值的一种。如果你执行 ``print(greet)`` 的话会输出类似
   function: 0xdeadbeef 之类的信息。

向函数传递信息
~~~~~~~~~~~~~~~

只需稍作修改，就可以让函数greet()不仅向用户显示Hello!，还将用户的名字也一起问候出来。
为此，可在函数定义 ``local greet = function()`` 的括号内添加 username。
通过在这里添加username，就可让函数接受你给username指定的任何值。现在，
这个函数要求你调用它时给username指定一个值。调用greet()时，可将一个名字传递给它，如下所示：

.. code:: lua

   local greet = function(username)
     print("Hello, " .. username .. "!")
   end

   greet("notify")

代码 ``greet("notify")`` 调用了函数greet()，并提供函数需要的信息。这个函数接受你传给他的名字，
并发出问候：Hello, notify!

实参与形参
~~~~~~~~~~

前面定义函数greet()时，要求给变量username指定一个值。
调用这个函数并提供这种信息(人名)时，它将打印相应的问候语。

在函数greet()的定义中，变量username是一个 *形参* ——函数完成其工作所需的一项信息。
在代码 ``greet("notify")`` 中，值"notify"是一个 *实参* 。实参是调用函数时传递给函数的信息。
我们调用函数时，将要让函数使用的信息放在括号内。在 ``greet("notify")`` 中，
将实参 "notify" 传递给了函数greet()，这个值被存储在形参username中。

.. hint::

  大家有时候会形参、实参不分,因此如果你看到有人将函数定义中的变量称为实参或将\
  函数调用中的变量称为形参,不要大惊小怪。

传递实参
---------

鉴于函数定义中可能包含多个形参,因此函数调用中也可能包含多个实参。在Lua中，\
向函数传递实参要求实参的顺序与形参的顺序相同。下面举例介绍这种方式。

位置实参
~~~~~~~~~

你调用函数时, Lua必须将函数调用中的每个实参都关联到函数定义中的一个形参。
下面我们来看一个显示武将信息的函数：

.. code:: lua

   --- 显示武将信息。
   --- @param package string @ 所属的扩展包
   --- @param name string @ 武将代码名称
   --- @param kingdom string @ 武将所属势力
   --- @param hp number @ 武将初始血量
   local describe=function(package, name, kingdom, hp) end

   describe(extensionName,"st__sunwukong","god",5)

这个函数定义了五个形参：package, name, kingdom, hp, maxHp, gender。
调用这个函数时，必须按照这个顺序提供实参。
可以看见如果我们换个顺序调用这个函数，就会报错：

.. code:: lua

   --- 显示武将信息。
   --- @param package string @ 所属的扩展包
   --- @param name string @ 武将代码名称
   --- @param kingdom string @ 武将所属势力
   --- @param hp number @ 武将初始血量
   local describe=function(package, name, kingdom, hp, maxHp, gender) end

   describe(extensionName,5,"god","st__sunwukong")

这么写就会报错，因为我们的第二个参数是name，在他定义的时候，我们name所对应的类型是string，而5是number类型
实参与形参的类型不同就会导致报错。

可选实参
~~~~~~~~~

有些时候，函数的某些参数是可选的。在这种情况下，我们可以给这些参数指定默认值。

.. code:: lua

   --- 显示武将信息。
   --- @param package string @ 所属的扩展包
   --- @param name string @ 武将代码名称
   --- @param kingdom string @ 武将所属势力
   --- @param hp number @ 武将初始血量
   --- @param maxHp? number @ 武将最大血量
   --- @param gender? string @ 武将性别
   local describe=function(package, name, kingdom, hp, maxHp, gender)
     if maxHp == nil then
       maxHp = hp
     end
     if gender == nil then
       gender = General.Male
     end
    end
  
    describe(extensionName,"st__sunwukong","god",5)

这样的话，即使我们在调用函数时不提供maxHp和gender的值，函数也能正常运行。

可变参数
~~~~~~~~~

有时，函数可能需要接受任意数量的实参。在这种情况下，我们可以用可变参数来表示。

.. code:: lua

   --- 显示武将信息。
   --- @param package string @ 所属的扩展包
   --- @param name string @ 武将代码名称
   --- @param kingdom string @ 武将所属势力
   --- @param hp number @ 武将初始血量
   --- @param maxHp number @ 武将最大血量
   --- @param gender string @ 武将性别
   --- @param ... any @ 任意数量的实参
   local describe = function(package, name, kingdom, hp, maxHp, gender, ...)
     if maxHp == nil then
       maxHp = hp
     end
     if gender == nil then
       gender = General.Male
     end

     -- 获取额外参数的数量
     local extraArgsCount = select("#", ...)
     print("额外参数的数量:", extraArgsCount)

     -- 使用额外参数
     for i = 1, extraArgsCount do
       local arg = select(i, ...)
       print("额外参数 " .. i .. ":", arg)
     end
   end

   describe("extensionName", "st__sunwukong", "god", 5, 5, General.Male, "武将", "技能1", "技能2")


这里，我们在函数定义中用三个点（``...``）来表示可变参数。select()函数可以用来获取额外参数的数量。
调用这个describe函数时，可以传入任意数量的实参。

返回值
------

函数可以返回一个值。在Lua中，函数的返回值有两种类型：

- 无返回值：函数执行完毕后，没有任何返回值。
- 有返回值：函数执行完毕后，返回一个值。

无返回值
~~~~~~~~

.. code:: lua

   --- 显示武将信息。
   --- @param package string @ 所属的扩展包
   --- @param name string @ 武将代码名称
   --- @param kingdom string @ 武将所属势力
   --- @param hp number @ 武将初始血量
   --- @param maxHp number @ 武将最大血量
   --- @param gender string @ 武将性别
   --- @return nil
   local describe=function(package, name, kingdom, hp, maxHp, gender)
     if maxHp == nil then
       maxHp = hp
     end
     if gender == nil then
       gender = General.Male
     end
   end

   describe(extensionName,"st__sunwukong","god",5,100,General.Male)

这里，函数describe()没有返回值，因此调用它时，不需要使用关键字return。

有返回值
~~~~~~~~

.. code:: lua

   --- 计算两个数的和。
   --- @param a number @ 第一个数
   --- @param b number @ 第二个数
   --- @return number @ 两个数的和
   local add=function(a, b)
     return a + b
   end

   local result=add(10, 20)
   print(result)

这里，函数add()有返回值，因此调用它时，需要使用关键字return。

函数的返回值可以是任何类型，包括nil、布尔值、字符串、数字、表、函数等。

函数的返回值可以被赋给一个变量，也可以作为表达式的一部分。

.. code:: lua

   --- 计算两个数的和。
   --- @param a number @ 第一个数
   --- @param b number @ 第二个数
   --- @return number @ 两个数的和
   local add=function(a, b)
     return a + b
   end

   local result=add(10, 20)
   local sum=result + 100
   print(sum)

这里，我们将函数add()的返回值赋给变量result，然后再加上100，得到的结果是300。

函数的返回值也可以作为另一个函数的实参。

.. code:: lua

   --- 计算两个数的和。
   --- @param a number @ 第一个数
   --- @param b number @ 第二个数
   --- @return number @ 两个数的和
   local add=function(a, b)
     return a + b
   end

   --- 计算两个数的差。
   --- @param a number @ 第一个数
   --- @param b number @ 第二个数
   --- @return number @ 两个数的差
   local sub=function(a, b)
     return a - b
   end

   local result=add(10, 20)
   local diff=sub(result, 50)
   print(diff)

这里，我们定义了另一个函数sub()，它接受两个参数，并返回它们的差。
我们调用add()函数，得到结果为30，然后将这个结果作为实参传递给sub()函数，得到的结果是20。

函数的调用方式
--------------

在Lua中，函数的调用方式有两种：

- 点调用：``obj.func(obj,arg1, arg2,...)``
- 冒号调用：``obj:func(arg1, arg2,...)``
点调用和冒号调用的区别在于：

- 点调用的第一个参数是对象本身，冒号调用的第一个参数是对象的方法。
- 点调用可以访问对象的私有方法，冒号调用只能访问对象的公有方法。
- 点调用可以访问对象的属性，冒号调用只能访问对象的公有属性。

在Lua中，函数调用的语法是：

.. code:: lua

   ---@class MyClass:Object
   ---@field name string
   ---@field age number


   function Myclass.func(self,arg1, arg2,...)
   function MyClass:func(arg1, arg2, ...)

这两种函数的参数都是一样的，都是以 ``self`` 作为第一个参数，但是冒号调用时会自动将冒号前面的对象作为第一个实参。
而点调用则仍然需要我们手动去写。

常用函数的\ ``table:map()``\ （虽然是table的函数，但实际上这不是lua原生的函数）的原型如下：

.. code-block:: lua

	---@param func fun(element, index, array): any
	function table:map(func)

但是实际上大家调用函数时，使用的不是\ ``tableA:map(...)``\ ，而是\ ``table.map(tableA, ...)``\ 。
关于什么时候可以/不可以用冒号\ ``:``\ 调用函数，这涉及到Lua库对一些自定义类型的特殊处理，这里不再赘述。

总而言之，日常编程时，除了调用table的函数需要用英文句号\ ``.``\ 以外，
其他地方用\ ``:``\ 调用函数会将自身传入函数的第一个参数（如果函数自身就是用冒号声明的话就是单独的一个\ ``self``\ 变量（这也是这个函数的真正的“第一个参数”））。
