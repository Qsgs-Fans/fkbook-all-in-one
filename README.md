# 新月之书

欢迎来到新月杀文档的Git仓库！

本文档使用Sphinx+RST编写，可以编译成HTML、PDF以及更多其他文档格式。

这份文档目前托管于 https://fkbook-all-in-one.readthedocs.io/ 欢迎前往阅读！

若想要贡献新内容，欢迎发起PR。

## 搭建环境

编写了文档之后自然需要在本地运行起来才好。环境搭建方式如下：

先安装Python3最新版，然后在仓库内Git bash here，先将仓库clone下来，
注意仓库的子模块指向的是github上的新月杀，建议手动clone一个。
以下是clone与构建放在一起的代码：


```sh
$ git clone https://gitee.com/Qsgs-Fans/fkbook-all-in-one
$ cd fkbook-all-in-one
$ git clone https://gitee.com/notify-ctrl/FreeKill

$ python -m venv .venv #若已经clone则从这条开始构建网页


#若你的操作系统为Linux执行这条
$ source .venv/bin/activate  
#若你的操作系统为windows，则执行这条
$ source .venv/Scripts/activate 
#source代码今后每次运行都要执行


$ pip install -r requirements.txt
$ make html # 有make的时候使用这个
# 若未安装make则使用这个命令
$ sphinx-build -M html . build/
```

然后build/html文件夹就会出现，查看index.html即可。
