#所有脚本均为张天宇本人自行编写

~/curl_Alarm
配合代理curl模式做的告警
怎么关闭：定时任务里关闭即可，同时把定时写入/opt/proxyall.log的日志也停止写入（日志不是我能控制写入的）

~/send_shell
代理机分发shell脚本的工具，分发主程序在send_shell/scp_ssh文件夹下
其中download文件夹内为所有分发的脚本，定时任务请使用我写的crontab.sh和url_crontab.sh来一键配置
host文件夹为所有需要分发主机的IP，如果今后代理机更换了，请修改分发的IP+端口
