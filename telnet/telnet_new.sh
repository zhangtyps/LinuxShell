#!/bin/bash
:<<INFO
@File : telnet.sh
@Time : 2021/03/23 10:21:01
@Author : 
@GitHub : https://github.com/zhangtyps
@Version : 1.6
@Desc : Linux批量telnet脚本，基本适用于所有云主机和容器环境。新版采用了mktemp生成临时文件，脚本运行结束后会自动清理临时文件。
INFO


TELNET_TMP_DIR=$(mktemp -d -t telnet_XXXXXX)
TELNET_LIST_TODO=$(mktemp -p $TELNET_TMP_DIR telnet_list_XXXXXX.txt)
TELNET_LIST_DONE=$(mktemp -p $TELNET_TMP_DIR telnet_list_done_XXXXXX.txt)
TELNET_FAIL=$(mktemp -p $TELNET_TMP_DIR fail_XXXXXX.log)
TELNET_SUCCESS=$(mktemp -p $TELNET_TMP_DIR success_XXXXXX.log)
TELNET_LOG=$(mktemp -p $TELNET_TMP_DIR main_XXXXXX.log)
TELNET_TEMP_LOG=$(mktemp -p $TELNET_TMP_DIR telnet_temp_XXXXXX.log)
TIME_OUT=5


#待检测的ip/url（IP丢到这里面，支持1个IP对应多个端口或端口端，多个端口用英文逗号隔开）
cat > $TELNET_LIST_TODO <<EOF
#请在此填入需要telnet的IP，此脚本支持如下IP格式
#192.168.1.1:80
#192.168.1.1:80,443
#192.168.1.1:1667-1669
#192.168.1.1:21,22,80-100
EOF



function deal_ip {
  ROW_NUM=0
  for line in $(cat $TELNET_LIST_TODO | grep -v ^\#)
  do
    let ROW_NUM++
    if ! $(echo $line | grep -q ":");then
      echo "[ERROR] 行$ROW_NUM: 端口号缺失，或未使用'：'分割IP和端口号，请复核IP列表！"
      exit 1
    fi
    CHECK_PORT_EXISTS=$(echo $line | cut -d : -f2)
    if [[ -z $CHECK_PORT_EXISTS ]];then
      echo "[ERROR] 行$ROW_NUM: 端口缺失，请复核IP列表！"
      exit 1
    fi
    CHECK_PORTS=$(echo $line | cut -d : -f2 | grep - || echo $line | cut -d : -f2 | grep ,)
    if [[ -n $CHECK_PORTS ]];then
      GET_IP=$(echo $line | cut -d : -f1)
      GET_PORTS_LIST=$(echo $line | cut -d : -f2)
      array=(${GET_PORTS_LIST//,/ })
      for var1 in "${array[@]}"
      do
        if [ $(echo $var1 | grep '-') ];then
          START_PORT=${var1%%-*}
          END_PORT=${var1##*-}
          if [ $START_PORT -gt $END_PORT ];then
            echo "[ERROR] 行$ROW_NUM: 起始端口$START_PORT > 结束端口$END_PORT，端口填写错误，程序退出！"
            exit 1
          fi
          array2=($(seq $START_PORT $END_PORT))
          for var2 in "${array2[@]}"
          do
            echo $GET_IP:$var2 >> $TELNET_LIST_DONE
          done
        else
          echo $GET_IP:$var1 >> $TELNET_LIST_DONE
        fi
      done
    else
      echo $line >> $TELNET_LIST_DONE
    fi
  done
}



function telnet_pg {
  NUM=0
  for line in $(cat $TELNET_LIST_DONE | grep -v ^\#)
  do
    let NUM=NUM+1
    IP=$(echo $line | awk -F ':' '{print$1}')
    PORT=$(echo $line | awk -F ':' '{print$2}')
    echo -n $NUM. telnet $IP $PORT
    timeout $TIME_OUT telnet $IP $PORT &> $TELNET_TEMP_LOG
    if [[ ! -f $TELNET_TEMP_LOG ]];then
      exit 1
    fi
    if [ $? -eq 124 ];then
      echo Trying $IP... >> $TELNET_TEMP_LOG
    fi
    echo -n $NUM. >> $TELNET_LOG
    cat $TELNET_TEMP_LOG >> $TELNET_LOG 
    SUCCESS_CLIENT=$(cat $TELNET_TEMP_LOG | grep -B 1 ']' | grep 'Connected to' | awk -F 'to ' '{print$2}' | cut -d. -f 1,2,3,4)
    if [ -n "$SUCCESS_CLIENT" ]; then
      echo "$SUCCESS_CLIENT:$PORT" >> $TELNET_SUCCESS
      echo -e " >> \033[32mOK\033[0m"
    else
      REASON=$(cat $TELNET_TEMP_LOG | grep -i 'connect to' | cut -d: -f 3)
      if [ -z "$REASON" ];then
        REASON="Timeout!"
      fi
      echo "$IP:$PORT" >> $TELNET_FAIL
      echo -e " >> \033[31mFAIL!\033[0m $REASON"
    fi
  done &
  wait
}


trap 'rm -rf "$TELNET_TMP_DIR"' EXIT


deal_ip
telnet_pg