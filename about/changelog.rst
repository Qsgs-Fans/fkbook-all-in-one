Changelog
===========

记载一些值得注意的或者破坏力较大的更新。FreeKill的更新不太严格按照版本号，不少重要更新直接体现在freekill-core仓库。

下面以主体版本号为大标题，freekill-core仓库的值得注意的commit hash为时间线，中间穿插freekill-asio的更新。
比0.5.12版本更老的就不补了。

FreeKill 0.5.12
------------------

将传输层传输的数据格式从JSON行改为CBOR流。core中的脚本也随之修改。

freekill-core
~~~~~~~~~~~~~~

- ``8483eba``: 初步支持用户从0创建自己的新桌游
- ``cad0573``: 支持将一张牌当装备牌使用
- ``73533d4``: 更完善的技能次数判断
- ``43a8cab``: Lua初步支持向客户端直接传输 ``Player``, ``Card``, ``General``, ``Skill`` 类型的数据（包括标记、banner、Request的data等）。显示尚不完善。
- ``7606d75``: Lua和Qml的API从此不需要（也不能）再写明 ``json.encode`` 等。暂时有一个检测JSON字符串并转为CBOR的兼容方案。

freekill-asio
~~~~~~~~~~~~~~~

- ``v0.0.4``: 修复一处生命周期的bug
- ``v0.0.3``: 修复死锁bug
- ``v0.0.2``: 增强ls系列命令，增加whitelist命令操作白名单
- ``v0.0.1``: 增加暂时封禁功能；修复大部分bug
- 新增freekill-asio，这是一个不带Qt的服务端重构。FreeKill中的server预计只会跟进协议，不会增加新功能（除非有热心贡献者PR）
