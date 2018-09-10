#!/usr/bin/env bash

#本次使用docker搭建zabbix的组合是mysql+docker+zabix-server
#先安装数据库mysql

docker run --name zabbix-mysql-server --hostname zabbix-mysql-server \
-e MYSQL_ROOT_PASSWORD="123456" \
-e MYSQL_USER="zabbix" \
-e MYSQL_PASSWORD="123456" \
-e MYSQL_DATABASE="zabbix" \
-p 3306:3306  \
-d mysql:5.7 \
--character-set-server=utf8 --collation-server=utf8_bin

#创建zabbix-server

docker run  --name zabbix-server-mysql --hostname zabbix-server-mysql \
--link zabbix-mysql-server:mysql \
-e DB_SERVER_HOST="mysql" \
-e MYSQL_USER="zabbix" \
-e MYSQL_DATABASE="zabbix" \
-e MYSQL_PASSWORD="123456" \
-v /etc/localtime:/etc/localtime:ro \
-v /data/docker/zabbix/alertscripts:/usr/lib/zabbix/alertscripts \
-v /data/docker/zabbix/externalscripts:/usr/lib/zabbix/externalscripts \
-p 10051:10051 \
-d \
zabbix/zabbix-server-mysql

#最后安装zabbix-web-nginx

docker run --name zabbix-web-nginx-mysql --hostname zabbix-web-nginx-mysql \
--link zabbix-mysql-server:mysql \
--link zabbix-server-mysql:zabbix-server \
-e DB_SERVER_HOST="mysql" \
-e MYSQL_USER="zabbix" \
-e MYSQL_PASSWORD="123456" \
-e MYSQL_DATABASE="zabbix" \
-e ZBX_SERVER_HOST="zabbix-server" \
-e PHP_TZ="Asia/Shanghai" \
-p 8000:80 \
-p 8443:443 \
-d \
zabbix/zabbix-web-nginx-mysql

#登录访问测试,浏览器访问ip:8000查看
#默认登录
#username:Admin
#password:zabbix
#监控本机时，需要将“127.0.0.1”改为本机IP；监控agent时，添加（add）主机(ZBX_HOSTNAME)监控模板后，可以开始监控agent了。

#创建Zabbix Java gateway实例
docker run --name zabbix-java-gateway -t -d zabbix/zabbix-java-gateway:latest


#zabbbix-agent的安装以及链接zabbix-server
#server-local-agent
docker run --restart=always --name zabbix-agent -p 10050:10050 -e ZBX_HOSTNAME="zabbix-server" -e ZBX_SERVER_HOST="server-ip"  -d zabbix/zabbix-agent
#server-agent-aws
docker run --restart=always --name zabbix-agent -p 10050:10050 -e ZBX_HOSTNAME="zabbix-aws" -e ZBX_SERVER_HOST="server-ip" -e ZBX_SERVER_PORT=10051 -d zabbix/zabbix-agent
#server-agent-xinjie
docker run --restart=always --name zabbix-agent -p 10050:10050 -e ZBX_HOSTNAME="zabbix-xinjie" -e ZBX_SERVER_HOST="server-ip" -e ZBX_SERVER_PORT=10051 -d zabbix/zabbix-agent

#测试服务器75主机
#server-agent-server
docker run --restart=always --name zabbix-agent -p 10050:10050 -e ZBX_HOSTNAME="zabbix-server" -e ZBX_SERVER_HOST="server-ip" -e ZBX_SERVER_PORT=10051 -d zabbix/zabbix-agent
#server-agent-80
docker run --restart=always --name zabbix-agent -p 10050:10050 -e ZBX_HOSTNAME="zabbix-80" -e ZBX_SERVER_HOST="server-ip" -e ZBX_SERVER_PORT=10051 -d zabbix/zabbix-agent
