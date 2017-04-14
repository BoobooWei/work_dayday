#!/bin/bash
#mysqlbin_dir=mysql
mem=/proc/meminfo
IP=$(/sbin/ifconfig eth0 | sed -n 's/.*addr:\([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\).*/\1/p')
monitor_ip="10.21.82.112"
monitor_user='dhx'
monitor_pwd='123'
disked="0.0"
recvnet=0
sendnet=0
mem_ratio="0.0"
load_avg_now="0.0"
statused=0
port="3306"
types=""
monitorini_id=0



function local_info(){
mysqlbin_dir=`/bin/ps -ef |grep 'mysql' |grep -v 'grep' |grep 'mysqld'|tail -n 1|/bin/awk '{split($0,a," ");aa=length(a);{for(i=1;i<=aa;i++) if(match(a[i],"basedir")) print a[i]}}'|/bin/awk -F '=' '{print $2}'`

if [ -n "$mysqlbin_dir" ]
then
        localinfo=`$mysqlbin_dir/bin/mysql -h$monitor_ip -u$monitor_user -p$monitor_pwd -N -e "select id,type,port from monitor.monitorini where ip='$IP' and serverout=1;"`
else
        localinfo=`/usr/bin/mysql -h$monitor_ip -u$monitor_user -p$monitor_pwd -N -e "select id,type,port from monitor.monitorini where ip='$IP' and serverout=1;"`
fi
if [ -n "$localinfo" ]
then
        monitorini_id=`/bin/echo $localinfo |/bin/awk '{print $1}'`
        types=`/bin/echo $localinfo |/bin/awk '{print $2}'`
        port=`/bin/echo $localinfo |/bin/awk '{print $3}'`
else
        /bin/echo "the monitorini do not have the ip information,please check it"
        exit 0
fi

}



function net(){
if [ -n "$1" ]; then
eth_name=$1
else
eth_name="eth0"
fi
i=0
send_o=`/sbin/ifconfig $eth_name | grep bytes | awk '{print $6}' | awk -F : '{print $2}'`
recv_o=`/sbin/ifconfig $eth_name | grep bytes | awk '{print $2}' | awk -F : '{print $2}'`
send_n=$send_o
recv_n=$recv_o
while [ $i -le 3153600000 ]; do
send_l=$send_n
recv_l=$recv_n
/bin/sleep $2
send_n=`/sbin/ifconfig $eth_name | grep bytes | awk '{print $6}' | awk -F : '{print $2}'`
recv_n=`/sbin/ifconfig $eth_name | grep bytes | awk '{print $2}' | awk -F : '{print $2}'`
i=`/usr/bin/expr $i + 1`
send_r=`/usr/bin/expr $send_n - $send_l`
recv_r=`/usr/bin/expr $recv_n - $recv_l`
total_r=`/usr/bin/expr $send_r + $recv_r`
send_ra=`/usr/bin/expr \( $send_n - $send_o \) / $i`
recv_ra=`/usr/bin/expr \( $recv_n - $recv_o \) / $i`
total_ra=`/usr/bin/expr $send_ra + $recv_ra`
sendn=`/sbin/ifconfig $eth_name | grep bytes | awk -F \( '{print $3}' | awk -F \) '{print $1}'`
recvn=`/sbin/ifconfig $eth_name | grep bytes | awk -F \( '{print $2}' | awk -F \) '{print $1}'`
load=`/usr/bin/uptime  |awk -F , '{print $4}' |awk -F : '{print $2}'`
clear
#echo  "Last second  :   Send rate: $send_r Bytes/sec  Recv rate: $recv_r Bytes/sec  Total rate: $total_r Bytes/sec"
#echo  "Average value:   Send rate: $send_ra Bytes/sec  Recv rate: $recv_ra Bytes/sec  Total rate: $total_ra Bytes/sec"
#echo  "Total traffic after startup:    Send traffic: $sendn  Recv traffic: $recvn"
mysqlbin_dir=`/bin/ps -ef |grep 'mysql' |grep -v 'grep' |grep 'mysqld'|tail -n 1|/bin/awk '{split($0,a," ");aa=length(a);{for(i=1;i<=aa;i++) if(match(a[i],"basedir")) print a[i]}}'|/bin/awk -F '=' '{print $2}'`
if [ -n "$mysqlbin_dir" ]
then
$mysqlbin_dir/bin/mysql -h$monitor_ip -u$monitor_user -p$monitor_pwd -e "insert into monitor.mNetLoad(monitorini_id,recvnet,sendnet,\`load\`) values($monitorini_id,$recv_r,$send_r,$load)"

else
/usr/bin/mysql -h$monitor_ip -u$monitor_user -p$monitor_pwd -e "insert into monitor.mNetLoad(monitorini_id,recvnet,sendnet,\`load\`) values($monitorini_id,$recv_r,$send_r,$load_avg_now)"
fi

done
}

local_info
net $1 $2
#function main(){
#local_info
#/bin/echo "monitorini_id=$monitorini_id,types=$types,port=$port"
#if [ -n "$types" ]
#then
#        server_monitor $types
#fi
#insert_mysql
#}
#main
