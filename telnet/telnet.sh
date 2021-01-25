#!/bin/bash
:<<INFO
@File : telnet.sh
@Time : 2021/01/25 21:21:01
@Author : zhangtyps
@GitHub : https://github.com/zhangtyps
@Version : 1.0
@Desc : linux批量telnet脚本。请在脚本下建立一个result名字的目录，以便脚本正常运行
INFO

NUM=0
SCRIPT_PATH=`pwd`
#BASEDIR=`cd $BASEDIR;pwd`
RESULT_PATH=$SCRIPT_PATH/result
#以下文件依次为：需要检测的IP/URL+端口，请放在脚本相同目录下；检测失败的IP记录；检测成功的IP记录；telnet检测的全日志记录
TELNET_LIST=telnet_list.txt   #支持域名+端口/IP+端口
TELNET_FAIL=$SCRIPT_PATH/result/fail.log
TELNET_SUCCESS=$SCRIPT_PATH/result/success.log
TELNET_LOG=$SCRIPT_PATH/result/main.log


#清空文件
true > $TELNET_FAIL
true > $TELNET_SUCCESS
true > $TELNET_LOG

for line in `cat $TELNET_LIST | grep -v ^#`
do
    let NUM=NUM+1
    TELNET_TEMP_LOG=$SCRIPT_PATH/result/telnet_temp.log
    IP=`echo $line | awk -F ':' '{print$1}'`
    PORT=`echo $line | awk -F ':' '{print$2}'`
    #sleep 1
    echo -n "$NUM. telnet $IP $PORT"
    telnet $IP $PORT &> $TELNET_TEMP_LOG
    cat $TELNET_TEMP_LOG >> $TELNET_LOG | echo $NUM. >> $TELNET_LOG
    SUCCESS_CLIENT=`cat $TELNET_TEMP_LOG | grep -B 1 ']' | grep 'Connected to' | awk -F 'to ' '{print$2}' | cut -d. -f 1,2,3,4`
    if [ -n "$SUCCESS_CLIENT" ]; then
        echo "$SUCCESS_CLIENT:$PORT" >> $TELNET_SUCCESS
        echo -e " >> \033[32mOK\033[0m"
        else
        echo "$IP:$PORT" >> $TELNET_FAIL
        echo -e " >> \033[31mFAIL!\033[0m"
    fi
done &
wait

#输出结果应该如下显示
:<<EOF
[wls81@DockerHost telnet2]$ ./telnet.sh 
1. telnet www.a.com 80 >> OK
2. telnet 10.1.1.1 3389 >> OK
3. telnet b.com 80 >> OK
4. telnet c.com 80 >> FAIL!
EOF