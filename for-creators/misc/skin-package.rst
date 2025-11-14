皮肤拓展
===============================

在新月杀中可以创建一个皮肤包，这样玩家在局内就能更换武将皮肤了。

创建一个皮肤拓展
----------------------------

首先创建一个拓展，当然你需要一个 ``init.lua`` 来注册这个拓展。

你当然可以像普通的武将拓展那样创建子包。只需要在 ``init.lua`` 中返回你创建的子包即可。

像这样，创建一个名为 ``my-skin-package`` 的皮肤拓展：

.. code:: lua

    local skin_shu = require "packages.my-skin-package.skins_shu" --创建一个“蜀势力”包
    local skin_wu = require "packages.my-skin-package.skins_wu" --创建一个“吴势力”包
    local skin_wei = require "packages.my-skin-package.skins_wei" --创建一个“魏势力”包

    return {
      skin_shu,
      skin_wu,
      skin_wei
    }

在子包中，你需要创建一个 ``Package`` 实例，并设置它的 ``extensionName`` 为你的拓展名。
然后就是具体地创建皮肤，你需要使用创建的 ``Package`` 的方法 ``addSkinPackage`` 来添加一个皮肤包。
函数的参数是一个表，里面包含 ``path`` 和 ``content`` 两个字段。你需要为这个皮肤包指定一个路径（ ``init.lua`` 下的相对路径），并且在 ``content`` 中为一个或多个同名武将指定皮肤。

.. hint::
    ``content`` 也是一个表，你需要为每一个元素创建一个指定的皮肤表。每一个元素包含着一个同名武将和他的皮肤，你可以在 ``content`` 里写多个“武将-皮肤”对来添加皮肤，只需要保证他们的 ``path`` 是相同的。 ``content`` 有 ``skins`` 和 ``enabled_generals`` 两个字段，对应着要添加的皮肤图片名和拥有这些皮肤的武将名。

具体的操作可以参考示例：

.. code:: lua

    local extension = Package:new("skins_shu", Package.SkinPack)
    extension.extensionName = "my-skin-package"

    ---@type SkinPackageContent
    local content = {
      {
        skins = { "汉昭烈帝.png", "花好月圆.gif", "明良千古.mp4" }, --你放在path下的文件名
        enabled_generals = { "liubei", "ex__liubei" } --启用的武将名
      },
      --可以添加多个武将，也可以在多个元素中使用相同的武将名和皮肤名，彼此是独立的
      {
        skins = { "忠肝义胆.jpg", "明良千古.wav" },
        enabled_generals = { "guanyu", "ex__guanyu" }
      },
    }

    --调用addSkinPackage方法，path指定拓展目录下的相对路径
    extension:addSkinPackage{
      path = "/image/generals",
      content = content
    }

然后你就成功创建了一个皮肤拓展。

