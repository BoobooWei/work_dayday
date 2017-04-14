#!/bin/sh
source   ~/.bash_profile
shell_dir=`pwd`
mysql_host="127.0.0.1"
mysql_user="monitordb"
mysql_pass="localhost123"
mysql_database="monitor"
Curdatetime=`date -d'-5000 min' +"%Y-%m-%d %H:%M:%S"`
updatetime=`date +"%Y-%m-%d %H:%M:%S"`
nextdatetime=`date -d'-1 day' +"%Y-%m-%d 00:00:00"`
enddatetime=`date -d'-1 day' +"%Y-%m-%d 23:59:59"`
date=`date +%Y-%m-%d-%H:%M`
Curdate=`date +%Y%m%d`
#log_file=./log_file.log
maillog=./mail_$date.log
mysqlbin_dir=`ps -ef |grep 'mysql' |grep -v 'grep' |grep 'mysqld'|tail -n 1|awk '{split($0,a," ");aa=length(a);{for(i=1;i<=aa;i++) if(match(a[i],"basedir")) print a[i]}}'|awk -F '=' '{print $2}'`
mysql_cmd1="select b.projectName,b.ip,a.disk,b.type,a.createtime from monitor.monitor a,monitor.monitorini b where a.monitorini_id=b.id and  a.createtime>='$Curdatetime' and a.\`status\`=0 and a.disk>=b.disk order by b.type,b.ip"
mysql_cmd2="select b.projectName,b.ip,a.recvnet,b.type,a.createtime from monitor.monitor a,monitor.monitorini b where a.monitorini_id=b.id and  a.createtime>='$Curdatetime' and a.\`status\`=0 and a.recvnet>=b.recvnet order by b.type,b.ip"
mysql_cmd3="select b.projectName,b.ip,a.sendnet,b.type,a.createtime from monitor.monitor a,monitor.monitorini b where a.monitorini_id=b.id and  a.createtime>='$Curdatetime' and a.\`status\`=0 and a.sendnet>=b.sendnet order by b.type,b.ip"
mysql_cmd4="select b.projectName,b.ip,a.\`load\`,b.type,a.createtime from monitor.monitor a,monitor.monitorini b where a.monitorini_id=b.id and  a.createtime>='$Curdatetime' and a.\`status\`=0 and a.\`load\`>=b.\`load\` order by b.type,b.ip"
mysql_cmd5="select b.projectName,b.ip,a.mem,b.type,a.createtime from monitor.monitor a,monitor.monitorini b where a.monitorini_id=b.id and  a.createtime>='$Curdatetime' and a.\`status\`=0 and a.mem>=b.mem order by b.type,b.ip"
mysql_cmd6="select b.projectName,b.ip,a.service,b.type,a.createtime from monitor.monitor a,monitor.monitorini b where a.monitorini_id=b.id and  a.createtime>='$Curdatetime' and a.\`status\`=0 and a.service=0 order by b.type,b.ip"
mysql_cmd7="select b.projectName,b.ip,b.type,max(a.disk),max(a.recvnet),max(a.sendnet),max(a.\`load\`),max(a.mem),a.createtime from monitor.monitor a,monitor.monitorini b where a.monitorini_id=b.id and  a.createtime>='$nextdatetime' and a.createtime<='$enddatetime' group by b.projectName,b.ip;"
mysql_cmd8="update monitor.monitor set \`status\`=1 where createtime>='$Curdatetime' and createtime<='$updatetime'"
function body(){
if [ -f /tmp/.$2.log ]
then
	rm -rf /tmp/.$2.log
fi
$mysqlbin_dir/bin/mysql -h$mysql_host -u$mysql_user -p$mysql_pass -N -e "${1}">>/tmp/.$2.log
case  $2 in 
	disk	)
			sed -i '1 s/^/项目名称\tIP地址\t磁盘使用百分比\t类型\t时间\t\t\t[1:MySQL 2:Redis 3:MongoDB 4:Ldap]\n/' /tmp/.disk.log;;
	recvnet	)
			sed -i '1 s/^/项目名称\tIP地址\t接收流量字节数\t类型\t时间\t\t\t[1:MySQL 2:Redis 3:MongoDB 4:Ldap]\n/' /tmp/.recvnet.log;;
	sendnet	)
			sed -i '1 s/^/项目名称\tIP地址\t发送流量字节数\t类型\t时间\t\t\t[1:MySQL 2:Redis 3:MongoDB 4:Ldap]\n/' /tmp/.sendnet.log;;
	load	)
			sed -i '1 s/^/项目名称\tIP地址\t负载\t类型\t时间\t\t\t[1:MySQL 2:Redis 3:MongoDB 4:Ldap]\n/' /tmp/.load.log;;
	mem		)
			sed -i '1 s/^/项目名称\tIP地址\t内存使用百分比\t类型\t时间\t\t\t[1:MySQL 2:Redis 3:MongoDB 4:Ldap]\n/' /tmp/.mem.log;;
	service	)
			sed -i '1 s/^/项目名称\tIP地址\t服务状态\t类型\t时间\t\t\t[1:MySQL 2:Redis 3:MongoDB 4:Ldap]\n/' /tmp/.service.log;;
	day		)
			sed -i '1 s/^/项目名称\tIP地址\t类型\t磁盘最大值\t接收流量最大值\t发送流量最大值\t负载最大值\t内存使用最大值\t\t\t[1:MySQL 2:Redis 3:MongoDB 4:Ldap]\n/' /tmp/.day.log;;
esac
}

function edit(){
if [ -f /tmp/sendmail.log ]
then
	echo ''>/tmp/sendmail.log
fi

for i in `ls -lh /tmp/.*.log|grep -v '.day.log'  |awk '{if($5>0) print $9}'` 
do 
	column -t $i >>/tmp/sendmail.log
	echo -ne "\n\n" >>/tmp/sendmail.log
done
}

function main(){
body "$mysql_cmd1" 'disk'
body "$mysql_cmd2" 'recvnet'
body "$mysql_cmd3" 'sendnet'
body "$mysql_cmd4" 'load'
body "$mysql_cmd5" 'mem'
body "$mysql_cmd6" 'service'

edit

warning=`cat /tmp/sendmail.log`
if [ -n "$warning" ]
then
	/usr/local/bin/python /usr/local/sbin/mail_send.py "Monitor alarm_$date" "$warning"
fi

hour=`date +'%H'`

if [ $hour = '08' ]
then
	if [ -f /tmp/.day.log ]
	then
		dayfile_time=`stat -c %y /tmp/.day.log |cut -c1-19`
		dayfile_second=`date -d "$dayfile_time" +%s`
		nowday_time=`date  +"%Y-%m-%d 00:00:00"`
		nowday_second=`date -d "$nowday_time" +%s`
		if [ $dayfile_second -le $nowday_second ]
		then
			body "$mysql_cmd7" 'day'
			column -t /tmp/.day.log >/tmp/dayreport.log
			dayreportcontent=`cat /tmp/dayreport.log`
			if [ -n "$dayreportcontent" ]
			then
				/usr/local/bin/python /usr/local/sbin/mail_send.py "Report_$date" "$dayreportcontent"
			fi
		else
			echo "the day report have sended"
		fi
	else
		body "$mysql_cmd7" 'day'
		column -t /tmp/.day.log >/tmp/dayreport.log
		dayreportcontent=`cat /tmp/dayreport.log`
		if [ -n "$dayreportcontent" ]
		then
			/usr/local/bin/python /usr/local/sbin/mail_send.py "Report_$date" "$dayreportcontent"
		fi
	fi
fi
$mysqlbin_dir/bin/mysql -h$mysql_host -u$mysql_user -p$mysql_pass -N -e "$mysql_cmd8"
}

main
