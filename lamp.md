# LAMP discus

> 搭建LAMP架构的论坛

> 服务器1台 172.25.0.10

## INSTALL

```shell
[root@workstation0 ~]# yum install -y httpd php php-mysql mariadb-server
```

## CONFIGURE

### APACHE

```shell
# 修改配置文件添加默认的动态网站首页
[root@workstation0 ~]# sed -i 's/index.html/index.html index.php/' /etc/httpd/conf/httpd.conf
# 下载论坛，解压到当前目录
[root@workstation0 ~]# wget http://172.25.254.254/content/MYSQL/00-pro/my-pro/discuz/Discuz_X3.0_SC_UTF8.zip
[root@workstation0 ~]# unzip Discuz_X3.0_SC_UTF8.zip
[root@workstation0 ~]# ls
anaconda-ks.cfg  Discuz_X3.0_SC_UTF8.zip  initial-setup-ks.cfg  readme  upload  utility
# 将upload中的文件第归复制到网站根目录下
[root@workstation0 ~]# cp upload/* /var/www/html -r
[root@workstation0 ~]# chmod 777 /var/www/html -R
```

### MARIADB

```shell
# 修改配置文件打开二进制日志为实时增量备份做准备
[root@workstation0 ~]# vim /etc/my.cnf
[root@workstation0 ~]# grep -v "^#" /etc/my.cnf|grep -v "^$"
[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
symbolic-links=0
log-bin=/var/lib/mysql-log/php
[mysqld_safe]
log-error=/var/log/mariadb/mariadb.log
pid-file=/var/run/mariadb/mariadb.pid
!includedir /etc/my.cnf.d
[root@workstation0 ~]# mkdir /var/lib/mysql-log
[root@workstation0 ~]# chown mysql. /var/lib/mysql-log
[root@workstation0 ~]# setenforce 0
```


## SERVICE

```shell
# 启动相应的服务，并设置为开机启动
[root@workstation0 ~]# systemctl stop firewalld
[root@workstation0 ~]# systemctl start mariadb
[root@workstation0 ~]# systemctl start httpd
[root@workstation0 ~]# systemctl enable mariadb
Created symlink from /etc/systemd/system/multi-user.target.wants/mariadb.service to /usr/lib/systemd/system/mariadb.service.
[root@workstation0 ~]# systemctl enable httpd
Created symlink from /etc/systemd/system/multi-user.target.wants/httpd.service to /usr/lib/systemd/system/httpd.service.
[root@workstation0 ~]# systemctl disable firewalld
Removed symlink /etc/systemd/system/dbus-org.fedoraproject.FirewallD1.service.
Removed symlink /etc/systemd/system/basic.target.wants/firewalld.service.
```

## PRIVILEGES

```shell
# 数据库设置root密码
[root@workstation0 ~]# mysqladmin -uroot password '(Uploo00king)'
# 对前端app进行授权
[root@workstation0 ~]# mysql -uroot -p'(Uploo00king)'
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 3
Server version: 5.5.44-MariaDB-log MariaDB Server

Copyright (c) 2000, 2015, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> create database php;
Query OK, 1 row affected (0.00 sec)

MariaDB [(none)]> grant all on php.* to php@172.25.0.10 identified by 'uplooking';
Query OK, 0 rows affected (0.00 sec)

MariaDB [(none)]> flush privileges;
Query OK, 0 rows affected (0.00 sec)

MariaDB [(none)]> \q
Bye
```

## PHP

> 通过浏览器访问172.25.0.10，让app连接mysql数据库


![1](pic/01.png)
![2](pic/02.png)
![3](pic/03.png)
![4](pic/04.png)
![5](pic/05.png)
![6](pic/06.png)
![7](pic/07.png)
