1. 获取所有某个binlog

   ```shell
   mysqlbinlog -vv --base64-output=DECODE-ROWS mastera.000028 > /root/mybinlog.txt
   ```

   ​

2. 复制一份binlog来分析

   ```shell
   cp /root/mybinlog.txt /root/mybinlog.txt.bac
   ```

   ​

3. 获取时间、位置、sql和语句

   ```shell
   # 截取所有sql带时间点和pos
   awk  '$0~/^###/ || $0~/end_log_pos.*flags/ {print $0}' mybinlog.txt.bac | sed 's/^### //;s@\/\*.*\*\/@@' > new


   ```
   
 4. python脚本抽取sql
 
 准备工作：
 
 1)python2.6
 
 2)MySQLDB模块
 
 3)mysql-server
 
 4)表的ddl
 
 5. binlogtosql.py
 
 该脚本将sql打印在屏幕上，如下所示:
 ```shell
 时间点		位置编号	SQL类型	SQL语句
-------------------------------------------------------
170718 11:40:45	s 637 		insert	INSERT INTO `ks`.`x2_session` SET sessionid='pu0qc0m90a0ffak0s98cihu206',sessionuserid=0,sessionusername='',sessionpassword='',sessionip='91.214.117.173',sessionmanage=0,sessiongroupid=0,sessioncurrent='',sessionrandcode='',sessionlogintime=0,sessiontimelimit=0,sessionlasttime=0,sessionmaster=0;
170718 11:40:45	s 1099 		update	UPDATE `ks`.`x2_session` SET sessionid='pu0qc0m90a0ffak0s98cihu206',sessionuserid=0,sessionusername='',sessionpassword='',sessionip='91.214.117.173',sessionmanage=0,sessiongroupid=0,sessioncurrent='',sessionrandcode='',sessionlogintime=0,sessiontimelimit=0,sessionlasttime=1500349245,sessionmaster=0 WHERE sessionid='pu0qc0m90a0ffak0s98cihu206' and sessionuserid=0 and sessionusername='' and sessionpassword='' and sessionip='91.214.117.173' and sessionmanage=0 and sessiongroupid=0 and sessioncurrent='' and sessionrandcode='' and sessionlogintime=0 and sessiontimelimit=0 and sessionlasttime=0 and sessionmaster=0;
170728 11:04:21	s 1439553 		delete	DELETE FROM `ks`.`x2_quest2knows` WHERE qkid=1219 and qkquestionid=1226 and qkknowsid=7 and qktype=0 
```
后续分析可以使用sed awk

6. 2binlogtosql.py

该脚本将sql保存在数据中个，如下所示：

```shell
mysql> select * from binlogtosql limit 3\G;
*************************** 1. row ***************************
     id: 1
  edate: 2017-07-18
  etime: 11:40:45
    pos: 637
   type: insert
sqlinfo: INSERT INTO `ks`.`x2_session`  SET  sessionid='pu0qc0m90a0ffak0s98cihu206', sessionuserid=0, sessionusername='', sessionpassword='', sessionip='91.214.117.173', sessionmanage=0, sessiongroupid=0, sessioncurrent='', sessionrandcode='', sessionlogintime=0, sessiontimelimit=0, sessionlasttime=0, sessionmaster=0;
*************************** 2. row ***************************
     id: 2
  edate: 2017-07-18
  etime: 11:40:45
    pos: 1099
   type: update
sqlinfo: UPDATE `ks`.`x2_session`  SET  sessionid='pu0qc0m90a0ffak0s98cihu206', sessionuserid=0, sessionusername='', sessionpassword='', sessionip='91.214.117.173', sessionmanage=0, sessiongroupid=0, sessioncurrent='', sessionrandcode='', sessionlogintime=0, sessiontimelimit=0, sessionlasttime=1500349245, sessionmaster=0  WHERE  sessionid='pu0qc0m90a0ffak0s98cihu206' and  sessionuserid=0 and  sessionusername='' and  sessionpassword='' and  sessionip='91.214.117.173' and  sessionmanage=0 and  sessiongroupid=0 and  sessioncurrent='' and  sessionrandcode='' and  sessionlogintime=0 and  sessiontimelimit=0 and  sessionlasttime=0 and  sessionmaster=0;
*************************** 3. row ***************************
     id: 3
  edate: 2017-07-18
  etime: 11:41:33
    pos: 1488
   type: insert
sqlinfo: INSERT INTO `ks`.`x2_session`  SET  sessionid='4mrnpa1iobeb0o5t81na4h31r6', sessionuserid=0, sessionusername='', sessionpassword='', sessionip='91.214.117.192', sessionmanage=0, sessiongroupid=0, sessioncurrent='', sessionrandcode='', sessionlogintime=0, sessiontimelimit=0, sessionlasttime=0, sessionmaster=0;
3 rows in set (0.00 sec)

ERROR: 
No query specified
```

后续分析可以使用sql语句

