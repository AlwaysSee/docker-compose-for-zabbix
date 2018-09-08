# 运维-服务器监控

本项目的目的是用于docker编排方式快速安装部署zabbix,实现对服务器的监控。

<b>实现思路：</b>

1、通过`docker-compose`创建所需的`zabbix-mysql` 、`zabbix-server`、`zabbix-web`、`zabbix-agent`容器。

2、通过`zabbix-server`向`zabbix-agent`收集监控信息。

3、`docker.sh`记录了普通创建容器的方式进行部署`zabbix`。


## 一、环境准备（首次执行）

以下操作只需要第一次在服务器上执行一次，若服务器上已经安装了“Docker Compose”则可以跳过本步骤。


### 1.1、运行以下命令下载最新版本的Docker Compose:

如果不能下载成功，则将`https`改为`http`

```
sudo curl -L https://github.com/docker/compose/releases/download/1.19.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
```

### 1.2、给Docker Compose应用可执行权限:

```
sudo chmod +x /usr/local/bin/docker-compose
```
## 二、执行部署

1、修改`docker-compose`中`web`服务`ZBX_SERVER_HOST`为`zabbix-server`的IP。

2、在刚才创建的`docker-compose.yml`目录下，执行`docker-compose up -d`，这样就会先后启动`mysql`和`zabbix-server`两个服务的容器。

```
docker-compose up -d
```
查看安装进度

```
docker logs -f zabbix-server
```

## 三、页面配置

1、使用`IP:8000`登录`web`页面,帐号`Admin`密码`zabbix`登录。

2、添加主机时，必须使用`agent`的`hostname`,添加监控项或监控模板后，才开始对`agent`进行监控。

3、在被监控服务器上执行以下命令，修改其中的IP为`zabbix-server`的IP，`ZBX_HOSTNAME`指本机命名。

````
docker run --name zabbix-agent -p 10050:10050 -e ZBX_HOSTNAME="zabbix-luzhou" -e ZBX_SERVER_HOST="47.98.108.18" -e ZBX_SERVER_PORT=10051 -d zabbix/zabbix-agent
````