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
#/bin/echo "$IP" >>/usr/local/sbin/ip.txt
function server_monitor()
{
	if [ -n $1 ]
		then
			/bin/echo "$IP has server $1"
	else
		/bin/echo "Error:the server type disapeared"
		exit 1
	fi
		
	type=$1

	case $type in 
		1)
			mysql_use;;

		2)
			redis_use;;

		3)
			mongodb_use;;

		*)
			over_server;;

	esac
}


function mysql_use()
{
mysqlbin_dir=`/bin/ps -ef |grep 'mysql' |grep -v 'grep' |grep 'mysqld'|head -n 2|/bin/awk '{split($0,a," ");aa=length(a);{for(i=1;i<=aa;i++) if(match(a[i],"basedir")) print a[i]}}'|/bin/awk -F '=' '{print $2}'`
#/bin/echo "test" >>/usr/local/sbin/ip.txt
#/bin/echo "$mysqlbin_dir" >>/usr/local/sbin/ip.txt
$mysqlbin_dir/bin/mysql -h127.0.0.1 -ulocal -p123^iLS  -e "select 1 "
if [ $? = 0 ]
then
	statused=1
else
	statused=0
fi
}

function redis_use()
{
/bin/ps -ef |grep 'redis-server' |grep -v 'grep'
if [ $? = 0 ]
then
        statused=1
else
        statused=0
fi
}


function mongodb_use()
{
/bin/ps -ef |grep 'mongod' |grep -v 'grep'
if [ $? = 0 ]
then
        statused=1
else
        statused=0
fi
}



function over_server()
{
	/bin/echo "do not have any service"
	statused=2
}


function get_Mem_info(){
        MemTotal=`/bin/awk '{if($1~/^MemTotal:/) print $2}' $mem`
        Cached=`/bin/awk '{if($1~/^Cached:/) print $2}' $mem`
        MemFree=`/bin/awk '{if($1~/^MemFree:/) print $2}' $mem`
        Buffers=`/bin/awk '{if($1~/^Buffers:/) print $2}' $mem`
        if [ "$Cached" -gt "$MemTotal" ]
                then
                        mem_free=$MemFree
			#echo $mem_free > $MONDIR/mem.txt
                else
                        mem_free=`expr $MemFree + $Buffers + $Cached`
			#echo $mem_free > $MONDIR/mem.txt
        fi
        mem_ratio=`/bin/awk 'BEGIN{printf "%.2f",(1-'$mem_free'/'$MemTotal')*100}'`
		#echo $mem_ratio >>  $MONDIR/mem.txt
		#echo "MEM=$mem_ratio" >> $MONDIR/monitor.sh
}




function get_Load_avg(){
        lv1=`uptime`
        loop=1
for i in `/bin/echo ${lv1##*:} | /bin/awk -F, '{print $1,$2,$3}'`
        do
                if [ "$loop" -eq 1 ]
                        then
                                load_avg_now=$i
                                let "loop += 1"

                elif [ "$loop" -eq 2 ]
                        then
                                load_avg_5m=$i
                                let "loop += 1"
                else
                        load_avg_15m=$i
                fi
		#echo $load_avg_1m $load_avg_5m $load_avg_15m > $MONDIR/load.txt
		#echo $CPULOAD     >>  $MONDIR/load.txt
        done
}
#echo "LOAD=$LOAD5" >> $MONDIR/monitor.sh



function get_network_last(){
if [ -n "$1" ]; then
eth_name=$1
else
eth_name="eth0"
fi

RXpre=$(/bin/cat /proc/net/dev | grep $eth_name | tr : " " | /bin/awk '{print $2}')
if [[ $RXpre == "" ]]; then
	/bin/echo "Error parameter,please input the right port after run the script!"
	exit 0
fi
TXpre=$(/bin/cat /proc/net/dev | grep $eth_name | tr : " " | /bin/awk '{print $10}')
sleep 1

RXnext=$(/bin/cat /proc/net/dev | grep $eth_name | tr : " " | /bin/awk '{print $2}')
TXnext=$(/bin/cat /proc/net/dev | grep $eth_name | tr : " " | /bin/awk '{print $10}')
#/bin/echo "$RXnext"  >> /usr/local/sbin/ip.txt
recvnet=$((${RXnext}-${RXpre}))
sendnet=$((${TXnext}-${TXpre}))

}

function disk_host(){
disk=`df -h |grep '/data' |/bin/awk -F ' '  '{print $(NF-1)}' |grep '%' |/bin/awk -F '%' '{print $1}' |sort -n |tail -n 1`
if [ -n "$disk" ]
then
        disked=$disk
else
        disk=`/bin/df -h |grep -v 'Filesystem' |/bin/awk -F ' '  '{print $(NF-1)}' |grep '%' |/bin/awk -F '%' '{if($1>80) print $1}'|head -n 1`

        if [ -n "$disk" ]
        then
                disked=$disk
        else
                disked=`/bin/df -h |grep -v 'Filesystem' |/bin/awk -F ' '  '{print $(NF-1)}' |grep '%' |/bin/awk -F '%' '{print $1}' |sort -n |tail -n 1`
        fi
fi
}

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


function  insert_mysql()
{
mysqlbin_dir=`/bin/ps -ef |grep 'mysql' |grep -v 'grep' |grep 'mysqld'|tail -n 1|/bin/awk '{split($0,a," ");aa=length(a);{for(i=1;i<=aa;i++) if(match(a[i],"basedir")) print a[i]}}'|/bin/awk -F '=' '{print $2}'`
if [ -n "$mysqlbin_dir" ]
then
$mysqlbin_dir/bin/mysql -h$monitor_ip -u$monitor_user -p$monitor_pwd -e "insert into monitor.monitor(monitorini_id,disk,recvnet,sendnet,\`load\`,mem,\`service\`,\`status\`,\`port\`,createtime) values($monitorini_id,$disked,$recvnet,$sendnet,$load_avg_now,$mem_ratio,$statused,0,$port,now())"

else
/usr/bin/mysql -h$monitor_ip -u$monitor_user -p$monitor_pwd -e "insert into monitor.monitor(monitorini_id,disk,recvnet,sendnet,\`load\`,mem,\`service\`,\`status\`,\`port\`,createtime) values($monitorini_id,$disked,$recvnet,$sendnet,$load_avg_now,$mem_ratio,$statused,0,$port,now())"
fi
}

function main(){
local_info
/bin/echo "monitorini_id=$monitorini_id,types=$types,port=$port"
if [ -n "$types" ]
then
	server_monitor $types
fi
get_Mem_info
get_Load_avg
get_network_last
disk_host
insert_mysql
}

main
