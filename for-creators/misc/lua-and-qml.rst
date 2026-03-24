Lua和QML的联动相关
======================

从QML调用Lua
----------------

C++底层为Qml提供了两个调用Lua的方式：直接调用一个全局变量的函数，或者求出某个Lua表达式的值。
在Qml的lua实用库中针对第二个功能进行了层层包装，以提供更好的调用Lua的体验。

由于全局变量并不是推荐的做法，所以就不提了

要使用下列函数，请在Qml文件中加载Fk模块：

.. code:: qml

   import Fk

Lua.tr(str)
~~~~~~~~~~~~

相当于 ``Fk:translate(str)`` ，用于翻译字符串。

Lua.evaluate(str)
~~~~~~~~~~~~~~~~~~~~

针对内容为 ``str`` 的Lua表达式，尝试对其进行求值，该函数的行为如下：

- 若返回了userdata类型或者协程，那么QML无法处理它们，会返回null
- 所有的JSON-like：直接返回对应的js值
- class实例: 返回该实例的js代理对象

  * 这里的class必须是middleclass库的类实例

- class实例的数组：返回js代理对象数组

.. note::

   这里所谓的JSON-like是指可以用 JSON 格式来表示的 Lua 数据结构，
   具体来说就是由以下几种基本类型组合而成的值：

   nil, boolean, string, number, table(对应object和array)

   其中table不可出现循环引用，不可出现类型为number的key（除非是数组）。

有必要说明所谓js代理对象在处理Lua的class实例时的原理和行为，以及这样的实例的用法。
以某个武将的实例为例：

.. code:: js

   const diaochan = Lua.evaluate('Fk.generals["diaochan"]');

因为General类注册了 ``__tocbor`` 方法，底层可以将其转为CBOR值从而传递到QML中，
但是CBOR值需要解码后才可以使用。所以这里就运用了代理对象的技巧来让返回值能像
一个普通的js对象一样操作。

.. note::

  CBOR一种二进制数据格式，兼容JSON-like的同时还可以拓展自定义数据类型。

  目前新月杀的一些类型注册到了cbor中，分别是Player, General, Skill, Card。
  只有注册了cbor自定义类型的class实例（也就是这里提到的几种）才能被
  ``Lua.evalute`` 正确识别。

只从功能上来说，你可以用点运算符（ ``.`` ）来取得返回值的任意字段，
只要对应值是能够被 ``Lua.evaluate`` 处理的值，或者是类的方法即可。接上面例子：

.. code:: js

   const diaochan = Lua.evaluate('Fk.generals["diaochan"]');
   console.log(diaochan.name);  // 输出 "diaochan"
   console.log(diaochan.getSkillNameList());  // 输出 "[lijian,biyue]"
   console.log(diaochan.package);  // 报错！虽然武将确实有package字段，但Package类型不在上述的四种类型中。

Lua.ev(str)
~~~~~~~~~~~~~

上文所述的 ``Lua.evaluate`` 的弱化版，只能处理JSON-like的值。

但是由于不需要提前判断表达式返回值的类型所以性能更好，按需使用吧。

Lua.fn(str)
~~~~~~~~~~~~~

类似于 ``Lua.evaluate`` ，但是专门解析function类型的值，返回一个js函数。
str对应的应当为一个function类型的Lua值。

在需要执行一段比较复杂的Lua逻辑时这个函数相当有用。

.. code:: js

   const tr = Lua.fn("Translate"); // tr是一个js函数，功能如同Lua全局函数 Translate
   console.log(tr("diaochan")); // 输出"貂蝉"
   
   // 也可以直接用Lua.fn包装一个较复杂的Lua函数，用来跑一些自定义逻辑
   const func = Lua.fn(`function(mode)
     local m = Fk.game_modes[mode]
     return {
       minPlayer = m.minPlayer,
       maxPlayer = m.maxPlayer,
     }
   end`)
   // 然后如同调用Js函数一样使用
   const ret = func("aaa_role_mode");
   console.log(JSON.stringify(ret)); // 可能输出'{"minPlayer":2,"maxPlayer":8}'

以此法获得的js函数只能传入以下的参数：

- JSON-like
- Lua对象的代理对象

Lua.createProxy(str)
~~~~~~~~~~~~~~~~~~~~~~~

可以无视注册tocbor的限制，为任何Lua table创建代理对象。
str对应的应当为一个table类型的Lua值，如果是JSON-like的简单table请直接使用
``Lua.evaluate``  或者 ``Lua.ev`` 。

例如 ``const client = Lua.createProxy("ClientInstance");`` ，这样client就可以
如同Lua中的 ``ClientInstance`` 来使用了，尽管它的类型不在上述几种注册了cbor的
类型之中。

一些常用的值已经预定义好：

- ``Lua.fk`` ：对应 ``Fk`` ，也就是Engine的实例
- ``Lua.self`` ：对应 ``Self`` 。
- ``Lua.client`` ：对应 ``ClientInstance`` 。

从Lua向Qml传递信息
---------------------

有时候需要从Lua中告诉程序该去创建哪个已定义的qml组件。

关于创建配置界面的lua代码，请看 :doc:`mode-config` 。

一般来说你会需要创建一个合乎 ``QmlComponent`` 类型注释的Lua表，该类型注释如下：

.. code:: lua

    ---@class QmlComponent
    ---@field uri? string QML模块uri
    ---@field name? string QML模块名
    ---@field url? string QML文件路径
    ---@field prop? { [string]: any } 属性字典
    ---@field model? QmlComponent? 如果需要model就创建

它规定了一个Qml组件的以下几点：

- 是什么模块？指定 ``url`` 字段，或者同时指定 ``uri`` 和 ``name`` 字段
- 创建它需要何种数据， ``prop`` 字段已提供
- 是否有创建model的需求， ``model`` 字段本身也是一个QmlComponent

这套类型规范是直接根据 ``Qt.createComponent`` 和 ``Component.createObject``
这两个Qml函数设计的。

关于url字段，或者uri字段与name字段，援引Qt文档：

::

  * Qt.createComponent(url)

  返回使用指定 url 的 QML 文件创建的 Component。

  例: Qt.createComponent("Button.qml")

  * Qt.createComponent(moduleUri, typeName)

  返回使用 moduleUri 和 typeName 指定的类型创建的 Component 对象。

  例: Qt.createComponent("QtQuick", "Rectangle")

所以url是指向qml文件路径，uri和name对应moduleUri和typeName，二者结合在一起
也能规定一个Qml类型。具体请自行查阅Qml文档。

prop字段用于 ``Component.createObject(QtObject parent, object properties)``
的properties参数。

model字段用于作为该可视化组件的model，如果指定的话，程序会优先创建model，
然后再将model作为新组件的 ``dataModel`` 属性来创建整个组件。
