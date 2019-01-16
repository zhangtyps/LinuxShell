# Linux Shell
一些工作自己写的shell脚本，放在这里记录一下


#### 一个比较局限的自动清空日志小脚本（非删除日志），目前功能有限，后续改进
```console
./auto_delete_log.sh
```

#### scp-autoDownOrSend/ 解决大量Linux机器相互传文件的问题
```console
# 服务器远程分发文件脚本，适用于大量账户密码相同客户机分发文件
./sshpass_send.sh
# 客户机定时scp自动拉去服务器上的文件，适用于上面脚本搞不定的情况 (通过expect语法处理交互的问题，其实这个本质上已经不算是shell脚本了……)
./scp_down.sh
```

#### loop-mission/ 解决循环执行任务的问题
```console
# 一个简单的以10秒为单位，循环执行任务的小脚本（linux不支持1分钟以下的定时任务）
./10s_loop_mission.sh

可以自定义秒级时间的死循环脚本
# 循环主体脚本，无需放在定时任务内
./curl-loop_body.sh
# 守护脚本，放在定时任务内使用（会自动拉起主体脚本，定时检测主体脚本状态）
./curl-loop_guard.sh
```

#### curl_alarm/ 代理机curl请求检测-未请求的代理机做告警-发送邮件到告警联系人（这个代码可能不好直接使用）
```console
# 对nginx请求日志做分析，拿到代理机的请求hostname，同时调用后续脚本（此脚本为入口脚本，放在定时任务里执行）
./log_sorting.sh
# 分析本地shell_temp/目录下预定义好的hostname和请求的hostname之间的区别，找到未定时请求的主机
./xx_checkhost.sh（cb_checkhost.sh和yg_checkhost.sh本质是一样的，用来检测不同提供商平台的代理机）
# 发送邮件脚本，此脚本使用Linux系统自带的mail命令发送邮件（如何设置Linux发件人邮箱，方法在脚本的注释内容里）
./mail.sh
```

#### Linux自动安装VNC远程桌面（阿里云上直接拖来的脚本）
```console
./install_vnc_server.sh
```

#### 检测lnmp环境下php yii任务状态，自动重启挂了的任务
```console
./yiic_guard.sh
```

#### VPS一键设定定时任务脚本（带参数模式，可以根据参数不同设定不同的定时任务，也可以自定义某些任务的时间）
```console
./crontab.sh
```

#### curl检测指定链接返回值，若返回值非200，则自动重新拨号

```console
./checkweibo.sh
```

#### 统计squid.log，计算代理请求次数和代理成功率
```console
./count-squid.sh
```

#### 老版本的zabbix2.4.7客户端自动部署安装脚本，因原脚本有问题，此为本人修改过的脚本
```console
./zabbix_autosetup_2.4.7.sh
```
