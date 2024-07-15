
>vsftpd 多用户 docker 配置

## 创建镜像
```sh
#vsftpd:centos7 表示镜像名:标签名
#最后的.号表示Dockerfile文件在当前目录中
cd vsftpd-centos \
docker build -t vsftpd:centos7 .
```

## 部署 docker 容器
```sh
docker run -d \
-v /my/data/directory:/home/vsftpd \
-v /my/data/usersconfig:/etc/vsftpd/usersconfig \
-v /my/data/vsftpd.conf:/etc/vsftpd/vsftpd.conf \
-v /my/data/virtual_users.pwd:/etc/vsftpd/virtual_users.pwd \
-p 20:20 \
-p 21:21 \
-p 21100-21110:21100-21110 \
--name vsftpd \
--restart=always \
vsftpd:centos7
```

## 使用方法（以下步骤1和2已经由 inotify 监控自动执行，这里仅做原理说明）
### 1、进入容器、添加用户和密码
```sh
docker exec -it vsftpd bash \
echo -e "ljs\nljsljs" >> /etc/vsftpd/virtual_users.pwd
```
### 2、创建目录、添加新用户的配置文件等操作（完成步骤1的新增用户后，此步骤也可直接重启容器实现）
```sh
#创建用户ftp目录
mkdir -p /home/vsftpd/ljs
#创建用户配置文件
cat > /etc/vsftpd/usersconfig/ljs << EOF
#此配置文件针对虚拟用户的个性配置，修改后用户重新登陆即可生效，不需要重启vsftpd服务
...
...
EOF
#设置ftp目录权限，每次新建用户目录时，都要执行一次
chown -R www-data:www-data /home/vsftpd/
#重新生成数据库文件
/usr/bin/db_load -T -t hash -f /etc/vsftpd/virtual_users.pwd /etc/vsftpd/virtual_users.db
```
## Supervisor
>使用 supervisor 管理 vsftpd 和 inotify 进程 \
```sh
#inotify监控/etc/vsftpd/virtual_users.pwd 文件被修改，执行"使用方法"的步骤2的4条命令，即可登陆ftp
inotifywait -mrq -e modify /etc/vsftpd/virtual_users.pwd | while read EVENT FILE; do
  ...
done
```
