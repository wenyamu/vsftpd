#!/bin/bash

file_path="/etc/vsftpd/virtual_users.pwd" # 要监视的文件路径

function check()
{
  #读取用户密码文件奇数行并创建目录
  users=$(awk 'NR%2==1' $file_path) # 获取文件的奇数行内容
  for user in $users; do
    mkdir -p "/home/vsftpd/$user" # 根据每行内容创建对应的子目录(存在则跳过)
    if [ ! -f "/etc/vsftpd/usersconfig/$user" ]; then # 如果用户配置文件不存在
      cat > /etc/vsftpd/usersconfig/$user << EOF
# 此配置文件针对虚拟用户的个性配置，修改后用户重新登陆即可生效，不需要重启vsftpd服务
# 指定虚拟用户的虚拟目录（虚拟用户登录后的主目录,即登录ftp后访问的根目录）
local_root=/home/vsftpd/$user
# 允许写入
write_enable=YES
# 允许浏览FTP目录和下载
anon_world_readable_only=NO
# 禁止用户下载
#download_enable=NO
# 允许虚拟用户上传文件
anon_upload_enable=YES
# 允许虚拟用户创建目录
anon_mkdir_write_enable=YES
# 允许虚拟用户执行其他操作（如改名、删除）
anon_other_write_enable=YES
# 上传文件的掩码,如022时，上传目录权限为755,文件权限为644
anon_umask=022

# 限制最高传输速度，单位为Bytes/s。如果为0表示不限制
anon_max_rate=204800
EOF
    fi
  done

  chown -R www-data:www-data /home/vsftpd/

  /usr/bin/db_load -T -t hash -f /etc/vsftpd/virtual_users.pwd /etc/vsftpd/virtual_users.db

  #降低virtual_users.db数据库文件的权限并删除原始明文文件virtual_users.pwd
  chmod 600 /etc/vsftpd/virtual_users.db
  #rm -f /etc/vsftpd/virtual_users.pwd
}

#创建容器首次运行执行一次
check

#监控文件被修改，执行程序
inotifywait -mrq -e modify "$file_path" | while read EVENT FILE; do
  check
done
