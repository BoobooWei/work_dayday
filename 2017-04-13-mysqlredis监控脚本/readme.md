# mysql redis 单实例监控脚本

## 监控架构

	monitor				----------	agent1
						----------	agent2
						----------	agent3
	monitor.sh(contab 1min)				agent.sh(crontab /5min)	
	mail_send.py

			
## 监控脚本说明

1. 在你的监控端放上monitor.sh脚本 作用每天早上8点把昨天的 都收集一下然后发送邮件
2. 放上mail_send.py发邮件脚本（py脚本里面mailto_list是你想发送的人）
3. 在每一台被监控端放上agent.sh脚本 如果被监控端的是mysql服务器做以下授权
 ```shell
	GRANT USAGE ON *.* TO 'agent'@'127.0.0.1' IDENTIFIED BY 'redhat'；
	GRANT SELECT ON `test`.* TO 'agent'@'127.0.0.1'；
```
4. 在没有装mysql服务的机器上`yum -y install mysql`装上mysql命令
5. 在每台被监控端 计划任务里面5分钟跑一次 
6. 监控端1分或者10分钟跑一次都随便你
7. 对于monitor 表特别要解释的是status表示发送邮件的状态只要监控端的monitor脚本没有执行那么状态肯定是0 一旦执行发送脚本状态肯定就是1了以后就都不会发第二次邮件了
8. 每天早上7点发送前一天所有的状态邮件不是报警平时是报警的发给你了你就要注意了
9. 该版本仅适合单实例的mysql redis mongodb
10. 里面的脚本看看 比如密码用户改成你自己的 agent.sh 需要往监控端插入数据需要授权 自己授权
```shell
monitor_ip="10.21.82.112"
monitor_user='admin'
monitor_pwd='123'
```
改成你自己需要的monitor_ip是监控端ip，在监控端需要授权给这个至少对monitor库有插入权限
11. 监控的网卡是eth0可以根据需要在agent.sh 脚本改动
12. monitorini表里面都是你自己填写进去被监控端的限额   执行agent.sh 会向monitor表里面插入数据；超过了monitorini配置表的限额就会发报警邮件
13. nlagent.sh 执行方式 sh nlagent eth0 1 代表每秒监控eth0的发送接收流量 还有负载 这个要单独建表
```shell
CREATE TABLE `mNetLoad` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `monitorini_id` int(11) NOT NULL,
  `recvnet` float NOT NULL,
  `sendnet` float NOT NULL,
  `load` float NOT NULL,
  PRIMARY KEY (`id`),
  KEY `N_monitor_createtime` (`load`,`monitorini_id`)
) ENGINE=MEMORY AUTO_INCREMENT=99 DEFAULT CHARSET=utf8;
```
