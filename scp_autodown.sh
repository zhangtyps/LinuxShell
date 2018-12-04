#!/usr/bin/expect
#自动通过scp命令下载远程主机上的文件，无需交互式输入密码，一切自动完成
#需先安装expect，直接yum install expect -y

#要使用参数模式，可以用下面注释内容的写法，注意某些密码含特殊字符，参数使用时要加入引号
#set port [lrange $argv 0 0]
#set host [lrange $argv 1 1]
set port "scp主机ssh端口号"
set host "scp主机的IP地址"
set user "登陆用户名"
set passwd "登陆密码"
#下载的文件路径比如/home/wangyang/download/*
#本地保存的路径，比如当前脚本运行的路径./
set remotepath "scp下载的文件路径"
set localpath "本地保存的路径"
set timeout -1

spawn scp -P $port $user@$host:$remotepath $localpath
expect {
"yes/no" { send "yes\r";exp_continue }
"password:" { send "$passwd\r" }
}
send "$passwd\r"
interact
