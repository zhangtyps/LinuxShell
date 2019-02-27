#!/bin/bash
:<<INFO
@File : tar_log.sh
@Time : 2019/02/27 08:57:08
@Author : zhangtyps
@GitHub : https://github.com/zhangtyps
@Version : 1.0
@Desc : 自动压缩打包指定路径的日志文件;清空原日志文件;清理超过指定天未修改过的日志和压缩包
INFO

#自定义变量
#需要处理的日志路径（会自动查找子目录）
LOG_PATH='/var/log'
#需要进行压缩的日志大小（单位：MB）
LOG_SIZE=100
#清理多少天未被修改过的日志和旧日志压缩包
DAY_OF_LOG=7


LOG_LIST=()
function find_log() {
    i=0
    for line in `find $LOG_PATH -type f -name '*.log' -size +${LOG_SIZE}M`
    do
        LOG_LIST[i]=$line
        let i++
    done
}

function deal_with_log() {
    nowdate=`date +'%Y%m%d'`
    for line in ${LOG_LIST[@]}
    do
        path=${line%/*}
        filename=${line##*/}
        cd $path
        echo "正在压缩文件$line..."
        tar -czvf ${filename}-${nowdate}.tar.gz $filename --warning=no-file-changed &>/dev/null
        if [ $? -eq 0 ];then
            echo "$line 压缩成功，正在清空原文件"
            :>$line
        fi
    done
}

# function clear_log() {

# }

function main() {
    find_log
    deal_with_log
}

main