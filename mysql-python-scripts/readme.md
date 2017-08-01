该脚本的功能如下：
1. 获取日志中的所有DML语句及时间位置
2. 进行DML语法修正
3. 转换时间戳为日期时间
4. 最终将转换后的SQL语句保存在数据库，表名mysqltobinlog

脚本使用方法：
1. bash b2s_pre.sh binlogfile 进行日志预处理，该脚本返回binlogfile.new文件
2. python binlog_analyze.py binlogfile.new  该脚本将binlog转换为sql并保存于数据库中
3. python foo.py  该脚本进行sql语句的分析，例如统计某个时段的sql类型占比

待改进：
1. 目前一次只能分析一个脚本，第二次分析会覆盖mysqltobinlog表
2. 分析的内容比较简单
3. sql回滚未实现

example:
# cp /var/lib/mysql-log/mastera.000028 .
# bash b2s_pre.sh mastera.000028 
# python binlog_analyze.py mastera.000028.new 
# python foo.py
该日志记录的时间段为：2017-07-20 2017-07-18 
某时段统计sql类型
Plz input t1:2017-07-18
Plz input t2:2017-07-20
2017-07-18~2017-07-20时间段内的不同SQL类型执行的数量为：
update 268 
insert 255 
delete 27 
2017-07-18~2017-07-20时间段内不同类型的sql所占比重：
update 0.4873 
insert 0.4636 
delete 0.0491
