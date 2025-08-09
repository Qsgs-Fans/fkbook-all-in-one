关于ipv6开服
===============

要通过ipv6部署新月杀服务器，首先需要检查自己服务器是否支持ipv6(以Debian12为例)

.. code:: sh

  # 检查服务器是否支持IPv6
  $ sudo apt update
  $ sudo apt install -y iptables
  $ sudo ip6tables -L

如果支持ipv6，则会输出ipv6的具体规则

.. code:: sh

  # 查看本机ip
  $ sudo ip -6 addr show 

这里以本人服务器为例：

.. code:: sh

  deb@k2450:~$ sudo ip -6 addr
  1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 state UNKNOWN qlen 1000
      inet6 ::1/128 scope host noprefixroute 
         valid_lft forever preferred_lft forever
  2: enp2s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 state UP qlen 1000
      inet6 2408:832e:c1:**:**:**:**:dbb8/64 scope global temporary dynamic 
         valid_lft 200171sec preferred_lft 25658sec
      inet6 2408:**************:845d/64 scope global temporary deprecated dynamic 
         valid_lft 200171sec preferred_lft 0sec
      inet6 2408:**************:16d6/64 scope global dynamic mngtmpaddr 
         valid_lft 200171sec preferred_lft 113771sec
      inet6 fe80::56ee:75ff:fe40:16d6/64 scope link 
         valid_lft forever preferred_lft forever

一般来说，如果只显示fe80::开头的ip，则说明服务器不支持公网ipv6访问，而公网的三个地址里，"scope global temporary dynamic"为正在使用的全球地址，也就是真实ip，可以使用tcping拨通；而"scope global temporary deprecated dynamic "是已经过期的动态ipv6地址，如果启用ddns后不及时清理就会持续堆积，最后导致ddns无法正常工作；"scope global dynamic mngtmpaddr "是一个通过SLAAC（无状态地址自动配置）生成的全球单播地址，带有mngtmpaddr标志，表示它是根据网络前缀管理生成的临时地址。这类地址也是动态的，但它是为了防止服务器直接暴露真实硬件MAC地址而设计的，主要目的是提供一个相对稳定的全球单播地址，同时保持一定的隐私性。

在确认了自己的ipv6的地址之后，首先第一件事便是开放端口

.. code:: sh

  # 开放ipv6的 tcp udp 端口（以默认9527为例）

  # 开启入站TCP端口9527
  $ sudo ip6tables -A INPUT -p tcp --dport 9527 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
  $ sudo ip6tables -A OUTPUT -p tcp --sport 9527 -m conntrack --ctstate ESTABLISHED -j ACCEPT

  # 开启出站TCP端口9527（如果需要）
  $ sudo ip6tables -A OUTPUT -p tcp --dport 9527 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
  $ sudo ip6tables -A INPUT -p tcp --sport 9527 -m conntrack --ctstate ESTABLISHED -j ACCEPT

  # 开启入站UDP端口9527
  $ sudo ip6tables -A INPUT -p udp --dport 9527 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
  $ sudo ip6tables -A OUTPUT -p udp --sport 9527 -m conntrack --ctstate ESTABLISHED -j ACCEPT

  # 开启出站UDP端口9527（如果需要）
  $ sudo ip6tables -A OUTPUT -p udp --dport 9527 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
  $ sudo ip6tables -A INPUT -p udp --sport 9527 -m conntrack --ctstate ESTABLISHED -j ACCEPT

  # 持久化保存v4 v6规则

  $ sudo apt-get update
  $ sudo apt-get install iptables-persistent
  $ sudo netfilter-persistent save

  # 手动保存规则

  $ sudo iptables-save > /etc/iptables/rules.v4
  $ sudo ip6tables-save > /etc/ip6tables/rules.v6

对于Debian/Ubuntu可以按照下面的方法保存配置文件

.. code:: sh

  #!/bin/sh
  /sbin/iptables-restore < /etc/iptables/rules.v4
  /sbin/ip6tables-restore < /etc/ip6tables/rules.v6
