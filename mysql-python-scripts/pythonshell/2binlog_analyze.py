#!/usr/bin/python
# -*- coding: utf-8 -*-

# Usage: python xxx.py 文件名-------------------------------------------------------------------------------------#
# #日志文件需要提前准备 											  											  #
# mysqlbinlog -vv --base64-output=DECODE-ROWS mastera.000028 > /root/mybinlog.txt 				  				  #	
# # 截取所有sql带时间点和pos											  										  #
# awk  '$0~/^###/ || $0~/end_log_pos.*flags/ {print $0}' mybinlog.txt | sed 's/^### //;s@\/\*.*\*\/@@' > new      #
#-----------------------------------------------------------------------------------------------------------------#
import sys
import re
import MySQLdb

url='localhost'
username='root'
password='(Uploo00king)'
dbname='ks'

sql_list=['INSERT','UPDATE','DELETE']

r=re.compile('INSERT|DELETE|UPDATE')
n=re.compile('#')
insert=re.compile('INSERT')
delete=re.compile('DELETE')
update=re.compile('UPDATE')
e=re.compile('@.*=')
w=re.compile('WHERE')
s=re.compile('SET')
a_file=open(sys.argv[1],'ro')
a_list=a_file.readlines()


def insert_row_format(i,url,username,password):
	insert_list=[]
	for i_str in i:
		if e.match(i_str.strip()):
			i_str_new=i_str.strip()+','
		else:
			i_str_new=i_str.strip()+' '
		insert_list.append(i_str_new)

	insert_list[-1]=insert_list[-1].replace(',',';')	 
	# 获取表名
	tb_col_list=[]
	tb_str=i[0].split()[2]
	dbname=tb_str.split('.')[0].strip('`')
	tbname=tb_str.split('.')[1].strip('`')
	# 连接数据库获取列名
	sql='desc ' + tbname + ';'
	db = MySQLdb.connect(url,username,password,dbname )
	cursor = db.cursor()
	cursor.execute(sql)
	data = cursor.fetchall()

	for i in data:
                tb_col_list.append(i[0])
	db.close()

	col_len_num=len(tb_col_list)
	for j in range(1,col_len_num+1):
		for u in insert_list:
			if e.match(u):
				u_new=u.replace('@'+str(j)+'=',tb_col_list[j-1]+'=')
				num22=insert_list.index(u)
				insert_list[num22]=u_new


#	for aa in insert_list:
#		sys.stdout.write(aa)
#	print
	isql_str = ' '.join(insert_list)
	return isql_str

def delete_row_format(i,url,username,password):
	delete_list=[]

	for i_str in i:
		if e.match(i_str.strip()):
			i_str_new=i_str.strip()+' and '
		else:
			i_str_new=i_str.strip()+' '
		delete_list.append(i_str_new)

	delete_list[-1]=delete_list[-1].replace('and',';')	 
	# 获取表名
	tb_col_list=[]
	tb_str=i[0].split()[2]
	dbname=tb_str.split('.')[0].strip('`')
	tbname=tb_str.split('.')[1].strip('`')
	# 连接数据库获取列名
	sql='desc ' + tbname + ';'
	db = MySQLdb.connect(url,username,password,dbname )
	cursor = db.cursor()
	cursor.execute(sql)
	data = cursor.fetchall()

	for i in data:
                tb_col_list.append(i[0])
	db.close()

	col_len_num=len(tb_col_list)
	for j in range(1,col_len_num+1):
		for u in delete_list:
			if e.match(u):
				u_new=u.replace('@'+str(j)+'=',tb_col_list[j-1]+'=')
				num22=delete_list.index(u)
				delete_list[num22]=u_new


#	for aa in delete_list:
#		sys.stdout.write(aa)
#	print

	dsql_str = ' '.join(delete_list)	
	return dsql_str

def update_row_format(i,url,username,password):
	update_list=[]
	where_list=[]
	set_list=[]
	u_len_num=len(i)
	for i_num in range(0,u_len_num):

		if w.match(i[i_num].strip()):
			w_index=i_num
		if s.match(i[i_num].strip()):
			s_index=i_num
	for i_num in range(0,u_len_num):
		if i_num < w_index:
			i_str_new=i[i_num].strip()+' '	
			update_list.append(i_str_new)
		if i_num == w_index:
			i_str_new=i[i_num].strip()+' '	
			where_list.append(i_str_new)
		if i_num > w_index and i_num < s_index-1:
			i_str_new=i[i_num].strip()+' and '
			where_list.append(i_str_new)
		if i_num == s_index-1:
			i_str_new=i[i_num].strip()+';'
			where_list.append(i_str_new)
		if i_num > s_index and i_num < u_len_num-1:
			i_str_new=i[i_num].strip()+','
			set_list.append(i_str_new)
		if i_num == s_index:
			i_str_new=i[i_num].strip()+' '
			set_list.append(i_str_new)
		if i_num == u_len_num-1:
			i_str_new=i[i_num].strip()+' '
			set_list.append(i_str_new)

	for set_str in set_list:
		update_list.append(set_str)
	for where_str in where_list:
		update_list.append(where_str)
	# 获取表名
	tb_col_list=[]
	tb_str=i[0].split()[1]
	dbname=tb_str.split('.')[0].strip('`')
	tbname=tb_str.split('.')[1].strip('`')
	# 连接数据库获取列名
	sql='desc ' + tbname + ';'
	db = MySQLdb.connect(url,username,password,dbname )
	cursor = db.cursor()
	cursor.execute(sql)
	data = cursor.fetchall()

	for i in data:
                tb_col_list.append(i[0])
	db.close()

	col_len_num=len(tb_col_list)
	for j in range(1,col_len_num+1):
		for u in update_list:
			if e.match(u):
				u_new=u.replace('@'+str(j)+'=',tb_col_list[j-1]+'=')
				num22=update_list.index(u)
				update_list[num22]=u_new


#	for aa in update_list:
#		sys.stdout.write(aa)
#	print
	usql_str = ' '.join(update_list)
	return usql_str

num=0
names=locals()
for a_str in a_list:
        if n.match(a_str):
                num=num+1
                names['b_list%d'%num]=[]
                time_str=a_str[1:16]
#               pos_str=a_str[41:46]
                s_num=a_str.index('end_log_pos')+11
                e_num=a_str.index('CRC')
                pos_str=a_str[s_num:e_num]
                names['b_list%d'%num].append(time_str)
                names['b_list%d'%num].append(pos_str)

        if r.match(a_str):
                if insert.match(a_str):
                        sql_type_str='insert'
                if delete.match(a_str):
                        sql_type_str='delete'
                if update.match(a_str):
                        sql_type_str='update'
                names['b_list%d'%num].append(sql_type_str)
                names['b_list%d'%num].append(a_str)

        if not r.match(a_str) and not n.match(a_str):
                names['b_list%d'%num].append(a_str)
		
	
def print_all():
	# 打印出时间点 位置编号 sql语句
	print "时间点\t\t位置编号\tSQL类型\tSQL语句"
	print "-------------------------------------------------------"
	for j in range(1,num+1):
		sys.stdout.write('{0}\t{1}\t\t{2}\t'.format(names['b_list%d'%j][0],names['b_list%d'%j][1],names['b_list%d'%j][2]))

		if names['b_list%d'%j][2]=='insert':
			insert_row_format(names['b_list%d'%j][3:],url,username,password)
		elif names['b_list%d'%j][2]=='delete':
			delete_row_format(names['b_list%d'%j][3:],url,username,password)
		else:
			update_row_format(names['b_list%d'%j][3:],url,username,password)

# 将b_list1~b_listN存入数据库中【时间,pos,type,sql】

def create_table():
        # 连接数据库创建表binlogtosql
        sql='create table binlogtosql (id int primary key auto_increment,edate date not null,etime time not null,pos int not null,type varchar(20) not null,sqlinfo text not null);'
        db = MySQLdb.connect(url,username,password,dbname )
        cursor = db.cursor()
	cursor.execute("DROP TABLE IF EXISTS binlogtosql")
        cursor.execute(sql)
        db.close()
def execute_insert(b,s):
	# 将b_list存入数据到binlogtosql表中
	# insert into binlogtosql values (null,'170731', '12:09:18',254,'insert','insert into sdfsdf  set a=1');
	col1='null'
	col2=b[0].split()[0]
	col3=b[0].split()[1]
	col4=b[1]
	col5=b[2]
	col6=s
	sql="insert into binlogtosql values (" + col1 + ",'" + col2 + "','" + col3 + "'," + col4 + ",'" + col5 + '''',"''' + col6 + '''");'''
	db = MySQLdb.connect(url,username,password,dbname )
        cursor = db.cursor()
        cursor.execute(sql)
	db.commit()
        db.close()



create_table()
for j in range(1,num+1):
	a1=names['b_list%d'%j]
        if names['b_list%d'%j][2]=='insert':
		a2=insert_row_format(names['b_list%d'%j][3:],url,username,password)
	elif names['b_list%d'%j][2]=='delete':
		a2=delete_row_format(names['b_list%d'%j][3:],url,username,password)
	else:
		a2=update_row_format(names['b_list%d'%j][3:],url,username,password)
	execute_insert(a1,a2.replace('"','\\\"'))





# 该日志记录的时间段
# select max(edate),min(edate) from binlogtosql order by edate;

# 统计某个时间段的SQL类型，从大到小，并计算百分比
# select type,count(id) from binlogtosql where edate='2017-07-19' group by type order by count(id) desc;
#+--------+-----------+
#| type   | count(id) |
#+--------+-----------+
#| insert |       170 |
#| update |       165 |
#| delete |        16 |
#+--------+-----------+

# 统计不同类型的sql所占比重
# select * from ((select t2.type,t2.c/t1.c insert_p from (select count(id) c from binlogtosql where edate='2017-07-19') t1 , (select type,count(id) c from binlogtosql where edate='2017-07-19' and type='insert') t2) union (select t2.type,t2.c/t1.c insert_p from (select count(id) c from binlogtosql where edate='2017-07-19') t1 , (select type,count(id) c from binlogtosql where edate='2017-07-19' and type='delete') t2) union (select t2.type,t2.c/t1.c insert_p from (select count(id) c from binlogtosql where edate='2017-07-19') t1 , (select type,count(id) c from binlogtosql where edate='2017-07-19' and type='update') t2)) t3 order by insert_p desc;
#+--------+----------+
#| type   | insert_p |
#+--------+----------+
#| insert |   0.4843 |
#| update |   0.4701 |
#| delete |   0.0456 |
#+--------+----------+


#print_all()
