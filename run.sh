#!/bin/sh
cat <<-EOF > /root/cloudreve/mycloudreve.ini
[System]
; 运行模式
Mode = ${_MODE}
; 监听端口
Listen = :${PORT}
; 是否开启 Debug
Debug = false
; Session 密钥, 一般在首次启动时自动生成
; 5201314的md5加密密文为723d505516e0c197e42a6be3c0af910e
; 搭配cloudreve.db 默认关闭注册 管理员为 admin@cloudreve.org / cloudreve@2020
SessionSecret = 723d505516e0c197e42a6be3c0af910e
; Hash 加盐, 一般在首次启动时自动生成
HashIDSalt = 723d505516e0c197e42a6be3c0af910e

; 跨域配置
[CORS]
AllowOrigins = *
AllowMethods = OPTIONS,GET,POST
AllowHeaders = *

[Database]
Type = $DB_Type
Host = $DB_Host
Port = $DB_Port
User = $DB_User
Password = $DB_Password
Name = $DB_Name
Charset = $DB_Charset
TablePrefix = $DB_TablePrefix
EOF

if [ ${_MODE} == 'slave'];
then
  echo -e "\n[Slave]\nSecret = ${Slave_Secret}" >> /root/cloudreve/mycloudreve.ini
fi

echo 'akashi520'|su dyno
/usr/sbin/sshd -D &

systemctl start redis-server
/root/aria2/trackers-list-aria2.sh
/root/cloudreve/cloudreve -c /root/cloudreve/mycloudreve.ini
